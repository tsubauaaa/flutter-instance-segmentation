import tensorflow as tf

converter = tf.lite.TFLiteConverter.from_keras_model_file("./mask_rcnn_book_0001.h5")
tfmodel = converter.convert()
open("model_instance_seg.tflite", "wb").write(tfmodel)
