/********************************************/
/*                                          */
/*              >>> ZIGZAG <<<              */
/*                                          */
/********************************************/

/**
 * Sets zigzagFloor and zigzagCeiling in response to control panel.
 * @param val   a value forwarded by ControlP5 that we will ignore (just in this case)
 */
public void setZigzagRange(float val) {
  // here's one way to retrieve the values of the range controller
  Range r1 = (Range) controlP5.getController("setZigzagRange");
  if (!r1.isInside()) {
    return;
  }
  zigzagFloor = (int) r1.getArrayValue()[0];
  zigzagCeiling = (int) r1.getArrayValue()[1];
}

/**
 * Sets the value above which the current sort method will randomly interrupt, when randomBreak 
 * is true (the default). Each sorting method uses a distinct value from 1 to 999. Quick sort
 * can use very low values, down to 1.0. The other sorting methods--shell sort, insert sort, 
 * bubble sort--generally work best with higher values. 
 * @param newBreakPoint   the breakpoint to set
 */
public void setZigzagPercent(float newZigzagPercent) {
  if (newZigzagPercent == zigzagPercent) return;
  zigzagPercent = newZigzagPercent;
}


/**
 * Performs a zigzag sort, centered in the image.
 * @param order   the width/height of each pixel block to sort
 */
public void zigzag(int order) {
  // TODO better fix: ControlP5 button press calls here with 0 for order, apparently...
  if (0 == order) order = zigzagBlockWidth;
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
  println("--- "+ zigzagStyle.name() +" zigzag ----");
  if (ZigzagStyle.PERMUTE != zigzagStyle) {
    for (int y = 0; y < dh; y++) {
      for (int x = 0; x < dw; x++) {
        // a quick way to sort only a determined percentage of cells
        if (random(100) > (int)(zigzagPercent)) continue;
        int mx = x * order + ow;
        int my = y * order + oh;
        int[] pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
        this.sortTool.sort(pix);
        zz.plant(img.pixels, pix, img.width, img.height, mx, my);
        if (ZigzagStyle.RANDOM == zigzagStyle) {
          if (random(1) > 0.5f) {
            zz.flipX();
          }
          if (random(1) > 0.5f) {
            zz.flipY();
          }
        }
      }
    }
  }
  else {
    // permute zigzag orientation in 2x2 blocks
    int[] perm = {0, 1, 2, 3};
    Zigzagger[] zzList = new Zigzagger[4];
    zzList[0] = zz;
    zz = new Zigzagger(order);
    zz.flipX();
    zzList[1] = zz;
    zz = new Zigzagger(order);
    zz.flipX();
    zz.flipY();
    zzList[2] = zz;
    zz = new Zigzagger(order);
    zz.flipY();
    zzList[3] = zz;
    int dw2 = dw/2;
    int dh2 = dh/2;
    for (int y = 0; y < dh2; y++) {
      for (int x = 0; x < dw2; x++) {
        // a quick way to sort only a determined percentage of cells
        if (random(100) > (int)(zigzagPercent)) continue;
        int mx = 2 * x * order + ow;
        int my = 2 * y * order + oh;
        shuffle(perm);
        zz = zzList[perm[0]];
        int[] pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
        this.sortTool.sort(pix);
        zz.plant(img.pixels, pix, img.width, img.height, mx, my);
        zz = zzList[perm[1]];
        my += order;
        pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
        this.sortTool.sort(pix);
        zz.plant(img.pixels, pix, img.width, img.height, mx, my);
        zz = zzList[perm[2]];
        mx += order;
        pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
        this.sortTool.sort(pix);
        zz.plant(img.pixels, pix, img.width, img.height, mx, my);
        zz = zzList[perm[3]];
        my -= order;
        pix = zz.pluck(img.pixels, img.width, img.height, mx, my);
        this.sortTool.sort(pix);
        zz.plant(img.pixels, pix, img.width, img.height, mx, my);
      }
    }
  }
  img.updatePixels();
  // necessary to call fitPixels to show updated image
  fitPixels(isFitToScreen, false);
}

/**
  * Performs a zigzag sort, centered in the image, sets the width of the square 
  * pixel blocks to a random number between zigzagFloor and zigzagCeiling + 1.
 */
public void zigzag() {
  int order = (int) random(zigzagFloor, zigzagCeiling + 1);
  zigzagBlockWidth = order;
  println("zigzagFloor = "+ zigzagFloor +", zigzagCeiling = "+ zigzagCeiling +", order = "+ order);
  zigzag(order);
}


/**
 * Facilitates the "zigzag" scanning of a square block of pixels with a variable edge dimension set by the user.
 * This sort of scanning is used in the JPEG compression algorithm, and occasionally shows up in JPEG errors (glitches).
 * Provides two methods for reading (pluck) and writing (plant) from an array of pixels.
 *
 */
class Zigzagger {
  /** x coordinates */
  private int[] xcoords;
  /** y coordinates */
  private int[] ycoords;
  /** the dimension of an edge of the square block of pixels */
  private int d;
  /** counter variable f = d + d - 1: number of diagonals in zigzag */
  private int f;

  /**
   * @param order   the number of pixels on an edge of the scan block
   */
  public Zigzagger(int order) {
    d = order;
    f = d + d - 1;
    xcoords = new int[d * d];
    ycoords = new int[d * d];
    generateCoords();
  }

  /**
   * Generates coordinates of a block of pixels of specified dimensions, offset from (0,0).
   */
  private void generateCoords() {
    int p = 0;
    int n = 0;
    for (int t = 0; t < f; t++) {
      if (t < d) {
        n++;
        if (n % 2 == 0) {
          for (int i = 0; i < n; i++) {
            xcoords[p] = n - i - 1;
            ycoords[p] = i;
            p++;
          }
        }
        else {
          for (int i = 0; i < n; i++) {
            xcoords[p] = i;
            ycoords[p] = n - i - 1;
            p++;
          }
        }
      }
      else {
        n--;
        if (n % 2 == 0) {
          for (int i = 0; i < n; i++) {
            xcoords[p] = d - i - 1 ;
            ycoords[p] = i + d - n;
            p++;
          }
        }
        else {
          for (int i = 0; i < n; i++) {
            xcoords[p] = i + d - n;
            ycoords[p] = d - i - 1;
            p++;
          }
        }
      }
    }
  }
  
  public void flipX() {
    int m = d - 1;
    for (int i = 0; i < xcoords.length; i++) {
      xcoords[i] = m - xcoords[i];
    }
  }

  public void flipY() {
    int m = d - 1;
    for (int i = 0; i < ycoords.length; i++) {
      ycoords[i] = m - ycoords[i];
    }
  }

  /**
   * @param pix   an array of pixels
   * @param w     width of the image represented by the array of pixels
   * @param h     height of the image represented by the array of pixels
   * @param x     x-coordinate of the location in the image to scan
   * @param y     y-coordinate of the location in the image to scan
   * @return      an array in the order determined by the zigzag scan
   */
  public int[] pluck(int[] pix, int w, int h, int x, int y) {
    int len = d * d;
    int[] out = new int[len];
    for (int i = 0; i < len; i++) {
      int p = (y + ycoords[i]) * w + (x) + xcoords[i];
      if (verbose) println("x = "+ x +", y = "+ y +", i = "+ i +", p = "+ p +", zigzag = ("+ xcoords[i] +", "+ ycoords[i] +")");
      out[i] = pix[p];
    }
    return out;
  }
  
  /**
   * @param pix      an array of pixels
   * @param sprout   an array of d * d pixels to write to the array of pixels
   * @param w        width of the image represented by the array of pixels
   * @param h        height of the image represented by the array of pixels
   * @param x        x-coordinate of the location in the image to write to
   * @param y        y-coordinate of the location in the image to write to
   */
  public void plant(int[] pix, int[] sprout, int w, int h, int x, int y) {
    for (int i = 0; i < d * d; i++) {
      int p = (y + ycoords[i]) * w + (x) + xcoords[i];
      pix[p] = sprout[i];
    }
  }
  
  /* (non-Javadoc)
   * returns a list of coordinate points that define a zigzag scan of order d.
   * @see java.lang.Object#toString()
   */
  public String toString() {
    StringBuffer buf = new StringBuffer();
    buf.append("Zigzag order: "+ this.d +"\n  ");
    for (int i = 0; i < xcoords.length; i++) {
      buf.append("("+ xcoords[i] +", "+ ycoords[i] +") ");
    }
    buf.append("\n");
    return buf.toString();
  }
}

