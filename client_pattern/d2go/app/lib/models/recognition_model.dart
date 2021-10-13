class RecognitionModel {
  RecognitionModel(this.rect, this.confidenceInClass, this.detectedClass);
  Rectangle rect;
  double confidenceInClass;
  int detectedClass;
}

class Rectangle {
  Rectangle(this.w, this.x, this.h, this.y);
  double w;
  double x;
  double h;
  double y;
}
