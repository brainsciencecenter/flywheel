#!/usr/bin/env python3

import os, shutil,  random
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

import argparse

import tensorflow as tf
from tensorflow.keras.layers import Layer, Input, Lambda, Dense, Flatten, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model, load_model
from tensorflow.keras.applications import VGG19
from tensorflow.keras.applications.vgg19 import preprocess_input
from tensorflow.keras.preprocessing import image
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import accuracy_score
import numpy as np
import pandas as pd
import keras_preprocessing
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from keras_preprocessing.image.dataframe_iterator import DataFrameIterator
from tensorflow.keras import backend as K
import cv2
import SimpleITK as sitk
from sklearn.metrics import accuracy_score
from classifier_functions import *


## IN and OUT directories, set before running validation
IN = '/mnt/in'
OUT = '/mnt/out'

ap = argparse.ArgumentParser()

ap.add_argument('-i', '--indir', default=False,  action='store', help='input directory')
ap.add_argument('-o', '--outdir', default=False,  action='store', help='output directory')

args = ap.parse_args()

if (args.indir):
    IN = args.indir

if (args.outdir):
    OUT = args.outdir

#IN = 'D:/Dropbox/UPENN/projects/MIDRC/sub-projects/challenge0/submission/IN'
#OUT = 'D:/Dropbox/UPENN/projects/MIDRC/sub-projects/challenge0/submission/OUT'

# load model in the submission folder
model= tf.keras.models.load_model("model.h5",custom_objects={'Gray2VGGInput': Gray2VGGInput})

## create data frames for validation dataset
images = [os.path.join(IN,file) for file in os.listdir(IN) if file.find('.dcm') != -1]
images_base = [file for file in os.listdir(IN) if file.find('.dcm') != -1]
validation_df = pd.DataFrame({'fileNamePath':images,'class':[random.choice([0,1]) for i in images]})
validation_df[['class']] = validation_df[['class']].astype("string")

## obtain images with preprocessings
n_images = len(images)
validation_generator = DCMDataFrameIterator(dataframe=validation_df,
                                       x_col='fileNamePath',
                                       y_col='class',
                                       shuffle=False,
                                       class_mode='binary',
                                       color_mode='grayscale',
                                       target_size=(500,500),
                                       batch_size=n_images
                                  )
image_batch,rand_label=next(validation_generator)


## predict the labels, output value in [0,1] and 0 for laterl and 1 for frontal.
lab_pred = model.predict(image_batch)
validation_df['class'] = lab_pred.reshape(-1)
validation_df['fileNamePath'] = images_base
## write predicted labels 
validation_df.to_csv(os.path.join(OUT,"classification_results.csv"), index=False)

# Copy model to output (more useful for training phase)
src="model.h5"
dest=OUT
shutil.copyfile(src, os.path.join(dest,src))
