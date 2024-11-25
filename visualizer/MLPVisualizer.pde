import java.util.Iterator;

class MLPVisualizer extends Animation {
  Tensor weights;
  int weightsNum;
  TensorVisualizer srcVis;
  TensorVisualizer trgVis;
  int iterations = 1;
  int trgIdx = 0;
  ArrayList<TensorVisualizer> weightsVisualizerList;
  boolean doCreateFilters = false;

  MLPVisualizer(MLP mlp, TensorVisualizer srcVis, TensorVisualizer trgVis) {
    this.weights = mlp.weights;
    this.srcVis = srcVis;
    this.trgVis = trgVis;
    this.weightsNum = this.weights.getShape().get(0);
    this.weightsVisualizerList = new ArrayList<TensorVisualizer>();
  }

  void startAnimation() {
    isComplete = false;
    doCreateFilters = true;
  }

  void resetAnimation() {
    isComplete = true;
    doCreateFilters = false;
    trgIdx = 0;
    this.weightsVisualizerList = new ArrayList<TensorVisualizer>();
  }

  void update() {
    if (!isComplete) {
      if (frameCount % 5 == 0) {

        for (int iter = 0; iter <  iterations; iter++) {
          if (doCreateFilters) {
            Tensor weightSlice = this.weights.slice(
              new int[]{trgIdx, 0},
              new int[]{trgIdx + 1, this.weights.getShape().get(1)}
              );
            PVector centerPos = srcVis.centerPos;
            TensorVisualizer tv = new TensorVisualizer(weightSlice, centerPos, srcVis.spacing, new PVector(), mlpBoxSize);
            tv.setAnimationDuration(70);
            tv.setCurPosOffset(new PVector(0, -50, 0));
            tv.setTrgPos(srcVis);
            tv.setVisible(true);
            tv.setIdxFlat(trgIdx, trgIdx);
            this.weightsVisualizerList.add(tv);
          }
        }

        trgIdx ++;
        if (trgIdx >= trgVis.tensor.getShape().get(0)) {
          trgIdx = 0;
          doCreateFilters = false;
        }
      }

      if (!doCreateFilters && this.weightsVisualizerList.size() == 0) {
        endAnimation();
      }
      Iterator<TensorVisualizer> iterator = this.weightsVisualizerList.iterator();
      while (iterator.hasNext()) {
        TensorVisualizer tvTemp = iterator.next();
        tvTemp.update();
        if (tvTemp.isAnimationComplete()) {
          if (tvTemp.getAnimationStage() < 1) {
            tvTemp.setAnimationDuration(70);
            tvTemp.setTrgPos(this.trgVis.boxes[tvTemp.idxFlatTrg]);
            tvTemp.setAnimationStage(tvTemp.getAnimationStage() + 1);
          } else if (tvTemp.getAnimationStage() < 2) {
            tvTemp.disposeBuffers();
            iterator.remove(); // Safe removal
          } else {
          }
        }
      }
    }
  }

  void draw() {
    for (TensorVisualizer tv : this.weightsVisualizerList) {
      tv.draw();
    }
  }
}
