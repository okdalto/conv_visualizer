class Box {
  int[] indices;
  Tensor tensor;
  PVector orgPos;
  PVector curPos;
  PVector trgPos;
  PVector orgSize;
  PVector curSize;
  PVector trgSize;
  PVector orgVal;
  PVector curVal;

  boolean isVisible = false;
  float damping = 0.2;  // 감쇄 계수
  float eps = 5.0;  //
  Box trgBox;

  int frameStart;
  int frameDuration;

  // 생성자
  Box(int[] indices, Tensor tensor, PVector startPos, PVector endPos, PVector startSize, PVector endSize) {
    this.indices = indices;
    this.tensor = tensor;
    this.orgPos = startPos;
    this.curPos = startPos;
    this.trgPos = endPos;
    this.orgSize = startSize;
    this.curSize = startSize;
    this.trgSize = endSize;
    this.orgVal = new PVector();
    this.curVal = new PVector();

    this.frameStart = frameCount;
    this.frameDuration = 50;
  }

  Box copy() {
    Box copiedBox = new Box(
      this.indices.clone(), // indices 배열 복사
      this.tensor, // Tensor는 참조 복사 (깊은 복사가 필요하면 tensor.copy() 등으로 변경)
      this.orgPos.copy(), // PVector는 copy()를 통해 복사
      this.trgPos.copy(),
      this.orgSize.copy(),
      this.trgSize.copy()
      );

    // 기타 필드 복사
    copiedBox.curPos = this.curPos.copy();
    copiedBox.curSize = this.curSize.copy();
    copiedBox.orgVal = this.orgVal.copy();
    copiedBox.curVal = this.curVal.copy();
    copiedBox.isVisible = this.isVisible;
    copiedBox.damping = this.damping;
    copiedBox.eps = this.eps;
    copiedBox.frameStart = this.frameStart;
    copiedBox.frameDuration = this.frameDuration;

    // trgBox는 null이 아닌 경우 copy해서 설정
    copiedBox.trgBox = (this.trgBox != null) ? this.trgBox.copy() : null;

    return copiedBox;
  }

  PVector getOrgPos() {
    return orgPos;
  }

  void setOrgPos(PVector pos) {
    orgPos = pos;
  }


  PVector getCurPos() {
    return curPos;
  }

  void setCurPos(PVector pos) {
    curPos = pos;
  }

  PVector getTrgPos() {
    return trgPos;
  }

  void setTrgPos(PVector pos) {
    trgPos = pos;
  }


  PVector getOrgSize() {
    return orgSize;
  }

  void setOrgSize(PVector size) {
    orgSize = size;
  }

  PVector getCurSize() {
    return curSize;
  }

  void setCurSize(PVector size) {
    curSize = size;
  }

  PVector getTrgSize() {
    return trgSize;
  }

  void setTrgSize(PVector size) {
    trgSize = size;
  }

  void setTrgBox(Box box) {
    trgBox = box;
  }

  void setCurVal(float val) {
    curVal.x = val;
    curVal.y = val;
    curVal.z = val;
  }

  float getVal() {
    return this.tensor.get(this.indices);
  }

  void setAnimationDuration(int duration) {
    this.frameDuration = duration;
  }

  void update() {
    float easing = easeInOutCirc((float)(frameCount - this.frameStart) / (float)this.frameDuration);
    easing = min(easing, 1.0);
    curPos = PVector.lerp(orgPos, trgPos, easing);
    curSize = PVector.lerp(orgSize, trgSize, easing);
    float val;
    if (this.trgBox != null) {
      val = trgBox.getVal();
    } else {
      val = getVal();
    }
    PVector valDiff = PVector.sub(new PVector(val, val, val), curVal);
    valDiff.mult(damping);
    curVal.add(valDiff);
  }

  void setVisible(boolean visibility) {
    this.isVisible = visibility;
  }

  boolean isCloseEnough() {
    boolean isClose = PVector.dist(curPos, trgPos) < eps;
    if (isClose && this.trgBox != null) {
      this.trgBox.setVisible(true);
    }
    return isClose;
  }

  void draw() {
    if (isVisible) {
      pushMatrix();
      translate(curPos.x, curPos.y, curPos.z);
      //noStroke();
      strokeWeight(0.5);
      stroke(255);
      fill(curVal.x, curVal.y, curVal.z);
      box(curSize.x, curSize.y, curSize.z);
      popMatrix();
    }
  }
}


class BoxGL {
  GL4 gl;
  int posVBO, ebo;

  float[] positionData = {
    -1.0f, -1.0f, 1.0f, // Vertex 1
    1.0f, -1.0f, 1.0f, // Vertex 2
    -1.0f, 1.0f, 1.0f, // Vertex 3
    1.0f, 1.0f, 1.0f, // Vertex 4
    -1.0f, 1.0f, -1.0f, // Vertex 5
    1.0f, 1.0f, -1.0f, // Vertex 6
    -1.0f, -1.0f, -1.0f, // Vertex 7
    1.0f, -1.0f, -1.0f   // Vertex 8
  };

  int[] indices = {
    0, 1, 2, 1, 3, 2, // Front face
    2, 3, 4, 3, 5, 4, // Right face
    4, 5, 6, 5, 7, 6, // Back face
    6, 7, 0, 7, 1, 0, // Left face
    1, 7, 3, 7, 5, 3, // Top face
    6, 0, 4, 0, 2, 4  // Bottom face
  };


  BoxGL(GL4 gl) {
    this.gl = gl;
    setupBuffers();
  }

  void setupBuffers() {
    int[] buffers = new int[2];
    gl.glGenBuffers(2, buffers, 0);
    posVBO = buffers[0];
    ebo = buffers[1];

    setupVBO(posVBO, positionData, 0); // Setup position VBO
    setupEBO(ebo, indices);            // Setup Element Buffer Object

    unbindBuffers();
  }
  void unbindBuffers() {
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
    gl.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, 0);
  }

  void setupVBO(int bufferId, float[] data, int attributeIndex) {
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, bufferId);
    FloatBuffer buffer = FloatBuffer.wrap(data);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, data.length * Float.BYTES, buffer, GL.GL_STATIC_DRAW);
    gl.glVertexAttribPointer(attributeIndex, 3, GL.GL_FLOAT, false, 0, 0);
    gl.glEnableVertexAttribArray(attributeIndex);
  }

  void setupEBO(int bufferId, int[] indices) {
    gl.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, bufferId);
    IntBuffer buffer = IntBuffer.wrap(indices);
    gl.glBufferData(GL.GL_ELEMENT_ARRAY_BUFFER, indices.length * Integer.BYTES, buffer, GL.GL_STATIC_DRAW);
  }

  void bindAttribute(int bufferId, int index, int componentCount) {
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, bufferId);
    gl.glVertexAttribPointer(index, componentCount, GL.GL_FLOAT, false, 0, 0);
    gl.glEnableVertexAttribArray(index);
  }

  void bindBuffers() {
    bindAttribute(posVBO, 0, 3);
    gl.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, ebo);
  }

  public void dispose() {
    int[] buffers = {posVBO, ebo};
    gl.glDeleteBuffers(buffers.length, buffers, 0);
  }
}


class Shader {
  GL4 gl;
  PShader pshader;
  int shaderProgram;
  int transformLoc;

  Shader(GL4 gl, String fragPath, String vertPath) {
    this.gl = gl;
    pshader = loadShader(fragPath, vertPath);
    shader(pshader);
    shaderProgram = pshader.glProgram;
    transformLoc = gl.glGetUniformLocation(shaderProgram, "transform");
    resetShader();
  }

  void useShader() {
    gl.glUseProgram(shaderProgram);
    setTransformMatrix();
  }

  void endShader() {
    gl.glUseProgram(0);
  }

  void setTransformMatrix() {
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    // Get and combine modelview and projection matrices
    float[] modelviewArray = new float[16];
    pgl.modelview.get(modelviewArray);
    float[] projectionArray = new float[16];
    pgl.projection.get(projectionArray);

    PMatrix3D modelview = new PMatrix3D(
      modelviewArray[0], modelviewArray[1], modelviewArray[2], modelviewArray[3],
      modelviewArray[4], modelviewArray[5], modelviewArray[6], modelviewArray[7],
      modelviewArray[8], modelviewArray[9], modelviewArray[10], modelviewArray[11],
      modelviewArray[12], modelviewArray[13], modelviewArray[14], modelviewArray[15]
      );
    PMatrix3D projection = new PMatrix3D(
      projectionArray[0], projectionArray[1], projectionArray[2], projectionArray[3],
      projectionArray[4], projectionArray[5], projectionArray[6], projectionArray[7],
      projectionArray[8], projectionArray[9], projectionArray[10], projectionArray[11],
      projectionArray[12], projectionArray[13], projectionArray[14], projectionArray[15]
      );

    PMatrix3D transformMatrix = projection.get();
    transformMatrix.apply(modelview);
    transformMatrix.transpose();

    FloatBuffer transformBuffer = FloatBuffer.allocate(16);
    transformBuffer.put(new float[] {
      transformMatrix.m00, transformMatrix.m01, transformMatrix.m02, transformMatrix.m03,
      transformMatrix.m10, transformMatrix.m11, transformMatrix.m12, transformMatrix.m13,
      transformMatrix.m20, transformMatrix.m21, transformMatrix.m22, transformMatrix.m23,
      transformMatrix.m30, transformMatrix.m31, transformMatrix.m32, transformMatrix.m33
      });
    transformBuffer.rewind();

    gl.glUniformMatrix4fv(transformLoc, 1, false, transformBuffer);
  }
}
