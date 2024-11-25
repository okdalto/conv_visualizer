import oscP5.*;
import netP5.*;
PGraphics pg;

int prevMouseX = -1;
int prevMouseY = -1;

OscP5 oscP5;
NetAddress myRemoteLocation;
Button sendButton;

int canvasX = 700;
int canvasY = 650;
int canvasW = 500;
int canvasH = 500;

int canvasLeft = canvasX - canvasW/2;
int canvasRight = canvasX + canvasW/2;
int canvasTop = canvasY - canvasH/2;
int canvasBottom = canvasY + canvasH/2;

PFont font;

void setup() {
  fullScreen(1);
  //font = createFont("NotoSansKR-Bold.ttf", 32); // 맑은 고딕 사용 예시
  //textFont(font);
  /* start oscP5, listening for incoming messages at port 12000 */
  OscProperties op = new OscProperties();
  op.setListeningPort(12000);
  op.setDatagramSize(10000);
  oscP5 = new OscP5(this, op);

  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  pg = createGraphics(32, 32);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();


  int buttonWidth = 300;
  int buttonHeight = 100;
  int buttonLeft = height + (width-height)/2 - buttonWidth/2;
  int buttonTop = height/2 - buttonHeight/2;

  sendButton = new Button(buttonLeft, buttonTop, buttonWidth, buttonHeight, "Predict", new Runnable() {
    public void run() {
      println("Button Clicked!");
      send();
    }
  }
  );
}


void draw() {
  pg.beginDraw();
  if (mousePressed) {
    if (prevMouseX == -1) {
      prevMouseX = mouseX;
      prevMouseY = mouseY;
    }
    pg.stroke(255);
    pg.strokeWeight(2.4);
    pg.line(
      32*map(mouseX, canvasLeft, canvasRight, 0, 1),
      32*map(mouseY, canvasTop, canvasBottom, 0, 1),
      32*map(prevMouseX, canvasLeft, canvasRight, 0, 1),
      32*map(prevMouseY, canvasTop, canvasBottom, 0, 1)
      );
    prevMouseX = mouseX;
    prevMouseY = mouseY;
  }
  pg.endDraw();

  background(0);


  image(pg, canvasLeft, canvasTop, canvasW, canvasH);
  stroke(255);
  int strokeWeightValue = 6;
  strokeWeight(strokeWeightValue);
  noFill();
  rect(canvasLeft, canvasTop, canvasW, canvasH);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("Draw a number between 0 and 9 below. \n The network will classify the number you wrote.\n\n아래의 네모 칸에 0에서 9사이의 숫자를 하나 그려보세요.\n 네트워크가 당신이 쓴 숫자를 분류합니다.", canvasX, canvasY - canvasH/2 - 150);

  sendButton.display();
}

void mousePressed() {
  sendButton.checkClick();
}

void mouseReleased() {
  sendButton.resetClick();
  prevMouseX = -1;
  prevMouseY = -1;
}

void send() {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/test");

  pg.loadPixels();
  myMessage.add(pg.pixels); /* add an int array to the osc message */
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);

  pg.beginDraw();
  pg.background(0);
  pg.endDraw();
}
