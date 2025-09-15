# Transform_SlitScan workshop guide

Slit-scan processing samples the same column of video across time to paint a stretched panorama. This sketch is a tight example for teaching video input, pixel arrays, and event-driven rendering.

## Boot sequence

1. Drop a short movie named `station.mov` into the `data/` directory (or rename the file used in the constructor).【F:Transform_SlitScan/Transform_SlitScan.pde†L15-L29】
2. Run the sketch. The `movieEvent` callback reads frames as they arrive and flips the `newFrame` flag; the draw loop only runs when there’s fresh data to paint.【F:Transform_SlitScan/Transform_SlitScan.pde†L31-L52】

## Teaching hooks

- **Pixel indexing:** Explore how `setPixelIndex` and `getPixelIndex` are computed. Students can visualize the marching `draw_position_x` pointer and understand linearized image buffers.【F:Transform_SlitScan/Transform_SlitScan.pde†L36-L47】
- **Window limits:** Once the pointer hits `window_width`, the sketch exits. Use this to talk about guard clauses and why we bail after filling the buffer.【F:Transform_SlitScan/Transform_SlitScan.pde†L46-L49】
- **Parameter experiments:** Encourage learners to change `video_slice_x` or `window_width` and predict the resulting visuals—great for illustrating how constants translate into design decisions.【F:Transform_SlitScan/Transform_SlitScan.pde†L15-L52】

## Further exploration

- Swap `Movie` for `Capture` to slit-scan a webcam feed.
- Store completed frames to disk for stop-motion style animations.
- Animate the slice position over time for hybrid motion blur effects.
