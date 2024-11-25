class MLP {
  Tensor weights;
  Tensor bias;
  int[] wShape;
  boolean relu;
  MLP(String  weightsPath, String biasPath, boolean relu) {
    String[] weightData = loadStrings(weightsPath);
    this.weights = parseMLPWeight(weightData);
    String[] biasData = loadStrings(biasPath);
    this.bias = parseConvBias(biasData);
    this.wShape = new int[2];
    this.relu = relu;
  }

  Tensor matMul(Tensor matrix1, Tensor matrix2) {
    int m1Rows = matrix1.getShape().get(0);
    int m1Cols = matrix1.getShape().get(1);
    int m2Cols = matrix2.getShape().get(1);

    // Check if the matrices can be multiplied
    if (m1Cols != matrix2.getShape().get(0)) {
      throw new IllegalArgumentException("Invalid matrix dimensions");
    }

    //float[][] result = new float[m1Rows][m2Cols];
    Tensor result = new Tensor(m1Rows, m2Cols);

    for (int i = 0; i < m1Rows; i++) {
      for (int j = 0; j < m2Cols; j++) {
        float sum = 0.0f;
        for (int k = 0; k < m1Cols; k++) {
          sum += matrix1.get(i, k) * matrix2.get(k, j);
        }
        result.set(sum, i, j);
      }
      //result[i][0] += bias[i];
      result.set(result.get(i, 0) + bias.get(i), i, 0);
      
      if (this.relu) {
        result._relu();
      }
    }

    return result;
  }

  Tensor forward(Tensor x) {
    return matMul(this.weights, x);
  }
}
