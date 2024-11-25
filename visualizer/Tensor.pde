import java.util.Arrays;

class Shape {
  int[] dimensions;
  int length;

  Shape(int... dimensions) {
    this.dimensions = dimensions;
    this.length = dimensions.length;
  }

  int get(int index) {
    return dimensions[index];
  }

  int getDimension(int index) {
    return dimensions[index];
  }

  int getNumDimensions() {
    return dimensions.length;
  }

  int getTotalSize() {
    return Arrays.stream(dimensions).reduce(1, (a, b) -> a * b);
  }

  int[] getDimensions() {
    return dimensions;
  }

  int[] toArray() {
    return dimensions.clone(); // 배열을 복제하여 반환
  }

  @Override
    String toString() {
    return Arrays.toString(dimensions);
  }
}

class Tensor {

  float[] data;
  Shape shape;

  // 생성자
  Tensor(int... shape) {
    this.shape = new Shape(shape);
    this.data = new float[Arrays.stream(shape).reduce(1, (a, b) -> a * b)];
  }

  Tensor clone() {
    // 같은 shape을 사용하여 새 텐서 생성
    Tensor clonedTensor = new Tensor(shape.toArray());

    // 원본 data 배열의 값을 새 텐서의 data 배열로 복사
    System.arraycopy(this.data, 0, clonedTensor.data, 0, this.data.length);

    return clonedTensor;
  }

  // squeeze 메서드 추가
  public Tensor squeeze() {
    // 크기가 1인 차원을 제외한 새로운 shape을 생성
    int[] newShape = Arrays.stream(shape.getDimensions())
      .filter(dim -> dim > 1) // 크기가 1인 차원 제외
      .toArray();

    // 모든 차원이 크기 1이면 최소 1차원으로 유지
    if (newShape.length == 0) {
      newShape = new int[]{1};
    }

    // 새로운 shape을 사용하여 Tensor 객체 생성
    Tensor squeezedTensor = new Tensor(newShape);

    //System.arraycopy(this.data, 0, squeezedTensor.data, 0, this.data.length);
    squeezedTensor.data = this.data;
    return squeezedTensor;
  }

  void _relu() {
    for (int i = 0; i < data.length; i++) {
      if (data[i] < 0) {
        data[i] = 0;
      }
    }
  }


  float get(int... indices) {
    int index = getIndex(this.shape, indices);
    if (index == -1) {
      return 0; // 패딩 영역으로 간주하고 0을 반환
    }
    return data[index];
  }

  void set(float value, int... indices) {
    int index = getIndex(this.shape, indices);
    if (index != -1) {
      data[index] = value; // 유효한 인덱스에만 값을 설정
    }
  }

  // shape 반환 (차원 정보)
  Shape getShape() {
    return shape;
  }

  void _reshape(int... newShape) {
    int newTotalSize = Arrays.stream(newShape).reduce(1, (a, b) -> a * b);
    int currentTotalSize = Arrays.stream(shape.toArray()).reduce(1, (a, b) -> a * b);
    if (newTotalSize != currentTotalSize) {
      throw new IllegalArgumentException("Total number of elements must remain the same");
    }
    this.shape = new Shape(newShape);
  }

  Tensor slice(int[] start, int[] end) {
    if (start.length != shape.length || end.length != shape.length) {
      throw new IllegalArgumentException("Start and end indices must match the tensor's shape dimensions");
    }

    // 각 차원의 크기를 계산하여 새로운 shape 정의
    int[] newShape = new int[shape.length];
    for (int i = 0; i < shape.length; i++) {
      newShape[i] = end[i] - start[i];
      if (newShape[i] <= 0) {
        throw new IllegalArgumentException("Invalid slice range for dimension " + i);
      }
    }

    Tensor slicedTensor = new Tensor(newShape);

    copySliceWithPadding(this, slicedTensor, start, new int[shape.length], 0);

    return slicedTensor;
  }

  // 재귀적으로 데이터를 슬라이스하여 복사하고, 범위를 벗어나면 zero padding 적용
  void copySliceWithPadding(Tensor original, Tensor sliced, int[] start, int[] indices, int dim) {
    if (dim == shape.length) {
      // 범위를 벗어난 인덱스가 있으면 zero padding
      for (int i = 0; i < shape.length; i++) {
        if (indices[i] < start[i] || indices[i] >= shape.get(i)) {
          sliced.set(0, indicesToSliceIndices(indices, start));
          return;
        }
      }
      // 범위 내의 인덱스에 원본 값을 복사
      sliced.set(original.get(indices), indicesToSliceIndices(indices, start));
    } else {
      for (int i = start[dim]; i < start[dim] + sliced.shape.get(dim); i++) {
        indices[dim] = i;
        copySliceWithPadding(original, sliced, start, indices, dim + 1);
      }
    }
  }

  // 원본 인덱스를 슬라이스 인덱스로 변환
  int[] indicesToSliceIndices(int[] indices, int[] start) {
    int[] sliceIndices = new int[indices.length];
    for (int i = 0; i < indices.length; i++) {
      sliceIndices[i] = indices[i] - start[i];
    }
    return sliceIndices;
  }


  @Override
    String toString() {
    return toStringRecursive(new int[shape.length], 0);
  }

  // 재귀적으로 각 차원을 순회하며 문자열로 변환
  String toStringRecursive(int[] indices, int dim) {
    if (dim == shape.length - 1) {  // 가장 안쪽 차원인 경우
      StringBuilder sb = new StringBuilder();
      sb.append("[");
      for (int i = 0; i < shape.get(dim); i++) {
        indices[dim] = i;
        sb.append(get(indices));
        if (i < shape.get(dim) - 1) {
          sb.append(", ");
        }
      }
      sb.append("]");
      return sb.toString();
    } else {  // 상위 차원인 경우
      StringBuilder sb = new StringBuilder();
      sb.append("[");
      for (int i = 0; i < shape.get(dim); i++) {
        indices[dim] = i;
        sb.append(toStringRecursive(indices, dim + 1));
        if (i < shape.get(dim) - 1) {
          sb.append(",\n ");
        }
      }
      sb.append("]");
      return sb.toString();
    }
  }

  float max() {
    if (data.length == 0) {
      throw new IllegalStateException("Tensor is empty");
    }

    float maxVal = data[0];
    for (int i = 1; i < data.length; i++) {
      if (data[i] > maxVal) {
        maxVal = data[i];
      }
    }
    return maxVal;
  }
}
