# webcam_glitch live demo notes

This sketch reuses the movie-glitch logic but feeds it with live webcam data. It’s fantastic for workshops because participants see themselves mutate in real time.

## Launch checklist

1. Plug in a webcam and confirm Processing recognizes it (Sketch → Add File → Capture list if needed).【F:webcam_glitch/webcam_glitch.pde†L1-L20】
2. Run the sketch. Capture frames stream into `video.pixels`, then the same brightness thresholding and bit shifting from `video_glitch` warps the feed.【F:webcam_glitch/webcam_glitch.pde†L13-L63】

## Interaction map

- **Mouse X:** Sets the brightness cutoff that decides which pixels get shifted.【F:webcam_glitch/webcam_glitch.pde†L19-L44】
- **Arrow keys:** UP/DOWN alter `shiftAmount`; LEFT/RIGHT change the `grid` density (which rows are processed).【F:webcam_glitch/webcam_glitch.pde†L67-L100】
- **TAB / ENTER:** Toggle between bright vs. dark region glitching and grayscale overlays. Use these toggles to discuss boolean flags and UI feedback loops.【F:webcam_glitch/webcam_glitch.pde†L67-L100】

## Classroom riffs

- Pair learners: one performs the controls while the other documents parameter changes and visual outcomes.
- Log `frameRate` and `shiftAmount` to build intuition about how CPU load responds to grid density.【F:webcam_glitch/webcam_glitch.pde†L19-L63】
- Challenge students to add recording/export features so they can share the results after the session.
