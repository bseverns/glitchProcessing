# MotionCVGlitch workshop notes

`MotionCVGlitch` uses lightweight computer-vision analysis instead of only raw pixels. It compares the current webcam frame to the previous one, measures motion band-by-band, then uses that motion signal to decide how much temporal RGB lag and scanline tearing to inject.

## Quick start

1. Install `processing.video`, plug in a camera, and run the sketch.
2. Move slowly and then sharply in front of the lens. Calm motion keeps the image relatively coherent; bigger motion pulls older frames into the red, green, and blue channels and triggers torn scanline segments.
3. Use `[` and `]` to change the temporal history depth, `LEFT`/`RIGHT` to change band height, and `UP`/`DOWN` to tune how sensitive the motion detector is.
4. Press `T` and `G` to shrink or expand the tear offset, `M` to show the motion overlay, `R` to reseed the tear field, and `S` to save a frame.

## Teaching highlights

- **Frame differencing as CV:** `updateMotion(...)` computes a simple motion signal by comparing channel energy in the current frame and the previous frame. That makes this a useful introduction to computer vision without adding an OpenCV dependency.
- **Motion as control data:** The sketch does not glitch everything equally. High-motion bands get deeper temporal lag and more aggressive scanline tears, which is a good demonstration of using analysis data to drive aesthetics.
- **Temporal channel desync:** `applyTemporalRgbLag(...)` pulls red, green, and blue from different moments in the frame history. Students can see that time offsets can be treated exactly like spatial channel offsets.
- **Irregular scanlines:** `applyIrregularScanlines(...)` creates short torn segments with randomized starts, lengths, and horizontal offsets. This gives a more broken-broadcast feel than shifting entire rows uniformly.

## Remix prompts

- Replace the band-based motion average with a grid so different screen regions can glitch independently.
- Use contour or face detection from an external CV library and only tear rows intersecting those regions.
- Feed the motion score into audio, lighting, or projection systems so movement becomes a control signal for a larger performance setup.
