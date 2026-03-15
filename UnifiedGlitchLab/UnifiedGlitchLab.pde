import java.io.File;
import processing.video.*;

final int SOURCE_GENERATED = 0;
final int SOURCE_IMAGE = 1;
final int SOURCE_MOVIE = 2;
final int SOURCE_WEBCAM = 3;

PGraphics generatedSource;
PImage stillImage;
Movie movieSource;
Capture webcamSource;
PImage slitBuffer;

int sourceMode = SOURCE_GENERATED;
int shiftAmount = 5;
int threshold = 360;
int grid = 2;
int patchCount = 14;
int slitPosition = 0;

boolean channelShiftEnabled = true;
boolean noiseEnabled = false;
boolean bitShiftEnabled = true;
boolean slitScanEnabled = false;
boolean movieReady = false;
boolean webcamReady = false;
boolean showHelp = true;

String statusMessage = "Generated source active. Press H for controls.";
int statusExpiresAt = 0;

void setup() {
  size(960, 540, P2D);
  frameRate(30);
  generatedSource = createGraphics(width, height, P2D);
  setStatus("Generated source active. Press 2, 3, or 4 to try image, movie, or webcam.");
}

void draw() {
  PImage sourceFrame = acquireSourceFrame();
  if (sourceFrame == null) {
    background(0);
    drawHud();
    return;
  }

  PImage output = sourceFrame.get();
  if (channelShiftEnabled) {
    applyChannelShift(output);
  }
  if (noiseEnabled) {
    applyNoiseBlocks(output);
  }
  if (bitShiftEnabled) {
    applyBitShift(output);
  }

  PImage displayFrame = output;
  if (slitScanEnabled) {
    updateSlitScan(output);
    displayFrame = slitBuffer;
  }

  image(displayFrame, 0, 0, width, height);
  drawHud();
}

PImage acquireSourceFrame() {
  switch(sourceMode) {
  case SOURCE_IMAGE:
    if (stillImage == null) {
      loadStillImage();
    }
    if (stillImage != null) {
      return stillImage;
    }
    break;
  case SOURCE_MOVIE:
    ensureMovie();
    if (movieSource != null && movieReady) {
      return movieSource;
    }
    break;
  case SOURCE_WEBCAM:
    ensureWebcam();
    if (webcamSource != null && webcamReady) {
      return webcamSource;
    }
    break;
  default:
    break;
  }

  renderGeneratedSource();
  return generatedSource;
}

void renderGeneratedSource() {
  float t = millis() * 0.001f;
  generatedSource.beginDraw();
  generatedSource.colorMode(HSB, 255);
  generatedSource.background(8, 180, 24);

  for (int x = 0; x < generatedSource.width; x += 24) {
    float hue = (x * 0.18f + t * 80.0f) % 255;
    float stripeHeight = generatedSource.height * (0.35f + 0.3f * sin(t + x * 0.01f));
    generatedSource.noStroke();
    generatedSource.fill(hue, 180, 255, 180);
    generatedSource.rect(x, generatedSource.height - stripeHeight, 18, stripeHeight);
  }

  generatedSource.noFill();
  for (int i = 0; i < 8; i++) {
    float orbit = t * (0.6f + i * 0.08f);
    float cx = generatedSource.width * (0.5f + 0.28f * sin(orbit + i));
    float cy = generatedSource.height * (0.5f + 0.22f * cos(orbit * 1.2f + i));
    float radius = 60 + 24 * i + 18 * sin(orbit * 2.0f);
    generatedSource.stroke((40 * i + 120) % 255, 120, 255, 170);
    generatedSource.strokeWeight(2);
    generatedSource.ellipse(cx, cy, radius, radius * 0.7f);
  }

  generatedSource.colorMode(RGB, 255);
  generatedSource.endDraw();
}

void applyChannelShift(PImage frame) {
  frame.loadPixels();
  color[] sourcePixels = new color[frame.pixels.length];
  arrayCopy(frame.pixels, sourcePixels);

  int sourceChannel = int(random(3));
  int targetChannel = int(random(3));
  int offsetX = int(random(max(1, frame.width)));
  int offsetY = int(random(max(1, frame.height)));

  for (int y = 0; y < frame.height; y++) {
    int shiftedY = (y + offsetY) % frame.height;
    for (int x = 0; x < frame.width; x++) {
      int shiftedX = (x + offsetX) % frame.width;
      int sourceIndex = shiftedY * frame.width + shiftedX;
      int targetIndex = y * frame.width + x;

      color sourcePixel = sourcePixels[sourceIndex];
      color targetPixel = frame.pixels[targetIndex];

      float sr = red(sourcePixel);
      float sg = green(sourcePixel);
      float sb = blue(sourcePixel);
      float tr = red(targetPixel);
      float tg = green(targetPixel);
      float tb = blue(targetPixel);
      float channelValue = sr;

      switch(sourceChannel) {
      case 1:
        channelValue = sg;
        break;
      case 2:
        channelValue = sb;
        break;
      default:
        break;
      }

      switch(targetChannel) {
      case 0:
        frame.pixels[targetIndex] = color(channelValue, tg, tb);
        break;
      case 1:
        frame.pixels[targetIndex] = color(tr, channelValue, tb);
        break;
      case 2:
        frame.pixels[targetIndex] = color(tr, tg, channelValue);
        break;
      }
    }
  }

  frame.updatePixels();
}

void applyNoiseBlocks(PImage frame) {
  int minPatchWidth = min(18, frame.width);
  int minPatchHeight = min(18, frame.height);
  int maxPatchWidth = max(minPatchWidth, min(frame.width, 140));
  int maxPatchHeight = max(minPatchHeight, min(frame.height, 140));

  for (int i = 0; i < patchCount; i++) {
    int patchWidth = minPatchWidth;
    int patchHeight = minPatchHeight;
    if (maxPatchWidth > minPatchWidth) {
      patchWidth = int(random(minPatchWidth, maxPatchWidth + 1));
    }
    if (maxPatchHeight > minPatchHeight) {
      patchHeight = int(random(minPatchHeight, maxPatchHeight + 1));
    }
    int sourceX = int(random(max(1, frame.width - patchWidth)));
    int sourceY = int(random(max(1, frame.height - patchHeight)));
    int destX = int(random(max(1, frame.width - patchWidth)));
    int destY = int(random(max(1, frame.height - patchHeight)));
    frame.copy(frame, sourceX, sourceY, patchWidth, patchHeight, destX, destY, patchWidth, patchHeight);
  }
}

void applyBitShift(PImage frame) {
  frame.loadPixels();
  int clampedGrid = max(1, grid);

  for (int y = 0; y < frame.height; y++) {
    for (int x = 0; x < frame.width; x++) {
      int index = y * frame.width + x;
      color c = frame.pixels[index];
      int r = (c >> 16) & 0xFF;
      int g = (c >> 8) & 0xFF;
      int b = c & 0xFF;

      if (y % clampedGrid == 0 && r + g + b > threshold) {
        frame.pixels[index] = (c << shiftAmount) | 0xFF000000;
      }
    }
  }

  frame.updatePixels();
}

void updateSlitScan(PImage frame) {
  if (slitBuffer == null || slitBuffer.width != frame.width || slitBuffer.height != frame.height) {
    slitBuffer = createImage(frame.width, frame.height, RGB);
    slitBuffer.loadPixels();
    for (int i = 0; i < slitBuffer.pixels.length; i++) {
      slitBuffer.pixels[i] = color(0);
    }
    slitBuffer.updatePixels();
    slitPosition = 0;
  }

  frame.loadPixels();
  slitBuffer.loadPixels();

  int sourceColumn = frame.width / 2;
  for (int y = 0; y < frame.height; y++) {
    int sourceIndex = y * frame.width + sourceColumn;
    int targetIndex = y * slitBuffer.width + slitPosition;
    slitBuffer.pixels[targetIndex] = frame.pixels[sourceIndex];
  }

  slitBuffer.updatePixels();
  slitPosition = (slitPosition + 1) % slitBuffer.width;
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
    case UP:
      threshold = min(765, threshold + 24);
      setStatus("Threshold " + threshold);
      break;
    case DOWN:
      threshold = max(0, threshold - 24);
      setStatus("Threshold " + threshold);
      break;
    case LEFT:
      grid = max(1, grid - 1);
      setStatus("Grid " + grid);
      break;
    case RIGHT:
      grid++;
      setStatus("Grid " + grid);
      break;
    }
    return;
  }

  switch(Character.toLowerCase(key)) {
  case '1':
    sourceMode = SOURCE_GENERATED;
    resetSlitScan();
    setStatus("Source: generated");
    break;
  case '2':
    if (loadStillImage()) {
      sourceMode = SOURCE_IMAGE;
      resetSlitScan();
      setStatus("Source: data/source.jpg");
    }
    break;
  case '3':
    if (ensureMovie()) {
      sourceMode = SOURCE_MOVIE;
      resetSlitScan();
      setStatus("Source: data/source.mov");
    }
    break;
  case '4':
    if (ensureWebcam()) {
      sourceMode = SOURCE_WEBCAM;
      resetSlitScan();
      setStatus("Source: webcam");
    }
    break;
  case 'q':
    channelShiftEnabled = !channelShiftEnabled;
    setStatus("Channel shift " + onOff(channelShiftEnabled));
    break;
  case 'w':
    noiseEnabled = !noiseEnabled;
    setStatus("Noise collage " + onOff(noiseEnabled));
    break;
  case 'e':
    bitShiftEnabled = !bitShiftEnabled;
    setStatus("Bit shift " + onOff(bitShiftEnabled));
    break;
  case 'r':
    slitScanEnabled = !slitScanEnabled;
    resetSlitScan();
    setStatus("Slit-scan " + onOff(slitScanEnabled));
    break;
  case '[':
    shiftAmount = max(1, shiftAmount - 1);
    setStatus("Shift amount " + shiftAmount);
    break;
  case ']':
    shiftAmount = min(24, shiftAmount + 1);
    setStatus("Shift amount " + shiftAmount);
    break;
  case '-':
    patchCount = max(1, patchCount - 1);
    setStatus("Patch count " + patchCount);
    break;
  case '=':
  case '+':
    patchCount++;
    setStatus("Patch count " + patchCount);
    break;
  case 's':
    saveFrame("unified-glitch-######.png");
    setStatus("Saved frame to sketch folder");
    break;
  case 'h':
    showHelp = !showHelp;
    break;
  }
}

boolean loadStillImage() {
  File imageFile = new File(dataPath("source.jpg"));
  if (!imageFile.exists()) {
    setStatus("No data/source.jpg found. Using generated source.");
    stillImage = null;
    return false;
  }

  stillImage = loadImage("source.jpg");
  if (stillImage == null) {
    setStatus("Could not load data/source.jpg. Using generated source.");
    return false;
  }

  return true;
}

boolean ensureMovie() {
  if (movieSource != null) {
    return true;
  }

  File movieFile = new File(dataPath("source.mov"));
  if (!movieFile.exists()) {
    setStatus("No data/source.mov found. Using generated source.");
    return false;
  }

  movieSource = new Movie(this, "source.mov");
  movieSource.loop();
  movieReady = false;
  return true;
}

boolean ensureWebcam() {
  if (webcamSource != null) {
    return true;
  }

  String[] cameras = Capture.list();
  if (cameras == null || cameras.length == 0) {
    setStatus("No webcam detected. Using generated source.");
    return false;
  }

  webcamSource = new Capture(this, cameras[0]);
  webcamSource.start();
  webcamReady = false;
  return true;
}

void movieEvent(Movie movie) {
  movie.read();
  movieReady = true;
}

void captureEvent(Capture capture) {
  capture.read();
  webcamReady = true;
}

void drawHud() {
  fill(0, 170);
  noStroke();
  rect(12, 12, 360, showHelp ? 186 : 42, 10);

  fill(255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("UnifiedGlitchLab  source: " + sourceName(sourceMode), 24, 24);

  if (millis() < statusExpiresAt) {
    text(statusMessage, 24, 46);
  }

  if (!showHelp) {
    return;
  }

  String info =
    "1 generated  2 image  3 movie  4 webcam\n" +
    "Q channel shift  W noise collage  E bit shift  R slit-scan\n" +
    "[ / ] shift amount: " + shiftAmount + "\n" +
    "UP / DOWN threshold: " + threshold + "\n" +
    "LEFT / RIGHT grid: " + grid + "\n" +
    "- / + patch count: " + patchCount + "\n" +
    "S save frame  H hide help";
  text(info, 24, 72);
}

void resetSlitScan() {
  slitBuffer = null;
  slitPosition = 0;
}

String sourceName(int mode) {
  switch(mode) {
  case SOURCE_IMAGE:
    return "image";
  case SOURCE_MOVIE:
    return "movie";
  case SOURCE_WEBCAM:
    return "webcam";
  default:
    return "generated";
  }
}

String onOff(boolean value) {
  if (value) {
    return "on";
  }
  return "off";
}

void setStatus(String message) {
  statusMessage = message;
  statusExpiresAt = millis() + 5000;
  println(message);
}
