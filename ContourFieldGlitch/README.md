# ContourFieldGlitch workshop notes

`ContourFieldGlitch` analyzes the webcam image as a coarse edge field instead of treating the frame as raw texture. Each grid cell estimates local contour strength and direction, then uses that CV map to drive temporal RGB shearing and broken scanline segments.

## Quick start

1. Install `processing.video`, plug in a camera, and run the sketch.
2. Point the camera at high-contrast shapes, text, hands, or faces. Strong edges produce the clearest contour-driven glitches.
3. Use `LEFT` and `RIGHT` to change the analysis cell size, `UP` and `DOWN` to raise or lower the edge threshold, and `[` / `]` to change temporal history depth.
4. Press `F` and `V` to shrink or expand RGB offset, `T` and `G` to change scanline tear range, `M` to show the contour analysis overlay, `R` to reseed the noise field, and `S` to save a frame.

## Teaching highlights

- **Feature-map CV:** `updateContourField(...)` computes a local edge magnitude and direction per cell using brightness differences. That makes the analysis visible and discussable as a feature map rather than a black-box effect.
- **Direction-aware glitching:** `applyContourTemporalShift(...)` uses gradient direction to decide where red and blue channels sample from, so the RGB split follows local contour orientation instead of drifting uniformly.
- **Localized irregularities:** `applyContourScanlines(...)` only tears short line segments near strong contours or occasional random bands. This is a closer match to broken signal artifacts than shifting every row equally.
- **Overlay as debugging tool:** The analysis overlay draws the cell grid and local gradient vectors, which is useful for teaching how CV signals become aesthetic control data.

## Remix prompts

- Replace the simple brightness-gradient estimate with Sobel kernels or Canny edges.
- Add contour tracing and let only the longest contours trigger tearing.
- Combine this contour field with the motion field from `MotionCVGlitch` so edges and movement compete for control.
