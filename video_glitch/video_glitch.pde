//to glitch videos

import java.io.File;
import processing.video.*; 
Movie mov;

PImage img1;
int w=640, h=480;
boolean hasFrame = false;

boolean bright = true;
boolean greyScale;
int shiftAmount = 4;
int grid = 1;

void setup() {
  //fullScreen();
  size(640, 480);
  File movieFile = new File(dataPath("bath.mov"));
  if (!movieFile.exists()) {
    failFast("Missing input movie: data/bath.mov");
  }
  mov = new Movie(this, "bath.mov"); 
  mov.play();
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

  int frameWidth = min(width, mov.width);
  int frameHeight = min(height, mov.height);

  for (int y = 0; y< frameHeight; y++)
  {
    for (int x = 0; x< frameWidth; x++)
    {
      color c = mov.pixels[y*mov.width+x]; 
      int r = (c >> 16) & 0xFF;  
      int g = (c >> 8) & 0xFF;  
      int b = c & 0xFF; 

      if (y %grid == 0) {

        if (bright)
        {
          if (r+g+b > mouseMap) {
            pixels[y*width+x] = c << shiftAmount; // Bit-shift based on shift amount
          } else {
            pixels[y*width+x] = c;
          }
        }

        if (!bright)
        {
          if (r+g+b < mouseMap) {
            pixels[y*width+x] = c << shiftAmount; // Bit-shift based on shift amount
          } else {
            pixels[y*width+x] = c;
          }
        }
      } else {
        pixels[y*width+x] = c;
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

void movieEvent(Movie movie) {
  movie.read();
  hasFrame = true;
}

void failFast(String message) {
  println(message);
  exit();
}
