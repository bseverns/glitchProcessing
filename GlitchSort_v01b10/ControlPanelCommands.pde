/********************************************/
/*                                          */
/*      >>> CONTROL PANEL COMMANDS <<<      */
/*                                          */
/********************************************/


/**
 * Sets glitchSteps.
 * @param val   the new value for glitchSteps
 */
public void setGlitchSteps(float val) {
  val = val < 1 ? 1 : (val > 100 ? 100 : val);
  if (val == glitchSteps) return;
  glitchSteps = val;
  glitchSteps = (int)  Math.floor(glitchSteps);
  ((Textlabel)controlP5.getController("glitchStepsLabel")).setValue("Steps = "+ (int)glitchSteps);
  if (null != ranger) {
    ranger.setNumberOfIntervals((int)glitchSteps);
    println("range intervals set to "+ (int) glitchSteps);
  }
  if (verbose) println("glitchSteps = "+ glitchSteps);
}

/**
 * Sets glitchSteps.
 * @param val   the new value for glitchSteps
 */
public void incrementGlitchSteps(boolean up) {
  // a workaround to permit us to call setGlitchSteps as a bottleneck method
  int steps = (int) glitchSteps;
  if (up) steps++;
  else steps--;
  setGlitchSteps(steps);
  controlP5.getController("setGlitchSteps").setBroadcast(false);
  controlP5.getController("setGlitchSteps").setValue(glitchSteps);
  controlP5.getController("setGlitchSteps").setBroadcast(true);
}

/**
 * Set the value of isGlitchCycle.
 * @param isCycle   the value to set isCycleGlitch
 * @param isFromControlPanel   true if called from the control panel, false otherwise
 */
public void setCycle(boolean isCycle, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    if (isCycle) ((CheckBox) controlP5.getGroup("Glitchmode")).activate(0);
    else ((CheckBox) controlP5.getGroup("Glitchmode")).deactivate(0);
  }
  else {
    isCycleGlitch = isCycle;
    if (null != rowNums) resetRowNums();
    // if isCycleGlitch was just set to true, reset ranger's index to 0
    if (isCycleGlitch && null != ranger) {
      ranger.resetCurrentIndex();
      println("range index reset to 0");
    }
    if (verbose) println("isCycleGlitch = "+ isCycleGlitch);
  }
}

/**
 * Sets mungeThreshold
 * @param val   the desired JPEG quality setting (* 100).
 */
public void setMungeThreshold(float val) {
  if ((int) val == mungeThreshold) return;
  mungeThreshold = (int) val;
  if (verbose) println("degrade quality = "+ degradeQuality);
}


/**
 * Toggles value of isMungeInverted, changes how difference mask operates in munge operation.
 * @param invert
 * @param isFromControlPanel
 */
public void invertMunge(boolean invert, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    if (invert) ((CheckBox) controlP5.getGroup("invertMunge")).activate(0);
    else ((CheckBox) controlP5.getGroup("invertMunge")).deactivate(0);
  }
  else {
    isMungeInverted = invert;
    println("isMungeInverted = "+ isMungeInverted);   
  }
}

/**
 * Sets degradeQuality
 * @param val   the desired JPEG quality setting (* 100).
 */
public void setQuality(float val) {
  if (val == degradeQuality * 100) return;
  degradeQuality = val * 0.01f;
  println("degrade quality = "+ this.twoPlaces.format(degradeQuality * 100));
}

/**
 * Increments or decrements and sets degradeQuality.
 * @param up   true if increment, false if decrement
 */
public void incrementDegradeQuality(boolean up) {
  // a workaround to permit us to call setQuality as a bottleneck method
  float q = (degradeQuality * 100);
  if (up) q++; 
  else q--;
  setQuality(constrain(q, 0, 100));
  controlP5.getController("setQuality").setBroadcast(false);
  controlP5.getController("setQuality").setValue(degradeQuality * 100);
  controlP5.getController("setQuality").setBroadcast(true);
}



/**
 * TODO
 * Sets the sorting method (QUICK, SHELL, BUBBLE, INSERT) used by sortTool.
 * @param type   the type of sorting method to use
 * @param isFromControlPanel   true if call is from a control panel interaction, false otherwise
 */
public void setSorter(SorterType type, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    ((RadioButton) controlP5.getGroup("setSorter")).activate(type.name());
  }
  else {
    sortTool.setSorter(type);
    breakPoint = sortTool.sorter.getBreakPoint();
    controlP5.getController("setBreakpoint").setBroadcast(false);
    controlP5.getController("setBreakpoint").setValue(breakPoint);
    ((Textlabel)controlP5.getController("breakpointLabel")).setValue("Breakpoint: " + sortTool.sorter.getSorterType().toString());
    controlP5.getController("setBreakpoint").setBroadcast(true);
    println(type.name() +" sorter loaded");
  }
  if (type == SorterType.BUBBLE || type == SorterType.INSERT) {
    // bubble and insert sorts are extremely slow: it only make sense to use them if they break (glitch)
    // so we set the break checkbox to true and lock it
    println("bubble or insert sort: break set to true");
    setRandomBreak(true, false);
    ((CheckBox) controlP5.getGroup("Sorting")).getItem(1).setLock(true);
  }
  else {
    // unlock the break checkbox
    ((CheckBox) controlP5.getGroup("Sorting")).getItem(1).setLock(false);
  }
}

/**
 * Sets the order of components used to sort pixels.
 * @param index   index number of CompOrder values 
 * @param isFromControlPanel   true if call is from a control panel interaction, false otherwise
 */
public void setCompOrder(int index, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    ((RadioButton) controlP5.getGroup("setCompOrder")).activate(index);
  }
  else {
    compOrderIndex = index;
    compOrder = CompOrder.values()[compOrderIndex];
    println("Color component order set to "+ compOrder.name());
  }
}

/**
 * @param val   true if sorting should be in ascending order, false otherwise 
 * @param isFromControlPanel   true if call is from a control panel interaction, false otherwise
 */
public void setAscending(boolean val, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    if (val) ((CheckBox) controlP5.getGroup("Sorting")).activate("Ascending");
    else ((CheckBox) controlP5.getGroup("Sorting")).deactivate("Ascending");
  }
  else {
    if (isAscendingSort == val) return;
    isAscendingSort = val;
    println("Ascending sort order is "+ isAscendingSort);
  }
}
  
/**
 * @param val   true if random breaks in sorting ("glitches") are desired, false otherwise.
 * @param isFromControlPanel   true if call is from a control panel interaction, false otherwise
 */
public void setRandomBreak(boolean val, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    if (val) ((CheckBox) controlP5.getGroup("Sorting")).activate("Break");
    else ((CheckBox) controlP5.getGroup("Sorting")).deactivate("Break");
  }
  else {
    if (randomBreak == val) return;
    randomBreak = val;
    sortTool.setRandomBreak(randomBreak);
    println("randomBreak is "+ randomBreak);
  }
}

/**
 * @param val   true if color channels should be swapped when sorting (more glitching). 
 * @param isFromControlPanel   true if call is from a control panel interaction, false otherwise
 */
public void setIsSwapChannels(boolean val, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    if (val) ((CheckBox) controlP5.getGroup("Sorting")).activate("Swap");
    else ((CheckBox) controlP5.getGroup("Sorting")).deactivate("Swap");
  }
  else {
    if (isSwapChannels == val) return;
    isSwapChannels = val;
    println("Swap color channels is "+ isSwapChannels);
  }
}

/**
 * @param newSwap   the swap value to set, determinse which channels are swapped.
 * @param isFromControlPanel   true if call is from a control panel interaction, false otherwise
 */
public void setSwap(SwapChannel newSwap, boolean isFromControlPanel) {
  if (swap == newSwap) return;
  if (!isFromControlPanel) {
    RadioButton rb1 = (RadioButton)controlP5.getGroup("setSourceChannel");
    RadioButton rb2 = (RadioButton)controlP5.getGroup("setTargetChannel");
    switch (newSwap) {
    case RR: {
      rb1.activate(0);
      rb2.activate(0);
      break;
    }
    case RG: {
      rb1.activate(0);
      rb2.activate(1);
      break;
    }
    case RB: {
      rb1.activate(0);
      rb2.activate(2);
      break;
    }
    case GR: {
      rb1.activate(1);
      rb2.activate(0);
      break;
    }
    case GG: {
      rb1.activate(1);
      rb2.activate(1);
      break;
    }
    case GB: {
      rb1.activate(1);
      rb2.activate(2);
      break;
    }
    case BR: {
      rb1.activate(2);
      rb2.activate(0);
      break;
    }
    case BG: {
      rb1.activate(2);
      rb2.activate(1);
      break;
    }
    case BB: {
      rb1.activate(2);
      rb2.activate(2);
      break;
    }
    }
  }
  else {
    swap = newSwap;
    println("swap is "+ swap.name());
  }
}

public void setZigzagStyle(ZigzagStyle style, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    ((RadioButton) controlP5.getGroup("setZigzagStyle")).activate(style.ordinal());
  }
  else {
    zigzagStyle = style;
    println("-- zizagStyle = "+ style.name());
  }
} 

/**
 * adjusts control panel text to reflect updated quantization value
 * @param val   the current quantization value
 */
public void setColorQuantize(float val) {
  if (val == colorQuantize) return;
  colorQuantize = (int) val;
  ((Textlabel)controlP5.getController("colorQuantizeLabel")).setValue("Colors = "+ colorQuantize);
  // if (verbose) 
  println("colorQuantize = "+ colorQuantize);
}

/**
 * Sets colorQuantize.
 * @param val   the new value for glitchSteps
 */
public void incrementColorQuantize(boolean up) {
  // a workaround to permit us to call setGlitchSteps as a bottleneck method
  int val = (int) colorQuantize;
  if (up && val < 128) val++;
  else if (val > 2) val--;
  setColorQuantize(val);
  controlP5.getController("setColorQuantize").setBroadcast(false);
  controlP5.getController("setColorQuantize").setValue(colorQuantize);
  controlP5.getController("setColorQuantize").setBroadcast(true);
}

/**
 * Sets the values of equalizer-controlled FFT settings.
 * @param isBrightness   true if brightness channel is affect by FFT, false otherwise
 * @param isHue          true if hue channel is affect by FFT, false otherwise
 * @param isSaturation   true if saturation channel is affect by FFT, false otherwise
 * @param isRed          true if red channel is affect by FFT, false otherwise
 * @param isGreen        true if green channel is affect by FFT, false otherwise
 * @param isBlue         true if blue channel is affect by FFT, false otherwise
 * @param isFromControlPanel   true if called from the control panel, false otherwise
 */
public void setEqChan(boolean isBrightness, boolean isHue, boolean isSaturation,
    boolean isRed, boolean isGreen, boolean isBlue, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    // println("setting equalizer HSB/RGB");
    if (isBrightness) ((CheckBox) controlP5.getGroup("ChanEq")).activate(0);
    else ((CheckBox) controlP5.getGroup("ChanEq")).deactivate(0);
    if (isHue) ((CheckBox) controlP5.getGroup("ChanEq")).activate(1);
    else ((CheckBox) controlP5.getGroup("ChanEq")).deactivate(1);
    if (isSaturation) ((CheckBox) controlP5.getGroup("ChanEq")).activate(2);
    else ((CheckBox) controlP5.getGroup("ChanEq")).deactivate(2);
    if (isRed) ((CheckBox) controlP5.getGroup("ChanEq")).activate(3);
    else ((CheckBox) controlP5.getGroup("ChanEq")).deactivate(3);
    if (isGreen) ((CheckBox) controlP5.getGroup("ChanEq")).activate(4);
    else ((CheckBox) controlP5.getGroup("ChanEq")).deactivate(4);
    if (isBlue) ((CheckBox) controlP5.getGroup("ChanEq")).activate(5);
    else ((CheckBox) controlP5.getGroup("ChanEq")).deactivate(5);
  }
  else {
    isEqGlitchBrightness = isBrightness;
    isEqGlitchHue = isHue;
    isEqGlitchSaturation = isSaturation;
    isEqGlitchRed = isRed;
    isEqGlitchGreen = isGreen;
    isEqGlitchBlue = isBlue;
    if (verbose) 
    {
      println("Equalizer FFT: ");
      print("  Brightness = "+ isEqGlitchBrightness);
      print(", Hue = "+ isEqGlitchHue);
      print(", Saturation = "+ isEqGlitchSaturation);
      print(", Red = "+ isEqGlitchRed);
      print(", Green = "+ isEqGlitchGreen);
      println(", Blue = "+ isEqGlitchBlue);
    }
  }
}

/**
 * Sets the values of statistically controlled FFT settings.
 * @param isBrightness   true if brightness channel is affect by FFT, false otherwise
 * @param isHue          true if hue channel is affect by FFT, false otherwise
 * @param isSaturation   true if saturation channel is affect by FFT, false otherwise
 * @param isRed          true if red channel is affect by FFT, false otherwise
 * @param isGreen        true if green channel is affect by FFT, false otherwise
 * @param isBlue         true if blue channel is affect by FFT, false otherwise
 * @param isFromControlPanel   true if called from the control panel, false otherwise
 */
public void setStatChan(boolean isBrightness, boolean isHue, boolean isSaturation,
    boolean isRed, boolean isGreen, boolean isBlue, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    // println("setting statistical HSB/RGB");
    if (isBrightness) ((CheckBox) controlP5.getGroup("ChanStat")).activate(0);
    else ((CheckBox) controlP5.getGroup("ChanStat")).deactivate(0);
    if (isHue) ((CheckBox) controlP5.getGroup("ChanStat")).activate(1);
    else ((CheckBox) controlP5.getGroup("ChanStat")).deactivate(1);
    if (isSaturation) ((CheckBox) controlP5.getGroup("ChanStat")).activate(2);
    else ((CheckBox) controlP5.getGroup("ChanStat")).deactivate(2);
    if (isRed) ((CheckBox) controlP5.getGroup("ChanStat")).activate(3);
    else ((CheckBox) controlP5.getGroup("ChanStat")).deactivate(3);
    if (isGreen) ((CheckBox) controlP5.getGroup("ChanStat")).activate(4);
    else ((CheckBox) controlP5.getGroup("ChanStat")).deactivate(4);
    if (isBlue) ((CheckBox) controlP5.getGroup("ChanStat")).activate(5);
    else ((CheckBox) controlP5.getGroup("ChanStat")).deactivate(5);
  }
  else {
    isStatGlitchBrightness = isBrightness;
    isStatGlitchHue = isHue;
    isStatGlitchSaturation = isSaturation;
    isStatGlitchRed = isRed;
    isStatGlitchGreen = isGreen;
    isStatGlitchBlue = isBlue;
    if (verbose) 
    {
      println("Statistical FFT: ");
      print("  Brightness = "+ isStatGlitchBrightness);
      print(", Hue = "+ isStatGlitchHue);
      print(", Saturation = "+ isStatGlitchSaturation);
      print(", Red = "+ isStatGlitchRed);
      print(", Green = "+ isStatGlitchGreen);
      println(", Blue = "+ isStatGlitchBlue);
    }
  }
}


/**
 * Toggles low frequency cut setting in statistical FFT control.
 * @param isCut
 * @param isFromControlPanel
 */
public void setLowFrequencyCut(boolean isCut, boolean isFromControlPanel) {
  if (!isFromControlPanel) {
    // println("setting statistical HSB/RGB");
    if (isCut) ((CheckBox) controlP5.getGroup("LowFreqCut")).activate(0);
    else ((CheckBox) controlP5.getGroup("LowFreqCut")).deactivate(0);
  }
  else {
    isLowFrequencyCut = isCut;
    println("isLowFrequencyCut = "+ isLowFrequencyCut);
  }
}

/**
 * Sets fftBlockWidth. 
 * @param val   the new value for eqGain
 */
public void setFFTBlockWidth(float val) {
  val = val < 3 ? 3 : (val > 9 ? 9 : val);
  int temp = (int) Math.pow(2, (int) val);
  if (temp == fftBlockWidth) return;
  resetFFT(temp);
}

/**
 * Sets value of leftBound used in statistical FFT interface
 * @param newLeftBound
 */
public void setLeftBound(float newLeftBound) {
  if (newLeftBound == leftBound) return;
  leftBound = newLeftBound;
}

/**
 * Sets value of rightBound used in statistical FFT interface
 * @param newRightBound
 */
public void setRightBound(float newRightBound) {
  if (newRightBound == rightBound) return;
  rightBound = newRightBound;
}

/**
 * Sets value of boost used in statistical FFT interface
 * @param newBoost
 */
public void setBoost(float newBoost) {
  if (newBoost == boost) return;
  boost = newBoost;
}

/**
 * Sets value of cut used in statistical FFT interface
 * @param newCut
 */
public void setCut(float newCut) {
  if (newCut == cut) return;
  cut = newCut;
}



/**
 * Bottleneck that catches events propagated by control panel, used particularly for radio buttons and checkboxes.
 * @param evt   the event from the control panel
 */
public void controlEvent(ControlEvent evt) {
  if (evt.isGroup()) {
    if ("setCompOrder".equals(evt.getName())) {
      setCompOrder((int) evt.getGroup().getValue(), true);
    }
    else if ("setSorter".equals((evt.getName()))) {
      SorterType type = SorterType.values()[(int) evt.getGroup().getValue()];
      setSorter(type, true);
    }
    else if ("Sorting".equals(evt.getName())) {
      int n = (int)(evt.getGroup().getArrayValue()[0]);
      setAscending(n == 1, true);
      n = (int)(evt.getGroup().getArrayValue()[1]);
      setRandomBreak(n == 1, true);
      n = (int)(evt.getGroup().getArrayValue()[2]);
      setIsSwapChannels(n == 1, true);
    }
    else if ("setSourceChannel".equals(evt.getName())) {
      int n = (int)(evt.getGroup().getValue());
      RadioButton rb = (RadioButton)controlP5.getGroup("setTargetChannel");
      int m = (int) rb.getValue();
      String str = ChannelNames.values()[n].toString() + ChannelNames.values()[m].toString();
      SwapChannel sc = SwapChannel.valueOf(str);
      setSwap(sc, true);
    }
    else if ("setTargetChannel".equals(evt.getName())) {
      RadioButton rb = (RadioButton)controlP5.getGroup("setSourceChannel");
      int n = (int) rb.getValue();
      int m = (int)(evt.getGroup().getValue());
      String str = ChannelNames.values()[n].toString() + ChannelNames.values()[m].toString();
      SwapChannel sc = SwapChannel.valueOf(str);
      setSwap(sc, true);
    }
    else if ("fitPixels".equals(evt.getName())) {
      int n = (int)(evt.getGroup().getArrayValue()[0]);
      fitPixels(n == 1, true);
    }
    else if (("setZigzagStyle").equals(evt.getName())) {
      ZigzagStyle z = ZigzagStyle.values()[(int) evt.getGroup().getValue()];
      setZigzagStyle(z, true);        
    }
    else if ("invertMunge".equals(evt.getName())) {
      int n = (int)(evt.getGroup().getArrayValue()[0]);
      invertMunge(n == 1, true);
    }
    else if ("Glitchmode".equals(evt.getName())) {
      int n = (int)(evt.getGroup().getArrayValue()[0]);
      setCycle(n == 1, true);
    }
    else if ("ChanEq".equals(evt.getName())) {
      if (verbose) println("ChanEq event");
      int b = (int)(evt.getGroup().getArrayValue()[0]);
      int h = (int)(evt.getGroup().getArrayValue()[1]);
      int s = (int)(evt.getGroup().getArrayValue()[2]);
      int r = (int)(evt.getGroup().getArrayValue()[3]);
      int g = (int)(evt.getGroup().getArrayValue()[4]);
      int bl = (int)(evt.getGroup().getArrayValue()[5]);
      setEqChan(b == 1, h == 1, s == 1, r == 1, g == 1, bl == 1, true);
    }
    else if ("ChanStat".equals(evt.getName())) {
      if (verbose) println("ChanStat event");
      int b = (int)(evt.getGroup().getArrayValue()[0]);
      int h = (int)(evt.getGroup().getArrayValue()[1]);
      int s = (int)(evt.getGroup().getArrayValue()[2]);
      int r = (int)(evt.getGroup().getArrayValue()[3]);
      int g = (int)(evt.getGroup().getArrayValue()[4]);
      int bl = (int)(evt.getGroup().getArrayValue()[5]);
      setStatChan(b == 1, h == 1, s == 1, r == 1, g == 1, bl == 1, true);
    }
    else if ("Shift".equals(evt.getName())) {
      isShiftR = ((int)(evt.getGroup().getArrayValue()[0])) == 1;
      isShiftG = ((int)(evt.getGroup().getArrayValue()[1])) == 1;
      isShiftB = ((int)(evt.getGroup().getArrayValue()[2])) == 1;
    }
    else if ("LowFreqCut".equals(evt.getName())) {
      if (verbose) println("LowFreqCut event");
      int cut = (int)(evt.getGroup().getArrayValue()[0]);
      setLowFrequencyCut(cut == 1, true);
    }
    if (verbose) {
      print("got an event from "+ evt.getGroup().getName() +"\t");
      for(int i=0; i < evt.getGroup().getArrayValue().length; i++) {
        print((int)(evt.getGroup().getArrayValue()[i]));
      }
      println("\t "+ evt.getGroup().getValue());
    }
  }
  else if (evt.isController()) {
    String name = evt.getController().getName();
    if (name.substring(0, 3).equals(sliderIdentifier)) {
      Slider con = (Slider) evt.getController();
      int bin = con.getId();
      float val = con.getValue();
      if (bin >= 0 && bin < eq.length) {
        if (val < 0) eq[bin] = val + 1;
        else eq[bin] = lerp(0, eqScale, val) + 1;
        String legend = "band "+ bin +" = "+ twoPlaces.format(eq[bin]);
        if (null != binTotals && bin < binTotals.length) {
          // TODO : duplicated code here, put it in a function
          legend += ", bin avg = "+ twoPlaces.format(binTotals[bin]);
          IntRange ir = bandList.get(bin);
          legend += ", cf = "+ twoPlaces.format((fft.indexToFreq(ir.upper) + fft.indexToFreq(ir.lower)) * 0.5f);
        }
        ((Textlabel)controlP5.getController("eqLabel")).setValue(legend);
      }
    }
    
  }
}

