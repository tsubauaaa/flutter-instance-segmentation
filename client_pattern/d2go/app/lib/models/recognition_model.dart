class RecognitionModel {
  RecognitionModel(this.rect, this.confidenceInClass, this.detectedClass);
  Rectangle rect;
  double confidenceInClass;
  int detectedClass;
}

class Rectangle {
  Rectangle(this.left, this.top, this.right, this.bottom);
  double left;
  double top;
  double right;
  double bottom;
}
