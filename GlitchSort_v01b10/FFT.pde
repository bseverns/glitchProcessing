/********************************************/
/*                                          */
/*                >>> FFT <<<               */
/*                                          */
/********************************************/

/**
 * Scales a frequency by a factor.
 * 
 * @param freq
 * @param fac
 */
public void fftScaleFreq(float freq, float fac) {
  fft.scaleFreq(freq, fac);
}



/**
 * Scales an array of frequencies by an array of factors.
 * @param freqs
 * @param facs
 */
public void fftScaleFreq(float[] freqs, float[] facs) {
  for (int i = 0; i < freqs.length; i++) {
    fft.scaleFreq(freqs[i], facs[i]);
  }
}

/**
 * Scales a single frequency bin (index number) by a factor.
 * 
 * @param bin
 * @param fac
 */
public void fftScaleBin(int bin, float fac) {
  fft.scaleBand(bin, fac);
}



/**
 * Scales an array of frequency bins (index numbers) by an array of factors.
 * @param bins
 * @param facs
 */
public void fftScaleBin(int[] bins, float[] facs) {
  for (int i = 0; i < bins.length; i++) {
    fft.scaleBand(bins[i], facs[i]);
  }
}

/**
 * placeholder for future development
 */
public void fftScaleFreqsTest() {
  float[] freqs = {};
  float[] facs = {};
 }

/*
 * FORMANTS
 * i beet 270 2290 3010 
 * I bit 390 1990 2550
 * e bet 530 1840 2480
 * ae bat 660 1720 2410
 * a father 730 1090 2440
 * U book 440 1020 2240
 * u boot 300 870 2240
 * L but 640 1190 2390
 * r bird 490 1350 1690
 * aw bought 570 840 2410
 *   
 */

/**
 * Calculates statistical variables from frequencies in the current FFT and returns then in an array.
 * 
 * @param l         left bound of bin index numbers
 * @param r         right bound of bin index numbers
 * @param verbose   true if output to consoles is desired, false otherwise
 * @param msg       a message to include with output
 * @return          an array of derived values: minimum, maximum, sum, mean, median, standard deviation, skew.
 */
public float[] fftStat(int l, int r, boolean verbose, String msg) {
  double sum = 0;
  double squareSum = 0;
  float[] values = new float[r - l];
  int index = 0;
  for (int i = l; i < r; i++) {
    float val = fft.getBand(i);
    sum += val;
    squareSum += val * val;
    values[index++] = val;
  }
  int mid = values.length/2;
  java.util.Arrays.sort(values);
  float median = (values[mid - 1] + values[mid])/2;
  float min = values[0];
  float max = values[values.length -1];
  float mean = (float) sum/(r - l);
  float variance = (float) squareSum/(r - l) - mean * mean;
  float standardDeviation = (float) Math.sqrt(variance);
  // Pearson's skew measure
  float skew = 3 * (mean - median)/standardDeviation;
  if (verbose) {
    println(msg);
    print("  min = "+ min);
    print("  max = "+ max);
    print("  sum = "+ (float) sum);
    print("  mean = "+ mean);
    print("  median = "+ median);
    println("  sd = "+ standardDeviation);
    println("  skew = "+ skew);
  }
  float[] results = new float[6];
  results[0] = min;
  results[1] = max;
  results[2] = mean;
  results[3] = median;
  results[4] = standardDeviation;
  results[5] = skew;
  return results;
}

/**
 * Extracts a selected channel from an array of rgb values.
 * 
 * @param samples   rgb values in an array of int
 * @param chan      the channel to extract 
 * @return          the extracted channel values as an array of floats
 */
public float[] pullChannel(int[] samples, ChannelNames chan) {
  // convert sample channel to float array buf
  float[] buf = new float[samples.length];
  int i = 0;
  switch (chan) {
  case L: {
    for (int argb : samples) buf[i++] = brightness(argb);
    break;
  }
  case H: {
    for (int argb : samples) buf[i++] = hue(argb);
    break;
  }
  case S: {
    for (int argb : samples) buf[i++] = saturation(argb);
    break;
  }
  case R: {
    for (int argb : samples)  buf[i++] = (argb >> 16) & 0xFF;
    break;
  }
  case G: {
    for (int argb : samples) buf[i++] = (argb >> 8) & 0xFF;
    break;
  }
  case B: {
    for (int argb : samples) buf[i++] = argb & 0xFF;
    break;
  }
  }
  return buf;
}

/**
 * Replaces a specified channel in an array of pixel values with a value 
 * derived from an array of floats and clipped to the range 0..255.
 * 
 * @param samples   an array of pixel values
 * @param buf       an array of floats
 * @param chan      the channel to replace
 */
public void pushChannel(int[] samples, float[] buf, ChannelNames chan) {
  // convert sample channel to float array buf
  int i = 0;
  switch (chan) {
  case L: {
    colorMode(HSB, 255);
    for (float component : buf) {
      int comp = Math.round((int) component); 
      comp = comp > 255 ? 255 : comp < 0 ? 0 : comp;
      int argb = samples[i];
      samples[i++] = color(Math.round(hue(argb)), Math.round(saturation(argb)), comp, 255);
    }
    break;
  }
  case H: {
    colorMode(HSB, 255);
    for (float component : buf) {
      int comp = Math.round((int) component); 
      comp = comp > 255 ? 255 : comp < 0 ? 0 : comp;
      int argb = samples[i];
      samples[i++] = color(comp, Math.round(saturation(argb)), Math.round(brightness(argb)), 255);
    }
    break;
  }
  case S: {
    colorMode(HSB, 255);
    for (float component : buf) {
      int comp = Math.round((int) component); 
      comp = comp > 255 ? 255 : comp < 0 ? 0 : comp;
      int argb = samples[i];
      samples[i++] = color(Math.round(hue(argb)), comp, Math.round(brightness(argb)), 255);
    }
    break;
  }
  case R: {
    colorMode(RGB, 255);
    for (float component : buf)  {
      int comp = Math.round((int) component); 
      comp = comp > 255 ? 255 : comp < 0 ? 0 : comp;
      int argb = samples[i];
      samples[i++] = 255 << 24 | comp << 16 | ((argb >> 8) & 0xFF) << 8 | argb & 0xFF;
    }
    break;
  }
  case G: {
    colorMode(RGB, 255);
    for (float component : buf) {
      int comp = Math.round((int) component); 
      comp = comp > 255 ? 255 : comp < 0 ? 0 : comp;
      int argb = samples[i];
      samples[i++] = 255 << 24 | ((argb >> 16) & 0xFF) << 16 | comp << 8 | argb & 0xFF;
    }
    break;
  }
  case B: {
    colorMode(RGB, 255);
    for (float component : buf) {
      int comp = Math.round((int) component); 
      comp = comp > 255 ? 255 : comp < 0 ? 0 : comp;
      int argb = samples[i];
      samples[i++] = 255 << 24 | ((argb >> 16) & 0xFF) << 16 | ((argb >> 8) & 0xFF) << 8 | comp & 0xFF;
    }
    break;
  }
  }
}

/**
 * Performs an FFT on a supplied array of samples, scales frequencies using settings in the 
 * equalizer interface, modifies the samples and also returns the modified samples. 
 * 
 * @param samples   an array of RGB values
 * @param chan      the channel to pass through the FFT
 * @return          the modified samples
 */
public int[] fftEqGlitch(int[] samples, ChannelNames chan) {
  // convert the selected channel to an array of floats
  float[] buf = pullChannel(samples, chan);
  // do a forward transform on the array of floats
  fft.forward(buf);
  // scale the frequencies in the fft by user-selected values from the equalizer interface
  for (int i = 0; i < calculatedBands; i++) {
    // get indices of the range of bands covered by each slider
    int pos = eq.length - i - 1;
    IntRange ir = bandList.get(pos);
    // get the scaling value set by the user
    float scale = eq[pos];
    // scale all bands between lower and upper index
    for (int j = ir.lower; j <= ir.upper; j++) {
      fft.scaleBand(j, scale);
    }
  }
  // inverse the transform
  fft.inverse(buf);
  pushChannel(samples, buf, chan);
  return samples;
}
  
/**
 * Performs a zigzag scan, centered in the image, and passes blocks 
 * to an FFT transform that uses a user-supplied equalization curve.
 * 
 * @param order   the width/height of each pixel block to sort
 */
public void eqZigzagFFT() {
  int order = (int) Math.sqrt(bufferSize);
  this.fftBlockWidth = order;
  Zigzagger zz = new Zigzagger(order);
  println("Zigzag order = "+ order);
  int dw = (img.width / order);
  int dh = (img.height / order);
  int w = dw * order;
  int h = dh * order;
  int ow = (img.width - w) / 2;
  int oh = (img.height - h) / 2;
  backup();
  img.loadPixels();
  for (int y = 0; y < dh; y++) {
    for (int x = 0; x < dw; x++) {
      int mx = x * order + ow;
      int my = y * order + oh;
//          if (random(1) > 0.5f) {
//            zz.flipX();
//          }
//          if (random(1) > 0.5f) {
//            zz.flipY();
//          }
      int[] pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
      // the samples are returned by fftEqGlitch, but they are modified already
      if (isEqGlitchBrightness) fftEqGlitch(pix, ChannelNames.L);
      if (isEqGlitchHue) fftEqGlitch(pix, ChannelNames.H);
      if (isEqGlitchSaturation) fftEqGlitch(pix, ChannelNames.S);
      if (isEqGlitchRed) fftEqGlitch(pix, ChannelNames.R);
      if (isEqGlitchGreen) fftEqGlitch(pix, ChannelNames.G);
      if (isEqGlitchBlue) fftEqGlitch(pix, ChannelNames.B);
      zz.plant(img.pixels, pix, img.width, img.height, mx, my);
    }
  }
  img.updatePixels();
  // necessary to call fitPixels to show updated image
  fitPixels(isFitToScreen, false);
//    analyzeEq(false);
}

/**
 * Performs an FFT on a supplied array of samples, scales frequencies using settings in the 
 * statistical interface, modifies the samples and also returns the modified samples. 
 * 
 * @param samples   an array of RGB values
 * @param chan      the channel to pass through the FFT
 * @return          the modified samples
 */
public float[] fftStatGlitch(int[] samples, ChannelNames chan) {
  // convert the selected channel to an array of floats
  float[] buf = pullChannel(samples, chan);
  // do a forward transform on the array of floats
  fft.forward(buf);
  // ignore first bin, the "DC component" if low frequency is cut
  int low = (isLowFrequencyCut) ? 1 : 0;
  float[] stats = fftStat(low, buf.length, false, "fft "+ chan.name());
  float min = stats[0];
  float max = stats[1];
  float mean = stats[2];
  float median = stats[3];
  float sd = stats[4];
  float skew = stats[5];
  int t = samples.length / 2;
  // typical values: left = 0.5f, right = 2.0f
//    float leftEdge = mean - sd * leftBound;
//    float rightEdge = mean + sd * rightBound;
  float leftEdge = leftBound < 0 ? mean - sd * -leftBound : mean + sd * leftBound;
  float rightEdge = rightBound < 0 ? mean - sd * -rightBound : mean + sd * rightBound;
//    println("min = "+ min +", max = "+ max +", mean = "+ mean +", median = "+ median +", sd = " + sd  +", skew = "+ skew +", leftBound = "+ leftBound +", rightBound = "+ rightBound);    
//    println("-- leftEdge = "+ leftEdge +", rightEdge = "+ rightEdge );
  // scale the frequencies in the fft, skipping band 0
  for (int i = 1; i < t; i++) {
    float val = fft.getBand(i);
    // frequencies whose amplitudes lie outside the bounds are scaled by the cut value
    if (val < leftEdge || val > rightEdge) fft.scaleBand(i, cut);
    // frequencies whose amplitudes lie inside the bounds are scaled by the boost value
    else {
      fft.scaleBand(i, boost);
    }
  }
  // inverse the transform
  fft.inverse(buf);
  pushChannel(samples, buf, chan);
  return stats;
}

/**
 * Performs a zigzag scan, centered in the image, and passes blocks 
 * to an FFT transform that uses statistical analysis to determine frequency scaling.
 * 
 * @param order   the width/height of each pixel block to sort
 */
public void statZigzagFFT() {
  int order = (int) Math.sqrt(bufferSize);
  this.fftBlockWidth = order;
  // eliminate fft averaging, don't need it
  // fft.logAverages(minBandWidth, bandsPerOctave);
  Zigzagger zz = new Zigzagger(order);
  println("Zigzag order = "+ order);
  int dw = (img.width / order);
  int dh = (img.height / order);
  int totalBlocks = dw * dh;
  int w = dw * order;
  int h = dh * order;
  int ow = (img.width - w) / 2;
  int oh = (img.height - h) / 2;
  float min = 0, max = 0, mean = 0, median = 0, sd = 0, skew = 0;
  float[] stats = new float[6];
  backup();
  img.loadPixels();
  for (int y = 0; y < dh; y++) {
    for (int x = 0; x < dw; x++) {
      int mx = x * order + ow;
      int my = y * order + oh;
//          if (random(1) > 0.5f) {
//            zz.flipX();
//          }
//          if (random(1) > 0.5f) {
//            zz.flipY();
//          }
      int[] pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
      if (isStatGlitchBrightness) stats = fftStatGlitch(pix, ChannelNames.L);
      if (isStatGlitchHue) stats = fftStatGlitch(pix, ChannelNames.H);
      if (isStatGlitchSaturation) stats = fftStatGlitch(pix, ChannelNames.S);
      if (isStatGlitchRed) stats = fftStatGlitch(pix, ChannelNames.R);
      if (isStatGlitchGreen) stats = fftStatGlitch(pix, ChannelNames.G);
      if (isStatGlitchBlue) stats = fftStatGlitch(pix, ChannelNames.B);
      min += stats[0];
      max += stats[1];
      mean += stats[2];
      median += stats[3];
      sd += stats[4];
      skew += stats[5];
      zz.plant(img.pixels, pix, img.width, img.height, mx, my);
    }
  }
  min /= totalBlocks;
  max /= totalBlocks;
  mean /= totalBlocks;
  median /= totalBlocks;
  sd /= totalBlocks;
  skew /= totalBlocks;
  float leftEdge = leftBound < 0 ? mean - sd * -leftBound : mean + sd * leftBound;
  float rightEdge = rightBound < 0 ? mean - sd * -rightBound : mean + sd * rightBound;
  println("---- Average statistical values for image before FFT ----");
  println("  min = "+ twoPlaces.format(min) +", max = "+ twoPlaces.format(max) +", mean = "+ twoPlaces.format(mean) 
      +", median = "+ twoPlaces.format(median) +", sd = " + twoPlaces.format(sd)  +", skew = "+ twoPlaces.format(skew));    
  println("  leftEdge = "+ twoPlaces.format(leftEdge) +", rightEdge = "+ twoPlaces.format(rightEdge) +", leftBound = "+ leftBound +", rightBound = "+ rightBound);
  img.updatePixels();
  // necessary to call fitPixels to show updated image
  fitPixels(isFitToScreen, false);
//    analyzeEq(false);
}


/**
 * Resets equalizer FFT controls
 */
public void resetEq() {
  for (int i = 0; i < eq.length; i++) {
    String token = sliderIdentifier + noPlaces.format(i);
    Slider slider = (Slider) controlP5.getController(token);
    slider.setValue(0);
  }
  analyzeEq(false);
}

/**
 * Resets statistical FFT controls
 */
public void resetStat() {
  Range r02 = (Range) controlP5.getController("setStatEqRange");
  r02.setBroadcast(false);
  r02.setLowValue(defaultLeftBound);
  r02.setHighValue(defaultRightBound);
  r02.setArrayValue(0, defaultLeftBound);
  r02.setArrayValue(1, defaultRightBound);
  rightBound = defaultRightBound;
  leftBound = defaultLeftBound;
  r02.setBroadcast(true);
  Numberbox n4 = (Numberbox) controlP5.getController("setBoost");
  n4.setValue(defaultBoost);
  Numberbox n5 = (Numberbox) controlP5.getController("setCut");
  n5.setValue(defaultCut);
}
  
/**
 * parameterless method that ControlP5 button calls (a workaround)
 */
public void analyzeEqBands() {
  analyzeEq(true);
}
 
// TODO calculate accurate center frequency values for the bands we actually have
/**
 * Examines display buffer Brightness channel and outputs mean 
 * amplitudes of frequency bands shown in equalizer.
 * 
 * @param isPrintToConsole   if true, prints information to console
 */
public void analyzeEq(boolean isPrintToConsole) {
  int order = (int) Math.sqrt(bufferSize);
  this.fftBlockWidth = order;
//      if (8 != order && 16 != order && 32 != order && 64 != order && 128 != order && 256 != order && 512 != order) {
//        println("block size must be 8, 16, 32, 64, 128, 256 or 512 for FFT glitching");
//        return;
//      }
  Zigzagger zz = new Zigzagger(order);
  // calculate how many complete blocks will fit horizontally and vertically
  int dw = (img.width / order);
  int dh = (img.height / order);
  int howManyBlocks =  dw * dh;
  // calculate the number of pixels in the vertical and horizontal block extents
  int w = dw * order;
  int h = dh * order;
  // calculate offsets towards the center, if blocks don't completely cover the image
  int ow = (img.width - w) / 2;
  int oh = (img.height - h) / 2;
  img.loadPixels();
  int blockNum = 0;
  binTotals = new double[calculatedBands];
  // minimum brightness value in image
  float min = -1;
  // maximum brightness value in image
  float max = 0;
  java.util.Arrays.fill(binTotals, 0);
  for (int y = 0; y < dh; y++) {
    for (int x = 0; x < dw; x++) {
      int mx = x * order + ow;
      int my = y * order + oh;
      int[] pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
      float[] buf = new float[pix.length];
      colorMode(HSB, 255);
      // load buf with brightness values from block at mx, my
      for (int i = 0; i < pix.length; i++) {
        int c = pix[i];
        buf[i] = brightness(c);
        if (verbose) println(pix[i]);
      }
      fft.forward(buf);
      float[] stats = fftStat(0, buf.length, false, "fft brightness in frequency domain");
      if (min == -1) min = stats[0];
      else if (min > stats[0]) min = stats[0];
      if (max < stats[1]) max = stats[1];
      // sum the values in each band in our band list and stash the mean value in binTotals
      for (int i = 0; i < calculatedBands; i++) {
        IntRange ir = bandList.get(i);
        float sum = 0;
        for (int j = ir.lower; j <= ir.upper; j++) {
          sum += fft.getBand(j);
        }
        // divide sum by (number of bins in band i) *  (total number of blocks)
        binTotals[i] += sum/((ir.upper - ir.lower + 1) * howManyBlocks);
      }
       blockNum++;
    }
  }
  if (isPrintToConsole) {
    println("--- "+ blockNum +" blocks read, min = "+ min +", max = "+ max);
    for (int i = 0; i <calculatedBands; i++) {
      // divide the accumlated mean values from each block's band ranges
      // by the total number of blocks to get the normalized average over the image
      println("  band "+ i +": "+ twoPlaces.format(binTotals[i]));
    }
  }
}

// TODO output accurate center frequency values 
/**
 * Calculates avaialable frequency bands for current FFT buffer, returns an array of integer ranges
 * representing frequency bin index numbers. Sets calculatedBands to size of bandList array.
 * 
 * @return   array of integer ranges corresponding to frequency bin index numbers
 */
public ArrayList<IntRange> calculateEqBands() {
  bandList = new ArrayList<IntRange>();
  int slots = minBandWidth * (bandsPerOctave);
  ArrayList<FloatRange> freqList = new ArrayList<FloatRange>(slots);
  // we can obtain frequencies up to the Nyquist limit, which is half the sample rate
  float hiFreq = sampleRate / 2.0f, loFreq = 0;
  // bandsPerOctave = 3
  FloatRange fr;
  int pos = slots - 1;
  for (int i = 0; i < minBandWidth; i++) {
    loFreq = hiFreq * 0.5f;
    float incFreq = (hiFreq - loFreq)/bandsPerOctave;
    // inner loop could be more efficient
    for (int j = bandsPerOctave; j > 0; j--) {
      fr = new FloatRange(loFreq + (j - 1) * incFreq, loFreq + j * incFreq);
      freqList.add(fr);
    }
    hiFreq = loFreq;
  }
  // reverse the frequency list, it should go from low to high
  for (int left = 0, right = freqList.size() - 1; left < right; left++, right--) {
    // exchange the first and last
    FloatRange temp = freqList.get(left); 
    freqList.set(left, freqList.get(right)); 
    freqList.set(right, temp);
  }
  // figure out the bins
  int hiBin = 0;
  int loBin = 0;
  float freq0 = fft.indexToFreq(0);
  float freq = fft.indexToFreq(hiBin);
  IntRange ir = null;
  for (FloatRange r : freqList) {
    if (freq < freq0) continue;
    while (freq < r.upper) {
      freq = fft.indexToFreq(hiBin++);
    }
    IntRange temp = new IntRange(loBin, hiBin);
    if (!temp.equals(ir)) {
      bandList.add(temp);
      ir = temp;
    }
    loBin = hiBin;
  }
  // TODO maybe there's a less kludgey way to initilize, without the following correction
  // fix off by two error....
  bandList.get(bandList.size() - 1).upper = fft.specSize() - 1;
  // omit printing of lists
  calculatedBands = bandList.size();
  println("----- number of frequency bands = "+ calculatedBands);
  // don't need to do averaging, without it FFT should be faster
  // (minBandWidth, bandsPerOctave);
  return bandList;
}


/**
 * not used
 */
public void printEqInfo() {
  int ct = 0;
  println("-------- frequencies --------");
  Iterator<FloatRange> iter = this.freqList.iterator();
  while (iter.hasNext()) {
    FloatRange fr = iter.next();
    println("  "+ ct++ +": "+ twoPlaces.format(fr.lower) +", "+ twoPlaces.format(fr.upper));
  }
  println();
}

/**
 * Calculates and outputs statistics for display buffer, determined by current FFT and equalizer bands. 
 */
public void testEq() {
  int slots = minBandWidth * (bandsPerOctave);
  ArrayList<FloatRange> freqList = new ArrayList<FloatRange>(slots);
  // we can obtain frequencies up to the Nyquist limit, which is half the sample rate
  float hiFreq = sampleRate / 2.0f, loFreq = 0;
  // bandsPerOctave = 3
  FloatRange fr;
  int pos = slots - 1;
  for (int i = 0; i < minBandWidth; i++) {
    loFreq = hiFreq * 0.5f;
    float incFreq = (hiFreq - loFreq)/bandsPerOctave;
    // inner loop could be more efficient
    for (int j = bandsPerOctave; j > 0; j--) {
      fr = new FloatRange(loFreq + (j - 1) * incFreq, loFreq + j * incFreq);
      freqList.add(fr);
    }
    hiFreq = loFreq;
  }
  // reverse the list
  for (int left = 0, right = freqList.size() - 1; left < right; left++, right--) {
    // exchange the first and last
    FloatRange temp = freqList.get(left); 
    freqList.set(left, freqList.get(right)); 
    freqList.set(right, temp);
  }
  // figure out the bins
  ArrayList<IntRange> theBandList = new ArrayList<IntRange>();
  int hiBin = 0;
  int loBin = 0;
  float freq0 = fft.indexToFreq(0);
  float freq = fft.indexToFreq(hiBin);
  IntRange ir = null;
  for (FloatRange r : freqList) {
    if (freq < freq0) continue;
    while (freq < r.upper) {
      freq = fft.indexToFreq(hiBin++);
    }
    IntRange temp = new IntRange(loBin, hiBin);
    if (!temp.equals(ir)) {
      theBandList.add(temp);
      ir = temp;
    }
    loBin = hiBin;
  }
  // print out the list
  int ct = 0;
  println("\n---- Frequency List ----");
  for (FloatRange r : freqList) {
    println("  "+ ct +": "+ r.toString());
    ct++;
  }
  ct = 0;
  println("\n---- Band List ----");
  for (IntRange r : theBandList) {
    println("  "+ ct +": "+ r.toString());
    ct++;
  }
  println("  freq 0 = "+ fft.indexToFreq(0) +", freq "+ fft.specSize() +" = "+ fft.indexToFreq(fft.specSize()));
  println("\n");
}

/**
 * sets up audification
 */
public void audify() {
  if (null == glitchSignal) {
    glitchSignal = new GlitchSignal();
    out = minim.getLineOut(Minim.STEREO, 64 * 64);
    out.addSignal(glitchSignal);
  }
  else {
    int blockEdgeSize = (int) Math.sqrt(bufferSize);
    // update dimensions to catch rotations, new images, etc.;
    int dw = (img.width / blockEdgeSize);
    int dh = (img.height / blockEdgeSize);
    int w = dw * blockEdgeSize;
    int h = dh * blockEdgeSize;
    int ow = (img.width - w) / 2;
    int oh = (img.height - h) / 2;
    int inX = 0, inY = 0;
    if (isFitToScreen) {
      inX = (int) map(mouseX, 0, fitImg.width, 0, img.width);
      inY = (int) map(mouseY, 0, fitImg.height, 0, img.height);
    }
    else {
      inX = mouseX;
      inY = mouseY;
    }
    int mapX = (inX/blockEdgeSize) * blockEdgeSize + ow;
    int mapY = (inY/blockEdgeSize) * blockEdgeSize + oh;
    if (mapX > w - blockEdgeSize + ow || mapY > h - blockEdgeSize + oh) return;
    Zigzagger zz = new Zigzagger(blockEdgeSize);
    img.loadPixels();
    int[] pix = zz.pluck(img.pixels, img.width, img.height, mapX, mapY);
    // do something to a single block
    if ('g' == lastCommand) this.sortTool.sort(pix);
    else if ('k' == lastCommand) fftStatGlitch(pix, ChannelNames.L);
    else if ('j' == lastCommand) fftEqGlitch(pix, ChannelNames.L);
    else this.sortTool.sort(pix);
    zz.plant(img.pixels, pix, img.width, img.height, mapX, mapY);
    img.updatePixels();
    // necessary to call fitPixels to show updated image
    fitPixels(isFitToScreen, false);
  }
}

/**
 * turns off audification
 */
public void audifyOff() {
  if (null != glitchSignal) {
    out.removeSignal(glitchSignal);
    glitchSignal = null;
  }
}

/**
 * @author paulhz
 * a class that implements an AudioSignal interface, used by Minim library to produce sound.
 */
public class GlitchSignal implements AudioSignal {
  int blockEdgeSize = 64;
  Zigzagger zz;
  int dw;
  int dh;
  int w;
  int h;
  int ow;
  int oh;
  int mapX;
  int mapY;
  float[] buf;

  public GlitchSignal() {
    println("audio Zigzag order = "+ blockEdgeSize);
    zz = new Zigzagger(blockEdgeSize);
    
  }
  
  public Zigzagger getZz() {
    if (null == zz) {
      zz = new Zigzagger(blockEdgeSize);
    }
    return zz;
  }
  
  public int getBlockEdgeSize() {
    return this.blockEdgeSize;
  }

  public void generate(float[] samp) {
    // update dimensions to catch rotations, new images, etc.;
    dw = (img.width / blockEdgeSize);
    dh = (img.height / blockEdgeSize);
    w = dw * blockEdgeSize;
    h = dh * blockEdgeSize;
    ow = (img.width - w) / 2;
    oh = (img.height - h) / 2;
    int inX = 0, inY = 0;
    if (isFitToScreen) {
      inX = (int) map(mouseX, 0, fitImg.width, 0, img.width);
      inY = (int) map(mouseY, 0, fitImg.height, 0, img.height);
    }
    else {
      inX = mouseX;
      inY = mouseY;
    }
    int mx = (inX/blockEdgeSize) * blockEdgeSize + ow;
    int my = (inY/blockEdgeSize) * blockEdgeSize + oh;
    if (mx > w - blockEdgeSize + ow || my > h - blockEdgeSize + oh) return;
    float fac = 1.0f/255 * 2.0f;
    if (mx == this.mapX && my == this.mapY) {
      // still in the same location, just copy the buffer
      for (int i = 0; i < buf.length; i++) {
        samp[i] = buf[i];
      }
    } 
    else {
      // in a new location, calculate a new buffer
      this.mapX = mx;
      this.mapY = my;
      int[] pix = getZz().pluck(img.pixels, img.width, img.height, mapX, mapY);
      buf = pullChannel(pix, ChannelNames.L);
      for (int i = 0; i < buf.length; i++) {
        buf[i] = buf[i] * fac - 1.0f;
        samp[i] = buf[i];
      }
    }
  }

  // this is a stricly mono signal
  public void generate(float[] left, float[] right)
  {
    generate(left);
    generate(right);
  }

}


