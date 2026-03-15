import processing.video.*; 
Capture video;

PImage img1;
int w=640, h=480;

boolean bright = true;
boolean greyScale;
int shiftAmount = 4;
int grid = 1;
boolean hasFrame = false;


void setup() {
  size(640, 480);
  video = new Capture(this, w, h); 
  video.start();
}

void draw() { 
  if (!hasFrame) {
    background(0);
    return;
  }

  loadPixels(); // Fills pixelarray
  float mouseMap = (int) map(mouseX, 0, width, 0, 255*3); // Brightness threshold mapped to mouse coordinates

  if (shiftAmount > 24 || shiftAmount < 0) {
    shiftAmount = 0;
  };

  for (int y = 0; y< h; y++)
  {
    for (int x = 0; x< w; x++)
    {
      color c = video.pixels[y*video.width+x]; 
      int r = (c >> 16) & 0xFF;  
      int g = (c >> 8) & 0xFF;  
      int b = c & 0xFF; 

      if (y %grid == 0) {

        if (bright)
        {
          if (r+g+b > mouseMap) {
            pixels[y*w+x] = c << shiftAmount; // Bit-shift based on shift amount
          } else {
            pixels[y*w+x] = c;
          }
        }

        if (!bright)
        {
          if (r+g+b < mouseMap) {
            pixels[y*w+x] = c << shiftAmount; // Bit-shift based on shift amount
          } else {
            pixels[y*w+x] = c;
          }
        }
      } else {
        pixels[y*w+x] = c;
      }
    }
  }
  updatePixels();

  if (greyScale) {
    filter(GRAY);
  }

  println("Shift amount: " + shiftAmount + " Frame rate: " + (int) frameRate + " Greyscale: " + greyScale) ;
}

void keyPressed()
  // Keyboard controls
{
  switch(keyCode) {
  case UP:
    shiftAmount++;
    break;
  case DOWN:
    shiftAmount--;
    break;
  case LEFT:
    if (grid > 1) {
      grid--;
    }    
    break;
  case RIGHT:
    grid++;    
    break;
  case TAB:
    bright = !bright;
    break;
  case ENTER:
    greyScale = !greyScale;
    break;
  }
}

void captureEvent(Capture c) { 
  c.read();
  hasFrame = true;
}
