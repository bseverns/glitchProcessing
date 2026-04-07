PGraphics generatedSource;
PImage stillImage;

int maxOffset = 96;
int bandHeight = 6;
float tearChance = 0.18f;
int glitchSeed = 0;

boolean useImageSource = false;
boolean showHud = true;

String statusMessage = "Generated source active. Press 2 to try data/source.jpg.";
int statusExpiresAt = 0;

void setup() {
  size(960, 540, P2D);
  frameRate(30);
  surface.setTitle("ScanlineTearGlitch");
  generatedSource = createGraphics(width, height, P2D);
  reseedGlitch();
  setStatus("Generated source active. Press 2 to try data/source.jpg.");
}

void draw() {
  PImage sourceFrame = acquireSourceFrame();
  if (sourceFrame == null) {
    background(0);
    drawHud();
    return;
  }

  PImage glitchedFrame = sourceFrame.get();
  applyScanlineTear(glitchedFrame);
  image(glitchedFrame, 0, 0, width, height);
  drawHud();
}

PImage acquireSourceFrame() {
  if (useImageSource && stillImage != null) {
    return stillImage;
  }

  renderGeneratedSource();
  return generatedSource;
}

void renderGeneratedSource() {
  float t = millis() * 0.001f;

  generatedSource.beginDraw();
  generatedSource.colorMode(HSB, 360, 100, 100, 100);
  generatedSource.background(220, 30, 8);

  for (int x = 0; x < generatedSource.width; x += 28) {
    float hue = (x * 0.35f + t * 65.0f) % 360;
    float stripeHeight = generatedSource.height * (0.35f + 0.3f * sin(t * 1.6f + x * 0.025f));
    generatedSource.noStroke();
    generatedSource.fill(hue, 82, 100, 78);
    generatedSource.rect(x, generatedSource.height - stripeHeight, 18, stripeHeight);
  }

  generatedSource.noFill();
  generatedSource.strokeWeight(3);
  for (int i = 0; i < 10; i++) {
    float orbit = t * (0.55f + i * 0.08f);
    float cx = generatedSource.width * (0.5f + 0.27f * sin(orbit + i * 0.5f));
    float cy = generatedSource.height * (0.5f + 0.22f * cos(orbit * 1.3f + i));
    float radius = 80 + i * 18 + 22 * sin(orbit * 1.8f);
    generatedSource.stroke((i * 34 + 40) % 360, 55, 100, 65);
    generatedSource.ellipse(cx, cy, radius, radius * 0.7f);
  }

  generatedSource.stroke(0, 0, 100, 18);
  generatedSource.strokeWeight(1);
  for (int y = 0; y < generatedSource.height; y += 24) {
    generatedSource.line(0, y, generatedSource.width, y);
  }

  generatedSource.fill(0, 0, 100, 80);
  generatedSource.textAlign(CENTER, CENTER);
  generatedSource.textSize(120);
  generatedSource.text("SCAN", generatedSource.width * 0.34f, generatedSource.height * 0.26f);
  generatedSource.text("TEAR", generatedSource.width * 0.67f, generatedSource.height * 0.74f);
  generatedSource.colorMode(RGB, 255);
  generatedSource.endDraw();
}

void applyScanlineTear(PImage frame) {
  frame.loadPixels();
  color[] sourcePixels = new color[frame.pixels.length];
  arrayCopy(frame.pixels, sourcePixels);

  int clampedBandHeight = max(1, bandHeight);
  int channelJitter = max(1, maxOffset / 5);
  float t = frameCount * 0.03f;

  // Treat the frame as stacked scanline bands so the distortion reads as signal damage.
  for (int y = 0; y < frame.height; y += clampedBandHeight) {
    float driftNoise = noise(glitchSeed * 0.011f, y * 0.025f, t);
    int offset = int(map(driftNoise, 0, 1, -maxOffset, maxOffset));

    // Occasional high-energy tears ride on top of the slower drift field.
    float tearNoise = noise(200 + glitchSeed * 0.017f, y * 0.08f, t * 2.4f);
    if (tearNoise > 1.0f - tearChance) {
      int burst = int(map(noise(400 + glitchSeed * 0.021f, y * 0.12f, t * 3.1f), 0, 1, -maxOffset * 2, maxOffset * 2));
      offset += burst;
    }

    int redOffset = offset;
    int greenOffset = offset / 2;
    int blueOffset = offset;
    float channelNoise = noise(800 + glitchSeed * 0.009f, y * 0.06f, t * 1.7f);
    if (channelNoise > 0.68f) {
      redOffset += channelJitter;
    } else if (channelNoise < 0.32f) {
      blueOffset -= channelJitter;
    } else {
      greenOffset -= channelJitter / 2;
    }

    int bandEnd = min(y + clampedBandHeight, frame.height);
    for (int bandY = y; bandY < bandEnd; bandY++) {
      int rowIndex = bandY * frame.width;
      for (int x = 0; x < frame.width; x++) {
        // Sample each color channel from a slightly different horizontal position.
        color redSample = sourcePixels[rowIndex + wrapIndex(x + redOffset, frame.width)];
        color greenSample = sourcePixels[rowIndex + wrapIndex(x + greenOffset, frame.width)];
        color blueSample = sourcePixels[rowIndex + wrapIndex(x + blueOffset, frame.width)];
        frame.pixels[rowIndex + x] = color(red(redSample), green(greenSample), blue(blueSample));
      }

      // Bright comb artifacts help large tears read more like broken video hardware.
      if (abs(offset) > maxOffset * 0.8f) {
        for (int x = 0; x < frame.width; x += 6) {
          frame.pixels[rowIndex + x] = lerpColor(frame.pixels[rowIndex + x], color(255), 0.35f);
        }
      }
    }
  }

  frame.updatePixels();
}

int wrapIndex(int value, int limit) {
  int wrapped = value % limit;
  if (wrapped < 0) {
    wrapped += limit;
  }
  return wrapped;
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
    case LEFT:
      bandHeight = max(1, bandHeight - 1);
      setStatus("Band height " + bandHeight);
      break;
    case RIGHT:
      bandHeight = min(48, bandHeight + 1);
      setStatus("Band height " + bandHeight);
      break;
    case UP:
      tearChance = min(0.85f, tearChance + 0.03f);
      setStatus("Tear chance " + nf(tearChance, 1, 2));
      break;
    case DOWN:
      tearChance = max(0.0f, tearChance - 0.03f);
      setStatus("Tear chance " + nf(tearChance, 1, 2));
      break;
    }
    return;
  }

  switch(Character.toLowerCase(key)) {
  case '1':
    useImageSource = false;
    setStatus("Source: generated");
    break;
  case '2':
    loadStillImage();
    if (stillImage != null) {
      useImageSource = true;
      setStatus("Source: data/source.jpg");
    }
    break;
  case '[':
    maxOffset = max(8, maxOffset - 8);
    setStatus("Max offset " + maxOffset);
    break;
  case ']':
    maxOffset = min(width / 2, maxOffset + 8);
    setStatus("Max offset " + maxOffset);
    break;
  case 'r':
    reseedGlitch();
    break;
  case 's':
    saveFrame("ScanlineTearGlitch-######.png");
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

void loadStillImage() {
  PImage candidate = loadImage("source.jpg");
  if (candidate == null) {
    stillImage = null;
    useImageSource = false;
    setStatus("Missing data/source.jpg. Using generated source.");
    return;
  }

  if (candidate.width != width || candidate.height != height) {
    candidate.resize(width, height);
  }
  stillImage = candidate;
}

void reseedGlitch() {
  glitchSeed = int(random(100000));
  noiseSeed(glitchSeed);
  setStatus("Reseeded glitch map " + glitchSeed);
}

void drawHud() {
  if (!showHud) {
    return;
  }

  noStroke();
  fill(0, 180);
  rect(16, 16, 420, 118, 10);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(12);
  String sourceLabel = "generated";
  if (useImageSource && stillImage != null) {
    sourceLabel = "data/source.jpg";
  }

  text(
    "ScanlineTearGlitch\n" +
    "source: " + sourceLabel + "\n" +
    "[ ] offset: " + maxOffset + "   LEFT/RIGHT band: " + bandHeight + "\n" +
    "UP/DOWN tear chance: " + nf(tearChance, 1, 2) + "   R reseed   S save\n" +
    "1 generated   2 image   H hide HUD",
    28,
    28
  );

  if (millis() < statusExpiresAt) {
    fill(255, 220, 140);
    text(statusMessage, 28, 100);
  }
}

void setStatus(String message) {
  statusMessage = message;
  statusExpiresAt = millis() + 2500;
  println(message);
}
