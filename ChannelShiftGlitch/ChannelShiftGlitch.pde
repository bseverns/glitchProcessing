/*

 Channel Shift Image Glitching Processing v1.1
 datamoshing.com | 2016
 
 */

PImage sourceImg;
PImage targetImg;

boolean glitchComplete = false;
boolean glitchSaved = false;

// script settings

// image path is relative to sketch directory
String imgFileName = "MyImage";
String fileType = "jpg";

// repeat the process this many times
int iterations = 5;

// use result image as new source for iterations
boolean recursiveIterations = false;

// shift the image vertically true/false
boolean shiftVertically = false;

// shift the image horizontally true/false
boolean shiftHorizontally = true;

void setup() {
  // load images into PImage variables
  targetImg = loadImage(imgFileName+"."+fileType);
  sourceImg = loadImage(imgFileName+"."+fileType);
  
  // use only numbers (not variables) for the size() command, Processing 3
  size(1, 1);

  // allow resize and update surface to image dimensions
  surface.setResizable(true);
  surface.setSize(targetImg.width, targetImg.height);

  // load image onto surface
  image(sourceImg, 0, 0);
}


void draw() { 
  if (!glitchComplete)
  {
    // load pixels
    sourceImg.loadPixels();
    targetImg.loadPixels();
  
    // repeat the process according to the iterations variable
    for(int i = 0;i < iterations;i++)
    {
      // generate random numbers for which channels to swap
      int sourceChannel = int(random(3));
      int targetChannel = int(random(3));
      
      // start with no horizontalShift
      int horizontalShift = 0; 
      
      // if shiftHorizontally is true, generate a random number to shift horizontally by
      if(shiftHorizontally)
        horizontalShift = int(random(targetImg.width));
      
      // start with no verticalShift
      int verticalShift = 0;
      
      // if shiftVertically is true, generate a random number to shift vertically by
      if(shiftVertically)
        verticalShift = int(random(targetImg.height));
      
      // shift the channel
      copyChannel(sourceImg.pixels, targetImg.pixels, verticalShift, horizontalShift, sourceChannel, targetChannel);
      
      // use the target as the new source for the next iteration
      if(recursiveIterations)
        sourceImg.pixels = targetImg.pixels;
    }
    
    // update the target pixels
    targetImg.updatePixels();
      
    // glitch is done, proceed to update surface and save
    glitchComplete = true;

    // load updated image onto surface
    image(targetImg, 0, 0, targetImg.width, targetImg.height);
  }

  if (glitchComplete && !glitchSaved) {

    // save surface
    targetImg.save(imgFileName+"_glitched.png");
    glitchSaved = true;
    println("Glitched image saved");
    println("Click or press any key to exit...");
  }
}

void copyChannel(color[] sourcePixels, color[] targetPixels, int sourceY, int sourceX, int sourceChannel, int targetChannel)
{
    // starting at the sourceY and pointerY loop through the rows
    for(int y = 0; y < targetImg.height; y++)
    {   
        // add y counter to sourceY
        int sourceYOffset = sourceY + y;
        
        // wrap around the top of the image if we've hit the bottom
        if(sourceYOffset >= targetImg.height)
          sourceYOffset -= targetImg.height;
              
        // starting at the sourceX and pointerX loop through the pixels in this row
        for(int x = 0; x < targetImg.width; x++)
        {
            // add x counter to sourceX
            int sourceXOffset = sourceX + x;
            
            // wrap around the left side of the image if we've hit the right side
            if(sourceXOffset >= targetImg.width)
              sourceXOffset -= targetImg.width;

            // get the color of the source pixel
            color sourcePixel = sourcePixels[sourceYOffset * targetImg.width + sourceXOffset];
            
            // get the RGB values of the source pixel
            float sourceRed = red(sourcePixel);
            float sourceGreen = green(sourcePixel);
            float sourceBlue = blue(sourcePixel);
   
            // get the color of the target pixel
            color targetPixel = targetPixels[y * targetImg.width + x]; 

            // get the RGB of the target pixel
            // two of the RGB channel values are required to create the new target color
            // the new target color is two of the target RGB channel values and one RGB channel value from the source
            float targetRed = red(targetPixel);
            float targetGreen = green(targetPixel);
            float targetBlue = blue(targetPixel);
            
            // create a variable to hold the new source RGB channel value
            float sourceChannelValue = 0;
            
            // assigned the source channel value based on sourceChannel random number passed in
            switch(sourceChannel)
            {
              case 0:
                // use red channel from source
                sourceChannelValue = sourceRed;
                break;
              case 1:
              // use green channel from source
                sourceChannelValue = sourceGreen;
                break;
              case 2:
              // use blue channel from source
                sourceChannelValue = sourceBlue;
                break;
            }
            
            // assigned the source channel value to a target channel based on targetChannel random number passed in
            switch(targetChannel)
            {
              case 0:
                // assign source channel value to target red channel
                targetPixels[y * targetImg.width + x] =  color(sourceChannelValue, targetGreen, targetBlue);
                break;
              case 1:
              // assign source channel value to target green channel
                targetPixels[y * targetImg.width + x] =  color(targetRed, sourceChannelValue, targetBlue);
                break;
              case 2:
                // assign source channel value to target blue channel
                targetPixels[y * targetImg.width + x] =  color(targetRed, targetGreen, sourceChannelValue);
                break;
            }

        }
    }
}

void keyPressed() {
  if (glitchSaved)
  {
    System.exit(0);
  }
}

void mouseClicked() {
  if (glitchSaved)
  {
    System.exit(0);
  }
}