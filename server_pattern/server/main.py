import base64
from io import BytesIO

import cv2
import numpy as np
import torch
import torchvision
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
import uvicorn
from fastapi import FastAPI
from PIL import Image
from pydantic import BaseModel
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor


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

threshold = 0.56


app = FastAPI()


def generate_result(prediction):
    instances_image = Image.fromarray(
        prediction[0]["masks"][0, 0].mul(255).byte().cpu().numpy()
    )
    instances_image = np.array(instances_image)
    cnt = 0
    for i, score in enumerate(prediction[0]["scores"].tolist()):
        if score < threshold:
            continue
        next = Image.fromarray(
            prediction[0]["masks"][i, 0].mul(255).byte().cpu().numpy()
        )
        binary_next = np.array(next.convert("L"), "f")
        mask = (binary_next > 128) * 255
        instances_image[mask == 255] = 255
        cnt += 1

    return instances_image, cnt


class InputData(BaseModel):
    image: bytes


@app.post("/predict")
async def index(data: InputData):
    # data.imageをmodelのinputに合わせる
    decimg = base64.b64decode(data.image, validate=True)
    decimg = Image.open(BytesIO(decimg)).convert("RGB")
    input_image = torchvision.transforms.functional.to_tensor(decimg)

    # 推論
    prediction = model([input_image.to(device)])

    # アプリで表示するためのresponse生成
    output_image, num_books = generate_result(prediction)
    _, res_image = cv2.imencode(".png", output_image)

    encoded_image_string = base64.b64encode(BytesIO(res_image.tobytes()).read())

    res_json = jsonable_encoder({"mime": "image/png", "image": encoded_image_string, "number_of_books": num_books})
    return JSONResponse(content=res_json)


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
