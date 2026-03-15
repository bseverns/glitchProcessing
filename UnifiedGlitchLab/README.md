# UnifiedGlitchLab

`UnifiedGlitchLab` is a single Processing sketch that folds together the repo's
main ideas:

- channel shifting from `ChannelShiftGlitch`
- collage cut-up behavior from `noise_glitch`
- thresholded bit shifting from `video_glitch` / `webcam_glitch`
- temporal accumulation from `Transform_SlitScan`

It starts in a generated mode so it can run immediately, then lets you switch to
optional image, movie, or webcam inputs.

## Controls

- `1`: generated source
- `2`: load `data/source.jpg`
- `3`: load `data/source.mov`
- `4`: use the first available webcam
- `Q`: toggle channel shift
- `W`: toggle noise collage
- `E`: toggle bit shift
- `R`: toggle slit-scan accumulation
- `[` / `]`: decrease or increase bit-shift amount
- `UP` / `DOWN`: adjust brightness threshold
- `LEFT` / `RIGHT`: adjust glitch grid
- `-` / `+`: adjust noise patch count
- `S`: save a frame to the sketch folder
- `H`: show or hide the HUD

## Setup

Install `processing.video` from the Processing Contributions Manager before
running this sketch.

Optional assets:

- `data/source.jpg`
- `data/source.mov`

If those files are not present, the sketch stays usable by falling back to its
generated source.
