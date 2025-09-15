# Glitch Processing Study Hall

Welcome to a curated stash of Processing sketches that glitch pixels, mangle video, and generally misbehave on purpose. Every folder is a ready-to-run sketch: drop the repo inside your Processing sketchbook, crack open the `.pde`, and start shredding. This README is the map so you can treat the codebase like a teaching lab instead of a mysterious junk drawer.

## Spin up your tools

1. Install Processing 3 (GlitchSort is happiest on Processing 2, but it still launches from modern versions) and grab the ControlP5 and Minim libraries from the Contributions Manager—they're hard requirements for the GlitchSort mega-sketch.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L17-L140】
2. Copy the folders you want to explore into your Processing sketchbook directory, then open them individually from the IDE. Each sketch ships with sample media inside its `data/` directory so you can press `Run` immediately.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L32-L103】【F:Transform_Landscape/Transform_Landscape.pde†L19-L60】【F:Transform_SlitScan/Transform_SlitScan.pde†L24-L52】【F:noise_glitch/noise_glitch.pde†L9-L38】【F:video_glitch/video_glitch.pde†L14-L107】【F:webcam_glitch/webcam_glitch.pde†L13-L105】
3. Skim the README that lives beside each sketch (they're new!) for a walkthrough of the intent, hotkeys, and parameter hacks. Use them like mini-lesson plans when you're teaching or learning alongside someone.

## Directory tour (a crash course)

| Sketch | Idea to steal | Input expectations | Play notes |
| --- | --- | --- | --- |
| `ChannelShiftGlitch` | Swaps RGB channels between random offsets to create datamosh streaks.| Place a still image named `MyImage.jpg` (or tweak `imgFileName`/`fileType`).【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L16-L83】 | Flip `shiftHorizontally`, `shiftVertically`, and `recursiveIterations` to control how chaotic the channel copying loop gets.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L20-L183】 |
| `GlitchSort_v01b10` | A full-featured pixel-sorting workstation with FFT tricks, color quantization, and ControlP5 UI.| Needs ControlP5 + Minim, and any image you load via the built-in file dialog (`o`).【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L53-L140】 | Use the control panel or keyboard shortcuts to juggle sorting algorithms, glitch cycles, audio-driven filters, and JPEG degradation while you teach the concepts live.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L97-L140】【F:GlitchSort_v01b10/ControlPanelCommands.pde†L12-L146】【F:GlitchSort_v01b10/Sorting.pde†L14-L147】 |
| `Transform_Landscape` | Extrudes image brightness into a rotating 3D landscape inspired by Form+Code.| Ships with `nasa-iceberg.jpg`; any grayscale-friendly image works once it lives in `data/`.【F:Transform_Landscape/Transform_Landscape.pde†L19-L60】 | Great for demonstrating brightness-to-geometry mapping in Processing’s 3D renderer—tweak `scale()` or sampling steps for performance lessons.【F:Transform_Landscape/Transform_Landscape.pde†L39-L59】 |
| `Transform_SlitScan` | Builds a slit-scan panorama by sampling the same video column over time.| Drop a clip named `station.mov` into `data/` or point to your own file.【F:Transform_SlitScan/Transform_SlitScan.pde†L15-L52】 | Marches a write head across the sketch window; amazing for discussing arrays, `Movie` events, and temporal sampling.【F:Transform_SlitScan/Transform_SlitScan.pde†L36-L51】 |
| `noise_glitch` | Glitches stills with cut-up collage fragments and copy-paste chaos.| Uses `smallsnarl.jpg`; swap in any 800×800 image or adjust the dimensions and copy calls.【F:noise_glitch/noise_glitch.pde†L5-L38】 | Walk through the `img.get`/`img.copy` combo to explain rectangular sampling, randomness, and export shortcuts (`s`).【F:noise_glitch/noise_glitch.pde†L19-L38】 |
| `video_glitch` | Bit-shifts video pixels in-place for live threshold-based tearing.| Load a `bath.mov` (or rename in code) and keep `processing.video` installed.【F:video_glitch/video_glitch.pde†L3-L107】 | Demonstrate how brightness thresholds, bit shifting, and keyboard-controlled parameters reshape moving footage.【F:video_glitch/video_glitch.pde†L21-L103】 |
| `webcam_glitch` | Same bit-shift logic as `video_glitch` but fed by a live camera.| Just needs a connected webcam recognized by Processing.【F:webcam_glitch/webcam_glitch.pde†L1-L105】 | Perfect for real-time workshops—mouse position sets the brightness threshold and arrow keys tweak the glitch grid while participants watch themselves warp.【F:webcam_glitch/webcam_glitch.pde†L19-L101】 |

## Suggested learning path

1. **Start with `ChannelShiftGlitch`** to teach pixel arrays, channel math, and safe iteration before saving glitch art automatically.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L20-L198】
2. **Graduate to `noise_glitch`** to show how `get()` and `copy()` turn randomness into collage strategies (and why bounding boxes matter).【F:noise_glitch/noise_glitch.pde†L19-L38】
3. **Jump into motion** with `video_glitch` or `webcam_glitch` to connect mouse/keyboard input with live pixel manipulation.【F:video_glitch/video_glitch.pde†L21-L103】【F:webcam_glitch/webcam_glitch.pde†L19-L101】
4. **Cap it off with `GlitchSort_v01b10`** as the advanced studio session—let the control panel teach design patterns, state management, and audio-reactive glitching.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L97-L200】【F:GlitchSort_v01b10/ControlPanelCommands.pde†L12-L146】【F:GlitchSort_v01b10/Sorting.pde†L14-L147】

## Extra resources

- Each sketch now includes a README that doubles as a micro-lesson plan.
- `GlitchSort_v01b10` still ships with Paul Hertz’s PDF manual—it's in the folder as `gs10b8_Manual_web.pdf` for deep dives.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L17-L140】
- The `docs/` directory contains shared setup notes and teaching prompts you can remix.

Now go jam: tweak variables while students watch, encourage failure, and save the weird results.
