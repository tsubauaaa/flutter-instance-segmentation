import os

import cv2
import tensorflow as tf
import torch

import model_convert
from load_model import get_instance_segmentation_model

CHECKPOINT_PATH = "./model_instance_seg3.pth"
DO_OPTIMIZE = True
OPTIMIZATIONS = [tf.lite.Optimize.DEFAULT]

MODEL_INPUT_WIDTH = 256
MODEL_INPUT_HEIGHT = 256
INPUT_SHAPE = (1, 3, MODEL_INPUT_HEIGHT, MODEL_INPUT_WIDTH)

IMG_PATH = "../server_pattern/server/test.png"


def infer(tflite_filepath, img_path):
    interpreter = tf.lite.Interpreter(model_path=tflite_filepath)
    interpreter.allocate_tensors()  # allocate memory

    # 入力層の構成情報を取得する
    input_details = interpreter.get_input_details()

    # 入力層に合わせて、画像を変換する
    img = cv2.imread(img_path)
    img = (img - 128) / 256  # 明度を正規化（モデル学習時のデータ前処理に合わせる）
    input_shape = input_details[0]["shape"]
    input_dtype = input_details[0]["dtype"]
    input_data = (
        cv2.resize(img, (input_shape[2], input_shape[3]))
        .transpose((2, 0, 1))
        .reshape(input_shape)
        .astype(input_dtype)
    )
    # indexにテンソルデータのポインタをセット
    interpreter.set_tensor(input_details[0]["index"], input_data)

    # 推論実行
    interpreter.invoke()

    # 出力層から結果を取り出す
    output_details = interpreter.get_output_details()
    output_data = interpreter.get_tensor(output_details[0]["index"])
    return output_data


if __name__ == "__main__":
    CHECKPOINT_DIR = os.path.dirname(CHECKPOINT_PATH)
    CHECKPOINT_BASE = os.path.basename(CHECKPOINT_PATH)
    OUT_DIR = os.path.join(CHECKPOINT_DIR, f"{MODEL_INPUT_WIDTH}_{MODEL_INPUT_HEIGHT}")
    os.makedirs(OUT_DIR, exist_ok=True)

    onnx_filepath = os.path.join(OUT_DIR, f"{CHECKPOINT_BASE}.onnx")
    pb_filepath = os.path.join(OUT_DIR, f"{CHECKPOINT_BASE}.pb")
    tflite_filepath = os.path.join(OUT_DIR, f"{CHECKPOINT_BASE}.tflite")

    # convert model
    # 作成したカスタム・データセットのクラスは、背景と本の2クラスのみ
    num_classes = 2

    # 補助関数を使って、モデルを取得
    model = get_instance_segmentation_model(num_classes)

    model.load_state_dict(torch.load(CHECKPOINT_PATH, map_location=torch.device("cpu")))

    # 変換したいモデルに合わせる
    tflite_filepath = model_convert.convert(
        model,
        onnx_filepath,
        pb_filepath,
        tflite_filepath,
        INPUT_SHAPE,
        DO_OPTIMIZE,
        OPTIMIZATIONS,
    )

    # test
    output_data = infer(tflite_filepath, IMG_PATH)
    print(output_data)
