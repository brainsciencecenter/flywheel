## Define generator pipeline related functions and classes
# Using the training phase generators 
# refer to https://stackoverflow.com/questions/62836692/imagedatagenerator-rescaling-to-1-1-instead-of-0-1
# https://www.tensorflow.org/api_docs/python/tf/keras/preprocessing/image/ImageDataGenerator

## for VGG, the image needs to be rescaled to [0,255], refer to 
## https://www.tensorflow.org/api_docs/python/tf/keras/applications/vgg19/preprocess_input
from __future__ import print_function, division
import keras_preprocessing
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from keras_preprocessing.image.dataframe_iterator import DataFrameIterator
from tensorflow.keras import backend as K
import cv2
import SimpleITK as sitk
import tensorflow as tf
from tensorflow.keras.layers import Layer, Input, Lambda, Dense, Flatten, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model, load_model
from tensorflow.keras.applications import VGG19
from tensorflow.keras.applications.vgg19 import preprocess_input
import numpy as np


class DCMDataFrameIterator(DataFrameIterator):
    def __init__(self, *arg, **kwargs):
        self.white_list_formats = ('dcm','nii.gz')
        super(DCMDataFrameIterator, self).__init__(*arg, **kwargs)
        self.dataframe = kwargs['dataframe']
        self.x = self.dataframe[kwargs['x_col']]
        self.y = self.dataframe[kwargs['y_col']]
        self.color_mode = kwargs['color_mode']
        self.target_size = kwargs['target_size']

    def _get_batches_of_transformed_samples(self, indices_array):
        # get batch of images
        batch_x = np.array([self.read_dcm_as_array(dcm_path, self.target_size, color_mode=self.color_mode)
                            for dcm_path in self.x.iloc[indices_array]])

        batch_y = np.array(self.y.iloc[indices_array].astype(np.uint8))  # astype because y was passed as str

        # transform images
        if self.image_data_generator is not None:
            for i, (x, y) in enumerate(zip(batch_x, batch_y)):
                transform_params = self.image_data_generator.get_random_transform(x.shape)
                batch_x[i] = self.image_data_generator.apply_transform(x, transform_params)
                # you can change y here as well, eg: in semantic segmentation you want to transform masks as well 
                # using the same image_data_generator transformations.
        
        for i, (x, y) in enumerate(zip(batch_x, batch_y)):
            batch_x[i] = self.rescale_fn(x)
        
        return batch_x, batch_y

    @staticmethod
    def read_dcm_as_array(dcm_path, target_size=(256, 256), color_mode='rgb'):
        #image_array = pydicom.dcmread(dcm_path).pixel_array
        image_array=sitk.GetArrayFromImage(sitk.ReadImage(dcm_path))
        image_array=np.squeeze(image_array)
        image_array = cv2.resize(image_array, target_size, interpolation=cv2.INTER_NEAREST)  #this returns a 2d array
        image_array = np.expand_dims(image_array, -1)
        if color_mode == 'rgb':
            image_array = cv2.cvtColor(image_array, cv2.COLOR_GRAY2RGB)
        return image_array
      
    @staticmethod  
    def rescale_fn(img):
        img = (img.astype(np.float32)-img.min()) / (img.max()-img.min()) * 255
        return img


## create input layer for pretrained VGG net
## refer to https://stackoverflow.com/questions/52065412/how-to-use-1-channel-images-as-inputs-to-a-vgg-model
## include the preprocessing for VGG
# refer to https://www.tensorflow.org/api_docs/python/tf/keras/applications/vgg19/preprocess_input
class Gray2VGGInput( Layer ) :
    """Custom conversion layer
    """
    def build( self, x ) :
        #self.image_mean = K.variable(value=np.array([103.939, 116.779, 123.68]).reshape([1,1,1,3]).astype('float32'), 
        #                             dtype='float32', 
        #                             name='imageNet_mean' )
        self.built = True
        return
    def call( self, x ) :
        rgb_x = K.concatenate( [x,x,x], axis=-1 )
        #norm_x = rgb_x - self.image_mean
        norm_x = preprocess_input(rgb_x)
        return norm_x
    def compute_output_shape( self, input_shape ) :
        return input_shape[:3] + (3,)
      

