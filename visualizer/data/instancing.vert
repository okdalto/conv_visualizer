#version 400 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 instanceOffset;
layout (location = 2) in vec4 instanceColor;
layout (location = 3) in vec3 instanceSize;

uniform mat4 transform;
out vec4 vertexColor;
void main() {
  gl_Position = transform * vec4(aPos * instanceSize * (0.5) + instanceOffset, 1.0);
  vertexColor = instanceColor;
}
