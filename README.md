
# Convolution Visualization Project

![main image](https://github.com/okdalto/conv_visualizer/blob/main/assets/DSC00115.JPG?raw=true)

[![video](http://img.youtube.com/vi/gqsYY4LKwFI/0.jpg)](http://www.youtube.com/watch?v=gqsYY4LKwFI "CNN(Convolutional Neural Network) Visualization")

한국어로 된 제작기를 보고 싶다면 저의 [블로그](https://okdalto.github.io/%EC%9E%91%EC%97%85/%EC%BB%A8%EB%B3%BC%EB%A3%A8%EC%85%98-%EC%8B%9C%EA%B0%81%ED%99%94-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8/)를 방문해주세요

## Getting Started

This project is divided into two main parts:

1. **Drawing**:
   - Provides an interactive canvas for users to draw numbers or shapes.
   - Uses Open Sound Control (OSC) to send the drawn image to the visualization part.
   - Converts canvas pixel data into OSC messages and transmits it to a specified address and port.

2. **Visualization**:
   - Processes the image data received from the Drawing part.
   - Visualizes how neural network layers (e.g., convolutional and fully connected layers) process the input image step by step.

### Prerequisites
- **[Processing](https://processing.org/)**: For running the visualization.
- **[oscP5](https://www.sojamo.de/libraries/oscp5/)**: For communication between drawing program and the visualization program.
- **[PeasyCam](https://mrfeinberg.com/peasycam/)**: Required for the camera control.
  
### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/convolution-visualization.git
   ```
2. Install dependencies:
   - Processing with oscP5, peasycam libraries.
3. Run the Processing sketches.

## Introduction

AI is undoubtedly one of the hottest topics in the world today. NVIDIA's rise to Nasdaq's top spot, Nobel Prize recognition for AI pioneers, and nations prioritizing AI research all highlight its global importance. Graphics cards are now considered strategic assets, and discussions about AI dominate news, forums, and even casual conversations. Yet, how well do we really understand AI? What does it truly mean, and how does it work?

This project began as a deeply personal journey of discovery, rooted in curiosity and skepticism about the mechanics of neural networks. It has evolved into a comprehensive visualization tool designed to demystify AI, showcasing how simple mathematical operations come together to achieve incredible results.

---

## Motivation

### Starting Point
The project started when I began learning AI with the book *"Deep Learning from Scratch"*. Following its examples, I was both intrigued and skeptical: could a series of matrix multiplications and simple activation functions truly classify handwritten digits? It seemed too simple, so I decided to build everything from scratch, starting with matrix multiplication, to see it for myself.

### Development Challenges
- **Language Choice**: I chose Java with Processing for its simplicity and familiarity, but later realized its limitations for rendering-intensive tasks.
- **Separation of Training and Visualization**: Training was done in PyTorch, and the weights were exported to be visualized in Processing.
- **Core Operations**: Implemented matrix multiplication, activation functions, and softmax, validating every result against PyTorch outputs.

### Initial Success
When the core calculations worked as expected, it was a revelation. Simple arithmetic and elementary functions could indeed power a neural network. It was both humbling and awe-inspiring to realize how such basic building blocks could lead to sophisticated AI systems.

---

## Project Evolution

### Drawing and Visualization Separation
The project is divided into two main parts:
1. **Drawing**:
   - Provides a canvas for users to draw numbers or shapes.
   - The drawn image is sent to the visualizer using the OSC (Open Sound Control) protocol.
   - OSC messages carry pixel data from the canvas and send it over the network.
2. **Visualization**:
   - Visualizes neural network operations using the received image data.
   - Demonstrates each layer of the neural network (convolution, pooling, fully connected) visually.

### Adding Convolutional Layers
To improve performance, I introduced convolutional modules and data augmentation (e.g., affine transformations). Visualizing convolutional operations brought new challenges:
- Displaying how filters move across the input.
- Showing the connections between input, intermediate computations, and output layers.
- Animating the convolutional process for clarity.

### Reshaping and MLP Visualization
Following the convolutional layers:
- **Reshape Visualization**: Demonstrated how data transitions from convolutional outputs to flattened tensors for fully connected layers.
- **MLP Visualization**: Showed how weights and biases interact with flattened inputs through matrix multiplications.

---

## Overcoming Performance Issues

### Draw Call Bottleneck
Processing's rendering limitations became apparent with the growing number of visualized elements. Each box in the visualization required an individual draw call, significantly slowing down rendering.

### GPU Acceleration with OpenGL
To solve this:
- **Instancing**: Leveraged OpenGL instancing to render thousands of boxes efficiently with a single draw call.
- **Shaders**: Developed custom GLSL shaders for vertex and fragment operations, including techniques like normal-based outlines and backface culling for better visualization.
- **VBOs**: Used Vertex Buffer Objects to send position, size, and color data to the GPU.

---

## Results

The final tool is capable of:
1. **Visualizing Neural Network Layers**: Including convolutional layers, reshaping, and fully connected layers.
2. **Interactive Input**: Allows users to draw numbers and see the network's inference process in real-time.
3. **Efficient Rendering**: Handles thousands of visualized elements smoothly, thanks to OpenGL optimization.

---

## Lessons Learned

1. **Complexity in Simplicity**: AI is built on simple mathematical principles, yet these principles combine to achieve incredible complexity.
2. **Visualization as Communication**: Making AI understandable requires not only technical accuracy but also intuitive and clear presentation.
3. **Performance Engineering**: Balancing high-quality visuals with real-time interactivity is a challenging but rewarding task.

---

## Why This Matters

AI often feels like magic, but it's fundamentally a product of mathematics and engineering. By visualizing its inner workings, this project aims to:
- **Educate**: Help people understand the mechanics behind AI.
- **Inspire**: Showcase the beauty of the processes driving modern AI.

As Isaac Asimov once said, *"Any sufficiently advanced technology is indistinguishable from magic."* This project reveals the magic—and the science—behind AI.
