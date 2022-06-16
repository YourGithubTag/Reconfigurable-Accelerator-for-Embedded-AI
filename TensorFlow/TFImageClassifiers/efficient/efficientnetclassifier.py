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

train_data, rest_data = data.split(0.9)
validation_data, test_data = rest_data.split(0.5)

print(" \n Loading EfficientNet-Lite0 \n")
model = image_classifier.create(train_data, validation_data=validation_data, epochs = 50)

print(" \n \n SUMMARY:  \n \n")
model.summary()
print(" \n \n Results:  \n \n")
loss, accuracy = model.evaluate(test_data)

print("  Loss: \n ")
print(loss)

print(" \n  accuracy: \n ")
print(accuracy)

model.export(export_dir='.',  tflite_filename='efficient.tflite')
model.export(export_dir='.',  tflite_filename='efficient_quant.tflite', quantization_config=config)


print(" \n \n TF-LITE Conversion accuracy:  \n \n")
Liteaccuracy = model.evaluate_tflite('efficient.tflite', validation_data)
print(" \n  accuracy: \n ")
print(Liteaccuracy)


print(" \n \n TF-LITE quantization accuracy:  \n \n")
quantizationaccuracy = model.evaluate_tflite('efficient_quant.tflite', validation_data)
print(" \n  accuracy: \n ")
print(quantizationaccuracy)