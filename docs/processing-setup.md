# Processing setup

This repo is easiest to use from the Processing IDE with each sketch opened as its
own project.

## Base install

1. Install Processing 3.x.
2. Open `Sketch -> Import Library -> Add Library...`.
3. Install the libraries used in this repo:
   - `processing.video`
   - `ControlP5`
   - `Minim`

## Sketch setup matrix

| Sketch | Needs bundled asset | Needs user asset | Needs library |
| --- | --- | --- | --- |
| `ChannelShiftGlitch` | No | `data/MyImage.jpg` unless renamed in code | None |
| `GlitchSort_v01b10` | No | Open an image at runtime with `o` | `ControlP5`, `Minim` |
| `Transform_Landscape` | `data/nasa-iceberg.jpg` | Optional replacement image | None |
| `Transform_SlitScan` | `data/station.mov` | Optional replacement movie | `processing.video` |
| `UnifiedGlitchLab` | Generated mode only | Optional `data/source.jpg`, `data/source.mov`, or webcam | `processing.video` |
| `noise_glitch` | `data/smallsnarl.jpg` | Optional replacement image | None |
| `video_glitch` | No | `data/bath.mov` unless renamed in code | `processing.video` |
| `webcam_glitch` | Live camera | Camera access | `processing.video` |

## Recommended repo check

Run this from the repo root:

```bash
python3 scripts/validate_repo.py
```

That script does not compile sketches. It verifies repo integrity: entry files,
README files, bundled media, and sketch-specific setup notes.

## Practical notes

- `GlitchSort_v01b10` is legacy Processing code. Keep Processing 2 available if you
  want the least friction with that sketch.
- `video_glitch` and `webcam_glitch` use arrow keys plus `TAB` and `ENTER` to change
  behavior while running.
- Several sketches write output files next to the sketch when you save or export, so
  expect generated images to appear in sketch directories during use.
