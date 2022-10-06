import os
import sys
from lungmask import mask  ## the code needs to be copied
import SimpleITK as sitk
import pickle as pk
import re
import argparse

parser = argparse.ArgumentParser(description='Segment COVID CTs')
parser.add_argument('--inImg',type=str,required=True)
parser.add_argument('--outSeg',type=str,required=True)
args = parser.parse_args()


model = pk.load(open("./model/unet_r231_v0_0.pkl","rb")) ## needs to be taken care of

## Reading Image
try:
  input_image = sitk.ReadImage(args.inImg)
  print("Image Size:")
  print(input_image.GetSize())
except:
  print("Reading image {} failed!".format(args.inImg))
  sys.exit(-1)
  
  
# Segment Image
# get seg
try:
  segmentation = mask.apply(input_image,model)
  seg_mask=sitk.GetImageFromArray(segmentation,isVector=False)
  seg_mask.SetOrigin(input_image.GetOrigin())
  seg_mask.SetDirection(input_image.GetDirection())
  seg_mask.SetSpacing(input_image.GetSpacing())
except:
  print("Processing segmentation for image {} failed!".format(args.inImg))
  sys.exit(-1)
  
  
  
# Write Image
# write seg
try:
  writer = sitk.ImageFileWriter()
  if not os.path.exists(os.path.dirname(args.outSeg)):
    os.mkdir(os.path.dirname(args.outSeg))
  writer.SetFileName(args.outSeg)
  writer.Execute(seg_mask)
except:
  print("Writing seg for image {} failed!".format(args.inImg))
  sys.exit(-1)
