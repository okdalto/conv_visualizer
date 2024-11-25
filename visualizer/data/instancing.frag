#version 400 core
in vec4 vertexColor;
out vec4 FragColor;
void main() {
  if(vertexColor.a < 0.5) {
    discard;
  }
  FragColor = vertexColor;
}
