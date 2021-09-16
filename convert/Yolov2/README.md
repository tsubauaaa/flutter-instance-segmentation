## convert Yolov2 to Tflite

### カスタムデータで学習

- tiny_yolov2_train_books.ipynb  
  　これを実施する。データ作成は Yolo_Label で行った。  
  参考 URL: https://github.com/developer0hye/Yolo_Label

### convert weights to Protobuf

- https://github.com/thtrieu/darkflow を clone する

- setup.py を build する

- 学習時に使った cfg を darkflow/cfg 配下に配置する

- conda 環境 py3-yolov2-tflite になる

  ```
  $ conda activate py3-yolov2-tflite
  ```

- 以下を実行する

  ```
  $ python flow --model cfg/tiny-yolo-book.cfg --load ./tiny-yolo_120000.weights --savepb
  ```

  参考 URL: https://www.tooploox.com/blog/card-detection-using-yolo-on-android

- built_graph/以下に pb ができる

### convert Protobuf to Tflite

- conda 環境 py3-yolov2-tflite になる

- 以下を実行する

  ```
  $ tflite_convert --graph_def_file=built_graph/tiny-yolo-book.pb --output_file=tiny-yolo-book.tflite --input_format=TENSORFLOW_GRAPHDEF --output_format=TFLITE --input_shape=1,416,416,3 --input_array=input --output_array=output
  ```
