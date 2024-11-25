import java.util.Iterator;

class Conv2DVisualizer extends Animation {
  Conv2D conv2D;
  Tensor weights;
  TensorVisualizer srcVis;
  TensorVisualizer trgVis;
  int iterations;
  ArrayList<TensorVisualizer> weightsVisualizerList;
  int srcIdxX = 0;
  int srcIdxY = 0;
  int srcIdxZ = 0;
  int trgIdx = 0;
  boolean doCreateFilters = false;

  Conv2DVisualizer(Conv2D conv2D, TensorVisualizer srcVis, TensorVisualizer trgVis, int iterations) {
    super();
    this.conv2D = conv2D;
    this.weights = conv2D.weights;
    this.srcVis = srcVis;
    this.trgVis = trgVis;
    this.iterations = iterations;

    this.weightsVisualizerList = new ArrayList<TensorVisualizer>();
  }

  void startAnimation() {
    isComplete = false;
    doCreateFilters = true;
  }

  void resetAnimation() {
    isComplete = true;
    doCreateFilters = false;
    srcIdxX = 0;
    srcIdxY = 0;
    srcIdxZ = 0;
    trgIdx = 0;
    this.weightsVisualizerList = new ArrayList<TensorVisualizer>();
  }

  void update() {
    if (!isComplete) {
      for (int iter = 0; iter <  iterations; iter++) {
        if (doCreateFilters) {
          int[] srcIdx;
          if (srcVis.tensor.getShape().getNumDimensions() <= 2) {
            srcIdx = new int[]{srcIdxY, srcIdxX};
          } else {
            srcIdx = new int[]{srcIdxZ, srcIdxY, srcIdxX};
          }
          int idx_flat_src = getIndex(srcVis.tensor.getShape(), srcIdx);

          int[] idx_3d_trg = index1DTo3D(trgIdx, trgVis.tensor.getShape());
          int idx_flat_trg = getIndex(trgVis.tensor.getShape(), idx_3d_trg);
          Tensor weightSlice = this.weights.slice(
            new int[]{idx_3d_trg[0], 0, 0, 0},
            new int[]{idx_3d_trg[0] + 1, this.weights.getShape().get(1), 3, 3}
            );
          PVector centerPos = srcVis.boxes[idx_flat_src].getTrgPos().copy();
          centerPos.z = srcVis.centerPos.z;
          TensorVisualizer tv = new TensorVisualizer(weightSlice, centerPos, srcVis.spacing, convBoxSize);
          tv.setAnimationDuration(40);
          tv.setCurPosOffset(new PVector(0, 0, 30));
          tv.setIdxFlat(idx_flat_src, idx_flat_trg);
          tv.setVisible(true);
          this.weightsVisualizerList.add(tv);

          if (srcVis.tensor.getShape().getNumDimensions() <= 2) {
            srcIdxX += 2;
            // X 범위를 초과할 경우 Y를 증가시키고 X를 초기화
            if (srcIdxX >= srcVis.tensor.getShape().get(1)) {
              srcIdxX = 0;
              srcIdxY += 2;
              // Y 범위를 초과할 경우 Z를 증가시키고 Y를 초기화
              if (srcIdxY >= srcVis.tensor.getShape().get(0)) {
                srcIdxY = 0;
                srcIdxX = 0;
              }
            }
          } else {
            srcIdxX += 2;
            // X 범위를 초과할 경우 Y를 증가시키고 X를 초기화
            if (srcIdxX >= srcVis.tensor.getShape().get(2)) {
              srcIdxX = 0;
              srcIdxY += 2;
              // Y 범위를 초과할 경우 Z를 증가시키고 Y를 초기화
              if (srcIdxY >= srcVis.tensor.getShape().get(1)) {
                srcIdxY = 0;
                // 3차원일 경우 Z를 증가, Z 범위 초과 시 모든 인덱스를 초기화
                srcIdxZ++;
                if (srcIdxZ >= srcVis.tensor.getShape().get(0)) {
                  srcIdxX = 0;
                  srcIdxY = 0;
                  srcIdxZ = 0;
                }
              }
            }
          }
          trgIdx ++;
          if (trgIdx >= trgVis.tensor.data.length) {
            doCreateFilters = false;
          }
        }

        if (this.weightsVisualizerList.size() == 0) {
          endAnimation();
        }
        Iterator<TensorVisualizer> iterator = this.weightsVisualizerList.iterator();
        while (iterator.hasNext()) {
          TensorVisualizer tvTemp = iterator.next();
          tvTemp.update();
          if (tvTemp.isAnimationComplete()) {
            if (tvTemp.getAnimationStage() < 1) {
              tvTemp.setAnimationDuration(40);
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
  }

  void draw() {
    for (TensorVisualizer tv : this.weightsVisualizerList) {
      tv.draw();
    }
  }
}
