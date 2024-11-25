
class Conv2D {
  Tensor weights;
  Tensor bias;
  int[] wShape;
  int stride = 2;

  Conv2D(String weightsPath, String biasPath) {
    String[] weightData = loadStrings(weightsPath);
    this.weights = parseConvWeightsToTensor(weightData);
    String[] biasData = loadStrings(biasPath);
    this.bias = parseConvBias(biasData);
    this.wShape = this.weights.getShape().toArray();
  }

  Tensor forward(Tensor x) {
    Shape xShape = x.getShape();
    int bSize = xShape.get(0);
    int imgSize = xShape.get(2)/2;
    int[] outShape = new int[]{bSize, this.wShape[0], imgSize, imgSize};
    int kernelH = this.wShape[2];
    int kernelW = this.wShape[3];
    int kernelHSize = kernelH/2;
    int kernelWSize = kernelW/2;
    Tensor result = new Tensor(outShape[0], outShape[1], outShape[2], outShape[3]);
    // loop over every output channel
    for (int i = 0; i < outShape[1]; i++) {
      // loop over every pixel
      for (int j = 0; j < outShape[2]; j++) {
        for (int k = 0; k < outShape[3]; k++) {
          // loop over kernel
          for (int l = 0; l < this.wShape[1]; l++) {
            for (int m = 0; m < kernelH; m++) {
              for (int n = 0; n < kernelW; n++) {
                int offsetX = m-kernelHSize;
                int offsetY = n-kernelWSize;
                result.set(result.get(0, i, j, k) + x.get(0, l, j*this.stride + offsetX, k*this.stride + offsetY) * weights.get(i, l, m, n), 0, i, j, k);
              }
            }
          }
          result.set(result.get(0, i, j, k) + this.bias.get(i), 0, i, j, k);
          result._relu();
        }
      }
    }
    return result;
  }
}
