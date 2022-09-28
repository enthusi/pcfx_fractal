# PCFX Mandelbrot
fractal Mandelbrot on PC-FX\
A Mandelbrot explorer fully written in v810 assembly.

## Controls
use ```button 1/2``` to adjust the number of iterations per pixel
use ```button 3/4``` to zoom in/out
use ```Controller``` pad for moving around

To build just type ```make``` given that you have the following tools in your path:
[v810 binutils](https://github.com/jbrandwood/v810-gcc)
[pcfx-tools](https://github.com/jbrandwood/pcfxtools)

## Technical details
- the palette based color cycle runs in 7upA vblank
- the 'decorative' border gfx is lz4 compressed
- the mandelbrot routine uses 32bit fixpoint math
- two 256color bitmap layers are being used here
- debugging using code upload via microcontroller to joystick port

YouTube recording:
[![Mandelbrot by PriorArt](http://img.youtube.com/vi/wd7M3JLtAvQ/0.jpg)](http://www.youtube.com/watch?v=wd7M3JLtAvQ "Mandelbrot by PriorArt")

## Credits
- code: *Martin 'enthusi' Wendt
