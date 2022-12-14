import os
import sys
from lungmask import mask
import SimpleITK as sitk
import pickle as pk
import re
import argparse
parser = argparse.ArgumentParser(description='Segment COVID CTs')
parser.add_argument('--inImg',type=str,required=True)
parser.add_argument('--outSeg',type=str,required=True)
args = parser.parse_args()
#args = parser.parse_args(["--inImg","./test/IN/PA024026_A_S4_D19010102_LUNG.nii","--outSeg","./test/OUT/seg.nii.gz"])

model = pk.load(open("./model/unet_r231_v0_0.pkl","rb")) ## needs to be taken care of

## Reading Image
try:
  input_image = sitk.ReadImage(args.inImg)
  print("Image Size:")
  print(input_image.GetSize())
except Exception as e:
  print("Reading image {} failed!".format(args.inImg))
  print("Error: {}".format(e))
  sys.exit(-1)
  
  
# Segment Image
# get seg
try:
    segmentation = mask.apply(input_image,model)
except Exception as e:
    print("Segmentation for image {} failed!".format(args.inImg))
    print("Error: {}".format(e))
    sys.exit(-1)
 
seg_mask=sitk.GetImageFromArray(segmentation,isVector=False)
seg_mask.SetOrigin(input_image.GetOrigin())
seg_mask.SetDirection(input_image.GetDirection())
seg_mask.SetSpacing(input_image.GetSpacing())

  
  
  
# Write Image
# write seg
try:
  writer = sitk.ImageFileWriter()
  if not os.path.exists(os.path.dirname(args.outSeg)):
    os.mkdir(os.path.dirname(args.outSeg))
  writer.SetFileName(args.outSeg)
  writer.Execute(seg_mask)
except Exception as e:
  print("Writing seg for image {} failed!".format(args.inImg))
  print("Error: {}".foramt(e))
  sys.exit(-1)
