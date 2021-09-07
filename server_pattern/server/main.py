from io import BytesIO
import torchvision
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
import torch
from fastapi import FastAPI
from pydantic import BaseModel
from starlette.responses import StreamingResponse


def get_instance_segmentation_model(num_classes):
    # COCOデータセットで事前学習したインスタンス・セグメンテーションのモデルをロードします
    model = torchvision.models.detection.maskrcnn_resnet50_fpn(pretrained=True)

    # 分類器に入力する特徴量の数を取得します
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    # 事前訓練済みのヘッドを新しいヘッドに置き換えます
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)

    # セグメンテーション・マスクの分類器に入力する特徴量の数を取得します
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    hidden_layer = 256
    # セグメテーション・マスクの推論器を新しいものに置き換えます
    model.roi_heads.mask_predictor = MaskRCNNPredictor(in_features_mask,
                                                       hidden_layer,
                                                       num_classes)

    return model


device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')

# 作成したカスタム・データセットのクラスは、背景と本の2クラスのみです
num_classes = 2

# 補助関数を使って、モデルを取得します
model = get_instance_segmentation_model(num_classes)

# モデルを正しいデバイス(GPU)に移動します
model.to(device)

model.load_state_dict(torch.load("model.pth", map_location=torch.device(device)))
model.eval()


app = FastAPI()


class Data(BaseModel):
    image: bytes


@app.post("/predict")
async def index(data: Data):
    # TODO: data.imageをmodelに合わせて加工
    input_image = data.image
    
    prediction = model([input_image.to(device)])
    
    # TODO: アプリで表示するための画像生成
    out_image = prediction

    return StreamingResponse(BytesIO(out_image.tobytes()), media_type="image/jpeg")