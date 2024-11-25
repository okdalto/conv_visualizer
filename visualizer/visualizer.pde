import com.jogamp.opengl.*;
import processing.opengl.*;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;
import oscP5.*;
import peasy.*;
PeasyCam cam;

Tensor tensor;
Conv2D conv1;
Conv2D conv2;
Conv2D conv3;
Conv2D conv4;
MLP mlp1;
MLP mlp2;

Tensor inputTensor;
TensorVisualizer tv1;
TensorVisualizer tv2;
TensorVisualizer tv3;
TensorVisualizer tv4;
TensorVisualizer tv5;
TensorVisualizer tv6;
TensorVisualizer tv7;
TensorVisualizer tv8;
TensorVisualizer tv9;

Conv2DVisualizer cv1;
Conv2DVisualizer cv2;
Conv2DVisualizer cv3;
Conv2DVisualizer cv4;

ReshapeVisualizer rv;

MLPVisualizer mv1;
MLPVisualizer mv2;

PGraphics canvas;

PVector convBoxSize = new PVector(12, 12, 12);
PVector mlpBoxSize = new PVector(4, 12, 12);

OscP5 oscP5;
PJOGL pgl;
GL4 gl;
BoxGL boxGL;
Shader instanceShader;
Shader outlineShader;


void settings() {
  size(600, 600, P3D);
  fullScreen(P3D, 2);
}

void setup() {
  frameRate(120);
  noCursor();
  cam = new PeasyCam(this, 400);

  pgl = (PJOGL)beginPGL();
  gl = pgl.gl.getGL4();

  boxGL = new BoxGL(gl);
  instanceShader = new Shader(gl, "instancing.frag", "instancing.vert");
  outlineShader = new Shader(gl, "outline.frag", "outline.vert");

  OscProperties op = new OscProperties();
  op.setListeningPort(12000);
  op.setDatagramSize(10000);
  oscP5 = new OscP5(this, op);

  //noSmooth();
  canvas = createGraphics(32, 32);
  canvas.beginDraw();
  canvas.background(0);
  canvas.endDraw();

  cam = new PeasyCam(this, 400);
  //inputTensor = new Tensor(1, 1, 32, 32);
  inputTensor = parseConvWeightsToTensor(loadStrings("randomTensor.txt"));

  conv1 = new Conv2D("conv1Weight.txt", "conv1Bias.txt");
  conv2 = new Conv2D("conv2Weight.txt", "conv2Bias.txt");
  conv3 = new Conv2D("conv3Weight.txt", "conv3Bias.txt");
  conv4 = new Conv2D("conv4Weight.txt", "conv4Bias.txt");
  mlp1 = new MLP("mlp1Weight.txt", "mlp1Bias.txt", true);
  mlp2 = new MLP("mlp2Weight.txt", "mlp2Bias.txt", false);

  Tensor conv1Result = conv1.forward(inputTensor);
  Tensor conv2Result = conv2.forward(conv1Result);
  Tensor conv3Result = conv3.forward(conv2Result);
  Tensor conv4Result = conv4.forward(conv3Result);
  Tensor flattened = conv4Result.clone();
  flattened._reshape(flattened.getShape().getTotalSize(), 1);

  Tensor mlp1Result = mlp1.forward(flattened);
  Tensor mlp2Result = mlp2.forward(mlp1Result);

  Tensor result = softmax(mlp2Result);

  tv1 = new TensorVisualizer(inputTensor, new PVector(0, 0, -1500), 20, convBoxSize);
  tv1.setVisible(true);
  tv2 = new TensorVisualizer(conv1Result, new PVector(0, 0, -1100), 20, convBoxSize);
  //tv2.setVisible(true);
  tv3 = new TensorVisualizer(conv2Result, new PVector(0, 0, -500), 20, convBoxSize);
  //tv3.setVisible(true);
  tv4 = new TensorVisualizer(conv3Result, new PVector(0, 0, 250), 20, convBoxSize);
  //tv4.setVisible(true);
  tv5 = new TensorVisualizer(conv4Result, new PVector(0, 0, 1000), 20, convBoxSize);
  //tv5.setVisible(true);
  tv6 = new TensorVisualizer(flattened, new PVector(0, 0, 1500), 6, mlpBoxSize);
  //tv6.setVisible(true);
  tv7 = new TensorVisualizer(mlp1Result, new PVector(0, 0, 1600), 6, mlpBoxSize);
  //tv7.setVisible(true);
  tv8 = new TensorVisualizer(result, new PVector(0, 0, 1700), 80, mlpBoxSize);
  //tv8.setVisible(true);


  mv2 = new MLPVisualizer(mlp2, tv7, tv8);
  mv1 = new MLPVisualizer(mlp1, tv6, tv7);
  mv1.setNextAnimation(mv2);

  rv = new ReshapeVisualizer(tv5, tv6);
  rv.setNextAnimation(mv1);
  rv.setState(loadCameraState("camstate_5.ser"));

  cv4 = new Conv2DVisualizer(conv4, tv4, tv5, 1);
  cv4.setNextAnimation(rv);
  cv4.setState(loadCameraState("camstate_4.ser"));
  cv3 = new Conv2DVisualizer(conv3, tv3, tv4, 2);
  cv3.setNextAnimation(cv4);
  cv3.setState(loadCameraState("camstate_3.ser"));
  cv2 = new Conv2DVisualizer(conv2, tv2, tv3, 2);
  cv2.setNextAnimation(cv3);
  cv2.setState(loadCameraState("camstate_2.ser"));
  cv1 = new Conv2DVisualizer(conv1, tv1, tv2, 16);
  cv1.setNextAnimation(cv2);
  cv1.setState(loadCameraState("camstate_1.ser"));
  //cv1.start();
}

void draw() {
  Tensor conv1Result = conv1.forward(inputTensor);
  Tensor conv2Result = conv2.forward(conv1Result);
  Tensor conv3Result = conv3.forward(conv2Result);
  Tensor conv4Result = conv4.forward(conv3Result);
  Tensor flattened = conv4Result.clone();
  flattened._reshape(flattened.getShape().getTotalSize(), 1);

  Tensor mlp1Result = mlp1.forward(flattened);
  Tensor mlp2Result = mlp2.forward(mlp1Result);

  Tensor result = softmax(mlp2Result);

  tv1.setTensor(inputTensor);
  tv2.setTensor(conv1Result);
  tv3.setTensor(conv2Result);
  tv4.setTensor(conv3Result);
  tv5.setTensor(conv4Result);
  tv6.setTensor(flattened);
  tv7.setTensor(mlp1Result);
  tv8.setTensor(result);

  background(0);

  beginPGL();
  outlineShader.useShader();
  gl.glEnable(GL4.GL_CULL_FACE);
  gl.glCullFace(GL4.GL_FRONT);  // 앞면을 컬링
  boxGL.bindBuffers();
  tv1.draw();
  tv2.draw();
  tv3.draw();
  tv4.draw();
  tv5.draw();
  tv6.draw();
  tv7.draw();
  tv8.draw();

  cv1.draw();
  cv2.draw();
  cv3.draw();
  cv4.draw();

  rv.draw();

  mv1.draw();
  mv2.draw();

  instanceShader.useShader();
  gl.glCullFace(GL4.GL_BACK);  // 뒷면을 컬링
  boxGL.bindBuffers();
  tv1.draw();
  tv2.draw();
  tv3.draw();
  tv4.draw();
  tv5.draw();
  tv6.draw();
  tv7.draw();
  tv8.draw();

  cv1.draw();
  cv2.draw();
  cv3.draw();
  cv4.draw();

  rv.draw();

  mv1.draw();
  mv2.draw();

  drawAnswers(tv8);

  endPGL();

  tv1.update();
  tv2.update();
  tv3.update();
  tv4.update();
  tv5.update();
  tv6.update();
  tv7.update();
  tv8.update();
  cv1.update();
  cv2.update();
  cv3.update();
  cv4.update();
  rv.update();
  mv1.update();
  mv2.update();

}

void keyPressed() {
  if (key == 'c') {
    reset();
  }
  if (Character.isDigit(key)) {
    saveCameraState(key);
  }
  switch (key) {
  case 'q':
    loadCameraState('1');
    break;
  case 'w':
    loadCameraState('2');
    break;
  case 'e':
    loadCameraState('3');
    break;
  case 'r':
    loadCameraState('4');
    break;
  case 't':
    loadCameraState('5');
    break;
  case 'y':
    loadCameraState('6');
    break;
  case 'u':
    loadCameraState('7');
    break;
  case 'i':
    loadCameraState('8');
    break;
  case 'o':
    loadCameraState('9');
    break;
  case 'p':
    loadCameraState('0');
    break;
  default:
    break;
  }
}

void reset() {
  tv2.setVisible(false);
  tv3.setVisible(false);
  tv4.setVisible(false);
  tv5.setVisible(false);
  tv6.setVisible(false);
  tv7.setVisible(false);
  tv8.setVisible(false);

  cv1.reset();
  cv2.reset();
  cv3.reset();
  cv4.reset();

  rv.reset();

  mv1.reset();
  mv2.reset();

  cv1.start();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  for (int i = 0; i < theOscMessage.typetag().length(); i++) {
    inputTensor.set(float(theOscMessage.get(i).intValue() >> 16 & 0xFF) / 255.0, 0, 0, i/32, i%32);
  }
  reset();
}
