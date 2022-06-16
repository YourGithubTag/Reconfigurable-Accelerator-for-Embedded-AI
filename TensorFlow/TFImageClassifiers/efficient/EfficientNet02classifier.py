import os

import numpy as np

import tensorflow as tf
assert tf.__version__.startswith('2')

from tflite_model_maker import model_spec
from tflite_model_maker import image_classifier
from tflite_model_maker.config import ExportFormat
from tflite_model_maker.config import QuantizationConfig
from tflite_model_maker.image_classifier import DataLoader

import matplotlib.pyplot as plt

#TODO: Quantization Config to 8 bit fixed point
config = QuantizationConfig.for_dynamic()

print("Loading DataSet")

image_path = tf.keras.utils.get_file(
      'flower_photos.tgz',
      'https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz',
      extract=True)
image_path = os.path.join(os.path.dirname(image_path), 'flower_photos')

data = DataLoader.from_folder(image_path)

train_data, rest_data = data.split(0.8)
validation_data, test_data = rest_data.split(0.5)

print(" \n Loading EfficientNet-Lite4 \n")

efficientnetlite4_spec = image_classifier.ModelSpec(uri='https://tfhub.dev/tensorflow/efficientnet/lite4/classification/2')


model = image_classifier.create(train_data, model_spec=efficientnetlite4_spec, validation_data=validation_data, epochs = 50)

print(" \n \n SUMMARY:  \n \n")
model.summary()

print(" \n \n Results:  \n \n")
loss, accuracy = model.evaluate(test_data)

print("  Loss: \n ")
print(loss)

print(" \n  accuracy: \n ")
print(accuracy)

model.export(export_dir='./TFLiteEfficient04/',  tflite_filename='efficientnet04.tflite')
model.export(export_dir='./TFLiteEfficient04/',  tflite_filename='efficient_net04_Quant.tflite', quantization_config=config)


print(" \n \n TF-LITE Conversion accuracy:  \n \n")
Liteaccuracy = model.evaluate_tflite('./TFLiteEfficient04/efficientnet04.tflite', validation_data)
print(" \n  accuracy: \n ")
print(Liteaccuracy)

print(" \n \n TF-LITE quantization accuracy:  \n \n")
quantizationaccuracy = model.evaluate_tflite('./TFLiteEfficient04/efficient_net04_Quant.tflite', validation_data)
print(" \n  accuracy: \n ")
print(quantizationaccuracy)
