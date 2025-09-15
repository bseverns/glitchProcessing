# video_glitch facilitator guide

This sketch glitches a playing movie by bit-shifting pixels whenever they cross a brightness threshold. It’s an expressive way to teach video playback, per-pixel math, and interactive controls.

## Setup

1. Place a clip named `bath.mov` (or edit the filename in `new Movie(...)`) inside the `data/` folder.【F:video_glitch/video_glitch.pde†L14-L19】
2. Run the sketch. It allocates a 1920×1080 window, reads frames into `mov.pixels`, and immediately starts bending them based on the threshold derived from `mouseX`.【F:video_glitch/video_glitch.pde†L16-L64】

## Classroom focus areas

- **Bit shifting demo:** Walk through how `c << shiftAmount` reinterprets the 32-bit ARGB color. Show students how shifting by huge values obliterates the image, then set limits with the UP/DOWN keys.【F:video_glitch/video_glitch.pde†L25-L76】
- **Threshold logic:** The `bright` toggle (TAB) flips between glitching high vs. low luminance regions. Let learners predict which areas will break as they slide the mouse horizontally.【F:video_glitch/video_glitch.pde†L21-L54】【F:video_glitch/video_glitch.pde†L67-L102】
- **Performance considerations:** Discuss why the sketch restricts work to rows where `y % grid == 0` and how the LEFT/RIGHT keys adjust that density.【F:video_glitch/video_glitch.pde†L40-L84】

## Push it further

- Add a GUI to expose `shiftAmount`, `grid`, and `bright` to beginners.
- Pipe audio-reactive data into `shiftAmount` for AV performances.
- Replace bit shifting with custom channel permutations borrowed from `ChannelShiftGlitch`.
