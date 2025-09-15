/*
 * Copyright (c) 2011, Paul Hertz This code is free software; you can
 * redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version
 * 3.0 of the License, or (at your option) any later version.
 * http://www.gnu.org/licenses/lgpl.html This software is distributed in
 * the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Lesser General Public License for more details. You should have
 * received a copy of the GNU Lesser General Public License along with this
 * library; if not, write to the Free Software Foundation, Inc., 51 Franklin St,
 * Fifth Floor, Boston, MA 02110-1301, USA
 * 
 * @author    Paul Hertz
 * @created   July 13, 2012 
 * @modified  June 6, 2013
 * @version   1.0b10 for Processing 2.0
 *        - various minor changes. The biggest change is that this version runs in Processing 2.0
 *        - Same old manual
 *        - save (s) and save a copy (S) commands, revert to saved (r) and revert to original (R)
 *        - open file (o) and load file to snapshot buffer (O)
 *        - rotate right (t) and rotate left (T)
 *        - added zigzag percent number box, sets percent of blocks that get zigzag sorted on each pass
 *        - ***** requires Processing 2.0, processing.org  *****
 *        - ***** requires ControlP5 2.0.4, www.sojamo.de/code ***** 
 * version    1.0b9 for Processing 1.5.1
 *        - added '_' (underscore) key command to turn 4 times repeating lastCommand
 *        - fixed dragging to work both when control panel is visible and when it is not, 
 *          without shift key--covers most cases, but doesn't track collapsed panels
 *        - added scaledLowPass method, low pass filter each RGB channel with different 
 *          FFT block size (64, 32, 16), component order depends on current Component Sorting Order setting
 *                Currently only triggered with ')' key command, works best when pixel dimension are multiples of 64.
 *        - added ZigzagStyle enum and zigzagStyle variable to set zigzag sorting to random angles, aligned angles, 
 *          or angles permuted in blocks of four
 *        - added global variables for control panel location and width
 *        - added flipX and flipY methods to Zigzagger to handle changing zigzag angle
 *        - changed default settings of statistical FFT
 *        - various small fixes 
 * version  1.0b8a
 *        - changes from last version
 *        - fixed denoise command to include edge and corner pixels
 *        - added lastCommand variable, tracks last key command in "gl<>9kjdGLKJD" 
 * This version has a new reference manual for version 1.0b8. 
 * If it wasn't included, see http://paulhertz.net/factory/2012/08/glitchsort2/.
 *        
 * 
 */ 

// uses pixel sorting to imitate wild glitches
// by Paul Hertz, 2012
// http://paulhertz.net/
// updates: http://paulhertz.net/factory/2012/08/glitchsort2/
// requires: 
//   Processing: http://processing.org/
//   ControlP5 library for Processing: http://www.sojamo.de/libraries/controlP5/


// ISSUES
// 0. Processing 2.0 resolved the image memory leak problem: this version of GlitchSort runs in Processing 2.0 (not 1.5.1!).
// 1. Type 'r' (reload) or 'f' fit to screen after loading the first picture to get correct window size. (Processing 1.5.1).
// 2. Using return key to load a file from the file dialog sometimes causes application to hang. Double-click works.
// 3. The display window may still hide a row or two of pixels, though I think I have 
//    fixed this. You can drag it a little bigger.
// 4. Audify ('/' and '\' is new and still kludgy, but the bugs that would cause a crash in 
//   1.0b7 pre-release "c" seem to have been fixed.
// 5. The Minim library routines I use for FFT are now deprecated, but functional. 
// 6. There must be other issues. 


import java.awt.Container;
import java.awt.Frame;
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.io.*;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import javax.imageio.*;
import javax.imageio.stream.*;

import processing.core.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

import controlP5.*;


// uses pixel sorting, quantization, FFT, etc. to imitate wild glitches, audifies pixels
// by Paul Hertz, 2012
// http://paulhertz.net/

// press spacebar to show or hide the control panel
// option-drag on control panel bar to move control panel
// shift-drag on image to pan large image (no shift key needed if control panel is hidden)
// press 'f' to toggle fit image to screen
// press 'o' to open a file
// press 'O' to load a file to the snapshot buffer
// press 's' to save display to a timestamped .png file
// press 'S' to save display to a timestamped .png file as a copy
// press 'r' to revert to the most recently saved version of the file
// press 'R' to revert to the oldest version of the file
// press 't' to turn the image 90 clockwise
// press 'g' to sort the pixels (glitch)
// press 'l' to sort in zigzag-scanned blocks
// press 'z' to undo the last action
// press '1' to select quick sort
// press '2' to select shell sort
// press '3' to select bubble sort
// press '4' to select insert sort
// press 'a' to change sort order to ascending or descending
// press 'b' to toggle random breaks in sorters
// press 'x' to toggle color channel swapping (glitchy!)
// press 'c' to step through the color channels swaps
// press '+' or '-' to step through color component orderings used for sorting
// press 'y' to turn glitch cycling on and off (for glitch steps > 1)
// press '[' or ']' to decrease or increase glitch steps
// press '{' or '}' to cycle through Shell sort settings
// press 'd' to degrade the image with low quality JPEG compression
// press UP or DOWN arrow keys to change degrade quality
// press 'p' to reduce (quantize) the color palette of the image
// press LEFT or RIGHT arrow keys to change color quantization
// press '<' or ',' to shift selected color channel one pixel left
// press '>' or '.' to shift selected color channel one pixel right
// press '9' to denoise image with a median filter
// press 'n' to grab a snapshot of the current image
// press 'u' to load the most recent snapshot
// press 'm' to munge the current image with the most recent snapshot and the undo buffer
// press 'j' to apply equalizer FFT
// press 'k' to apply statistical FFT
// press '/' to turn audify on and execute commands on a single block of pixels
// press '\' to turn audify off
// press '_' to turn 90 degrees and execute last command, four times
// press ')' to run scaled low pass filter
// press 'v' to turn verbose output on and off
// press 'h' to show help message


/* TODO  teh list
 * 
 * bug fix for sorting - blocks or lines get skipped (done)
 * "real-time" compositing preview
 * break out commands into command pattern class that can be effectively journaled
 * create a genetic algorithm driven version
 * sorting breaks at user-selected pixel value
 * interactive channel-shifting
 * more buffers
 * save and load FFT settings
 * termites
 * performance interface
 *     load image list and step through it (with programmable Markov chaining)
 *     multiple buffers
 *     pass audio to another app with osc
 *     perhaps: use new version of minim library
 *     "Stick" audio sources to locations, select multiple blocks
 *     real time glitch from camera
 * 
 * 
 */

/** the current component order to use for sorting */
CompOrder compOrder;
/** handy variable for stepping through the CompOrder enum */
int compOrderIndex = 0;
/** the current channel swapping scheme for glitchy color fx */
SwapChannel swap = SwapChannel.BB;
/** current format of pixels to use in sorting a subarray of pixels from an image */
SortFormat format = SortFormat.ROW;
/** default is random orientations for zigzag sorting */
ZigzagStyle zigzagStyle = ZigzagStyle.RANDOM;
/** a SortSelector offers a strategy to manage different sorting algorithms */
SortSelector sortTool;
/** the most recently saved version of the selected file */
File displayFile;
/** the original file, selected with the 'open' command */
File originalFile;
/** the primary image to display and glitch */
PImage img;
/** an image buffer used to undo the most recent operation, usually contains an earlier version of the primary image */
PImage bakImg;
/** a version of the image scaled to fit the screen dimensions, for display only */
PImage fitImg;
/** a snapshot of the primary image, used as an extended undo buffer and for the "munge" operation */
PImage snapImg;
/** true if image should fit screen, otherwise false */
boolean isFitToScreen = false;
/** maximum width for the display window */
int maxWindowWidth;
/** maximum height for the display window */
int maxWindowHeight;
/** width of the image when scaled to fit the display window */
int scaledWidth;
/** height of the image when scaled to fit the display window */
int scaledHeight;
/** current width of the frame (display window) */
int frameWidth;
/** current height of the frame (display window) */
int frameHeight;
/** flags when a large image can be dragged (translated) in the display window */
boolean isDragImage = false;
/** translation on the x-axis for an image larger than the display window */
int transX = 0;
/** translation on the y-axis for an image larger than the display window */
int transY = 0;
/** reference to the frame (display window) */
Frame myFrame;
/** true if sorting is interrupted, causing glitches. if false, horizontal lines of pixels are completely sorted */
boolean randomBreak = true;
/** true if lots of output to the monitor is desired (useful for debugging) */
boolean verbose = false;
/** true if pixels values are sorted in ascending numeric order */
boolean isAscendingSort = false;
/** true if pixels that are exchanged in sorting swap a pair of channels, creating color artifacts */
boolean isSwapChannels = false;
/** an array of row numbers for the horizontal lines of pixels, used when sorting */
int[] rowNums;
/** the current row of pixels being sorted */
int row = 0;  
/** 
 * a value from 1..999 that determines how often a sorting method is interrupted.  
 * In general, higher values decrease the probability of interruption, and so do more sorting. 
 * However, each sorting method behaves differently. Quick sort is sensitive from 1..999. 
 * Shell sort seems to do best from 900..999; lower values result in sorting only at the the image edge.
 * Bubble sort does well from 990..999: at 999 it will diffuse the pixels. Insert sort seems 
 * to be effective from 990..999. 
 * TODO: create a more intuitive setting for breakpoint, with greater precision where needed.
 */
float breakPoint = 500;
/** number of partitions of pixel rows, (1/glitchSteps * number of rows) rows of pixels 
  are sorted (glitched) each time the sort command is executed */
float glitchSteps = 1;
/** if true, sorting steps are cyclical: rows will be sorted by successive sort commands
  and the order in which rows are sorted will not be shuffled until all rows are sorted. 
  if false, the 1/glitchSteps rows are sorted and then the row order is shuffled */
boolean isCycleGlitch = false;
RangeManager ranger; 
RangeManager zigzagRanger; 
/** the JPEG quality setting for degrading the image by saving it as a JPEG and then reloading it */
float degradeQuality = 0.125f;
/** the value below which the maximum absolute difference between color channel values induces munging */
int mungeThreshold = 16;
/** "munging" compares the current image with the undo buffer. When isMungeInverted is false, 
 * pixels outside the difference threshold are replaced with corresponding pixels from the snapshot buffer.
 * When isMungeInverted is true, pixels within the threshold are replaced. */
boolean isMungeInverted = false;
/** Color quantizer, for color reduction, using an octree.  */
ImageColorQuantizer quant;
/** The number of colors to reduce to, should not exceed 255 limit imposed by octree */
int colorQuantize = 32;
/** maximum dimension of zigzag sorting block */
int zigzagCeiling = 64;
/** minimum dimension of zigzag sorting block */
int zigzagFloor = 8;
/** percentage of blocks that will be zigzag sorted */
float zigzagPercent = 100.0f;
// ratio and divisor values for Shell sort, feel free to add your own pairs
int[] shellParams = {2,3, 2,5, 3,5, 3,7, 3,9, 4,7, 4,9, 5,7, 5,9, 5,11, 8,13};
// shell params index
int shellIndex = 8;
boolean isShiftR = true;
boolean isShiftG = false;
boolean isShiftB = false;
// file count for filenames in sequence
int fileCount = 0;
// timestamp for filenames
String timestamp; 

// FFT
Minim minim;
FFT fft;
int zigzagBlockWidth = 128;
int fftBlockWidth = 64;
int bufferSize;
float sampleRate = 44100.0f;
public float eqMax = 1;
public float eqMin = -1;
public float eqScale = 1;
public float eqGain = 1;
float[] eq;
//* array to store average amplitude for each range of bands in averaged FFT */
double[] binTotals;
//* array to store band indices in averaged FFT band, has some problems */
ArrayList<IntRange> bandList;
//* array to store band low and high frequencies for each averaged FFT band */
ArrayList<FloatRange> freqList;
int minBandWidth = 11;
int bandsPerOctave = 3;
/** when we call calculateEqBands, the actual number of bands may differ from the internal value  */
int calculatedBands;
/** default maximum number of eq bands */
int eqBands = 33;
boolean isEqGlitchBrightness = true;
boolean isEqGlitchHue = false;
boolean isEqGlitchSaturation = false;
boolean isEqGlitchRed = false;
boolean isEqGlitchGreen = false;
boolean isEqGlitchBlue = false;
int eqPos = 0;
boolean isStatGlitchBrightness = true;
boolean isStatGlitchHue = false;
boolean isStatGlitchSaturation = false;
boolean isStatGlitchRed = false;
boolean isStatGlitchGreen = false;
boolean isStatGlitchBlue = false;
/** for statistical FFT, number of standard deviations to the left of mean */
public float leftBound = -0.25f, defaultLeftBound = leftBound;
/** for statistical FFT, number of standard deviations to the right of mean */
public float rightBound = 5.0f, defaultRightBound = rightBound;
/** factor to multiiply values within left and right bounds of mean */
float boost = 2.0f, defaultBoost = boost;
/** factor to multiply values outside left and right bounds of mean */
float cut = 0.5f, defaultCut = cut;
public boolean isLowFrequencyCut = true;
float[] audioBuf;

// Control Panel
ControlP5 controlP5;
Group settings;
Group fftSettings;
Tab settingsTab;
Tab fftSettingsTab;
public int eqH = 100;
public int controlPanelHeight = 392;
public int controlPanelWidth = 284;
public int controlPanelX = 4;
public int controlPanelY = 36;
DecimalFormat twoPlaces;
DecimalFormat noPlaces;
List<ControllerInterface<?>> mouseControls;
String sliderIdentifier = "_eq";

// Audio
char lastCommand;
public GlitchSignal glitchSignal;
public AudioOutput out;


public void setup() {
  println("Display: "+ displayWidth +", "+ displayHeight);
  size(640, 480);
  smooth();
  // max window width is the screen width
  maxWindowWidth = displayWidth;
  // leave window height some room for title bar, etc.
  maxWindowHeight = displayHeight - 56;
  // image to display
  img = createImage(width, height, ARGB);
  // image for undo 
  bakImg = createImage(width, height, ARGB);
  // the primary tool for sorting
  sortTool = new SortSelector();
  sortTool.setRandomBreak(randomBreak);
  // initial order of color channels for sorting
  compOrder = CompOrder.values()[compOrderIndex];
  // initialize number formatters
  initDecimalFormat();
  initFFT();
  // initialize ControlP5 and build our control panels
  controlP5 = new ControlP5(this);
  // load Glitch panel
  loadGlitchPanel();
  // load FFT panel
  loadFFTPanel(eqH, eqMin, eqMax);
  // initialize panel settings, now that panels are loaded
  initPanelSettings();
  printHelp();
  // TODO include version number here
  println("GlitchSort version 1.0b10, created June 6, 2013, for Processing 2.0");
  // okay now to open an image file
  chooseFile();
  // Processing initializes the frame and hands it to you in the "frame" field.
  // Eclipse does things differently. Use findFrame method to get the frame in Eclipse.
  myFrame = findFrame();
  myFrame.setResizable(true);
  // the first time around, window won't be resized, a reload should resize it
  revert(false);
  // initialize timestamp, used in filename
  // timestamp = year() + nf(month(),2) + nf(day(),2) + "-"  + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
  timestamp = nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
}

/* (non-Javadoc)
 * @see processing.core.PApplet#stop()
 * we need this to assure that minim stops on exit
 */
public void stop() {
  minim.stop();
  super.stop();
}

/**
 * Sets up FFT buffer at fftBlockWidth * fftBlockWidth, calls calculateEqBands to calculates the number 
 * of equalizer bands available for current buffer size, initializes eq array.
 */
public void initFFT() {
  minim = new Minim(this);
  // we process square blocks of pixels as if they were an audio signal
  bufferSize = fftBlockWidth * fftBlockWidth;
  fft = new FFT(bufferSize, sampleRate);
  // we do our own calculation of logarithmic bands
  calculateEqBands();
  // calculateEqBnds sets the variable calculatedBands
  eq = new float[calculatedBands];
  java.util.Arrays.fill(eq, 0);
}

/**
 * @param newSize   new size for edge of a pixel block, must be a power of 2
 */
public void resetFFT(int newSize) {
  fftBlockWidth = newSize;
  if (true) println("-- fftBlockWidth = "+ fftBlockWidth);
  // reset the slider, usually redundant call, should have no side effects if broadcast is off
  Slider s4 = (Slider) controlP5.getController("setFFTBlockWidth"); 
  s4.setBroadcast(false);
  s4.setValue((int) Math.sqrt(fftBlockWidth));
  s4.setBroadcast(true);
  // redraw the text label for the block size, on our control panel
  Textlabel l11 = (Textlabel) controlP5.getController("blockSizeLabel");
  l11.setText("FFT Block Size = "+ fftBlockWidth);
  // we process square blocks of pixels as if they were an audio signal
  bufferSize = fftBlockWidth * fftBlockWidth;
  fft = new FFT(bufferSize, sampleRate);
  println("  fft timesize = "+ fft.timeSize());
  // we do our own calculation of logarithmic bands
  calculateEqBands();
  // calculateEqBnds sets the variable calculatedBands for the new size of pixel block
  eq = new float[calculatedBands];
  java.util.Arrays.fill(eq, 0);
  // create a new equalizer on the FFT control panel
  // setupEqualizer(eqPos, eqH, eqMax, eqMin);
  showEqualizerBands();
}

/**
 * initializes the zero place and two place decimal number formatters
 */
public void initDecimalFormat() {
  // DecimalFormat sets formatting conventions from the local system, unless we tell it otherwise.
  // make sure we use "." for decimal separator, as in US, not a comma, as in many other countries 
  Locale loc = Locale.US;
  DecimalFormatSymbols dfSymbols = new DecimalFormatSymbols(loc);
  dfSymbols.setDecimalSeparator('.');
  twoPlaces = new DecimalFormat("0.00", dfSymbols);
  noPlaces = new DecimalFormat("00", dfSymbols);
}

/**
 * @return   Frame where Processing draws, useful method in Eclipse
 */
public Frame findFrame() {
  Container f = this.getParent();
  while (!(f instanceof Frame) && f!=null)
    f = f.getParent();
  return (Frame) f;
}

/**
 * Prints help message to the console
 */
public void printHelp() {
  println("press spacebar to show or hide the control panel");
  println("option-drag on control panel bar to move control panel");
  println("shift-drag on image to pan large image (no shift key needed if control panel is hidden)");
  println("press 'f' to toggle fit image to screen");
  println("press 'o' to open a file");
  println("press 'O' to load a file to the snapshot buffer");
  println("press 's' to save display to a timestamped .png file");
  println("press 'S' to save display to a timestamped .png file as a copy");
  println("press 'r' to revert to the most recently saved version of the file");
  println("press 'R' to revert to the oldest version of the file");
  println("press 't' to turn the image 90 clockwise");
  println("press 'g' to sort the pixels (glitch)");
  println("press 'l' to sort in zigzag-scanned blocks");
  println("press 'z' to undo the last action");
  println("press '1' to select quick sort");
  println("press '2' to select shell sort");
  println("press '3' to select bubble sort");
  println("press '4' to select insert sort");
  println("press 'a' to change sort order to ascending or descending");
  println("press 'b' to toggle random breaks in sorters");
  println("press 'x' to toggle color channel swapping (glitchy!)");
  println("press 'c' to step through the color channels swaps");
  println("press '+' or '-' to step through color component orderings used for sorting");
  println("press 'y' to turn glitch cycling on and off (for glitch steps > 1)");
  println("press '[' or ']' to decrease or increase glitch steps");
  println("press '{' or '}' to cycle through Shell sort settings");
  println("press 'd' to degrade the image with low quality JPEG compression");
  println("press UP or DOWN arrow keys to change degrade quality");
  println("press 'p' to reduce (quantize) the color palette of the image");
  println("press LEFT or RIGHT arrow keys to change color quantization");
  println("press '<' or ',' to shift selected color channel one pixel left");
  println("press '>' or '.' to shift selected color channel one pixel right");
  println("press '9' to denoise image with a median filter");
  println("press 'n' to grab a snapshot of the current image");
  println("press 'u' to load the most recent snapshot");
  println("press 'm' to munge the current image with the most recent snapshot and the undo buffer");
  println("press 'j' to apply equalizer FFT");
  println("press 'k' to apply statistical FFT");
  println("press '/' to turn audify on and execute commands on a single block of pixels");
  println("press '\' to turn audify off");
  println("press '_' to turn 90 degrees and execute last command, four times");
  println("press ')' to run scaled low pass filter");
  println("press 'v' to turn verbose output on and off");
  println("press 'h' to show help message");
}


public void draw() {
  if (isFitToScreen) {
    image(fitImg, 0, 0);
  }
  else {
    background(255);
    image(img, -transX, -transY);
  }
  trackMouseEq();
}

/**
 * Experimental tool for setting a command sequence in variable cmd
 */
public void commandSequence() {
  String cmd;
  // (rotate zigzag save) 4 rotation sequence
  // cmd = "lcstlctttsttlcttstttlcts";
  // (degrade undo munge) 8 times
  // cmd = "dzmdzmdzmdzmdzmdzmdzmdzm";
  // (FFT:4 turn FFT:4 turn:3)
  // cmd = "kkkktkkkkttt";
  // (FFT turn):4
  // cmd = "ktktktkt";
  // (zigzag turn munge cycle)
  // cmd = "lmtltttmttlttmtttltm";
  // (zigzag turn cycle)
  cmd = "ltltltlt";
  // rpzimi[dzm]:
  exec(cmd);
}

/**
 * Experimental tool for executing a command sequence
 */
public void commandSequence(char cue) {
  String cmd;
  // (char in turn cycle)
  cmd = "t"+ cue +"t"+ cue +"t"+ cue +"t"+ cue;
  // rpzimi[dzm]:
  exec(cmd);
}

/**
 * Executes a supplied command sequence
 * @param cmd   a command sequence
 */
public void exec(String cmd) {
  char[] cycle = cmd.toCharArray();
  for (char ch : cycle) {
    decode(ch);
  }
}

/**
 * Demo method of a brief animation output as PNG files 
 */
public void anim() {
  zigzagFloor = 24;
  zigzagCeiling = 96;
  this.setAscending(true, false);
  this.setCompOrder(CompOrder.HSB.ordinal(), false);
  this.setSwap(SwapChannel.BB, false);
  this.setIsSwapChannels(true, false);
  String cmd = "nskl stlttt sttltt stttltmc";
  for (int i = 0; i < 8; i++) {
    exec(cmd);
  }
}


/**
 * Uses statistical FFT to reduce high frequencies in R, G and B channels. Each channel is
 * processed separately at a different scale (64, 32, and 16 pixel wide blocks). The order
 * of the channels is determined by the current Component Sorting Order settings. If the setting
 * uses the RGB channels, that setting determines the channel order; otherwise, a random RGB order
 * is used. Once processed, the image is ready to be sharpened again with the statistical FFT
 * (key command 'k'). Amazingly, the information trhown out by the lowpass can be reasonably well
 * reconstructed, but of course it's glitchy. If the image dimensions are not evenly divisible by 64,
 * artifacts will result. 
 */
public void scaledLowPass() {
  int savedCompOrderIndex = compOrderIndex;
  String ordStr = CompOrder.values()[compOrderIndex].toString();
  if (compOrderIndex > CompOrder.BGR.ordinal()) {
    ordStr = CompOrder.values()[(int) random(6)].toString();
  }
  this.setCompOrder(CompOrder.HSB.ordinal(), false);
  this.setAscending(true, false);
  setIsSwapChannels(true, false);
  this.setSwap(SwapChannel.BB, false);
  // exec("t1gttt");
  setRightBound(-0.5f);
  setLeftBound(-5f);
  if (ordStr.charAt(0) == 'R') {
    setStatChan(false, false, false, true, false, false, false);
  }
  else if (ordStr.charAt(0) == 'G') {
    setStatChan(false, false, false, false, true, false, false);
  }
  else {
    setStatChan(false, false, false, false, false, true, false);
  }
  setFFTBlockWidth(4);
  exec("tktktktk");
  if (ordStr.charAt(1) == 'R') {
    setStatChan(false, false, false, true, false, false, false);
  }
  else if (ordStr.charAt(1) == 'G') {
    setStatChan(false, false, false, false, true, false, false);
  }
  else {
    setStatChan(false, false, false, false, false, true, false);
  }
  setFFTBlockWidth(5);    
  exec("tktktktk");
  if (ordStr.charAt(2) == 'R') {
    setStatChan(false, false, false, true, false, false, false);
  }
  else if (ordStr.charAt(2) == 'G') {
    setStatChan(false, false, false, false, true, false, false);
  }
  else {
    setStatChan(false, false, false, false, false, true, false);
  }
  setFFTBlockWidth(6);    
  exec("tktktktk");
  setStatChan(true, false, false, false, false, false, false);
  setFFTBlockWidth(4);
  this.resetStat();
  //exec("tktktktk");   
  //exec("tktktktk");
  //exec("t9t9t9t9t9t9t9t9");
  // set compOrder back to previous value
  this.setCompOrder(savedCompOrderIndex, false);
  println("Channel order: "+ ordStr);
}

/* (non-Javadoc)
 * @see processing.core.PApplet#mousePressed()
 * if the ControlP5 control panel is hidden, permit image panning
 * also allow panning if both tabs are not active, as at startup
 * or any time the mouse is not within an active tab
 * I have not handled the cases where tabs are collapsed.
 */
public void mousePressed() {
  if (!controlP5.isVisible() || !(settingsTab.isActive() || fftSettingsTab.isActive())) isDragImage = true;
  else {
    Rectangle r = new Rectangle(controlPanelX, controlPanelY, controlPanelWidth, controlPanelHeight);
    isDragImage = !r.contains(mouseX, mouseY);
  }
}

// handle dragging to permit large images to be panned
// shift-drag will always work, shift key is not needed if control panel is hidden 
public void mouseDragged() {
  if (isDragImage) {
    translateImage(-mouseX + pmouseX, -mouseY + pmouseY);
  }
}

/* (non-Javadoc)
 * handles key presses intended as commands
 * @see processing.core.PApplet#keyPressed()
 */
public void keyPressed() {
  if (key == '_') {
    commandSequence(lastCommand);
  }
  else if (key == ')') {
    scaledLowPass();
  }
  else if (key != CODED) {
    decode(key);
  }
  else {
    if (keyCode == UP) {
      incrementDegradeQuality(true);      // increment degradeQuality
    }
    else if (keyCode == DOWN) {
      incrementDegradeQuality(false);     // decrement degradeQuality
    }
    else if (keyCode == RIGHT) {
      incrementColorQuantize(true);       // incremeent colorQuantize
    }
    else if (keyCode == LEFT) {
      incrementColorQuantize(false);      // decrement colorQuantize
    }
  }
  if ("gl<>9kjdGLKJD".indexOf(key) > -1) lastCommand = key;
}
  
/**
 * associates characters input from keyboard with commands
 * @param ch   a char value representing a command
 */
public void decode(char ch) {
  if (ch == ' ') {
    toggleControlPanelVisibility();          // hide and show control panels
  }
  else if (ch == '1') {
    setSorter(SorterType.QUICK, false);      // use quick sort 
  }
  else if (ch == '2') {
    setSorter(SorterType.SHELL, false);      // use shell sort
  }
  else if (ch == '3') {
    setSorter(SorterType.BUBBLE, false);     // use bubble sort
  }
  else if (ch == '4') {
    setSorter(SorterType.INSERT, false);     // use insert sort
  }
  else if (ch == 'g' || ch == 'G') {
    sortPixels();                            // 'g' for glitch: sort with current algorithm
  }
  else if (ch == 'o') {
    openFile();                              // open a new file
  }
  else if (ch == 'O') {
    loadFileToSnapshot();                    // load a file to the snapshot buffer
  }
  else if (ch == 'n' || ch == 'N') {
    snap();                                  // save display to snapshot buffer
  }
  else if (ch == 'u' || ch == 'U') {
    unsnap();                                // copy snapshot buffer to display
  }
  else if (ch == 'b' || ch == 'B') {
    setRandomBreak(!randomBreak, false);     // toggle random break on or off
  }
  else if (ch == 'v' || ch == 'V') {
    //verbose = !verbose;                      // toggle verbose on or off
    println("verbose is "+ verbose);
  }
  else if (ch == 's') {
    saveFile(false);                         // save to file
  }
  else if (ch == 'S') {
    saveFile(true);                          // save to file as copy
  }
  else if (ch == '=' || ch == '+') {
    int n = (compOrderIndex + 1) % CompOrder.values().length;
    setCompOrder(n, false);                  // increment compOrderIndex
  }
  else if (ch == '-' || ch == '_') {
    int n = (compOrderIndex + CompOrder.values().length - 1) % CompOrder.values().length;
    setCompOrder(n, false);                  // decrement compOrderIndex
  }
  else if (ch == 'a' || ch == 'A') {
    // ascending or descending sort
    setAscending(!isAscendingSort, false);   // toggle ascending/descending sort
  }
  else if (ch == 'r') {
    revert(false);                           // reload display from disk
  }
  else if (ch == 'R') {
    revert(true);                                // reload display from orignal file on disk
  }
  else if (ch == 't') {
    rotatePixels(true);                          // rotate display 90 degrees right (CW)
  }
  else if (ch == 'T') {
    rotatePixels(false);                          // rotate display 90 degrees left (CCW)
  }
  else if (ch == 'x' || ch == 'X') {
    setIsSwapChannels(!isSwapChannels, false);   // toggle channel swapping (color glitching)
  }
  else if (ch == 'c' || ch == 'C') {
    int n = (swap.ordinal() + 1) % SwapChannel.values().length;
    setSwap(SwapChannel.values()[n], false);     // increment swap channel settings
  }
  else if (ch == 'z' || ch == 'Z') {
    restore();                               // copy undo buffer to display
  }
  else if (ch == 'h' || ch == 'H') {
    printHelp();                             // print help message
  }
  else if (ch == 'f' || ch == 'F') {
    fitPixels(!isFitToScreen, false);        // toggle display window size to fit to screen or not
  }
  else if (ch == 'd' || ch == 'D') {
    degrade();                               // save and reload JPEG with current compression quality
  }
  else if (ch == 'm' || ch == 'M') {
    munge();                                 // composite display and snapshot with undo buffer difference mask 
  }
  else if (ch == 'i' || ch == 'I') {
    invertMunge(!isMungeInverted, false);    // invert functioning of the difference mask for munge command
  }
  else if (ch == 'y' || ch == 'Y') {
    setCycle(!isCycleGlitch, false);         // in multi-step sort, cycle through all lines in image
  }
  else if (ch == 'p' || ch == 'P') {
    reduceColors();                          // quantize colors
  }
  else if (ch == 'l' || ch == 'L') {
    zigzag();                                // perform a zigzag sort
  }
  else if (ch == 'k' || ch == 'K') {
    statZigzagFFT();                         // perform an FFT using statistical interface settings
  }
  else if (ch == 'j' || ch == 'J') {
    eqZigzagFFT();                           // perform an FFT using equalizer interface settings
  }
  else if (ch == ';') {
    analyzeEq(true);                         // perform analysis of frequencies in image 
  }
  else if (ch == '{') {
    decShellIndex();                         // step to previous shell sort settings
  }
  else if (ch == '}') {
    incShellIndex();                         // step to next shell sort settings
  }
  else if (ch == '*') {
    anim();                                  // save an animation
  }
  else if (ch == ':') {
    testEq();                                // run a test of the FFT
  }
  else if (ch == '[') {
    incrementGlitchSteps(false);             // increase the glitchSteps value
  }
  else if (ch == ']') {
    incrementGlitchSteps(true);              // decrease the glitchSteps value
  }
  else if (ch == '/') {
    audify();                                // turn on audify
  }
  else if (ch == '\\') {
    audifyOff();                             // turn off audify
  }
  else if (ch == '9') {
    denoise();                              // denoise
  }
  else if (ch == ',' || ch == '<') {
    shiftLeft();                            // shift selected color channel left
  }
  else if (ch == '.' || ch == '>') {
    shiftRight();                           // shift selected color channel right
  }
}

/**
 * tracks mouse movement over the equalizer in the FFT control panel
 */
public void trackMouseEq() {
  if (controlP5.isVisible()) {
    if (fftSettings.isVisible()) {
      mouseControls = controlP5.getMouseOverList();
      for (ControllerInterface<?> con : mouseControls) {
        if (con.getName().length() > 3 && con.getName().substring(0, 3).equals(sliderIdentifier)) {
          if (mousePressed) {
            float[] pos = con.getAbsolutePosition();
            PVector vec = new PVector(pos[0], pos[1]);
            float v = map(mouseY, vec.y, vec.y + eqH, eqMax, eqMin);
            if (v != con.getValue()) {
              // println(con.getName() +": "+ vec.y +"; mouseY: "+ mouseY +"; v = "+ v);
              con.setValue(v);
            }
          }
          else {
            if (con.getId() >= 0) {
              int bin = con.getId();
              // write out the current amplitude setting from the eq tool
              if (bin < eq.length) {
                String legend = "band "+ bin +" = "+ twoPlaces.format(eq[bin]);
                if (null != binTotals && bin < binTotals.length) {
                  legend += ", bin avg = "+ twoPlaces.format(binTotals[bin]);
                  // legend += ", bins "+ bandList.get(eq.length - bin - 1).toString();
                  // get indices of the range of bands covered by each slider and calculate their center frequency
                  IntRange ir = bandList.get(bin);
                  legend += ", cf = "+ twoPlaces.format((fft.indexToFreq(ir.upper) + fft.indexToFreq(ir.lower)) * 0.5f);
                  // get the scaling value set by the user
                }
                ((Textlabel)controlP5.getController("eqLabel")).setValue(legend);
              }
            }
          }
        }
      }
    }
    else {
      // println("conditions not met");
    }
  }
}

/***** moved ControlP5 control panel setup to its own tab from here *****/


/********************************************/
/*                                          */
/*          >>> GLITCH COMMANDS <<<         */
/*                                          */
/********************************************/

/**
 * opens a user-specified file (JPEG, GIF or PNG only)
 */
public void openFile() {
  chooseFile();
}

/**
 * reverts display and display buffer to last opened file
 */
public void revert(boolean toOriginalFile) {
  if (null != displayFile) {
    if (toOriginalFile) loadOriginalFile(); 
    else loadFile();
    if (isFitToScreen) fitPixels(true, false);
    // reset row numbers and translation
    loadRowNums();
    resetRanger();
    shuffle(rowNums);
    clipTranslation();
  }
}

/**
 * Sets the value above which the current sort method will randomly interrupt, when randomBreak 
 * is true (the default). Each sorting method uses a distinct value from 1 to 999. Quick sort
 * can use very low values, down to 1.0. The other sorting methods--shell sort, insert sort, 
 * bubble sort--generally work best with higher values. 
 * @param newBreakPoint   the breakpoint to set
 */
public void setBreakpoint(float newBreakPoint) {
  if (newBreakPoint == breakPoint) return;
  breakPoint = newBreakPoint;
  sortTool.sorter.setBreakPoint(breakPoint);
}

/**
 * increments shellIndex, changes shell sort settings
 */
public void incShellIndex() {
  shellIndex = shellIndex < shellParams.length - 3 ? shellIndex + 2 : 0;
  int r = shellParams[shellIndex];
  int d = shellParams[shellIndex + 1];
  sortTool.shell.setRatio(r);
  sortTool.shell.setDivisor(d);
  println("ShellIndex = "+ shellIndex +", Shellsort ratio = "+ r +", divisor = "+ d);
}
/**
 * decrements shellIndex, changes shell sort settings
 */
public void decShellIndex() {
  shellIndex = shellIndex > 1 ? shellIndex - 2 : shellParams.length - 2;
  int r = shellParams[shellIndex];
  int d = shellParams[shellIndex + 1];
  sortTool.shell.setRatio(r);
  sortTool.shell.setDivisor(d);
  println("ShellIndex = "+ shellIndex +", Shellsort ratio = "+ r +", divisor = "+ d);
}

/**
 * Initializes rowNums array, used in stepped or cyclic sorting, with img.height elements.
 */
public void loadRowNums() {
  rowNums = new int[img.height];
  for (int i = 0; i < img.height; i++) rowNums[i] = i;
}

/**
 * Initializes rowNums array to rowCount elements, shuffles it and sets row value to 0.
 */
public void resetRowNums(int rowCount) {
  rowNums = new int[rowCount];
  for (int i = 0; i < rowCount; i++) rowNums[i] = i;
  resetRowNums();
}
/**
 * Shuffles rowNums array and sets row value to 0.
 */
public void resetRowNums() {
  shuffle(rowNums);
  row = 0;
  if (verbose) println("Row numbers shuffled");
}

/**
 * Sets RangeManager stored in ranger to intial settings, with a range of img.height 
 * and number of intervals equal to glitchSteps.
 */
public void resetRanger() {
  if (null == ranger) {
    ranger = new RangeManager(img.height, (int) glitchSteps);
  }
  else {
    ranger.resetCurrentIndex();
    ranger.setRange(img.height);
    ranger.setNumberOfIntervals((int) glitchSteps);
  }
  if (verbose) println("range index reset to 0");
}

/**
 * rotates image and backup image 90 degrees clockwise
 */
public void rotatePixels(boolean isTurnRight) {
  if (null == img) return;
  if (isTurnRight) img = rotateImageRight(img);
  else img = rotateImageLeft(img);
  fitPixels(isFitToScreen, false);
  // rotate undo buffer image, don't rotate snapshot
  if (null != bakImg) {
    if (isTurnRight) bakImg = rotateImageRight(bakImg);
    else bakImg = rotateImageLeft(bakImg);
  }
  // load the row numbers
  loadRowNums();
  resetRanger();
  // shuffle the row numbers
  shuffle(rowNums);
  // clip translation to image bounds
  clipTranslation();
}

/**
 * rotates image pixels 90 degrees clockwise
 * @param image   the image to rotate
 * @return        the rotated image
 */
public PImage rotateImageRight(PImage image) {
  // rotate image 90 degrees
  int h = image.height;
  int w = image.width;
  int i = 0;
  PImage newImage = createImage(h, w, ARGB);
  newImage.loadPixels();
  for (int ry = 0; ry < w; ry++) {
    for (int rx = 0; rx < h; rx++) {
      newImage.pixels[i++] = image.pixels[(h - 1 - rx) * image.width + ry];
    }
  }
  newImage.updatePixels();
  return newImage;
}

/**
 * rotates image pixels 90 degrees clockwise
 * @param image   the image to rotate
 * @return        the rotated image
 */
public PImage rotateImageLeft(PImage image) {
  // rotate image 90 degrees
  int h = image.height;
  int w = image.width;
  int i = 0;
  PImage newImage = createImage(h, w, ARGB);
  newImage.loadPixels();
  for (int ry = w-1; ry >= 0; ry--) {
    for (int rx = h-1; rx >= 0; rx--) {
      newImage.pixels[i++] = image.pixels[(h - 1 - rx) * image.width + ry];
    }
  }
  newImage.updatePixels();
  return newImage;
}

/**
 * rotates image pixels 90 degrees clockwise
 * @param image   the image to rotate
 * @return        the rotated image
 */
public PImage rotateImage(PImage image) {
  // rotate image 90 degrees
  image.loadPixels();
  int h = image.height;
  int w = image.width;
  int i = 0;
  PImage newImage = createImage(h, w, ARGB);
  newImage.loadPixels();
  for (int ry = 0; ry < w; ry++) {
    for (int rx = 0; rx < h; rx++) {
      newImage.pixels[i++] = image.pixels[(h - 1 - rx) * image.width + ry];
    }
  }
  newImage.updatePixels();
  return newImage;
}

/**
 * tranlates the display image by a specified horizontal and vertical distances
 * @param tx   distance to translate on x-axis
 * @param ty   distance to translate on y-axis
 */
public void translateImage(int tx, int ty) {
  transX += tx;
  transY += ty;
  clipTranslation();
}

/**
 * handles clipping of a translated image to the display window
 */
public void clipTranslation() {
  int limW = (frameWidth < img.width) ? img.width - frameWidth : 0;
  int limH = (frameHeight < img.height) ? img.height - frameHeight : 0;
  if (transX > limW) transX = limW;
  if (transX < 0) transX = 0;
  if (transY > limH) transY = limH;
  if (transY < 0) transY = 0;
  // println(transX +", "+ transY  +", limit width = "+ limW  +", limit height = "+ limH +", image width = "+ img.width +", image height = "+ img.height);    
}

/**
 * Sorts the pixels line by line, in random order, using the current
 * sorting method set in sortTool.
 * @fix moved loadPixels outside loop
 * TODO implement a cycle and row manager class
 */
public void sortPixels() {
  if (null == img || null == ranger) {
    println("No image is available for sorting or the ranger is not initialized (sortPixels method)");
    return;
  }
  backup();
  img.loadPixels();
  if (isCycleGlitch) {
    IntRange range;
    if (ranger.hasNext()) {
      range = ranger.getNext();
      println(range.toString());
    } 
    else {
      ranger.resetCurrentIndex();
      range = ranger.getNext();
      resetRowNums();
      println("starting a new cycle");
    }
    for (int i = range.lower; i < range.upper; i++) {
      int n = rowNums[i];
      if (verbose) println("sorting row "+ n +" at index "+ i);
      row++;
      int l = n * img.width;
      int r = l + img.width - 1;
      sortTool.sort(img.pixels, l, r);
    }
  }
  else {
    int rowMax = (int)(Math.round(rowNums.length / glitchSteps));
    for (int i = 0; i < rowMax; i++) {
      int n = rowNums[i];
      if (verbose) println("sorting row "+ n);
      int l = n * img.width;
      int r = l + img.width - 1;
      sortTool.sort(img.pixels, l, r);
    }
    shuffle(rowNums);
  }
  img.updatePixels();
  fitPixels(isFitToScreen, false);
}

/**
 * Saves a copy of the currently displayed image in img to bakImg.
 */
public void backup() {
  bakImg = img.get();
}

/**
 * Undoes the last command. Not applicable to munge command.
 */
public void restore() {
  // store a copy of the current image in tempImg
  PImage tempImg = img.get();
  img = bakImg;
  bakImg = tempImg;
  // println("--- restore");
  fitPixels(isFitToScreen, false);
  // if the display image and the backup image are different sizes, we need to reset rows and translation
  loadRowNums();
  resetRanger();
  shuffle(rowNums);
  clipTranslation();
}

/**
 * Saves a copy of the currently displayed image in img to snapImg.
 */
public void snap() {
//    if (null == snapImg) snapImg = createImage(width, height, ARGB);
//    snapImg.resize(img.width, img.height);
//    snapImg.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
  snapImg = img.get();
  println("took a snapshot of current state");
}

/**
 * copies snapImg to img, undo buffer bakImg is not changed
 */
public void unsnap() {
  if (null == snapImg) return;
  img = snapImg.get();
  fitPixels(isFitToScreen, false);
  // if the display image and the snapshot image are different sizes, we need to reset rows and translation
  loadRowNums();
  resetRanger();
  shuffle(rowNums);
  clipTranslation();
}

/**
 * loads a file into snapshot buffer.
 */
public void loadFileToSnapshot() {
  selectInput("Image file for snapshot buffer:", "snapshotFileSelected");
}

public void snapshotFileSelected(File selectedFile) {
  if (null != selectedFile) {
    noLoop();
    File snapFile = selectedFile;
    snapImg = loadImage(snapFile.getAbsolutePath());
    println("loaded "+ snapFile.getName() +" to snapshot buffer: width = "+ snapImg.width +", height = "+ snapImg.height);
    loop();
  }
  else {
    println("No file was selected");
  }
}

/**
 * Composites the current image (img) with the snapshot (snapImg) using the undo buffer (bakImg)
 * as a mask. When the largest absolute difference between a pixel in the image and the same
 * pixel in the undo buffer is greater than mungeThreshold, a pixel from the snapshot will be written
 * to the image. The undo buffer and the snapshot will be resized to the image dimensions if
 * necessary (it's not called "munge" for nothing).
 */
public void munge() {
  if (null == bakImg || null == snapImg) {
    println("To munge an image you need an undo buffer and a snapshot");
    return;
  }
  if (img.width != bakImg.width || img.height != bakImg.height) {
    bakImg.resize(img.width, img.height);
  }
  if (img.width != snapImg.width || img.height != snapImg.height) {
    snapImg.resize(img.width, img.height);
  }
  img.loadPixels();
  bakImg.loadPixels();
  snapImg.loadPixels();
  int alpha = 255 << 24;
  for (int i = 0; i < img.pixels.length; i++) {
    int src = Math.abs(img.pixels[i]);
    int targ = Math.abs(bakImg.pixels[i]);
    int diff = maxColorDiff(src, targ);
    if (isMungeInverted) {
      if (diff < mungeThreshold) {
        img.pixels[i] = snapImg.pixels[i] | alpha;
      }
      
    }
    else {
      if (diff > mungeThreshold) {
        img.pixels[i] = snapImg.pixels[i] | alpha;
      }
    }
  }
  println("munged -----");
  img.updatePixels();
  fitPixels(isFitToScreen, false);
}


/**
 * degrades the image by saving it as a low quality JPEG and loading the saved image
 */
public void degrade() {
  try {
    backup();
    println("degrading");
    degradeImage(img, degradeQuality);
    if (isFitToScreen) fitPixels(true, false);
  } catch (IOException e) {
    // Auto-generated catch block
    e.printStackTrace();
  }
}

/**
 * Quantizes colors in image to a user-specified value between 2 and 255
 */
public void reduceColors() {
  BufferedImage im = (BufferedImage) img.getImage();
  if (null == quant) {
    quant = new ImageColorQuantizer(colorQuantize);
  }
  else {
    quant.setColorCount(colorQuantize);
  }
  quant.filter(im, null);
  int[] px = quant.pixels;
  if (px.length != img.pixels.length) {
    println("---- pixel arrays are not equal (method reduceColors)");
    return;
  }
  backup();
  img.loadPixels();
  int alpha = 255 << 24;
  for (int i = 0; i < px.length; i++) {
    // provide the alpha channel, otherwise the image will vanish
    img.pixels[i] = px[i] | alpha;
  }
  img.updatePixels();
  fitPixels(isFitToScreen, false);
}

/**
 * implements a basic 3x3 denoise (median) filter
 * TODO provide generalized filter for any edge dimension, tuned to individual color channels
 */
public void denoise() {
  int boxW = 3;
  int medianPos = 4;
  backup();
  PImage imgCopy = img.get();
  int w = img.width;
  int h = img.height;
  int[] pix = new int[boxW * boxW];
  img.loadPixels();
  for (int v = 1; v < h - 1; v++) {
    for (int u = 1; u < w - 1; u++) {
      int k = 0;
      for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
          pix[k] = imgCopy.get(u + i, v + j);
          k++;
        }
      }
      Arrays.sort(pix);
      img.set(u, v, pix[medianPos]);
    }
  }
  // prepare array for edges
  pix = new int[(boxW - 1) * boxW];
  // left edge
  for (int v = 1; v < h - 1; v++) {
    int u = 0;
    int k = 0;
    for (int j = -1; j <= 1; j++) {
      for (int i = 0; i <= 1; i++) {
        pix[k] = imgCopy.get(u + i, v + j);
        k++;
      }
    }
    Arrays.sort(pix);
    img.set(u, v, meanColor(pix[2], pix[3]));
  }
  // right edge
  for (int v = 1; v < h - 1; v++) {
    int u = w - 1;
    int k = 0;
    for (int j = -1; j <= 1; j++) {
      for (int i = 0; i <= 1; i++) {
        pix[k] = imgCopy.get(u - i, v + j);
        k++;
      }
    }
    Arrays.sort(pix);
    img.set(u, v, meanColor(pix[2], pix[3]));
  }
  // top edge
  for (int u = 1; u < w - 1; u++) {
    int v = 0;
    int k = 0;
    for (int j = 0; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        pix[k] = imgCopy.get(u + i, v + j);
        k++;
      }
    }
    Arrays.sort(pix);
    img.set(u, v, meanColor(pix[2], pix[3]));
  }
  // bottom edge 
  for (int u = 1; u < w - 1; u++) {
    int v = h - 1;
    int k = 0;
    for (int j = 0; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        pix[k] = imgCopy.get(u + i, v - j);
        k++;
      }
    }
    Arrays.sort(pix);
    img.set(u, v, meanColor(pix[2], pix[3]));
  }
  // prepare array for corners
  pix = new int[(boxW - 1) * (boxW - 1)];
  // do the corners
  pix[0] = imgCopy.get(0, 0);
  pix[1] = imgCopy.get(0, 1);
  pix[2] = imgCopy.get(1, 0);
  pix[3] = imgCopy.get(1, 1);
  Arrays.sort(pix);
  img.set(0, 0, meanColor(pix[1], pix[2]));
  pix[0] = imgCopy.get(w - 1, 0);
  pix[1] = imgCopy.get(w - 1, 1);
  pix[2] = imgCopy.get(w - 2, 0);
  pix[3] = imgCopy.get(w - 2, 1);
  Arrays.sort(pix);
  img.set(w - 1, 0, meanColor(pix[1], pix[2]));
  pix[0] = imgCopy.get(0, h - 1);
  pix[1] = imgCopy.get(0, h - 2);
  pix[2] = imgCopy.get(1, h - 1);
  pix[3] = imgCopy.get(1, h - 2);
  Arrays.sort(pix);
  img.set(0, h - 1, meanColor(pix[1], pix[2]));
  pix[0] = imgCopy.get(w - 1, h - 1);
  pix[1] = imgCopy.get(w - 1, h - 2);
  pix[2] = imgCopy.get(w - 2, h - 1);
  pix[3] = imgCopy.get(w - 2, h - 1);
  Arrays.sort(pix);
  img.set(w - 1, h - 1, meanColor(pix[1], pix[2]));
  img.updatePixels();
  fitPixels(isFitToScreen, false);
}


/**
 * Shifts selected RGB color channel one pixel left.
 */
public void shiftLeft() {
  backup();
  img.loadPixels();
  int c1, c2;
  // I've unwound the loop so as to check the channel to shift only once
  if (isShiftR) {
    for (int i = 0; i < rowNums.length; i++) {
      int l = i * img.width;
      int r = l + img.width - 1;
      int temp = img.pixels[l];
      for (int u = l + 1; u <= r; u++) {
        c1 = img.pixels[u];
        c2 = img.pixels[u - 1];
        img.pixels[u - 1] = 255 << 24 | ((c1 >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | c2 & 0xFF;
      }
      c2 = img.pixels[r];
      img.pixels[r] = 255 << 24 | ((temp >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | c2 & 0xFF;
    }
  }
  else if (isShiftG) {
    for (int i = 0; i < rowNums.length; i++) {
      int l = i * img.width;
      int r = l + img.width - 1;
      int temp = img.pixels[l];
      for (int u = l + 1; u <= r; u++) {
        c1 = img.pixels[u];
        c2 = img.pixels[u - 1];
        img.pixels[u - 1] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((c1 >> 8) & 0xFF) << 8 | c2 & 0xFF;
      }
      c2 = img.pixels[r];
      img.pixels[r] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((temp >> 8) & 0xFF) << 8 | c2 & 0xFF;
    }
  }
  else if (isShiftB) {
    for (int i = 0; i < rowNums.length; i++) {
      int l = i * img.width;
      int r = l + img.width - 1;
      int temp = img.pixels[l];
      for (int u = l + 1; u <= r; u++) {
        c1 = img.pixels[u];
        c2 = img.pixels[u - 1];
        img.pixels[u - 1] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | c1 & 0xFF;
      }
      c2 = img.pixels[r];
      img.pixels[r] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | temp & 0xFF;
    }
  }
  img.updatePixels();
  fitPixels(isFitToScreen, false);
}

/**
 * Shifts selected RGB channel one pixel right.
 */
public void shiftRight() {
  backup();
  img.loadPixels();
  int c1, c2;
  // I've unwound the loop so as to check the channel o shift only once
  if (isShiftR) {
    for (int i = 0; i < rowNums.length; i++) {
      int l = i * img.width;
      int r = l + img.width - 1;
      int temp = img.pixels[r];
      for (int u = r - 1; u >= l; u--) {
        c1 = img.pixels[u];
        c2 = img.pixels[u + 1];
        img.pixels[u + 1] = 255 << 24 | ((c1 >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | c2 & 0xFF;
      }
      c2 = img.pixels[l];
      img.pixels[l] = 255 << 24 | ((temp >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | c2 & 0xFF;
    }
  }
  else if (isShiftG) {
    for (int i = 0; i < rowNums.length; i++) {
      int l = i * img.width;
      int r = l + img.width - 1;
      int temp = img.pixels[r];
      for (int u = r - 1; u >= l; u--) {
        c1 = img.pixels[u];
        c2 = img.pixels[u + 1];
        img.pixels[u + 1] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((c1 >> 8) & 0xFF) << 8 | c2 & 0xFF;
      }
      c2 = img.pixels[l];
      img.pixels[l] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((temp >> 8) & 0xFF) << 8 | c2 & 0xFF;
    }
  }
  else if (isShiftB) {
    for (int i = 0; i < rowNums.length; i++) {
      int l = i * img.width;
      int r = l + img.width - 1;
      int temp = img.pixels[r];
      for (int u = r - 1; u >= l; u--) {
        c1 = img.pixels[u];
        c2 = img.pixels[u + 1];
        img.pixels[u + 1] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | c1 & 0xFF;
      }
      c2 = img.pixels[l];
      img.pixels[l] = 255 << 24 | ((c2 >> 16) & 0xFF) << 16 | ((c2 >> 8) & 0xFF) << 8 | temp & 0xFF;
    }
  }
  img.updatePixels();
  fitPixels(isFitToScreen, false);
}

/**
 * TODO fit full image into frame, with no hidden pixels. Works when fitToScreen is true, fails in some 
 * extreme instances when fitToScreen is false. 
 * This method is a bottleneck for all screen display--keep it so. 
 * Fits images that are too big for the screen to the screen, or displays as much of a large image 
 * as fits the screen if every pixel is displayed. There is still some goofiness in getting the whole
 * image to display--bottom edge gets hidden by the window. It would be good to have a scrolling window.
 * 
 * @param fitToScreen   true if image should be fit to screen, false if every pixel should displayed
 * @param isFromControlPanel   true if the control panel dispatched the call, false otherwise
 */
public void fitPixels(boolean fitToScreen, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    if (fitToScreen) ((CheckBox) controlP5.getGroup("fitPixels")).activate(0);
    else ((CheckBox) controlP5.getGroup("fitPixels")).deactivate(0);
  }
  else {
    if (fitToScreen) {
      fitImg = createImage(img.width, img.height, ARGB);
      scaledWidth = fitImg.width;
      scaledHeight = fitImg.height;
      fitImg = img.get();
      // calculate proportions of window and image, 
      // be sure to convert ints to floats to get the math right
      // ratio of the window height to the window width
      float windowRatio = maxWindowHeight/(float)maxWindowWidth;
      // ratio of the image height to the image width
      float imageRatio = fitImg.height/(float)fitImg.width;
      if (verbose) {
        println("maxWindowWidth "+ maxWindowWidth +", maxWindowHeight "+ maxWindowHeight +", screen ratio "+ windowRatio);
        println("image width "+ fitImg.width +", image height "+ fitImg.height +", image ratio "+ imageRatio);
      }
      if (imageRatio > windowRatio) {
        // image is proportionally taller than the display window, 
        // so scale image height to fit the window height
        scaledHeight = maxWindowHeight;
        // and scale image width by window height divided by image height
        scaledWidth = Math.round(fitImg.width * (maxWindowHeight / (float)fitImg.height));
      }
      else {
        // image is proportionally equal to or wider than the display window, 
        // so scale image width to fit the windwo width
        scaledWidth = maxWindowWidth;
        // and scale image height by window width divided by image width
        scaledHeight = Math.round(fitImg.height * (maxWindowWidth / (float)fitImg.width));
      }
      fitImg.resize(scaledWidth, scaledHeight);
      if (null != myFrame) myFrame.setSize(scaledWidth, scaledHeight + 48);
    }
    else {
      scaledWidth = img.width;
      scaledHeight = img.height;
      if (null != myFrame) {
        frameWidth = scaledWidth <= maxWindowWidth ? scaledWidth : maxWindowWidth;
        frameHeight = scaledHeight <= maxWindowHeight ? scaledHeight : maxWindowHeight;
        myFrame.setSize(frameWidth, frameHeight + 38);
      }
    }
    // println("scaledWidth = "+ scaledWidth +", scaledHeight = "+ scaledHeight +", frameWidth = "+ frameWidth +", frameHeight = "+ frameHeight);
    isFitToScreen = fitToScreen;
  }
}

/***** Control Panel Commands moved from here to their own tab *****/
  
/********************************************/
/*                                          */
/*              >>> UTILITY <<<             */
/*                                          */
/********************************************/

/**
 * Shuffles an array of integers into random order.
 * Implements Richard Durstenfeld's version of the Fisher-Yates algorithm, popularized by Donald Knuth.
 * see http://en.wikipedia.org/wiki/Fisher-Yates_shuffle
 * @param intArray an array of <code>int</code>s, changed on exit
 */
public void shuffle(int[] intArray) {
  for (int lastPlace = intArray.length - 1; lastPlace > 0; lastPlace--) {
    // Choose a random location from 0..lastPlace
    int randLoc = (int) (random(lastPlace + 1));
    // Swap items in locations randLoc and lastPlace
    int temp = intArray[randLoc];
    intArray[randLoc] = intArray[lastPlace];
    intArray[lastPlace] = temp;
  }
}

/**
 * Breaks a Processing color into R, G and B values in an array.
 * @param argb   a Processing color as a 32-bit integer 
 * @return       an array of integers in the intRange 0..255 for 3 primary color components: {R, G, B}
 */
public static int[] rgbComponents(int argb) {
  int[] comp = new int[3];
  comp[0] = (argb >> 16) & 0xFF;  // Faster way of getting red(argb)
  comp[1] = (argb >> 8) & 0xFF;   // Faster way of getting green(argb)
  comp[2] = argb & 0xFF;          // Faster way of getting blue(argb)
  return comp;
}

/**
 * Creates a Processing ARGB color from r, g, b, and alpha channel values. Note the order
 * of arguments, the same as the Processing color(value1, value2, value3, alpha) method. 
 * @param r   red component 0..255
 * @param g   green component 0..255
 * @param b   blue component 0..255
 * @param a   alpha component 0..255
 * @return    a 32-bit integer with bytes in Processing format ARGB.
 */
public static int composeColor(int r, int g, int b, int a) {
  return a << 24 | r << 16 | g << 8 | b;
}

/**
 * Creates a Processing ARGB color from r, g, b, values in an array. 
 * @param comp   array of 3 integers in range 0..255, for red, green and blue components of color
 *               alpha value is assumed to be 255
 * @return       a 32-bit integer with bytes in Processing format ARGB.
 */
public static int composeColor(int[] comp) {
  return 255 << 24 | comp[0] << 16 | comp[1] << 8 | comp[2];
}
/**
 * Returns the largest difference between the components of two colors. 
 * If the value returned is 0, colors are identical.
 * @param color1
 * @param color2
 * @return
 */
public static int maxColorDiff(int color1, int color2) {
  int rDiff = Math.abs(((color1 >> 16) & 0xFF) - ((color2 >> 16) & 0xFF));
  int gDiff = Math.abs(((color1 >> 8) & 0xFF) - ((color2 >> 8) & 0xFF));
  int bDiff = Math.abs(((color1) & 0xFF) - ((color2) & 0xFF));
  return Math.max(Math.max(rDiff, gDiff), bDiff);
}

public static int meanColor(int argb1, int argb2) {
  int[] comp1 = rgbComponents(argb1);
  int[] comp2 = rgbComponents(argb2);
  for (int i = 0; i < comp1.length; i++) {
    comp1[i] = (int) ((comp1[i] + comp2[i]) * 0.5f);
  }
  return composeColor(comp1);
}


/********************************************/
/*                                          */
/*             >>> FILE I/O <<<             */
/*                                          */
/********************************************/

/**
 * saves current image to a uniquely-named file
 */
public void saveFile(boolean isCopy) {
  String shortName = originalFile.getName();
  String[] parts = shortName.split("\\.");
  // String attributes = compOrder.name();
  // if (isSwapChannels) attributes += "_"+ swap.name();
  // String fName = parts[0] +"_"+ timestamp +"_"+ attributes +".png";
  String fName = parts[0] +"_"+ timestamp +"_"+ fileCount +".png";
  fileCount++;
  if (!isCopy) println("saving to "+ fName);
  else  println("saving copy to "+ fName);
  img.save(fName);
  if (!isCopy) {
    // Eclipse and Processing have different default paths
    // println("sketchPath = "+ sketchPath);
    displayFile = new File(sketchPath +"/"+ fName);
  }
}

/**
 * @return   true if a file reference was successfully returned from the file dialogue, false otherwise
 */
public void chooseFile() {
  selectInput("Choose an image file.", "displayFileSelected");
}

public void displayFileSelected(File selectedFile) {
  File oldFile = displayFile;
  if (null != selectedFile && oldFile != selectedFile) {
    noLoop();
    displayFile = selectedFile;
    originalFile = selectedFile;
    loadFile();
    if (isFitToScreen) fitPixels(true, false);
    loop();
  }
  else {
    println("No file was selected");
  }
}


/**
 * loads a file into variable img.
 */
public void loadFile() {
  println("\nselected file "+ displayFile.getAbsolutePath());
  img = loadImage(displayFile.getAbsolutePath());
  transX = transY = 0;
  fitPixels(isFitToScreen, false);
  println("image width "+ img.width +", image height "+ img.height);
  resetRowNums(img.height);
  if (null == ranger) {
    ranger = new RangeManager(img.height, (int) glitchSteps);
  }
  else {
    ranger.setRange(img.height);
  }
  analyzeEq(false);
}

/**
 * loads original file into variable img.
 */
public void loadOriginalFile() {
  println("\noriginal file "+ originalFile.getAbsolutePath());
  displayFile = originalFile;
  img = loadImage(displayFile.getAbsolutePath());
  transX = transY = 0;
  fitPixels(isFitToScreen, false);
  println("image width "+ img.width +", image height "+ img.height);
  resetRowNums(img.height);
  if (null == ranger) {
    ranger = new RangeManager(img.height, (int) glitchSteps);
  }
  else {
    ranger.setRange(img.height);
  }
  analyzeEq(false);
}


/**
 * @param image          the image to degrade
 * @param quality        the desired JPEG quality
 * @throws IOException   error thrown by file i/o
 */
public void degradeImage(PImage image, float quality) throws IOException {
  Iterator<ImageWriter> iter = ImageIO.getImageWritersByFormatName("jpeg");
  ImageWriter writer = (ImageWriter)iter.next();
  ImageWriteParam iwp = writer.getDefaultWriteParam();
  iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
  iwp.setCompressionQuality(quality);     
  try {
    BufferedImage bi =  (BufferedImage) image.getImage();
    String shortName = displayFile.getName();
    String[] parts = shortName.split("\\.");
    // String fName = parts[0] +"_q"+ Math.round(quality * 100) +".jpg";
    // just save one degrade file per image
    String fName = parts[0] +"_degrade" +".jpg";
    File temp = new File(savePath(fName));
    FileImageOutputStream output = new FileImageOutputStream(temp);
    writer.setOutput(output);
    IIOImage outImage = new IIOImage(bi, null, null);
    writer.write(null, outImage, iwp);
    writer.dispose();
    PImage newImage = loadImage(temp.getAbsolutePath());
    img = newImage;
    println("degraded "+ fName);
  }
  catch (FileNotFoundException e) {
    println("file not found error " + e);
  }
  catch (IOException e) {
    println("IOException "+ e);
  }
}

/***** RangeManager classes moved from there to their own tab *****/

/***** FFT methods moved from here to their own tab *****/

/***** Zigzag methods moved from here to their own tab *****/

/****** Sorting methods moved from here to their own tab *****/  


