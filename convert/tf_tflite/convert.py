import keras.backend as keras
import numpy as np
import tensorflow as tf

import mrcnn.model as modellib  # https://github.com/matterport/Mask_RCNN/
from mrcnn.config import Config

PATH_TO_SAVE_FROZEN_PB = "./"
FROZEN_NAME = "saved_model.pb"


def load_model(Weights):
    global model, graph

    class InferenceConfig(Config):
        NAME = "coco"
        NUM_CLASSES = 1 + 80
        IMAGE_META_SIZE = 1 + 3 + 3 + 4 + 1 + NUM_CLASSES
        DETECTION_MAX_INSTANCES = 100
        DETECTION_MIN_CONFIDENCE = 0.7
        DETECTION_NMS_THRESHOLD = 0.3
        GPU_COUNT = 1
        IMAGES_PER_GPU = 1

    config = InferenceConfig()
    Weights = Weights
    Logs = "./logs"
    model = modellib.MaskRCNN(mode="inference", config=config, model_dir=Logs)
    model.load_weights(Weights, by_name=True)
    graph = tf.get_default_graph()


# Reference https://github.com/bendangnuksung/mrcnn_serving_ready/blob/master/main.py
def freeze_session(session, keep_var_names=None, output_names=None, clear_devices=True):
    graph = session.graph

    with graph.as_default():
        freeze_var_names = list(
            set(v.op.name for v in tf.global_variables()).difference(
                keep_var_names or []
            )
        )

        output_names = output_names or []
        input_graph_def = graph.as_graph_def()

        if clear_devices:
            for node in input_graph_def.node:
                node.device = ""

        frozen_graph = tf.graph_util.convert_variables_to_constants(
            session, input_graph_def, output_names, freeze_var_names
        )
        return frozen_graph


def freeze_model(model, name):
    frozen_graph = freeze_session(
        sess, output_names=[out.op.name for out in model.outputs][:4]
    )
    directory = PATH_TO_SAVE_FROZEN_PB
    tf.train.write_graph(frozen_graph, directory, name, as_text=False)


def keras_to_tflite(in_weight_file, out_weight_file):
    sess = tf.Session()
    keras.set_session(sess)
    load_model(in_weight_file)
    global model
    freeze_model(model.keras_model, FROZEN_NAME)
    # https://github.com/matterport/Mask_RCNN/issues/2020#issuecomment-596449757
    input_arrays = ["input_image"]
    output_arrays = ["mrcnn_class/Softmax", "mrcnn_bbox/Reshape"]
    converter = tf.contrib.lite.TocoConverter.from_frozen_graph(
        PATH_TO_SAVE_FROZEN_PB + "/" + FROZEN_NAME,
        input_arrays,
        output_arrays,
        input_shapes={"input_image": [1, 256, 256, 3]},
    )
    converter.target_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS,
    ]
    converter.post_training_quantize = True
    tflite_model = converter.convert()
    open(out_weight_file, "wb").write(tflite_model)
    print("*" * 80)
    print("Finished converting keras model to Frozen tflite")
    print("PATH: ", out_weight_file)
    print("*" * 80)


keras_to_tflite("./full_model2.h5", "./model_instance_seg.tflite")
