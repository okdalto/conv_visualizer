class ReshapeVisualizer extends Animation {

  TensorVisualizer srcVis;
  TensorVisualizer trgVis;
  TensorVisualizer tv;

  ReshapeVisualizer(TensorVisualizer srcVis, TensorVisualizer trgVis) {
    super();
    this.srcVis = srcVis;
    this.trgVis = trgVis;
    this.tv = this.srcVis.copy();
  }

  void startAnimation() {
    isComplete = false;
    tv.setCurVal(srcVis);
    tv.setTrgSize(mlpBoxSize);
    tv.setAnimationDuration(100);
    tv.setTrgPos(trgVis);
    tv.setVisible(true);
  }

  void resetAnimation() {
    isComplete = true;
  }

  void update() {
    if (!isComplete) {
      this.tv.update();
      if (tv.isAnimationComplete()) {
        trgVis.setVisible(true);
        resetAnimation();
        endAnimation();
      }
    }
  }

  void draw() {
    if (!isComplete) {
      this.tv.draw();
    }
  }
}
