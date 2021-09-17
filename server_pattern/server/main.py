import base64
from io import BytesIO
from textwrap import fill

import cv2
import numpy as np
import torch
import torchvision
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from numpy import ndarray
from PIL import Image
from pydantic import BaseModel
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
from torchvision.transforms import functional, transforms


def get_instance_segmentation_model(num_classes):
    # COCOデータセットで事前学習したインスタンス・セグメンテーションのモデルをロード
    model = torchvision.models.detection.maskrcnn_resnet50_fpn(pretrained=True)

    # 分類器に入力する特徴量の数を取得
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    # 事前訓練済みのヘッドを新しいヘッドに置き換え
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)

    # セグメンテーション・マスクの分類器に入力する特徴量の数を取得
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    hidden_layer = 256
    # セグメテーション・マスクの推論器を新しいものに置き換え
    model.roi_heads.mask_predictor = MaskRCNNPredictor(
        in_features_mask, hidden_layer, num_classes
    )

    return model


device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")

# 作成したカスタム・データセットのクラスは、背景と本の2クラスのみ
num_classes = 2

# 補助関数を使って、モデルを取得
model = get_instance_segmentation_model(num_classes)

# モデルを正しいデバイス(GPU)に移動
model.to(device)

model.load_state_dict(
    torch.load("model_instance_seg.pth", map_location=torch.device(device))
)
model.eval()

threshold = 0.8


app = FastAPI()


def generate_result(prediction, original_image: Image):
    image_size = original_image.size

    output_image: ndarray = np.array(original_image)
    fill_image = np.copy(output_image)
    num_of_books = 0

    for i, score in enumerate(prediction[0]["scores"].tolist()):
        if score < threshold:
            continue
        instance_mask: Image = functional.to_pil_image(
            prediction[0]["masks"][i, 0].mul(255).byte()
        )
        instance_mask = instance_mask.resize(image_size, Image.NEAREST)
        random_color = list(np.random.choice(range(256), size=3))
        fill_image[np.array(instance_mask) > 0] = random_color
        num_of_books += 1

    fill_image = Image.fromarray(fill_image)
    output_image = Image.fromarray(output_image)
    output_image = Image.blend(output_image, fill_image, 0.4)

    output_image = np.array(output_image)

    return output_image, num_of_books


class InputData(BaseModel):
    image: bytes


@app.post("/predict")
async def index(data: InputData):
    # data.imageをmodelのinputに合わせる
    decimg = base64.b64decode(data.image, validate=True)
    decimg = Image.open(BytesIO(decimg)).convert("RGB")
    image_width = decimg.size[0]
    image_height = decimg.size[1]
    size_ratio = image_width / image_height
    resize_height = 256
    transform = transforms.Compose(
        [
            transforms.Resize((resize_height, int(resize_height * size_ratio))),
            transforms.ToTensor(),
        ]
    )

    input_image = transform(decimg)

    # 推論
    prediction = model([input_image.to(device)])

    # アプリで表示するためのresponse生成
    output_image, num_books = generate_result(prediction, decimg)
    output_image = cv2.cvtColor(output_image, cv2.COLOR_RGB2BGR)
    _, res_image = cv2.imencode(".png", output_image)

    encoded_image_string = base64.b64encode(BytesIO(res_image.tobytes()).read())

    res_json = jsonable_encoder(
        {
            "mime": "image/png",
            "image": encoded_image_string,
            "numberOfBooks": num_books,
        }
    )
    return JSONResponse(content=res_json)
