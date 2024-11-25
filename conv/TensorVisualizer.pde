class TensorVisualizer {
  Tensor tensor;
  PVector centerPos;
  PVector boxSize;
  PVector boxStartSize;

  float spacing;
  Box[] boxes;
  int animationStage = 0;

  int idxFlatSrc;
  int idxFlatTrg;

  float[] offsets;
  float[] colors;
  float[] sizes;
  int offsetVBO;
  int colorVBO;
  int sizeVBO;

  TensorVisualizer(Tensor tensor, PVector centerPos, float spacing, PVector boxSize) {
    this.tensor = tensor.squeeze();
    this.centerPos = centerPos;
    this.spacing = spacing;
    this.boxSize = boxSize;
    if (this.tensor.getShape().getNumDimensions() > 3) {
      throw new IllegalArgumentException("Tensor must have 3 or fewer dimensions");
    }
    this.boxes = new Box[this.tensor.getShape().getTotalSize()];

    this.offsets = new float[this.boxes.length * 3];
    this.colors = new float[this.boxes.length * 4];
    this.sizes = new float[this.boxes.length * 3];
    setVbo();

    int[] indices = new int[this.tensor.getShape().getNumDimensions()];
    createBoxes(indices, 0, boxSize);
  }

  TensorVisualizer(Tensor tensor, PVector centerPos, float spacing, PVector boxStartSize, PVector boxSize) {
    this.tensor = tensor.squeeze();
    this.centerPos = centerPos;
    this.spacing = spacing;
    this.boxSize = boxSize;
    this.boxStartSize = boxStartSize;
    if (this.tensor.getShape().getNumDimensions() > 3) {
      throw new IllegalArgumentException("Tensor must have 3 or fewer dimensions");
    }
    this.boxes = new Box[this.tensor.getShape().getTotalSize()];

    this.offsets = new float[this.boxes.length * 3];
    this.colors = new float[this.boxes.length * 4];
    this.sizes = new float[this.boxes.length * 3];
    setVbo();

    int[] indices = new int[this.tensor.getShape().getNumDimensions()];
    createBoxes(indices, 0, boxSize);
  }

  void setVbo() {
    int[] buffer = new int[3];
    gl.glGenBuffers(3, buffer, 0);
    this.offsetVBO = buffer[0];
    this.colorVBO = buffer[1];
    this.sizeVBO = buffer[2];
  }

  void bindBuffers() {
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, this.offsetVBO);
    FloatBuffer offsetBuffer = FloatBuffer.wrap(offsets);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, offsets.length * Float.BYTES, offsetBuffer, GL.GL_DYNAMIC_DRAW);
    gl.glVertexAttribPointer(1, 3, GL.GL_FLOAT, false, 0, 0);
    gl.glEnableVertexAttribArray(1);
    gl.glVertexAttribDivisor(1, 1);

    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, this.colorVBO);
    FloatBuffer colorBuffer = FloatBuffer.wrap(colors);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, colors.length * Float.BYTES, colorBuffer, GL.GL_DYNAMIC_DRAW);
    gl.glVertexAttribPointer(2, 4, GL.GL_FLOAT, false, 0, 0);
    gl.glEnableVertexAttribArray(2);
    gl.glVertexAttribDivisor(2, 1);

    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, this.sizeVBO);
    FloatBuffer sizeBuffer = FloatBuffer.wrap(sizes);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, sizes.length * Float.BYTES, sizeBuffer, GL.GL_DYNAMIC_DRAW);
    gl.glVertexAttribPointer(3, 3, GL.GL_FLOAT, false, 0, 0);
    gl.glEnableVertexAttribArray(3);
    gl.glVertexAttribDivisor(3, 1);
  }

  void unbindBuffers() {
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
    gl.glVertexAttribDivisor(1, 0);
    gl.glVertexAttribDivisor(2, 0);
    gl.glVertexAttribDivisor(3, 0);
  }

  public void disposeBuffers() {
    int[] buffers = {this.offsetVBO, this.colorVBO, this.sizeVBO};
    ((PJOGL)pgl).gl.glDeleteBuffers(1, buffers, 0);
  }

  TensorVisualizer copy() {
    // 새로 생성된 TensorVisualizer 객체
    TensorVisualizer copy = new TensorVisualizer(this.tensor, this.centerPos.copy(), this.spacing, this.boxSize);

    // 복제할 속성들
    copy.animationStage = this.animationStage;
    copy.idxFlatSrc = this.idxFlatSrc;
    copy.idxFlatTrg = this.idxFlatTrg;

    // Box 배열 복사
    for (int i = 0; i < this.boxes.length; i++) {
      copy.boxes[i] = this.boxes[i].copy(); // Box 클래스에 copy 메서드가 있어야 합니다.
    }

    return copy;
  }


  void setIdxFlat(int idxFlatSrc, int idxFlatTrg) {
    this.idxFlatSrc = idxFlatSrc;
    this.idxFlatTrg = idxFlatTrg;
  }

  private void createBoxes(int[] indices, int dim, PVector boxSize) {
    if (dim == this.tensor.getShape().getNumDimensions()) {
      PVector pos = new PVector();
      int boxIndex = getIndex(this.tensor.shape, indices);
      if (this.tensor.getShape().getNumDimensions() == 3) {
        int halfX = (this.tensor.getShape().get(1)) / 2;
        int halfY = (this.tensor.getShape().get(2)) / 2;
        int halfZ = (this.tensor.getShape().get(0)) / 2;
        float x = map(indices[1], 0, this.tensor.getShape().get(1) - 1, -halfX * spacing, halfX * spacing);
        float y = map(indices[2], 0, this.tensor.getShape().get(2) - 1, -halfY * spacing, halfY * spacing);
        float z = map(indices[0], 0, this.tensor.getShape().get(0) - 1, -halfZ * spacing, halfZ * spacing);
        pos.x = y;
        pos.y = x;
        pos.z = z;
      } else if (this.tensor.getShape().getNumDimensions() == 2) {
        int halfX = (this.tensor.getShape().get(0) - 1) / 2;
        int halfY = (this.tensor.getShape().get(1) - 1) / 2;
        float x = map(indices[0], 0, this.tensor.getShape().get(0) - 1, -halfX * spacing, halfX * spacing);
        float y = map(indices[1], 0, this.tensor.getShape().get(1) - 1, -halfY * spacing, halfY * spacing);
        pos.x = y;
        pos.y = x;
      } else {
        int halfX = (this.tensor.getShape().get(0) - 1) / 2;
        float x = map(indices[0], 0, this.tensor.getShape().get(0) - 1, -halfX * spacing, halfX * spacing);
        pos.x = x;
      }
      pos.add(this.centerPos);
      if (this.boxStartSize == null) {
        boxes[boxIndex] = new Box(indices.clone(), this.tensor, pos.copy(), pos.copy(), boxSize, boxSize);
      } else {
        boxes[boxIndex] = new Box(indices.clone(), this.tensor, pos.copy(), pos.copy(), this.boxStartSize, boxSize);
      }
      return;
    }

    for (int i = 0; i < this.tensor.getShape().get(dim); i++) {
      indices[dim] = i;
      createBoxes(indices, dim + 1, boxSize); // 다음 차원으로 이동
    }
  }

  void setTensor(Tensor tensor) {
    if (!(tensor.getShape().getTotalSize() == this.tensor.getShape().getTotalSize())) {
      throw new IllegalArgumentException("Shape of the new tensor must match the shape of the visualizer tensor");
    }
    Tensor squeezed = tensor.squeeze();
    this.tensor.shape = squeezed.shape;
    this.tensor.data = squeezed.data;
  }

  void setTrgPos(TensorVisualizer tv) {
    if (!(tv.tensor.data.length == this.tensor.data.length)) {
      throw new IllegalArgumentException("Shape of the new tensor must match the shape of the visualizer tensor");
    }
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].frameStart = frameCount;
      this.boxes[i].setTrgPos(tv.boxes[i].getTrgPos());
    }
  }

  void setCurSize(PVector size) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].setCurSize(size);
    }
  }

  void setTrgSize(PVector size) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].setTrgSize(size);
    }
  }

  void setCurVal(TensorVisualizer tv) {
    if (!(tv.tensor.data.length == this.tensor.data.length)) {
      throw new IllegalArgumentException("Shape of the new tensor must match the shape of the visualizer tensor");
    }
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].setCurVal(tv.boxes[i].getVal());
    }
  }

  void setTrgPos(Box box) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].frameStart = frameCount;
      this.boxes[i].setOrgSize(this.boxes[i].getTrgSize());
      this.boxes[i].setOrgPos(this.boxes[i].getTrgPos());
      this.boxes[i].setTrgPos(box.getTrgPos());
      this.boxes[i].setTrgBox(box);
    }
  }

  void setCurPosOffset(PVector offset) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].curPos.add(offset);
    }
  }

  void setAnimationDuration(int duration) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].setAnimationDuration(duration);
    }
  }

  void setTrgPosOffset(PVector offset) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].trgPos.add(offset);
    }
  }

  void setVisible(boolean visiblity) {
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].setVisible(visiblity);
    }
  }

  int getAnimationStage() {
    return this.animationStage;
  }

  void setAnimationStage(int stage) {
    this.animationStage = stage;
  }

  boolean isAnimationComplete() {
    for (Box box : boxes) {
      if (!box.isCloseEnough()) {
        return false;
      }
    }
    return true;
  }

  void update() {
    for (Box box : boxes) {
      box.update();
    }
  }

  void draw() {
    //for (Box box : boxes) {
    //  box.draw();
    //}
    for (int i = 0; i < boxes.length; i++) {
      this.offsets[i * 3 + 0] = boxes[i].curPos.x;
      this.offsets[i * 3 + 1] = boxes[i].curPos.y;
      this.offsets[i * 3 + 2] = boxes[i].curPos.z;

      this.colors[i * 4 + 0] = boxes[i].curVal.x;
      this.colors[i * 4 + 1] = boxes[i].curVal.y;
      this.colors[i * 4 + 2] = boxes[i].curVal.z;
      this.colors[i * 4 + 3] = boxes[i].isVisible ? 1.0f : 0.0f;


      this.sizes[i * 3 + 0] = boxes[i].curSize.x;
      this.sizes[i * 3 + 1] = boxes[i].curSize.y;
      this.sizes[i * 3 + 2] = boxes[i].curSize.z;
    }
    bindBuffers();
    gl.glDrawElementsInstanced(GL.GL_TRIANGLES, boxGL.indices.length, GL.GL_UNSIGNED_INT, 0, offsets.length/3);
    unbindBuffers();
  }
}
