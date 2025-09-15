# noise_glitch classroom notes

`noise_glitch.pde` chops up an image and reassembles it as a chaotic collage. It’s concise enough to read line-by-line with students while still flexing core Processing APIs.

## Kickoff

1. Keep `smallsnarl.jpg` (or your own texture) inside `data/` and make sure `size(800,800)` matches the dimensions unless you plan to refactor the copy calls.【F:noise_glitch/noise_glitch.pde†L5-L26】
2. Run the sketch. It draws the original image, waits a beat, then loops 800 times grabbing random rectangles and pasting them back in new spots.【F:noise_glitch/noise_glitch.pde†L15-L27】
3. Tap `s` anytime to save the current canvas to disk using a randomized suffix—handy for collecting variations quickly.【F:noise_glitch/noise_glitch.pde†L32-L38】

## Concepts to emphasize

- **Sampling rectangles:** Compare the active `img.get(random…)` call with the commented deterministic version to discuss the difference between targeted and stochastic remixes.【F:noise_glitch/noise_glitch.pde†L19-L25】
- **Copy semantics:** `img.copy(...)` demonstrates how source rectangles, destination coordinates, and scaling parameters work. Let learners deliberately push values outside image bounds to see the results.【F:noise_glitch/noise_glitch.pde†L23-L26】
- **Stateful randomness:** The global `count` combined with random seeds ensures saved filenames don’t collide. Use it to introduce the idea of storing run-specific metadata.【F:noise_glitch/noise_glitch.pde†L5-L38】

## Remix ideas

- Replace `delay(1000)` with a frame-based gate so the animation continues in real time.
- Add keyboard toggles to switch between the random and deterministic sampling strategies mid-run.
- Blend in a secondary image (`otherImage`) to demonstrate collage across sources.
