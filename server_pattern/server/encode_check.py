import base64

with open("output.png", "rb") as image_file:
    encoded_image_string = base64.b64encode(image_file.read())

payload = {"mime": "image/png", "image": encoded_image_string, "some_other_data": None}

print(payload["image"])
