# Transform_Landscape teaching notes

This sketch extrudes an image into a rotating 3D landscape by mapping pixel brightness to depth. It’s straight from *Form+Code* and still a killer example for blending image processing with geometry.

## Run it

1. Confirm `nasa-iceberg.jpg` (or your replacement) lives in the `data/` folder.【F:Transform_Landscape/Transform_Landscape.pde†L19-L34】
2. Hit **Run**. The sketch loads the pixels into a `values[][]` buffer, sets up an OpenGL window, and spins the structure so you can study the form from every angle.【F:Transform_Landscape/Transform_Landscape.pde†L19-L59】

## Talking points

- **Brightness sampling:** `brightness(pixel)` is converted to integers and stored in a 2D array. Pause here to discuss nested loops, coordinate order (`values[x][y]`), and why we precompute instead of recalculating per frame.【F:Transform_Landscape/Transform_Landscape.pde†L25-L34】
- **3D transforms:** Highlight `translate`, `scale`, and `rotateY` to explain how Processing handles scene graphs. Changing `angle += 0.005` affects rotation speed—hand the keyboard to students to experiment.【F:Transform_Landscape/Transform_Landscape.pde†L39-L46】
- **Line mesh:** Each pair of points draws a short vertical line; shrinking the loop step (currently `+= 2`) increases resolution while impacting performance, which sets up a discussion about trade-offs.【F:Transform_Landscape/Transform_Landscape.pde†L47-L59】

## Extensions

- Replace `line` with `point` or `box` to compare rendering costs.
- Normalize brightness values to control the height range explicitly.
- Export the geometry data to teach interoperability with other 3D tools.
