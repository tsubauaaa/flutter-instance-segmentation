import base64
from io import BytesIO

import requests
from PIL import Image

file_path = "./test.jpg"

with open(file_path, "rb") as img:
    encimg = base64.b64encode(img.read())

encimg_str = encimg.decode("utf-8")
payload = {"image": encimg_str}

res = requests.post(
    "http://127.0.0.1:8000/predict",
    json=payload,
    headers={"Content-Type": "application/json"},
)

img = Image.open(BytesIO(res.content))
img.show(img)

# img.save("output.png")
