# ChannelShiftGlitch lesson plan

ChannelShiftGlitch is a one-file wonder that shuffles RGB channels across an image to create color-separated smears. It’s excellent for teaching pixel arrays, modular arithmetic, and deterministic vs. random iteration.

## Quick start

1. Drop an image into `data/` and rename it `MyImage.jpg` (or change `imgFileName` and `fileType` at the top of the sketch).【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L16-L45】
2. Press **Run**. The sketch loads your image, resizes the Processing surface to match, and immediately starts glitching.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L32-L93】
3. When the loop finishes, the glitched PNG is saved next to the sketch and the console invites you to exit with a click or key press.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L95-L198】

## Teaching highlights

- **Iteration playground:** `iterations` defines how many times we re-run the channel copy loop. Flip `recursiveIterations` on to show how feeding outputs back into inputs compounds chaos.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L20-L83】
- **Directional shifts:** Toggle `shiftHorizontally`/`shiftVertically` to demonstrate how random offsets wrap around thanks to manual modulus logic inside `copyChannel`. Challenge learners to predict the pattern before revealing the result.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L63-L179】
- **Pixel math:** Step through `copyChannel` slowly and trace how Processing stores pixels in a flat array, how we split colors into components, and how we reassemble them with `color(...)`. Encourage students to tweak the switch statements for custom channel mixes.【F:ChannelShiftGlitch/ChannelShiftGlitch.pde†L105-L183】

## Remix prompts

- Swap `random(...)` for deterministic offsets to teach systematic channel shifts (think 8-bit 3D glasses).
- Add UI knobs (ControlP5 sliders, for example) so students can watch the glitch evolve without re-running.
- Wrap the glitch in a loop that iterates over every image in the `data/` folder for a batch-processing homework assignment.
