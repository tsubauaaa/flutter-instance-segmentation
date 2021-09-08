import base64
import requests
from io import BytesIO
from PIL import Image

file_path = "./test.png"

with open(file_path, "rb") as img:
    encimg = base64.b64encode(img.read())

encimg_str = encimg.decode("utf-8")
payload = {"image": encimg_str}

res = requests.post(
    "http://127.0.0.1:8000/predict",
    json=payload,
    headers={"Content-Type": "application/json"},
)

# base64 string
image_base64_string = res.json()["image"]
# base64 decoding
docoded_image_string = base64.b64decode(image_base64_string)

res_image = Image.open(BytesIO(docoded_image_string))
res_image.show()

# with open("output.png", "wb") as f:
#     f.write(docoded_image_string)
