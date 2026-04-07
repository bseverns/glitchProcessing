# glitchProcessing

`glitchProcessing` is a small collection of Processing sketches for pixel sorting,
channel shifting, slit-scan video, image-to-landscape transforms, and live camera
glitching. Each top-level sketch folder is intended to open directly in the
Processing IDE.

## What is in here

| Sketch | Focus | Bundled input | Extra setup |
| --- | --- | --- | --- |
| `ChannelShiftGlitch` | RGB channel displacement on still images | No | Add `data/MyImage.jpg` or change the filename in code |
| `ContourFieldGlitch` | Webcam contour analysis driving temporal RGB shears and local scanline tears | Live camera | Install `processing.video` |
| `GlitchSort_v01b10` | Pixel sorting workstation with UI and FFT tools | Runtime file picker | Install `ControlP5` and `Minim` |
| `HybridCVGlitch` | Webcam hybrid of contour and motion analysis driving temporal shear and torn scanlines | Live camera | Install `processing.video` |
| `MotionCVGlitch` | Webcam motion analysis driving temporal RGB lag and torn scanlines | Live camera | Install `processing.video` |
| `ScanlineTearGlitch` | Horizontal scanline tearing with channel desync | Generated source; optional `data/source.jpg` | None |
| `Transform_Landscape` | Image brightness mapped into 3D geometry | `data/nasa-iceberg.jpg` | None |
| `Transform_SlitScan` | Slit-scan video sampling | `data/station.mov` | Install `processing.video` |
| `UnifiedGlitchLab` | Unified glitch instrument with generated, image, movie, and webcam sources | Generated mode works immediately | Install `processing.video`; optional `data/source.jpg` and `data/source.mov` |
| `noise_glitch` | Collage-style still image glitches | `data/smallsnarl.jpg` | None |
| `video_glitch` | Thresholded bit-shift glitches on video | No | Install `processing.video` and add `data/bath.mov` |
| `webcam_glitch` | Live webcam version of `video_glitch` | Live camera | Install `processing.video` |

## Quick start

1. Install Processing 3.x.
2. Open the Contributions Manager and install the libraries used by the sketches you want:
   `processing.video`, `ControlP5`, and `Minim`.
3. Open a sketch folder in Processing and run its `.pde` entry file.
4. If a sketch expects user media, place it in that sketch's `data/` folder first.

## Repo validation

Run the repo check before teaching from the sketches or cleaning up the tree:

```bash
python3 scripts/validate_repo.py
```

The validator checks that each sketch still has its entry file, README, and bundled
assets. It also reports any sketch-specific manual setup, such as user-supplied
images or required Processing libraries.

## Notes

- `GlitchSort_v01b10` is older code written for Processing 2 and still works best there,
  though the rest of the repo is straightforward to explore from Processing 3.
- `ChannelShiftGlitch` and `video_glitch` now include placeholder `data/` folders so
  the expected input location is explicit.
- `ContourFieldGlitch` and `MotionCVGlitch` are complementary CV examples: one follows
  contours, the other follows motion.
- `HybridCVGlitch` merges both signals on one grid so you can teach weighting,
  thresholds, and competing control data without adding another library.
- `MotionCVGlitch` uses simple frame differencing rather than an external OpenCV
  library, so it stays easy to teach from a stock Processing + `processing.video` setup.
- `ScanlineTearGlitch` runs without assets by generating its own source art, but you can
  drop in `data/source.jpg` to make it a still-image exercise.
- See [docs/processing-setup.md](/Users/bseverns/Documents/GitHub/glitchProcessing/docs/processing-setup.md)
  for a slightly more detailed setup checklist.
