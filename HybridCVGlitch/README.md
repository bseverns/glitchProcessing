# HybridCVGlitch workshop notes

`HybridCVGlitch` combines the two CV ideas in the repo instead of keeping them separate. It measures local contour strength and direction like `ContourFieldGlitch`, measures per-cell frame change like `MotionCVGlitch`, and then blends those signals so motion decides when the picture destabilizes while contours decide where the RGB shear and torn lines align.

## Quick start

1. Install `processing.video`, plug in a camera, and run the sketch.
2. Move in front of strong edges such as text, hands, faces, or high-contrast objects. Static edges alone produce structure; motion through those edges makes the glitch activate more aggressively.
3. Use `LEFT` and `RIGHT` to change analysis cell size, `UP` and `DOWN` to tune the hybrid activation threshold, and `[` / `]` to change temporal history depth.
4. Press `F` and `V` to adjust RGB offset, `T` and `G` to change tear range, `M` to show the analysis overlay, `R` to reseed the noise field, and `S` to save a frame.

## Teaching highlights

- **Competing CV signals:** `updateHybridField(...)` computes both edge strength and motion strength on the same grid, then blends them into one activation map. This is useful for showing that “computer vision data” is often just a stack of interpretable signals.
- **Division of labor:** `applyHybridTemporalShift(...)` uses motion to deepen temporal lag while using contour direction to orient channel offsets. The result feels more intentional than either signal alone.
- **Conditional tearing:** `applyHybridScanlines(...)` only tears where the blended activation is high enough, so the image breaks hardest where movement intersects meaningful structure.
- **Overlay for critique:** The analysis overlay helps students debug why some regions break apart and others stay stable, which makes it easier to talk about thresholding and weighting choices.

## Remix prompts

- Change the edge/motion weighting so static contours dominate or, conversely, so only movement matters.
- Introduce face detection and multiply the hybrid activation inside face regions only.
- Turn the activation map into a mask that switches between several glitch strategies instead of only one.
