# ScanlineTearGlitch exercise notes

`ScanlineTearGlitch` pulls a source image sideways in horizontal bands, then desynchronizes the RGB channels so the frame looks torn apart by a bad signal. It is a compact exercise for teaching scanline iteration, wraparound indexing, and how small offsets can become a strong visual language.

## Quick start

1. Open the sketch and press **Run**. It starts immediately with a generated source image, so there is no media setup required.
2. Tap `2` if you want to process your own still image instead. The sketch looks for `data/source.jpg` and resizes it to the sketch window when found.
3. Use `[` and `]` to change the drift amount, `LEFT`/`RIGHT` to widen or tighten the scanline bands, and `UP`/`DOWN` to control how often large tears appear.
4. Press `R` to reseed the glitch field and `S` to save a frame variation to the sketch folder.

## Teaching highlights

- **Row-based pixel logic:** `applyScanlineTear` iterates through the image band-by-band instead of pixel-by-pixel first, which is a clean way to explain why glitch artifacts often feel like broken scanlines instead of random noise.
- **Wraparound sampling:** `wrapIndex(...)` keeps displaced samples inside the same row. This is a good place to discuss modulo arithmetic, negative offsets, and why wraparound feels different from clipping.
- **Channel misregistration:** The sketch samples red, green, and blue from slightly different horizontal offsets. Students can see how a small change in source coordinates creates a much larger perceived distortion.
- **Noise as choreography:** The main offset, burst tears, and channel jitter all come from Perlin noise fields. That makes the glitch feel structured instead of purely random and gives learners a practical use for continuous noise.

## Remix prompts

- Swap the horizontal tears for vertical ones by changing the band loop to work on columns.
- Add a brightness gate so only bright or dark rows are allowed to tear.
- Replace the generated source art with a webcam or movie frame to turn the exercise into a live glitch instrument.
