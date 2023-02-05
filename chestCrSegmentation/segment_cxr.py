#!/usr/bin/env python
# coding: utf-8
import sys
import torch
from networks.xlsor import XLSor
import torch.nn as nn
import functools
from inplace_abn import InPlaceABNSync
from torch.utils import data
from dataset.datasets import XRAYDataTestSet
import numpy as np
import os
from PIL import Image as PILImage
import argparse
import SimpleITK as sitk
import re
import shutil

parser = argparse.ArgumentParser(prog="Segmentation",description="Seg CXR Images")
parser.add_argument("--dataDir",required=True,type=str)
#parser.add_argument("--dataFormat",required=True,type=str)
parser.add_argument('--resultDir',type=str,required=True)
#args = parser.parse_args(['--dataDir','./data',
#                          '--dataFormat','png',
#                          '--resultDir','./results'])

outputFold=args.resultDir
if not os.path.exists(outputFold):
  os.makedirs(outputFold)
  
dataSet = os.path.basename(args.dataDir)
pretrainDir = "./models/XLSor.pth"
IMG_MEAN = np.array((120,120,120), dtype=np.float32)

## create temp folder to convert to pngs with parameters remembered (3 dimensional)
caster = sitk.CastImageFilter()
caster.SetOutputPixelType(sitk.sitkUInt8)
if not os.path.exists("temp"):
    os.mkdir("temp")
else:
    shutil. rmtree("temp")
    os.mkdir("temp")
record = {}
for ifile in os.listdir(args.dataDir):
    if ifile.endswith((".nii", ".nii.gz")):
        irecord = {}
        img = sitk.ReadImage(os.path.join(args.dataDir,ifile))
        img_rescaled = caster.Execute(sitk.RescaleIntensity(img))
        png_filename = re.sub(r"nii\.gz","png",ifile)
        sitk.WriteImage(img_rescaled,os.path.join("temp",png_filename))
        irecord['spacing'] = img.GetSpacing()
        irecord['origin'] = img.GetOrigin()
        irecord['size'] = img.GetSize()
        irecord['direction'] = img.GetDirection()
        img_basename = re.sub(r"\.nii\.gz","",ifile)
        record[img_basename] = irecord
        sitk.WriteImage(img_rescaled,os.path.join("temp",png_filename))

testloader = data.DataLoader(XRAYDataTestSet("./temp", 
                                             "png", 
                                             crop_size=(512, 512), 
                                             mean=IMG_MEAN, 
                                             scale=False,mirror=False), 
                                             batch_size=1, 
                                             shuffle=False, 
                                             pin_memory=True)

NUM_CLASSES = 1 ## final num of channels
BatchNorm2d = functools.partial(InPlaceABNSync, activation='identity')
model = XLSor(num_classes=NUM_CLASSES)
saved_state_dict = torch.load(pretrainDir)
model.load_state_dict(saved_state_dict)
model.eval()
model.cuda()

# predict
# ===================================
for index, batch in enumerate(testloader):
  image, size,org_size, name = batch
  
  with torch.no_grad():
    prediction = model(image.cuda(), 2)
    #prediction = model(image, 2)
    if isinstance(prediction, list):
      prediction = prediction[0]
    img_width,img_height,img_channels=org_size[0]
    interp = nn.Upsample(size=(img_width, img_height), mode='bilinear',align_corners=True) # smooth boundary for bilinear interpolation
    prediction = interp(prediction).cpu().data[0].numpy().transpose(1, 2, 0)
    output_im = PILImage.fromarray((np.clip(prediction[:,:,0],0,1)* 255).astype(np.uint8))
    #output_im.save(os.path.join(outputFold , os.path.basename(name[0]).replace('.png','_xlsor.png')))
    output_im.save(os.path.join(outputFold , os.path.basename(name[0])))

  print( name[0] + " processed")



# loop through result fold
for ifile in os.listdir(outputFold):
    if ifile.endswith(".png"):
        ifile_basename = re.sub(r"\.png","",ifile)
        if ifile_basename in record.keys():
            img = sitk.ReadImage(os.path.join(outputFold,ifile))
            img.SetSpacing(record[ifile_basename]["spacing"])
            img.SetOrigin(record[ifile_basename]["origin"])
            #img.SetDirection(record[ifile_basename]["direction"])
            sitk.WriteImage(img,os.path.join(outputFold,ifile_basename+".nii.gz"))


