# Processing setup & teaching prompts

This cheat sheet is the companion for workshops. Use it to get a classroom ready fast and to remind yourself which concepts each sketch can illustrate.

## Install once, glitch often

- **Processing core:** Install the latest Processing 3.x release. All sketches compile there; GlitchSort just prefers the Processing 2 runtime for nostalgia reasons.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L17-L140】
- **Libraries:**
  - `ControlP5` (UI widgets for GlitchSort’s control panel).【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L53-L140】
  - `Minim` (FFT and audio hooks for GlitchSort).【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L87-L134】
  - `processing.video` (used by slit-scan, movie glitching, and webcam glitching sketches).【F:Transform_SlitScan/Transform_SlitScan.pde†L13-L52】【F:video_glitch/video_glitch.pde†L3-L107】【F:webcam_glitch/webcam_glitch.pde†L1-L105】
- **Sketchbook layout:** Each folder in this repo is a self-contained sketch. Copy only the folders you want into your Processing sketchbook and rename if you need to run multiple variants side-by-side.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L16-L103】【F:noise_glitch/noise_glitch.pde†L9-L38】

## Media prep checklist

| Sketch | Default asset | Quick swap instructions |
| --- | --- | --- |
| ChannelShiftGlitch | `data/MyImage.jpg` placeholder – sample images included.| Replace `imgFileName`/`fileType` at the top of the sketch or drop a file with that name into `data/`.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L16-L45】 |
| GlitchSort_v01b10 | No default file; you open an image from the UI.| Hit `o` to open an image and `O` to load a snapshot; the undo/snapshot buffers update automatically.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L97-L132】 |
| Transform_Landscape | `data/nasa-iceberg.jpg`.| Swap the filename in `loadImage` or replace the file; resize images if performance tanks.【F:Transform_Landscape/Transform_Landscape.pde†L19-L59】 |
| Transform_SlitScan | `data/station.mov`.| Change the constructor path or drop in your own clip with the same name.【F:Transform_SlitScan/Transform_SlitScan.pde†L15-L52】 |
| noise_glitch | `data/smallsnarl.jpg`.| Adjust `size()` and the rectangle dimensions if you use a different resolution.【F:noise_glitch/noise_glitch.pde†L9-L38】 |
| video_glitch | expects `bath.mov` in `data/`.| Edit the filename in `new Movie(...)` for other footage.【F:video_glitch/video_glitch.pde†L14-L53】 |
| webcam_glitch | Live webcam capture.| Nothing to prep besides connecting a camera.【F:webcam_glitch/webcam_glitch.pde†L13-L44】 |

## Teaching angles (suggested talking points)

- **Arrays & iteration:** Channel shift and noise glitch sketches are perfect for introducing nested loops, offsets, and wraparound logic in `copyChannel` and `img.copy`. Walk through how indices are calculated before hitting `Run`.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L77-L183】【F:noise_glitch/noise_glitch.pde†L19-L38】
- **State & UI:** Use GlitchSort to discuss how complex sketches manage state machines, UI callbacks, and modular sort strategies. The ControlP5 command handlers are intentionally verbose for demonstration.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L97-L200】【F:GlitchSort_v01b10/ControlPanelCommands.pde†L12-L146】【F:GlitchSort_v01b10/Sorting.pde†L14-L147】
- **3D thinking:** Transform_Landscape shows how image brightness maps to 3D coordinates and how animation steps accumulate via `angle`. Slow down the loops to debug in front of students.【F:Transform_Landscape/Transform_Landscape.pde†L25-L59】
- **Temporal sampling:** The slit-scan sketch is a gentle entry into event-driven code (`movieEvent`) and writing to the window buffer manually. Print indices live so learners see the scanning head progress.【F:Transform_SlitScan/Transform_SlitScan.pde†L31-L51】
- **Live interaction:** Both `video_glitch` and `webcam_glitch` tie keyboard and mouse to pixel manipulation, which is a slick segue into discussing bit operations (`<<`) and thresholds.【F:video_glitch/video_glitch.pde†L21-L103】【F:webcam_glitch/webcam_glitch.pde†L19-L101】

## Classroom vibes

Encourage experimentation: save iterations often (`ChannelShiftGlitch` saves automatically; GlitchSort’s `s` key stamps PNGs), and let learners break the sketches by pushing parameters past sane limits—then debug together. That’s where the punk-rock learning happens.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L95-L198】【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L97-L140】
