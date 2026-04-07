import processing.video.*;

Capture webcam;
PImage previousFrame;
PImage[] history;

float[] edgeField;
float[] motionField;
float[] gradXField;
float[] gradYField;
float[] hybridField;

int fieldCols = 0;
int fieldRows = 0;
int historyWriteIndex = 0;
int historyCount = 0;
int cellSize = 12;
int temporalDepth = 7;
int maxChannelOffset = 22;
int maxTearOffset = 112;
float activationThreshold = 0.24f;
float randomLineChance = 0.03f;
float globalActivation = 0.0f;
int glitchSeed = 0;

boolean hasFrame = false;
boolean cameraAvailable = false;
boolean showHud = true;
boolean showAnalysisOverlay = false;

String statusMessage = "Waiting for camera frames.";
int statusExpiresAt = 0;

void setup() {
  size(640, 480, P2D);
  frameRate(30);
  surface.setTitle("HybridCVGlitch");
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
  setStatus("Camera ready. Motion decides when; contours decide where.");
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

  updateHybridField(currentFrame);
  pushHistory(currentFrame);

  PImage glitchedFrame = currentFrame.get();
  applyHybridTemporalShift(glitchedFrame, currentFrame);
  applyHybridScanlines(glitchedFrame);

  image(glitchedFrame, 0, 0, width, height);

  if (showAnalysisOverlay) {
    drawAnalysisOverlay();
  }
  drawHud();
}

void updateHybridField(PImage frame) {
  ensureFieldBuffers();
  frame.loadPixels();

  float totalActivation = 0;
  int sampleStep = max(1, cellSize / 2);

  if (previousFrame != null) {
    previousFrame.loadPixels();
  }

  // Estimate contour strength and motion on the same grid so the two signals can be blended.
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      int centerX = constrain(cellX * cellSize + cellSize / 2, 1, width - 2);
      int centerY = constrain(cellY * cellSize + cellSize / 2, 1, height - 2);

      float left = luminanceAt(frame, centerX - sampleStep, centerY);
      float right = luminanceAt(frame, centerX + sampleStep, centerY);
      float up = luminanceAt(frame, centerX, centerY - sampleStep);
      float down = luminanceAt(frame, centerX, centerY + sampleStep);

      float gx = (right - left) / 255.0f;
      float gy = (down - up) / 255.0f;
      float edgeMagnitude = constrain(sqrt(gx * gx + gy * gy), 0, 1);

      float motionMagnitude = 0;
      if (previousFrame != null) {
        float currentValue = luminanceAt(frame, centerX, centerY);
        float previousValue = luminanceAt(previousFrame, centerX, centerY);
        motionMagnitude = abs(currentValue - previousValue) / 255.0f;
      }

      edgeField[index] = lerp(edgeField[index], edgeMagnitude, 0.35f);
      motionField[index] = lerp(motionField[index], motionMagnitude, 0.4f);
      gradXField[index] = lerp(gradXField[index], gx, 0.3f);
      gradYField[index] = lerp(gradYField[index], gy, 0.3f);

      // Motion is weighted a bit higher so static edges structure the image without constantly tearing it.
      float activation = constrain(edgeField[index] * 0.55f + motionField[index] * 0.95f, 0, 1);
      hybridField[index] = lerp(hybridField[index], activation, 0.35f);
      totalActivation += hybridField[index];
    }
  }

  globalActivation = totalActivation / max(1, fieldCols * fieldRows);
  previousFrame = frame.get();
}

void pushHistory(PImage frame) {
  history[historyWriteIndex] = frame.get();
  historyWriteIndex = (historyWriteIndex + 1) % history.length;
  historyCount = min(history.length, historyCount + 1);
}

void applyHybridTemporalShift(PImage frame, PImage currentFrame) {
  frame.loadPixels();
  currentFrame.loadPixels();

  int clampedDepth = min(temporalDepth, history.length - 1);
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    int yStart = cellY * cellSize;
    int yEnd = min(yStart + cellSize, height);

    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      float edgeStrength = edgeField[index];
      float motionStrength = motionField[index];
      float activation = hybridField[index];

      int lagBase = int(map(constrain(motionStrength * 2.5f + activation * 0.7f, 0, 1), 0, 1, 0, clampedDepth));
      int redLag = constrain(lagBase + 1, 0, max(0, historyCount - 1));
      int greenLag = constrain(max(0, lagBase / 2), 0, max(0, historyCount - 1));
      int blueLag = constrain(lagBase + 2, 0, max(0, historyCount - 1));

      // Motion chooses how far back in time to sample; contour direction chooses where to shear.
      PImage redFrame = getHistoryFrame(redLag, currentFrame);
      PImage greenFrame = getHistoryFrame(greenLag, currentFrame);
      PImage blueFrame = getHistoryFrame(blueLag, currentFrame);
      redFrame.loadPixels();
      greenFrame.loadPixels();
      blueFrame.loadPixels();

      int directionX = int(gradXField[index] * maxChannelOffset * (0.7f + edgeStrength * 2.8f));
      int directionY = int(gradYField[index] * max(4, maxChannelOffset / 2) * (0.4f + edgeStrength * 2.0f));
      int motionJitter = int(sin(frameCount * 0.09f + index * 0.3f) * motionStrength * maxChannelOffset * 1.4f);

      int xStart = cellX * cellSize;
      int xEnd = min(xStart + cellSize, width);
      for (int y = yStart; y < yEnd; y++) {
        int rowIndex = y * width;
        for (int x = xStart; x < xEnd; x++) {
          int redIndex = flatIndex(wrapValue(x + directionX + motionJitter, width), wrapValue(y + directionY, height));
          int greenIndex = flatIndex(wrapValue(x - motionJitter / 2, width), y);
          int blueIndex = flatIndex(wrapValue(x - directionX - motionJitter, width), wrapValue(y - directionY, height));
          int targetIndex = rowIndex + x;

          color redSample = redFrame.pixels[redIndex];
          color greenSample = greenFrame.pixels[greenIndex];
          color blueSample = blueFrame.pixels[blueIndex];

          frame.pixels[targetIndex] = color(red(redSample), green(greenSample), blue(blueSample));
        }
      }
    }
  }

  frame.updatePixels();
}

void applyHybridScanlines(PImage frame) {
  frame.loadPixels();
  color[] sourcePixels = new color[frame.pixels.length];
  arrayCopy(frame.pixels, sourcePixels);

  float t = frameCount * 0.045f;
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      float activation = hybridField[index];
      float edgeStrength = edgeField[index];
      float motionStrength = motionField[index];
      float tearNoise = noise(glitchSeed * 0.01f, cellX * 0.19f, cellY * 0.13f + t);

      if (activation < activationThreshold && tearNoise < 1.0f - randomLineChance) {
        continue;
      }

      int startX = cellX * cellSize;
      int baseY = constrain(cellY * cellSize + int(noise(glitchSeed * 0.03f, cellX * 0.27f, cellY * 0.09f + t) * max(1, cellSize - 1)), 0, height - 1);
      int segmentLength = int(map(activation, 0, 1, cellSize * 2, width * 0.28f));
      segmentLength = constrain(segmentLength, 12, width / 2);
      int thickness = 1 + int(map(motionStrength, 0, 1, 0, 3));

      // Contours steer the tear direction while motion adds instability and thickness.
      float contourOffset = gradXField[index] * maxTearOffset * (0.45f + edgeStrength * 2.6f);
      float motionOffset = sin(frameCount * 0.14f + index * 0.41f) * maxTearOffset * motionStrength * 0.85f;
      float jitterOffset = map(noise(glitchSeed * 0.05f, cellX * 0.31f, cellY * 0.17f + t * 1.5f), 0, 1, -maxTearOffset * 0.35f, maxTearOffset * 0.35f);
      int offset = int(contourOffset + motionOffset + jitterOffset);

      for (int y = baseY; y < min(height, baseY + thickness); y++) {
        int rowIndex = y * width;
        for (int dx = 0; dx < segmentLength; dx++) {
          int targetX = wrapValue(startX + dx, width);
          int sourceX = wrapValue(targetX + offset, width);
          frame.pixels[rowIndex + targetX] = sourcePixels[rowIndex + sourceX];
        }

        if (abs(offset) > maxTearOffset * 0.7f) {
          for (int x = startX; x < startX + segmentLength; x += 5) {
            int streakX = wrapValue(x, width);
            frame.pixels[rowIndex + streakX] = lerpColor(frame.pixels[rowIndex + streakX], color(255), 0.24f);
          }
        }
      }
    }
  }

  frame.updatePixels();
}

void drawAnalysisOverlay() {
  noFill();
  strokeWeight(1);

  // The overlay shows where the hybrid activation is high and which way the local contour points.
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      float edgeStrength = edgeField[index];
      float motionStrength = motionField[index];

      float x = cellX * cellSize;
      float y = cellY * cellSize;
      stroke(255 * motionStrength, 180 * edgeStrength, 255 * edgeStrength, 60 + 140 * hybridField[index]);
      rect(x, y, cellSize, cellSize);

      float cx = x + cellSize * 0.5f;
      float cy = y + cellSize * 0.5f;
      stroke(80, 220, 255, 180);
      line(cx, cy, cx + gradXField[index] * cellSize * 2.0f, cy + gradYField[index] * cellSize * 2.0f);
    }
  }
}

void drawHud() {
  if (!showHud) {
    return;
  }

  noStroke();
  fill(0, 170);
  rect(16, 16, 456, 124, 10);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(12);
  text(
    "HybridCVGlitch\n" +
    "[ ] depth: " + temporalDepth + "   LEFT/RIGHT cell: " + cellSize + "\n" +
    "UP/DOWN activation threshold: " + nf(activationThreshold, 1, 2) + "   T/G tear: " + maxTearOffset + "\n" +
    "F/V RGB offset: " + maxChannelOffset + "   M analysis overlay   R reseed   S save\n" +
    "global activation: " + nf(globalActivation, 1, 3),
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

void ensureFieldBuffers() {
  int requiredCols = max(1, (width + cellSize - 1) / cellSize);
  int requiredRows = max(1, (height + cellSize - 1) / cellSize);
  if (requiredCols == fieldCols && requiredRows == fieldRows && edgeField != null) {
    return;
  }

  fieldCols = requiredCols;
  fieldRows = requiredRows;
  int total = fieldCols * fieldRows;
  edgeField = new float[total];
  motionField = new float[total];
  gradXField = new float[total];
  gradYField = new float[total];
  hybridField = new float[total];
}

int cellIndex(int x, int y) {
  return y * fieldCols + x;
}

int wrapValue(int value, int limit) {
  int wrapped = value % limit;
  if (wrapped < 0) {
    wrapped += limit;
  }
  return wrapped;
}

int flatIndex(int x, int y) {
  return y * width + x;
}

float luminanceAt(PImage frame, int x, int y) {
  color c = frame.pixels[flatIndex(constrain(x, 0, width - 1), constrain(y, 0, height - 1))];
  return 0.299f * red(c) + 0.587f * green(c) + 0.114f * blue(c);
}

PImage getHistoryFrame(int lag, PImage fallback) {
  if (historyCount == 0) {
    return fallback;
  }

  int clampedLag = constrain(lag, 0, max(0, historyCount - 1));
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

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
    case LEFT:
      cellSize = max(6, cellSize - 1);
      ensureFieldBuffers();
      setStatus("Cell size " + cellSize);
      break;
    case RIGHT:
      cellSize = min(36, cellSize + 1);
      ensureFieldBuffers();
      setStatus("Cell size " + cellSize);
      break;
    case UP:
      activationThreshold = min(0.7f, activationThreshold + 0.01f);
      setStatus("Activation threshold " + nf(activationThreshold, 1, 2));
      break;
    case DOWN:
      activationThreshold = max(0.04f, activationThreshold - 0.01f);
      setStatus("Activation threshold " + nf(activationThreshold, 1, 2));
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
  case 'f':
    maxChannelOffset = max(4, maxChannelOffset - 2);
    setStatus("RGB offset " + maxChannelOffset);
    break;
  case 'v':
    maxChannelOffset = min(64, maxChannelOffset + 2);
    setStatus("RGB offset " + maxChannelOffset);
    break;
  case 'm':
    showAnalysisOverlay = !showAnalysisOverlay;
    setStatus(showAnalysisOverlay ? "Analysis overlay on" : "Analysis overlay off");
    break;
  case 'r':
    reseedGlitch();
    break;
  case 's':
    saveFrame("HybridCVGlitch-######.png");
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
  setStatus("Reseeded hybrid glitch field " + glitchSeed);
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
