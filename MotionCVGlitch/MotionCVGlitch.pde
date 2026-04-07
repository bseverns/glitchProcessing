import processing.video.*;

Capture webcam;
PImage previousFrame;
PImage[] history;

float[] rawBandMotion;
float[] smoothedBandMotion;
int[] sampleCounts;

int historyWriteIndex = 0;
int historyCount = 0;
int bandHeight = 6;
int temporalDepth = 8;
int maxTearOffset = 96;
float motionThreshold = 0.12f;
float randomTearChance = 0.08f;
float globalMotion = 0.0f;
int glitchSeed = 0;

boolean hasFrame = false;
boolean cameraAvailable = false;
boolean showHud = true;
boolean showMotionOverlay = false;

String statusMessage = "Waiting for camera frames.";
int statusExpiresAt = 0;

void setup() {
  size(640, 480, P2D);
  frameRate(30);
  surface.setTitle("MotionCVGlitch");
  history = new PImage[12];
  reseedGlitch();
  setupCamera();
}

void setupCamera() {
  String[] cameras = Capture.list();
  if (cameras == null || cameras.length == 0) {
    cameraAvailable = false;
    setStatus("No camera detected. Connect one and rerun the sketch.");
    return;
  }

  webcam = new Capture(this, cameras[0]);
  webcam.start();
  cameraAvailable = true;
  setStatus("Camera ready. Motion drives temporal RGB lag and scanline tears.");
}

void draw() {
  background(8);

  if (!cameraAvailable) {
    drawCenteredMessage("No camera detected.\nThis sketch needs live video.");
    drawHud();
    return;
  }

  if (!hasFrame) {
    drawCenteredMessage("Waiting for camera frames...");
    drawHud();
    return;
  }

  PImage currentFrame = webcam.get();
  if (currentFrame.width != width || currentFrame.height != height) {
    currentFrame.resize(width, height);
  }

  updateMotion(currentFrame);
  pushHistory(currentFrame);

  PImage glitchedFrame = currentFrame.get();
  applyTemporalRgbLag(glitchedFrame, currentFrame);
  applyIrregularScanlines(glitchedFrame);

  image(glitchedFrame, 0, 0, width, height);

  if (showMotionOverlay) {
    drawMotionOverlay();
  }
  drawHud();
}

void updateMotion(PImage currentFrame) {
  ensureBandBuffers();
  currentFrame.loadPixels();

  for (int i = 0; i < rawBandMotion.length; i++) {
    rawBandMotion[i] = 0;
    sampleCounts[i] = 0;
  }

  if (previousFrame == null) {
    previousFrame = currentFrame.get();
    for (int i = 0; i < smoothedBandMotion.length; i++) {
      smoothedBandMotion[i] = 0;
    }
    globalMotion = 0;
    return;
  }

  previousFrame.loadPixels();

  // Sample a coarse grid of pixels and accumulate motion per horizontal band.
  for (int y = 0; y < height; y += 2) {
    int bandIndex = min(rawBandMotion.length - 1, y / bandHeight);
    int rowIndex = y * width;
    for (int x = 0; x < width; x += 4) {
      color currentColor = currentFrame.pixels[rowIndex + x];
      color previousColor = previousFrame.pixels[rowIndex + x];

      float diff = abs(channelEnergy(currentColor) - channelEnergy(previousColor)) / 765.0f;
      rawBandMotion[bandIndex] += diff;
      sampleCounts[bandIndex]++;
    }
  }

  globalMotion = 0;
  for (int i = 0; i < rawBandMotion.length; i++) {
    float bandAverage = 0;
    if (sampleCounts[i] > 0) {
      bandAverage = rawBandMotion[i] / sampleCounts[i];
    }

    // Light smoothing keeps the bands reactive without flickering frame-to-frame.
    smoothedBandMotion[i] = lerp(smoothedBandMotion[i], bandAverage, 0.35f);
    globalMotion += smoothedBandMotion[i];
  }

  globalMotion /= max(1, smoothedBandMotion.length);
  previousFrame = currentFrame.get();
}

void pushHistory(PImage frame) {
  history[historyWriteIndex] = frame.get();
  historyWriteIndex = (historyWriteIndex + 1) % history.length;
  historyCount = min(history.length, historyCount + 1);
}

void applyTemporalRgbLag(PImage frame, PImage currentFrame) {
  frame.loadPixels();
  currentFrame.loadPixels();

  int clampedDepth = min(temporalDepth, history.length - 1);
  for (int bandIndex = 0; bandIndex < smoothedBandMotion.length; bandIndex++) {
    int yStart = bandIndex * bandHeight;
    int yEnd = min(yStart + bandHeight, height);
    float motion = smoothedBandMotion[bandIndex];

    int baseLag = int(map(constrain(motion * 3.0f, 0, 1), 0, 1, 0, clampedDepth));
    int redLag = constrain(baseLag + 1, 0, historyCount - 1);
    int greenLag = constrain(max(0, baseLag / 2), 0, historyCount - 1);
    int blueLag = constrain(baseLag + 2, 0, historyCount - 1);

    // Pull different channels from different moments in time to make motion smear chromatic.
    PImage redFrame = getHistoryFrame(redLag, currentFrame);
    PImage greenFrame = getHistoryFrame(greenLag, currentFrame);
    PImage blueFrame = getHistoryFrame(blueLag, currentFrame);

    redFrame.loadPixels();
    greenFrame.loadPixels();
    blueFrame.loadPixels();

    int wobble = int(sin(frameCount * 0.08f + bandIndex * 0.7f) * maxTearOffset * 0.18f * motion * 6.0f);

    for (int y = yStart; y < yEnd; y++) {
      int rowIndex = y * width;
      for (int x = 0; x < width; x++) {
        int redIndex = rowIndex + wrapIndex(x + wobble, width);
        int greenIndex = rowIndex + x;
        int blueIndex = rowIndex + wrapIndex(x - wobble, width);

        color redSample = redFrame.pixels[redIndex];
        color greenSample = greenFrame.pixels[greenIndex];
        color blueSample = blueFrame.pixels[blueIndex];

        frame.pixels[rowIndex + x] = color(red(redSample), green(greenSample), blue(blueSample));
      }
    }
  }

  frame.updatePixels();
}

void applyIrregularScanlines(PImage frame) {
  frame.loadPixels();
  color[] sourcePixels = new color[frame.pixels.length];
  arrayCopy(frame.pixels, sourcePixels);

  float t = frameCount * 0.05f;
  for (int bandIndex = 0; bandIndex < smoothedBandMotion.length; bandIndex++) {
    float motion = smoothedBandMotion[bandIndex];
    float tearNoise = noise(glitchSeed * 0.01f, bandIndex * 0.21f, t);
    boolean forceTear = motion > motionThreshold;
    boolean randomTear = tearNoise > 1.0f - randomTearChance;

    if (!forceTear && !randomTear) {
      continue;
    }

    int yStart = bandIndex * bandHeight;
    int yEnd = min(yStart + bandHeight, height);
    int segmentCount = 1 + int(map(constrain(motion * 4.0f, 0, 1), 0, 1, 0, 3));

    // Motion activates a few short torn segments instead of shifting the whole row.
    for (int segment = 0; segment < segmentCount; segment++) {
      float startNoise = noise(glitchSeed * 0.03f + segment * 13.0f, bandIndex * 0.29f, t * 1.7f);
      float lengthNoise = noise(glitchSeed * 0.05f + segment * 19.0f, bandIndex * 0.37f, t * 1.9f);
      float offsetNoise = noise(glitchSeed * 0.07f + segment * 23.0f, bandIndex * 0.41f, t * 2.1f);

      int startX = int(map(startNoise, 0, 1, 0, width - 1));
      int segmentLength = int(map(lengthNoise, 0, 1, width * 0.08f, width * (0.25f + motion * 0.55f)));
      segmentLength = constrain(segmentLength, 12, width);
      int offset = int(map(offsetNoise, 0, 1, -maxTearOffset, maxTearOffset) * (0.5f + motion * 3.0f));

      for (int y = yStart; y < yEnd; y++) {
        int rowIndex = y * width;
        for (int dx = 0; dx < segmentLength; dx++) {
          int targetX = wrapIndex(startX + dx, width);
          int sourceX = wrapIndex(targetX + offset, width);
          frame.pixels[rowIndex + targetX] = sourcePixels[rowIndex + sourceX];
        }

        if (abs(offset) > maxTearOffset * 0.85f) {
          for (int x = startX; x < startX + segmentLength; x += 7) {
            int streakX = wrapIndex(x, width);
            frame.pixels[rowIndex + streakX] = lerpColor(frame.pixels[rowIndex + streakX], color(255), 0.25f);
          }
        }
      }
    }
  }

  frame.updatePixels();
}

PImage getHistoryFrame(int lag, PImage fallback) {
  if (historyCount == 0) {
    return fallback;
  }

  int clampedLag = constrain(lag, 0, historyCount - 1);
  int index = historyWriteIndex - 1 - clampedLag;
  while (index < 0) {
    index += history.length;
  }

  PImage frame = history[index];
  if (frame == null) {
    return fallback;
  }
  return frame;
}

void ensureBandBuffers() {
  int bandCount = max(1, (height + bandHeight - 1) / bandHeight);
  if (rawBandMotion != null && rawBandMotion.length == bandCount) {
    return;
  }

  rawBandMotion = new float[bandCount];
  smoothedBandMotion = new float[bandCount];
  sampleCounts = new int[bandCount];
}

float channelEnergy(color c) {
  return red(c) + green(c) + blue(c);
}

int wrapIndex(int value, int limit) {
  int wrapped = value % limit;
  if (wrapped < 0) {
    wrapped += limit;
  }
  return wrapped;
}

void drawMotionOverlay() {
  noStroke();
  fill(0, 120);
  rect(16, height - 100, 180, 84, 8);

  for (int i = 0; i < smoothedBandMotion.length; i++) {
    float motion = smoothedBandMotion[i];
    float barWidth = map(motion, 0, 0.45f, 0, 150);
    float y = height - 88 + i * (72.0f / smoothedBandMotion.length);
    fill(255, 150, 90, 210);
    rect(28, y, barWidth, max(2, 72.0f / smoothedBandMotion.length - 1));
  }
}

void drawHud() {
  if (!showHud) {
    return;
  }

  noStroke();
  fill(0, 170);
  rect(16, 16, 420, 124, 10);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(12);
  text(
    "MotionCVGlitch\n" +
    "[ ] depth: " + temporalDepth + "   LEFT/RIGHT band: " + bandHeight + "\n" +
    "UP/DOWN threshold: " + nf(motionThreshold, 1, 2) + "   T/G tear: " + maxTearOffset + "\n" +
    "M motion overlay   R reseed   S save   H hide HUD\n" +
    "global motion: " + nf(globalMotion, 1, 3),
    28,
    28
  );

  if (millis() < statusExpiresAt) {
    fill(255, 220, 140);
    text(statusMessage, 28, 98);
  }
}

void drawCenteredMessage(String message) {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(message, width * 0.5f, height * 0.5f);
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
    case LEFT:
      bandHeight = max(2, bandHeight - 1);
      ensureBandBuffers();
      setStatus("Band height " + bandHeight);
      break;
    case RIGHT:
      bandHeight = min(24, bandHeight + 1);
      ensureBandBuffers();
      setStatus("Band height " + bandHeight);
      break;
    case UP:
      motionThreshold = min(0.45f, motionThreshold + 0.01f);
      setStatus("Motion threshold " + nf(motionThreshold, 1, 2));
      break;
    case DOWN:
      motionThreshold = max(0.02f, motionThreshold - 0.01f);
      setStatus("Motion threshold " + nf(motionThreshold, 1, 2));
      break;
    }
    return;
  }

  switch(Character.toLowerCase(key)) {
  case '[':
    temporalDepth = max(1, temporalDepth - 1);
    setStatus("Temporal depth " + temporalDepth);
    break;
  case ']':
    temporalDepth = min(history.length - 1, temporalDepth + 1);
    setStatus("Temporal depth " + temporalDepth);
    break;
  case 't':
    maxTearOffset = max(16, maxTearOffset - 8);
    setStatus("Max tear offset " + maxTearOffset);
    break;
  case 'g':
    maxTearOffset = min(width / 2, maxTearOffset + 8);
    setStatus("Max tear offset " + maxTearOffset);
    break;
  case 'm':
    showMotionOverlay = !showMotionOverlay;
    setStatus(showMotionOverlay ? "Motion overlay on" : "Motion overlay off");
    break;
  case 'r':
    reseedGlitch();
    break;
  case 's':
    saveFrame("MotionCVGlitch-######.png");
    setStatus("Saved frame to sketch folder");
    break;
  case 'h':
    showHud = !showHud;
    if (showHud) {
      setStatus("HUD visible");
    }
    break;
  }
}

void reseedGlitch() {
  glitchSeed = int(random(100000));
  noiseSeed(glitchSeed);
  setStatus("Reseeded tear field " + glitchSeed);
}

void setStatus(String message) {
  statusMessage = message;
  statusExpiresAt = millis() + 2500;
  println(message);
}

void captureEvent(Capture c) {
  c.read();
  hasFrame = true;
}
