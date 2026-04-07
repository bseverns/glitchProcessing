import processing.video.*;

Capture webcam;
PImage[] history;

float[] rawEdgeField;
float[] edgeField;
float[] gradXField;
float[] gradYField;

int fieldCols = 0;
int fieldRows = 0;
int historyWriteIndex = 0;
int historyCount = 0;
int cellSize = 14;
int temporalDepth = 6;
int maxChannelOffset = 18;
int maxTearOffset = 96;
float edgeThreshold = 0.22f;
float randomLineChance = 0.035f;
float globalEdgeEnergy = 0.0f;
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
  surface.setTitle("ContourFieldGlitch");
  history = new PImage[10];
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
  setStatus("Camera ready. Edges now drive temporal RGB shear and scanline tears.");
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

  updateContourField(currentFrame);
  pushHistory(currentFrame);

  PImage glitchedFrame = currentFrame.get();
  applyContourTemporalShift(glitchedFrame, currentFrame);
  applyContourScanlines(glitchedFrame);

  image(glitchedFrame, 0, 0, width, height);

  if (showAnalysisOverlay) {
    drawAnalysisOverlay();
  }
  drawHud();
}

void updateContourField(PImage frame) {
  ensureFieldBuffers();
  frame.loadPixels();

  float totalEdge = 0;
  int sampleStep = max(1, cellSize / 2);

  // Build a coarse edge-and-direction field from local brightness differences.
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
      float magnitude = sqrt(gx * gx + gy * gy);
      magnitude = constrain(magnitude, 0, 1);

      rawEdgeField[index] = magnitude;
      edgeField[index] = lerp(edgeField[index], magnitude, 0.35f);
      gradXField[index] = lerp(gradXField[index], gx, 0.3f);
      gradYField[index] = lerp(gradYField[index], gy, 0.3f);

      totalEdge += edgeField[index];
    }
  }

  globalEdgeEnergy = totalEdge / max(1, fieldCols * fieldRows);
}

void pushHistory(PImage frame) {
  history[historyWriteIndex] = frame.get();
  historyWriteIndex = (historyWriteIndex + 1) % history.length;
  historyCount = min(history.length, historyCount + 1);
}

void applyContourTemporalShift(PImage frame, PImage currentFrame) {
  frame.loadPixels();
  currentFrame.loadPixels();

  int clampedDepth = min(temporalDepth, history.length - 1);
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    int yStart = cellY * cellSize;
    int yEnd = min(yStart + cellSize, height);

    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      float strength = edgeField[index];
      float gx = gradXField[index];
      float gy = gradYField[index];

      int lagBase = int(map(constrain((strength - edgeThreshold * 0.5f) * 2.2f, 0, 1), 0, 1, 0, clampedDepth));
      int redLag = constrain(lagBase + 1, 0, max(0, historyCount - 1));
      int blueLag = constrain(lagBase + 2, 0, max(0, historyCount - 1));

      // Strong contours pull the red and blue channels from offset positions and older frames.
      PImage redFrame = getHistoryFrame(redLag, currentFrame);
      PImage blueFrame = getHistoryFrame(blueLag, currentFrame);
      redFrame.loadPixels();
      blueFrame.loadPixels();

      int offsetX = int(gx * maxChannelOffset * (0.6f + strength * 2.6f));
      int offsetY = int(gy * max(4, maxChannelOffset / 2) * (0.4f + strength * 1.8f));

      int xStart = cellX * cellSize;
      int xEnd = min(xStart + cellSize, width);
      for (int y = yStart; y < yEnd; y++) {
        int rowIndex = y * width;
        for (int x = xStart; x < xEnd; x++) {
          int redIndex = flatIndex(wrapValue(x + offsetX, width), wrapValue(y + offsetY, height));
          int blueIndex = flatIndex(wrapValue(x - offsetX, width), wrapValue(y - offsetY, height));
          int targetIndex = rowIndex + x;

          color redSample = redFrame.pixels[redIndex];
          color blueSample = blueFrame.pixels[blueIndex];
          color greenSample = currentFrame.pixels[targetIndex];

          frame.pixels[targetIndex] = color(red(redSample), green(greenSample), blue(blueSample));
        }
      }
    }
  }

  frame.updatePixels();
}

void applyContourScanlines(PImage frame) {
  frame.loadPixels();
  color[] sourcePixels = new color[frame.pixels.length];
  arrayCopy(frame.pixels, sourcePixels);

  float t = frameCount * 0.04f;
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      float strength = edgeField[index];
      float tearNoise = noise(glitchSeed * 0.01f, cellX * 0.19f, cellY * 0.17f + t);

      if (strength < edgeThreshold && tearNoise < 1.0f - randomLineChance) {
        continue;
      }

      int startX = cellX * cellSize;
      int baseY = constrain(cellY * cellSize + int(noise(glitchSeed * 0.03f, cellX * 0.23f, cellY * 0.11f + t) * max(1, cellSize - 1)), 0, height - 1);
      int thickness = 1 + int(map(strength, 0, 1, 0, 2));
      int segmentLength = int(map(strength, 0, 1, cellSize * 2, width * 0.22f));
      segmentLength = constrain(segmentLength, 14, width / 2);

      // The contour direction biases the tear, then noise roughens it into something less uniform.
      float directedOffset = gradXField[index] * maxTearOffset * (0.4f + strength * 2.8f);
      float jitterOffset = map(noise(glitchSeed * 0.05f, cellX * 0.29f, cellY * 0.13f + t * 1.7f), 0, 1, -maxTearOffset * 0.5f, maxTearOffset * 0.5f);
      int offset = int(directedOffset + jitterOffset);

      for (int y = baseY; y < min(height, baseY + thickness); y++) {
        int rowIndex = y * width;
        for (int dx = 0; dx < segmentLength; dx++) {
          int targetX = wrapValue(startX + dx, width);
          int sourceX = wrapValue(targetX + offset, width);
          frame.pixels[rowIndex + targetX] = sourcePixels[rowIndex + sourceX];
        }

        if (abs(offset) > maxTearOffset * 0.75f) {
          for (int x = startX; x < startX + segmentLength; x += 6) {
            int streakX = wrapValue(x, width);
            frame.pixels[rowIndex + streakX] = lerpColor(frame.pixels[rowIndex + streakX], color(255), 0.22f);
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

  // Visualize both the sampled cells and the local gradient vectors.
  for (int cellY = 0; cellY < fieldRows; cellY++) {
    for (int cellX = 0; cellX < fieldCols; cellX++) {
      int index = cellIndex(cellX, cellY);
      float strength = edgeField[index];
      float gx = gradXField[index];
      float gy = gradYField[index];

      float x = cellX * cellSize;
      float y = cellY * cellSize;
      stroke(255, 160, 80, 40 + 180 * strength);
      rect(x, y, cellSize, cellSize);

      float cx = x + cellSize * 0.5f;
      float cy = y + cellSize * 0.5f;
      stroke(80, 220, 255, 180);
      line(cx, cy, cx + gx * cellSize * 2.0f, cy + gy * cellSize * 2.0f);
    }
  }
}

void drawHud() {
  if (!showHud) {
    return;
  }

  noStroke();
  fill(0, 170);
  rect(16, 16, 452, 124, 10);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(12);
  text(
    "ContourFieldGlitch\n" +
    "[ ] depth: " + temporalDepth + "   LEFT/RIGHT cell: " + cellSize + "\n" +
    "UP/DOWN edge threshold: " + nf(edgeThreshold, 1, 2) + "   T/G tear: " + maxTearOffset + "\n" +
    "F/V RGB offset: " + maxChannelOffset + "   M analysis overlay   R reseed   S save\n" +
    "global edge energy: " + nf(globalEdgeEnergy, 1, 3),
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
  if (requiredCols == fieldCols && requiredRows == fieldRows && rawEdgeField != null) {
    return;
  }

  fieldCols = requiredCols;
  fieldRows = requiredRows;
  int total = fieldCols * fieldRows;
  rawEdgeField = new float[total];
  edgeField = new float[total];
  gradXField = new float[total];
  gradYField = new float[total];
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
      edgeThreshold = min(0.65f, edgeThreshold + 0.01f);
      setStatus("Edge threshold " + nf(edgeThreshold, 1, 2));
      break;
    case DOWN:
      edgeThreshold = max(0.05f, edgeThreshold - 0.01f);
      setStatus("Edge threshold " + nf(edgeThreshold, 1, 2));
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
    saveFrame("ContourFieldGlitch-######.png");
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
  setStatus("Reseeded contour tear field " + glitchSeed);
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
