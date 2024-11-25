int getIndex(Shape shape, int... indices) {
  int index = 0;
  for (int i = 0; i < indices.length; i++) {
    // 현재 차원의 유효 범위를 초과하는지 확인
    if (indices[i] < 0 || indices[i] >= shape.get(i)) {
      // 범위를 벗어나는 경우, 0으로 처리 (padding 처리)
      return -1; // 예외 처리용 인덱스 (패딩 영역으로 간주)
    }
    index = index * shape.get(i) + indices[i];
  }
  return index;
}

int[] index1DTo2D(int idx, Shape shape) {
  if (shape.getNumDimensions() != 2) {
    throw new IllegalArgumentException("Shape must have exactly 2 dimensions.");
  }
  int totalSize = shape.getTotalSize();

  idx = Math.floorMod(idx, totalSize);

  int dimX = shape.getDimension(0);
  int dimY = shape.getDimension(1);

  int idxY = idx % dimY;
  int idxX = idx / dimY;

  return new int[]{idxX, idxY};
}

int[] index1DTo3D(int idx, Shape shape) {
  if (shape.getNumDimensions() != 3) {
    throw new IllegalArgumentException("Shape must have exactly 3 dimensions.");
  }
  int totalSize = shape.getTotalSize();

  idx = Math.floorMod(idx, totalSize);

  int dimX = shape.getDimension(0);
  int dimY = shape.getDimension(1);
  int dimZ = shape.getDimension(2);

  int idxZ = idx % dimZ;
  int idxY = (idx / dimZ) % dimY;
  int idxX = idx / (dimY * dimZ);

  return new int[]{idxX, idxY, idxZ};
}

Tensor parseConvBias(String[] bias) {
  int outChNum = bias.length;
  Tensor tensor = new Tensor(new int[]{outChNum}); // 1차원 텐서 생성

  for (int i = 0; i < outChNum; i++) {
    tensor.set(Float.parseFloat(bias[i]), i); // 각 요소를 Tensor에 저장
  }

  return tensor;
}

Tensor parseConvWeightsToTensor(String[] weights) {
  int outChNum = weights.length;
  int inChNum = 0;
  int kernelWNum = 0;
  int kernelHNum = 0;

  // 각 차원의 크기를 계산
  for (int i = 0; i < outChNum; i++) {
    String[] inCh = weights[i].split("!");
    inChNum = inCh.length;
    for (int j = 0; j < inChNum; j++) {
      String[] kernelW = inCh[j].split(",");
      kernelWNum = kernelW.length;
      for (int k = 0; k < kernelWNum; k++) {
        String[] kernelH = kernelW[k].split(" ");
        kernelHNum = kernelH.length;
      }
    }
  }

  // Tensor의 shape을 정의하고, Tensor 객체를 생성
  int[] shape = {outChNum, inChNum, kernelWNum, kernelHNum};
  Tensor tensor = new Tensor(shape);

  // 파싱한 데이터를 Tensor에 저장
  for (int i = 0; i < outChNum; i++) {
    String[] inCh = weights[i].split("!");
    for (int j = 0; j < inChNum; j++) {
      String[] kernelW = inCh[j].split(",");
      for (int k = 0; k < kernelWNum; k++) {
        String[] kernelH = kernelW[k].split(" ");
        for (int l = 0; l < kernelHNum; l++) {
          // 값을 Tensor의 1차원 배열에 설정
          tensor.set(Float.parseFloat(kernelH[l]), i, j, k, l);
        }
      }
    }
  }
  return tensor;
}

public Tensor parseMLPWeight(String[] weights) {
  int batchNum = weights.length;
  int inChNum = weights[0].split(" ").length;

  Tensor tensor = new Tensor(new int[]{batchNum, inChNum}); // 2차원 Tensor 생성

  for (int i = 0; i < batchNum; i++) {
    String[] inCh = weights[i].split(" ");
    for (int j = 0; j < inCh.length; j++) {
      tensor.set(Float.parseFloat(inCh[j]), i, j); // 각 요소를 Tensor에 설정
    }
  }
  return tensor;
}

public Tensor softmax(Tensor tensor) {
  Shape originalShape = tensor.getShape();
  Tensor flattened = tensor.clone();
  flattened._reshape(flattened.getShape().getTotalSize());

  float maxVal = tensor.max();

  float sumExp = 0;
  for (int i = 0; i < flattened.getShape().get(0); i++) {
    //data[i] = (float) Math.exp(data[i] - maxVal);
    flattened.set((float) Math.exp(flattened.get(i) - maxVal), i);
    sumExp += flattened.get(i);
  }

  for (int i = 0; i < flattened.getShape().get(0); i++) {
    flattened.set(flattened.get(i)/sumExp, i);
  }

  // 원래 shape로 되돌림
  flattened._reshape(originalShape.toArray());
  return flattened;
}

float easeInOutCirc(float x) {
  if (x < 0.5) {
    return (1 - sqrt(1 - pow(2 * x, 2))) / 2;
  } else {
    return (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2;
  }
}




void saveCameraState(char num) {
  CameraState state = cam.getState();
  String path = String.format(dataPath("camstate_%c.ser"), num);

  try (FileOutputStream fileOut = new FileOutputStream(path);
  ObjectOutputStream out = new ObjectOutputStream(fileOut)) {

    out.writeObject(state); // 객체를 직렬화하여 파일에 저장
    System.out.println("객체가 성공적으로 저장되었습니다.");
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void loadCameraState(char num) {
  CameraState state = null;
  String path = String.format(dataPath("camstate_%c.ser"), num);

  try (FileInputStream fileIn = new FileInputStream(path);
  ObjectInputStream in = new ObjectInputStream(fileIn)) {

    state = (CameraState) in.readObject(); // 객체를 역직렬화
    System.out.println("객체가 성공적으로 로드되었습니다.");
    System.out.println("로드된 객체: " + state);
  }
  catch (IOException | ClassNotFoundException e) {
    e.printStackTrace();
  }

  if (state != null) {
    cam.setState(state, 200);
  }
}


CameraState loadCameraState(String  path) {
  CameraState state = null;

  try (FileInputStream fileIn = new FileInputStream(dataPath(path));
  ObjectInputStream in = new ObjectInputStream(fileIn)) {

    state = (CameraState) in.readObject();
    System.out.println("객체가 성공적으로 로드되었습니다.");
    System.out.println("로드된 객체: " + state);
  }
  catch (IOException | ClassNotFoundException e) {
    e.printStackTrace();
  }

  return state;
}

void drawAnswers(TensorVisualizer tv) {
  for (int i = 0; i < tv.boxes.length; i++) {
    if (tv.boxes[i].isVisible) {
      textSize(15);
      text(i, tv.boxes[i].curPos.x, tv.boxes[i].curPos.y + 30, tv.boxes[i].curPos.z);
    }
  }
}
