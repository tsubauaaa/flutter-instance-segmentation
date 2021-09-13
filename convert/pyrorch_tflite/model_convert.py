import os
import subprocess

import tensorflow as tf
import torch


def convert_torch_to_onnx(model, onnx_filepath, input_shape):
    dummy_input = torch.randn(input_shape)
    torch.onnx.export(
        model,
        dummy_input,
        onnx_filepath,
        verbose=True,
        input_names=["input"],
        output_names=["output"],
        opset_version=11,
    )
    assert os.path.exists(onnx_filepath)

    return onnx_filepath


def convert_onnx_to_tensorflow(onnx_filepath, pb_filepath):
    subprocess.run(f"onnx-tf convert -i {onnx_filepath} -o {pb_filepath}", shell=True)
    assert os.path.exists(pb_filepath)


def convert_tensorflow_to_tflite(
    pb_filepath, tflite_filepath, do_optimize, optimizations
):
    # input_arrays = ["input"]
    # output_arrays = ["output"]

    converter = tf.lite.TFLiteConverter.from_saved_model(pb_filepath)
    if do_optimize:
        converter.optimizations = optimizations  # 量子化する時のみ
        # converter.target_spec.supported_types = [tf.float16]
        # converter.inference_input_type = tf.float16
        # converter.inference_output_type = tf.float16
    tflite_model = converter.convert()

    with open(tflite_filepath, "wb") as f:
        f.write(tflite_model)
    assert os.path.exists(tflite_filepath)


def convert(
    model,
    onnx_filepath,
    pb_filepath,
    tflite_filepath,
    input_shape,
    do_optimize,
    optimizations,
):
    print("################ torch to onnx ###############")
    if os.path.exists(onnx_filepath):
        print(f"already exists {onnx_filepath}")
    else:
        convert_torch_to_onnx(model, onnx_filepath, input_shape)

    print("################ onnx to tensorflow ################")
    if os.path.exists(pb_filepath):
        print(f"already exists {pb_filepath}")
    else:
        convert_onnx_to_tensorflow(onnx_filepath, pb_filepath)

    print("################ tensorflow to tflite ################")
    if os.path.exists(tflite_filepath):
        print(f"already exists {tflite_filepath}")
    else:
        convert_tensorflow_to_tflite(
            pb_filepath, tflite_filepath, do_optimize, optimizations
        )

    return tflite_filepath
