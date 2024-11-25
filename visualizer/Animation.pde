public abstract class Animation {
  boolean isComplete = true;
  CameraState state;
  protected Animation nextAnimation; // 다음 애니메이션

  public Animation() {
  }

  public void setState(CameraState state) {
    this.state = state;
  }

  // 애니메이션을 시작하는 메소드
  public void start() {
    resetAnimation(); // 애니메이션을 리셋하고
    startAnimation(); // 시작 로직을 수행
    if (state != null) {
      cam.setState(state, 400);
    }
  }

  // 애니메이션을 리셋하는 메소드
  public void reset() {
    resetAnimation(); // 추가적인 리셋 로직이 필요한 경우 구현
  }

  // 상속받은 클래스에서 구현될 리셋 로직
  protected abstract void resetAnimation();

  // 상속받은 클래스에서 구현될 시작 로직
  protected abstract void startAnimation();

  // 애니메이션 업데이트 메소드
  public abstract void update();

  // 애니메이션이 완료되었는지 확인하는 메소드
  public boolean isComplete() {
    return isComplete;
  }

  // 다음 애니메이션을 설정하는 메소드
  public void setNextAnimation(Animation nextAnimation) {
    this.nextAnimation = nextAnimation;
  }

  public void endAnimation() {
    isComplete = true;
    resetAnimation();
    if (this.nextAnimation != null)
      nextAnimation.start();
  }
}
