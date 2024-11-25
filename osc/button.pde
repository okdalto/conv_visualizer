class Button {
  float x, y, w, h;
  String text;
  color defaultColor, hoverColor, clickColor;
  boolean isHovered = false;
  boolean isClicked = false;
  Runnable action;

  // 생성자
  Button(float x, float y, float w, float h, String text, Runnable action) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
    this.action = action;

    defaultColor = color(200);  // 기본 색상 (회색)
    hoverColor = color(150);    // 호버 색상 (좀 더 어두운 회색)
    clickColor = color(100);    // 클릭 색상 (더 어두운 회색)
  }

  // 버튼 그리기
  void display() {
    // 마우스가 버튼 위에 있는지 확인
    isHovered = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;

    // 색상 설정
    if (isClicked) {
      fill(clickColor);
    } else if (isHovered) {
      fill(hoverColor);
    } else {
      fill(defaultColor);
    }

    // 버튼 그리기
    noStroke();
    rect(x, y, w, h);

    // 텍스트 그리기
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(50);
    text(text, x + w / 2, y + h / 2);
  }

  // 클릭 체크
  void checkClick() {
    if (isHovered && mousePressed) {
      isClicked = true;
      action.run();  // 설정된 기능 실행
    }
  }

  // 클릭 종료 후 원래 상태로 돌아가기
  void resetClick() {
    isClicked = false;
  }
}
