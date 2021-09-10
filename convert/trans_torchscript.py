import torch
import torchvision
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


script_model = torch.jit.script(model)
script_model.save("model_instance_seg.pt")
