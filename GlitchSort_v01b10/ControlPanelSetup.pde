/********************************************/
/*                                          */
/*           >>> CONTROL PANEL <<<          */
/*                                          */
/********************************************/

/**
 * Shows or hides the control panel
 */
public void toggleControlPanelVisibility() {
  boolean p5Vis = controlP5.isVisible();
  if (p5Vis) {
    controlP5.hide();
  }
  else {
    controlP5.show();
  }
}

/**
 * Initializes and arranges the "glitch" control panel widgets
 * TODO control panel
 */
public void loadGlitchPanel() {
  int panelBack = color(123, 123, 144, 255);
  int yPos = 4;
  int step = 18;
  int spacer = 4;
  int widgetH = 14;
  int labelW = 144;
  int panelHeight = controlPanelHeight;
  settings = controlP5.addGroup("Glitch", controlPanelX, controlPanelY, controlPanelWidth);
  settings.setBackgroundColor(panelBack);
  settings.setBackgroundHeight(panelHeight);
  settings.setBarHeight(widgetH + 4);
  settings.setMoveable(false);     // option-drag on bar to move menu not permitted
  // add widgets
  // row of buttons: open, save, revert
  Button b1 = controlP5.addButton("openFile", 0, 8, yPos, 76, widgetH);
  b1.setGroup(settings);
  b1.getCaptionLabel().set("Open (o)");
  Button b2 = controlP5.addButton("saveFile", 0, controlPanelWidth/3 + 4, yPos, 76, widgetH);
  b2.setGroup(settings);
  b2.getCaptionLabel().set("Save (s)");
  Button b3 = controlP5.addButton("revert", 0, 2 * controlPanelWidth/3 + 4, yPos, 76, widgetH);
  b3.setGroup(settings);
  b3.getCaptionLabel().set("Revert (r)");
  // fit to screen/show all pixels toggle, rotate and undo buttons
  yPos += step;
  CheckBox ch0 = controlP5.addCheckBox("fitPixels", 8, yPos + 2);
  ch0.setGroup(settings);
  ch0.setColorForeground(color(120));
  ch0.setColorActive(color(255));
  ch0.setColorLabel(color(255));
  ch0.setItemsPerRow(3);
  ch0.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox
  ch0.addItem("Fit To Screen (f)", 1);
  ch0.setColorForeground(color(233, 233, 0));
  Button b5 = controlP5.addButton("rotatePixels", 0, 2 * controlPanelWidth/3 + 4, yPos, 76, widgetH);
  b5.setGroup(settings);
  b5.getCaptionLabel().set("Turn 90 (t)");
  Button b6 = controlP5.addButton("restore", 0, controlPanelWidth/3 + 4, yPos, 76, widgetH);
  b6.setGroup(settings);
  b6.getCaptionLabel().set("Undo (z)");
  // sorting section
  yPos += step + spacer;
  Textlabel l1 = controlP5.addTextlabel("sorterLabel", "Sorting", 8, yPos);
  l1.setGroup(settings);
  Textlabel l1u = controlP5.addTextlabel("sortingLabelUnder", "________________________________", 8, yPos + 3);
  l1u.setGroup(settings);
  // sort  button
  yPos += step;
  Button b4 = controlP5.addButton("sortPixels", 0, 8, yPos, 76, widgetH);
  b4.setGroup(settings);
  b4.getCaptionLabel().set("Sort (g)");
  // sorter selection radio buttons
  yPos += step + 2;
  RadioButton r1 = controlP5.addRadioButton("setSorter", 8, yPos);
  r1.setGroup(settings);
  r1.setColorForeground(color(120));
  r1.setColorActive(color(255));
  r1.setColorLabel(color(255));
  r1.setItemsPerRow(5);
  r1.setSpacingColumn(40);
  r1.setNoneSelectedAllowed(false);
  // enum SorterType {QUICK, SHELL, BUBBLE, INSERT;} 
  int n = 0;
  labelW = 32;
  r1.addItem("QUICK", n++);
  r1.addItem("SHELL", n++);
  r1.addItem("BUBBLE", n++);
  r1.addItem("INSERT", n++);
  setRadioButtonStyle(r1, labelW);
  /* r1.activate("QUICK"); */ // will throw a (non-fatal but annoying) error, see startup method
  // sorting checkboxes
  yPos += step - 4;
  CheckBox ch2 = controlP5.addCheckBox("Sorting", 8, yPos);
  ch2.setGroup(settings);
  ch2.setColorForeground(color(120));
  ch2.setColorActive(color(255));
  ch2.setColorLabel(color(255));
  ch2.setItemsPerRow(3);
  ch2.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox
  ch2.addItem("Ascending", 1);
  ch2.addItem("Break", 2);
  ch2.addItem("Swap", 3);
  ch2.setColorForeground(color(233, 233, 0));
  ch2.activate(1);
  // breakPoint number box
  yPos += step;
  Numberbox n1 = controlP5.addNumberbox("setBreakpoint", breakPoint, 8, yPos, 100, widgetH);
  n1.setGroup(settings);
  n1.setMultiplier(1f);
  n1.setDecimalPrecision(1);
  n1.setMin(1.0f);
  n1.setMax(999.0f);
  n1.getCaptionLabel().set("");
  // label for breakPoint number box
  Textlabel l2 = controlP5.addTextlabel("breakpointLabel", "Breakpoint: " + sortTool.sorter.getSorterType().toString(), 112, yPos + 4);
  l2.setGroup(settings);
  // glitchSteps slider
  yPos += step;
  Slider s1 = controlP5.addSlider("setGlitchSteps", 1, 100.1f, 1, 8, yPos, 101, widgetH);
  s1.setGroup(settings);
  s1.setDecimalPrecision(0);
  s1.getCaptionLabel().set("");
  s1.setSliderMode(Slider.FLEXIBLE);
  // label for glitchSteps slider
  Textlabel l3 = controlP5.addTextlabel("glitchStepsLabel", "Steps = "+ (int)glitchSteps, 112, yPos + 4);
  l3.setGroup(settings);
  // cycle checkbox
  CheckBox ch3 = controlP5.addCheckBox("Glitchmode", 2 * controlPanelWidth/3 + 4, yPos + 2);
  ch3.setGroup(settings);
  ch3.setColorForeground(color(120));
  ch3.setColorActive(color(255));
  ch3.setColorLabel(color(255));
  ch3.setItemsPerRow(3);
  ch3.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox
  ch3.addItem("Cycle", 1);
  ch3.setColorForeground(color(233, 233, 0));
  ch3.deactivate(0);    
  // sort order
  // label the radio button group
  yPos += step;
  Textlabel l5 = controlP5.addTextlabel("compOrderLabel", "Component Sorting Order:", 8, yPos + 4);
  l5.setGroup(settings);
  // move to next row
  yPos += step;
  RadioButton r2 = controlP5.addRadioButton("setCompOrder", 8, yPos);
  r2.setGroup(settings);
  r2.setColorForeground(color(120));
  r2.setColorActive(color(255));
  r2.setColorLabel(color(255));
  r2.setItemsPerRow(6);
  r2.setSpacingColumn(32);
  r2.setSpacingRow(4);
  // enum CompOrder {RGB, RBG, GBR, GRB, BRG, BGR, HSB, HBS, SBH, SHB, BHS, BSH;}
  n = 0;
  labelW = 24;
  r2.addItem("RGB", n++);
  r2.addItem("RBG", n++);
  r2.addItem("GBR", n++);
  r2.addItem("GRB", n++);
  r2.addItem("BRG", n++);
  r2.addItem("BGR", n++);
  r2.addItem("HSB", n++);
  r2.addItem("HBS", n++);
  r2.addItem("SBH", n++);
  r2.addItem("SHB", n++);
  r2.addItem("BHS", n++);
  r2.addItem("BSH", n++);
  setRadioButtonStyle(r2, labelW);
  r2.setNoneSelectedAllowed(false);
  /* r2.activate("RGB"); */ // will throw a (non-fatal but annoying) error, see startup method
  // channel swap
//    yPos += step + step/2;
//    Textlabel l6 = controlP5.addTextlabel("swapLabel", "Swap Channels:", 8, yPos + 4);
//    l6.setGroup(settings);
  yPos += step + step - 4;
  int inset = 80;
  Textlabel l7 = controlP5.addTextlabel("sourceLabel", "Swap Source:", 8, yPos);
  l7.setGroup(settings);
  RadioButton r3 = controlP5.addRadioButton("setSourceChannel", inset, yPos);
  r3.setGroup(settings);
  r3.setColorForeground(color(120));
  r3.setColorActive(color(255));
  r3.setColorLabel(color(255));
  r3.setItemsPerRow(3);
  r3.setSpacingColumn(32);
  n = 0;
  r3.addItem("R1", n++);
  r3.addItem("G1", n++);
  r3.addItem("B1", n++);
  setRadioButtonStyle(r3, labelW);
  r3.setNoneSelectedAllowed(false);
  yPos += step;
  Textlabel l8 = controlP5.addTextlabel("targetLabel", "Swap Target:", 8, yPos);
  l8.setGroup(settings);
  RadioButton r4 = controlP5.addRadioButton("setTargetChannel", inset, yPos);
  r4.setGroup(settings);
  r4.setColorForeground(color(120));
  r4.setColorActive(color(255));
  r4.setColorLabel(color(255));
  r4.setItemsPerRow(3);
  r4.setSpacingColumn(32);
  n = 0;
  r4.addItem("R2", n++);
  r4.addItem("G2", n++);
  r4.addItem("B2", n++);
  setRadioButtonStyle(r4, labelW);
  r4.setNoneSelectedAllowed(false);
  // zigzag intRange
  yPos += step;
  // use values that permit full stepwise range
  // addRange(name, min, max, defaultMin, defaultMax, x, y, w, h) 
  Range r01 = controlP5.addRange("setZigzagRange", 4, 144, 8, 64, 8, yPos, 160, widgetH);
  r01.setGroup(settings);
  r01.setDecimalPrecision(0);
  r01.setLowValue(8);
  r01.setHighValue(64);
  r01.getCaptionLabel().set("");
  // label for zigzag range slider
  Textlabel l10 = controlP5.addTextlabel("zigzagRangeLabel", "Z Range", 170, yPos + 4);
  l10.setGroup(settings);
  // zigzag button
  Button b12 = controlP5.addButton("zigzag", 0, 2 * controlPanelWidth/3 + 28, yPos, 60, widgetH);
  b12.setGroup(settings);
  b12.getCaptionLabel().set("Zigzag (l)");
  yPos += step;
  // zigzag sorting style
  RadioButton r6 = controlP5.addRadioButton("setZigzagStyle", 8, yPos);
  r6.setGroup(settings);
  r6.setColorForeground(color(120));
  r6.setColorActive(color(255));
  r6.setColorLabel(color(255));
  r6.setItemsPerRow(3);
  r6.setSpacingColumn(48);
  n = 0;
  labelW = 40;
  r6.addItem("Random", n++);
  r6.addItem("Align", n++);
  r6.addItem("Permute", n++);
  setRadioButtonStyle(r6, labelW);
  r6.setNoneSelectedAllowed(false);
  // zigzagPercent number box
  Numberbox n2 = controlP5.addNumberbox("setZigzagPercent", zigzagPercent, 218, yPos, 48, widgetH);
  n2.setGroup(settings);
  n2.setMultiplier(1f);
  n2.setDecimalPrecision(1);
  n2.setMin(1.0f);
  n2.setMax(100.0f);
  n2.getCaptionLabel().set("");
  // label for zigzagPercent number box
  Textlabel l10a = controlP5.addTextlabel("zigzagPercentLabel", "%:", 192, yPos + 2);
  l10a.setGroup(settings);
  // degrading, compositing section
  yPos += step + spacer;
  Textlabel l20 = controlP5.addTextlabel("degradeLabel", "Degrade + Quantize + Munge", 8, yPos);
  l20.setGroup(settings);
  Textlabel l20u = controlP5.addTextlabel("degradeLabelUnder", "________________________________", 8, yPos + 3);
  l20u.setGroup(settings);    
  // degrade controls
  yPos += step;
  Slider s2 = controlP5.addSlider("setQuality", 100, 0, 13.0f, 8, yPos, 128, widgetH);
  s2.setGroup(settings);
  s2.setDecimalPrecision(1);
  s2.getCaptionLabel().set("");
  s2.setSliderMode(Slider.FLEXIBLE);
  // label for degrade quality slider
  Textlabel l4 = controlP5.addTextlabel("QualityLabel", "Quality", 137, yPos + 4);
  l4.setGroup(settings);
  // degrade button
  Button b10 = controlP5.addButton("degrade", 0, 2 * controlPanelWidth/3 + 28, yPos, 60, widgetH);
  b10.setGroup(settings);
  b10.getCaptionLabel().set("Degrade (d)");
  // reduce colors slider
  yPos += step;
  Slider s3 = controlP5.addSlider("setColorQuantize", 2, 128, colorQuantize, 8, yPos, 127, widgetH);
  s3.setGroup(settings);
  s3.setDecimalPrecision(0);
  s3.getCaptionLabel().set("");
  s3.setSliderMode(Slider.FLEXIBLE);
  // label for color quantize slider
  Textlabel l9 = controlP5.addTextlabel("colorQuantizeLabel", "Colors = "+ colorQuantize, 137, yPos + 4);
  l9.setGroup(settings);
  // reduce colors button
  Button b11 = controlP5.addButton("reduceColors", 0, 2 * controlPanelWidth/3 + 28, yPos, 60, widgetH);
  b11.setGroup(settings);
  b11.getCaptionLabel().set("Reduce (p)");
  yPos += step;
  Button b14 = controlP5.addButton("shiftLeft", 0, 8, yPos, 32, widgetH);
  b14.setGroup(settings);
  b14.getCaptionLabel().set(" << ");    
  RadioButton r5 = controlP5.addRadioButton("Shift", 48, yPos + 2);
  r5.setGroup(settings);
  r5.setColorForeground(color(120));
  r5.setColorActive(color(255));
  r5.setColorLabel(color(255));
  r5.setItemsPerRow(3);
  r5.setSpacingColumn((controlPanelWidth - 8)/12);
  // add items to the checkbox
  r5.addItem("R", 1);
  r5.addItem("G", 2);
  r5.addItem("B", 3);
  r5.setColorForeground(color(233, 233, 0));
  r5.activate(0);   
  Button b15 = controlP5.addButton("shiftRight", 0, 48 + 4 * ((controlPanelWidth - 8)/12), yPos, 32, widgetH);
  b15.setGroup(settings);
  b15.getCaptionLabel().set(" >> ");    
  Button b13 = controlP5.addButton("denoise", 0, 2 * controlPanelWidth/3 + 28, yPos, 60, widgetH);
  b13.setGroup(settings);
  b13.getCaptionLabel().set("Denoise (9)");
  // snap, unsnap
  yPos += step + spacer;
  Button b7 = controlP5.addButton("snap", 0, 8, yPos, 76, widgetH);
  b7.setGroup(settings);
  b7.getCaptionLabel().set("Snap (n)");
  Button b8 = controlP5.addButton("unsnap", 0, controlPanelWidth/3 + 4, yPos, 76, widgetH);
  b8.setGroup(settings);
  b8.getCaptionLabel().set("Unsnap (u)");
  // invert munge checkbox
  CheckBox ch6 = controlP5.addCheckBox("invertMunge", 2 * controlPanelWidth/3 + 4, yPos + 2);
  ch6.setGroup(settings);
  ch6.setColorForeground(color(120));
  ch6.setColorActive(color(255));
  ch6.setColorLabel(color(255));
  ch6.setItemsPerRow(3);
  ch6.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox
  ch6.addItem("Invert Munge (i)", 0);
  ch6.setColorForeground(color(233, 233, 0));   
  // mungeThreshold setting
  yPos += step;
  Slider s5 = controlP5.addSlider("setMungeThreshold", 100, 1, mungeThreshold, 8, yPos, 101, widgetH);
  s5.setGroup(settings);
  s5.setDecimalPrecision(0);
  s5.getCaptionLabel().set("");
  s5.setSliderMode(Slider.FLEXIBLE);
  // label for degrade quality slider
  Textlabel l19 = controlP5.addTextlabel("mungeThresholdLabel", "Munge Threshold", 112, yPos + 4);
  l19.setGroup(settings);
  // munge button
  Button b9 = controlP5.addButton("munge", 0, 2 * controlPanelWidth/3 + 28, yPos, 60, widgetH);
  b9.setGroup(settings);
  b9.getCaptionLabel().set("Munge (m)");      
  // nexxxxxt....
  yPos += step;
  // create glitch settings tab
  Tab global = controlP5.getTab("default");
  global.setLabel("");
  global.hide();
  settings.moveTo("glitch");
  settingsTab = controlP5.getTab("glitch");
  settingsTab.activateEvent(true);
  settingsTab.setLabel("  Glitch  ");
  settingsTab.setId(1);
}

/**
 * Initializes and arranges the FFT control panel widgets
 * TODO FFT panel
 */
public void loadFFTPanel(int h, float min, float max) {
  int panelBack = color(123, 123, 144, 255);
  int yPos = 6;
  int step = 18;
  int widgetH = 14;
  int labelW = 144;
  int panelHeight = controlPanelHeight;
  fftSettings = controlP5.addGroup("FFT", controlPanelX, controlPanelY, controlPanelWidth);
  fftSettings.setBackgroundColor(panelBack);
  fftSettings.setBackgroundHeight(panelHeight);
  fftSettings.setBarHeight(widgetH + 4);
  fftSettings.setMoveable(false);     // dragging throws absolute position off...
  // add widgets
  // legend
  Textlabel l12 = controlP5.addTextlabel("equalizerLabel", "Equalizer FFT", 8, yPos);
  l12.setGroup(fftSettings);    
  Textlabel l12u = controlP5.addTextlabel("equalizerLabelUnder", "________________________________", 8, yPos + 3);
  l12u.setGroup(fftSettings);   
  // row of buttons: 
  yPos += step + step/3;
  Button b13 = controlP5.addButton("eqZigzagFFT", 0, 8, yPos, 64, widgetH);
  b13.setGroup(fftSettings);
  b13.getCaptionLabel().set("Run (j)");
  Button b14 = controlP5.addButton("resetEq", 0, controlPanelWidth/3, yPos, 64, widgetH);
  b14.setGroup(fftSettings);
  b14.getCaptionLabel().set("Reset");
  //// incorporate analysis into FFT ?
  Button b15 = controlP5.addButton("analyzeEqBands", 0, 2 * controlPanelWidth/3, yPos, 64, widgetH);
  b15.setGroup(fftSettings);
  b15.getCaptionLabel().set("Analyze (;)");
  yPos += step;
  // label at bottom of eQ bands
  Textlabel l13 = controlP5.addTextlabel("eqLabel", "----", 8, yPos + h + step/2);
  l13.setGroup(fftSettings);
  // equalizer
  setupEqualizer(yPos, h, max, min);
  showEqualizerBands();
  yPos += h + step + step/2;
  // HSB/RGB checkboxes for equalizer-controlled FFT
  CheckBox ch4 = controlP5.addCheckBox("ChanEq", 8, yPos + 2);
  ch4.setGroup(fftSettings);
  ch4.setColorForeground(color(120));
  ch4.setColorActive(color(255));
  ch4.setColorLabel(color(255));
  ch4.setItemsPerRow(3);
  ch4.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox, note that we can't use names that start with sliderIdentifier "_eq" 
  ch4.addItem("eqBrightness", 1);
  ch4.getItem(0).setCaptionLabel("Brightness");
  ch4.setColorForeground(color(233, 233, 0));
  ch4.addItem("eqHue", 2);
  ch4.getItem(1).setCaptionLabel("Hue");
  ch4.setColorForeground(color(233, 233, 0));
  ch4.addItem("eqSaturation", 3);
  ch4.getItem(2).setCaptionLabel("Saturation");
  ch4.setColorForeground(color(233, 233, 0));
  // add items to the checkbox
  ch4.addItem("eqRed", 4);
  ch4.getItem(3).setCaptionLabel("Red");
  ch4.setColorForeground(color(233, 233, 0));
  ch4.addItem("eqGreen", 5);
  ch4.getItem(4).setCaptionLabel("Green");
  ch4.setColorForeground(color(233, 233, 0));
  ch4.addItem("eqBlue", 6);
  ch4.getItem(5).setCaptionLabel("Blue");
  ch4.setColorForeground(color(233, 233, 0));
  // statistical FFT settings section
  // section label
  yPos += 2 * step;
  Textlabel l14 = controlP5.addTextlabel("statFFTLabel", "Statistical FFT", 8, yPos);
  l14.setGroup(fftSettings);
  Textlabel l14u = controlP5.addTextlabel("statFFTLabelUnder", "________________________________", 8, yPos + 3);
  l14u.setGroup(fftSettings);   
  // buttons
  yPos += step;
  Button b16 = controlP5.addButton("statZigzagFFT", 0, 8, yPos, 64, widgetH);
  b16.setGroup(fftSettings);
  b16.getCaptionLabel().set("Run (k)");
  Button b17 = controlP5.addButton("resetStat", 0, controlPanelWidth/3, yPos, 64, widgetH);
  b17.setGroup(fftSettings);
  b17.getCaptionLabel().set("Reset");
  //------- begin slider
  // use a range slider for bounds
  yPos += step;
  // addRange(name, min, max, defaultMin, defaultMax, x, y, w, h) 
  Range r02 = controlP5.addRange("setStatEqRange", -5.0f, 5.0f, leftBound, rightBound, 8, yPos, 180, widgetH);
  r02.setGroup(fftSettings);
  r02.setDecimalPrecision(2);
  r02.setLowValue(leftBound);
  r02.setHighValue(rightBound);
  r02.getCaptionLabel().set("");
  // label for statistical eQ range slider
  Textlabel l16 = controlP5.addTextlabel("statEqRangeLabel", "Deviation", 190, yPos + 4);
  l16.setGroup(fftSettings);
  //------- end slider
  // number box for boost
  yPos += step;
  Numberbox n4 = controlP5.addNumberbox("setBoost", boost, 8, yPos, 40, widgetH);
  n4.setGroup(fftSettings);
  n4.setMultiplier(0.01f);
  n4.setDecimalPrecision(2);
  n4.setMin(0.0f);
  n4.setMax(8.0f);
  n4.getCaptionLabel().set("");
  // label for boost number box
  Textlabel l17 = controlP5.addTextlabel("boostLabel", "IN Scale", 48, yPos + 4);
  l17.setGroup(fftSettings);
  // number box for cut
  Numberbox n5 = controlP5.addNumberbox("setCut", cut, (controlPanelWidth - 8)/3, yPos, 40, widgetH);
  n5.setGroup(fftSettings);
  n5.setMultiplier(0.01f);
  n5.setDecimalPrecision(2);
  n5.setMin(0.0f);
  n5.setMax(8.0f);
  n5.getCaptionLabel().set("");
  // label for cut number box
  Textlabel l18 = controlP5.addTextlabel("cutLabel", "OUT Scale", (controlPanelWidth - 8)/3 + 40, yPos + 4);
  l18.setGroup(fftSettings);
  // low cut checkbox
  CheckBox ch6 = controlP5.addCheckBox("LowFreqCut", 2 * (controlPanelWidth - 8)/3 + 8, yPos + 4);    
  ch6.setGroup(fftSettings);
  ch6.setColorForeground(color(120));
  ch6.setColorActive(color(255));
  ch6.setColorLabel(color(255));
  ch6.setItemsPerRow(3);
  ch6.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox
  ch6.addItem("lowCut", 0);
  ch6.getItem(0).setCaptionLabel("Low Cut");
  ch6.setColorForeground(color(233, 233, 0));
  // HSB/RGB checkboxes for statistically-controlled FFT
  yPos += step;
  CheckBox ch5 = controlP5.addCheckBox("ChanStat", 8, yPos + 2);    
  ch5.setGroup(fftSettings);
  ch5.setColorForeground(color(120));
  ch5.setColorActive(color(255));
  ch5.setColorLabel(color(255));
  ch5.setItemsPerRow(3);
  ch5.setSpacingColumn((controlPanelWidth - 8)/4);
  // add items to the checkbox
  ch5.addItem("statBrightness", 1);
  ch5.getItem(0).setCaptionLabel("Brightness");
  ch5.setColorForeground(color(233, 233, 0));
  ch5.addItem("statHue", 2);
  ch5.getItem(1).setCaptionLabel("Hue");
  ch5.setColorForeground(color(233, 233, 0));
  ch5.addItem("statSaturation", 3);
  ch5.getItem(2).setCaptionLabel("Saturation");
  ch5.setColorForeground(color(233, 233, 0));
  // add items to the checkbox
  ch5.addItem("statRed", 4);
  ch5.getItem(3).setCaptionLabel("Red");
  ch5.setColorForeground(color(233, 233, 0));
  ch5.addItem("statGreen", 5);
  ch5.setColorForeground(color(233, 233, 0));
  ch5.getItem(4).setCaptionLabel("Green");
  ch5.addItem("statBlue", 6);
  ch5.getItem(5).setCaptionLabel("Blue");
  ch5.setColorForeground(color(233, 233, 0));
  // section label
  yPos += 2 * step;
  Textlabel l19 = controlP5.addTextlabel("blockSizeSectionLabel", "FFT Block Size", 8, yPos);
  l19.setGroup(fftSettings);
  Textlabel l19u = controlP5.addTextlabel("blockSizeSectionLabelUnder", "________________________________", 8, yPos + 3);
  l19u.setGroup(fftSettings);   
  // slider for FFT block size can't have it in FFT Panel because of a concurrent modification error when we regenerate the FFT panel
  yPos += step;
  Slider s4 = controlP5.addSlider("setFFTBlockWidth", 3, 9, 6, 8, yPos, 64, widgetH); 
  s4.setGroup(fftSettings);
  s4.setDecimalPrecision(0);
  s4.getCaptionLabel().set("");
  Textlabel l11 = controlP5.addTextlabel("blockSizeLabel", "FFT Block Size = "+ fftBlockWidth, 76, yPos + 2);
  l11.setGroup(fftSettings);
  // move fftSettings into a tab
  fftSettings.moveTo("FFT");
  fftSettingsTab = controlP5.getTab("FFT");
  fftSettingsTab.activateEvent(true);
  fftSettingsTab.setLabel("  FFT  ");
  fftSettingsTab.setId(2);
}

/**
 * Sets left and right eQ bounds in response to control panel.
 * @param val   a value forwarded by ControlP5 that we will ignore (just in this case)
 */
public void setStatEqRange(float val) {
  // here's one way to retrieve the values of the range controller
  Range r1 = (Range) controlP5.getController("setStatEqRange");
  if (!r1.isInside()) {
    return;
  }
  leftBound = r1.getArrayValue()[0];
  rightBound = r1.getArrayValue()[1];
}

/**
 * Sets up and draws the multi-band equalizer control.
 * @param yPos   y-offset of control position
 * @param h      height of a slider
 * @param max    maximum value represented by slider
 * @param min    minimum value represented by slider
 */
public void setupEqualizer(int yPos, int h, float max, float min) {
  int eqW = 8;
  int left = 8;
  // we use a fixed maximum number of bands and show or hide bands as FFT buffer size varies
  int lim = eqBands;
  for (int i = 0; i < lim; i++) {
    String token = sliderIdentifier + noPlaces.format(i);
    Slider slider = controlP5.addSlider(token).setPosition(left, yPos).setSize(eqW, h).setId(i);
    slider.setMax(max);
    slider.setMin(min);
    slider.setValue(0);
    slider.setMoveable(false).setLabelVisible(false);
    int fc = color(199, 47, 21, 255);
    slider.setColorForeground(fc);
    int bc = color(233, 233, 254, 255);
    slider.setColorBackground(bc);
    slider.setGroup(fftSettings);
    left += eqW;
  }
  if (0 == eqPos) eqPos = yPos;
}

/**
 * removes the equalizer from the control panel, currently not used
 */
public void removeEqualizer() {
  int lim = eq.length;
  for (int i = 0; i < lim; i++) {
    String token = sliderIdentifier + noPlaces.format(i);
    Slider slider = (Slider) controlP5.getController(token);
    slider.remove();
  }
}

/**
 * shows equalizer bands used for current FFT block size, hides others
 */
public void showEqualizerBands() {
  // precautionary coding. The number of eq bins (eq.length) should not excede the max number of bands.
  int lim = eq.length > eqBands ? eqBands : eq.length;
  for (int i = 0; i < lim; i++) {
    String token = sliderIdentifier + noPlaces.format(i);
    Slider slider = (Slider) controlP5.getController(token);
    slider.setVisible(true);
    // set value to 0
    slider.setValue(0);
  }
  for (int i = lim; i < eqBands; i++) {
    String token = sliderIdentifier + noPlaces.format(i);
    Slider slider = (Slider) controlP5.getController(token);
    slider.setVisible(false);
    // don't change the value, bins are out of range for ControlP5 propagated event
  }
}


/**
 * @param rb      formats radio button style
 * @param width   width of radio button.
 */
void setRadioButtonStyle(RadioButton rb, int width) {
  for (Toggle t: rb.getItems()) {
    t.setColorForeground(color(233, 233, 0));
    Label l = t.getCaptionLabel();
    l.enableColorBackground();
    l.setColorBackground(color(80));
    l.getStyle().movePadding(2,0,-1,2);
    l.getStyle().moveMargin(-2,0,0,-3);
    l.getStyle().backgroundWidth = width;
  }
}

/**
 * Once control panels have been created and drawn, set up initial positions and values
 */
public void initPanelSettings() {
  // simplest way to avoid some annoying errors is to set various control panel radio buttons
  // after panel has been constructed
  setSorter(SorterType.BUBBLE, false);
  this.setBreakpoint(999);
  setSorter(SorterType.SHELL, false);
  this.setBreakpoint(996);
  setSorter(SorterType.QUICK, false);
  this.setBreakpoint(1);
  setCompOrder(compOrderIndex, false);
     setSwap(SwapChannel.RR, false);
  setEqChan(true, false, false, false, false, false, false);
  setStatChan(true, false, false, false, false, false, false);
  setLowFrequencyCut(false, false);
  Slider s4 = (Slider) controlP5.getController("setFFTBlockWidth"); 
  s4.setSliderMode(Slider.FLEXIBLE);
  s4.setNumberOfTickMarks(7);
  setZigzagStyle(zigzagStyle, false);
} 



