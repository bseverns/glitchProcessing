/********************************************/
/*                                           /
/*              >>> SORTING <<<              /
/*                                           /
/********************************************/

/** SORTING SELECTOR **/
// similar to the strategy design pattern
// Could be designed around criteria such as stability, speed, worst case behavior
// to select appropriate sorting method automatically. For now, since glitching is all we're doing,
// it's just a tool for choosing different sorters.


/**
 * Class for selecting a sorting method among those available.
 *
 */
class SortSelector {
  Sorter sorter;
  InsertSorter insert;
  ShellSorter shell;
  QuickSorter quick;
  BubbleSorter bubble;
  
  public SortSelector() {
    shell = new ShellSorter();
    quick = new QuickSorter();
    bubble = new BubbleSorter();
    insert = new InsertSorter();
    this.sorter = quick;
  }
  
  public void setRandomBreak(boolean isRandomBreak) {
    shell.setRandomBreak(isRandomBreak);
    quick.setRandomBreak(isRandomBreak);
    bubble.setRandomBreak(isRandomBreak);
    insert.setRandomBreak(isRandomBreak);
  }
  
  public QuickSorter getQuick() {
    return quick;
  }
  
  public ShellSorter getShell() {
    return shell;
  }
  
  public BubbleSorter getBubble() {
    return bubble;
  }
  
  public InsertSorter getInsert() {
    return insert;
  }

  public Sorter getSorter() {
    return sorter;
  }
  
  public void setSorter(SorterType type) {
    switch (type) {
    case QUICK: { sorter = quick; break; }
    case SHELL: { sorter = shell; break; }
    case BUBBLE: { sorter = bubble; break; }
    case INSERT: { sorter = insert; break; }
    default: { sorter = quick; }
    }
  }

  public void sort(int[] a, int l, int r) {
    sorter.sort(a, l, r);
  }
  
  public void sort(int[] a) {
    sorter.sort(a);
  }
  
  public void insertSort(int[] a, int l, int r) {
    insert.sort(a, l, r);
  }

  public void bubbleSort(int[] a, int l, int r) {
    bubble.sort(a, l, r);
  }

  public void shellSort(int[] a, int l, int r) {
    shell.sort(a, l, r);
  }

  public void quickSort(int[] a, int l, int r) {
    quick.sort(a, l, r);
  }

}


/** SORTING METHODS **/

/**
 * Basic sorting interface, implemented by InsertSorter, QuickSorter, ShellSorter and BubbleSorter classes.
 */
interface Sorter {
  /**
   * Compare two ints, return true if first is less than second.
   * @param v   an int 
   * @param w   another int to compare with the first
   * @return    true if the first int is less than the second, false otherwise
   */
  public boolean less(int v, int w);
  /**
   * Exchange two ints in an array.
   * @param a   an array of int
   * @param i   an index into the array
   * @param j   an index into the array
   */
  public void exch(int[] a, int i, int j);
  /**
   * Compares two ints in an array and exchanges them if the int  
   * at the first index is less than the int at the second index.
   * @param a   an array of int
   * @param i   an index into the array
   * @param j   an index into the array
   */
  public void compExch(int[] a, int i, int j);    
  /**
   * Sort an array or int between a left index and a right index.
   * Each sorting algorithm has its own implementation of this method that 
   * fills in the abstract method in AbstractSorter.
   * @param a   an array of int
   * @param l   the left (lower) index
   * @param r   the right (upper) index
   */
  public void sort(int[] a, int l, int r);
  /**
   * Sorts an array of ints, returning result in the array
   * This is a convenience method, implemented in the abstract class AbstractSorter
   * @param a   an array of int
   */
  public void sort(int[] a);
  /**
   * @return the breakPoint
   */
  public float getBreakPoint();
  /**
   * @param breakPoint the breakPoint to set
   */
  public void setBreakPoint(float breakPoint);
  /**
   * @return the sorterType
   */
  public SorterType getSorterType();
}

/**
 * Abstract class extended by all sorting classes.
 *
 */
abstract class AbstractSorter implements Sorter {
  boolean isRandomBreak = false;
  public float breakPoint = 500.0f;
  public SorterType sorterType;
  public long count = 0;
  int testV = 0;
  int testW = 0;
  int[] compV;
  int[] compW;
  
  // permits many different evaluations of the color values of two pixels.
  // could be optimized, but then it would be harder to understand
  public boolean less(int v, int w) { 
    compV = rgbComponents(v);
    compW = rgbComponents(w);
    testV = v;
    testW = w;
    switch(compOrder) {
    case RGB: {
      break;
    }
    case BRG: {
      testV = composeColor(compV[2], compV[0], compV[1], 255);
      testW = composeColor(compW[2], compW[0], compW[1], 255);
      break;
    }
    case GBR: {
      testV = composeColor(compV[1], compV[2], compV[0], 255);
      testW = composeColor(compW[1], compW[2], compW[0], 255);
      break;
    }
    case GRB: {
      testV = composeColor(compV[1], compV[0], compV[2], 255);
      testW = composeColor(compW[1], compW[0], compW[2], 255);
      break;
    }
    case BGR: {
      testV = composeColor(compV[2], compV[1], compV[0], 255);
      testW = composeColor(compW[2], compW[1], compW[0], 255);
      break;
    }
    case RBG: {
      testV = composeColor(compV[0], compV[2], compV[1], 255);
      testW = composeColor(compW[0], compW[2], compW[1], 255);
      break;
    }
    case HSB: {
      colorMode(HSB, 255);
      int hueV = Math.round(hue(v));
      int brightV = Math.round(brightness(v));
      int satV = Math.round(saturation(v));
      int hueW = Math.round(hue(w));
      int brightW = Math.round(brightness(w));
      int satW = Math.round(saturation(w));
      testV = composeColor(hueV, satV, brightV, 255);
      testW = composeColor(hueW, satW, brightW, 255);
      colorMode(RGB, 255);
      break;
    }
    case HBS: {
      colorMode(HSB, 255);
      int hueV = Math.round(hue(v));
      int brightV = Math.round(brightness(v));
      int satV = Math.round(saturation(v));
      int hueW = Math.round(hue(w));
      int brightW = Math.round(brightness(w));
      int satW = Math.round(saturation(w));
      testV = composeColor(hueV, brightV, satV, 255);
      testW = composeColor(hueW, brightW, satW, 255);
      colorMode(RGB, 255);
      break;
    }
    case BHS: {
      colorMode(HSB, 255);
      int hueV = Math.round(hue(v));
      int brightV = Math.round(brightness(v));
      int satV = Math.round(saturation(v));
      int hueW = Math.round(hue(w));
      int brightW = Math.round(brightness(w));
      int satW = Math.round(saturation(w));
      testV = composeColor(brightV, hueV, satV, 255);
      testW = composeColor(brightW, hueW, satW, 255);
      colorMode(RGB, 255);
      break;
    }
    case SHB: {
      colorMode(HSB, 255);
      int hueV = Math.round(hue(v));
      int brightV = Math.round(brightness(v));
      int satV = Math.round(saturation(v));
      int hueW = Math.round(hue(w));
      int brightW = Math.round(brightness(w));
      int satW = Math.round(saturation(w));
      testV = composeColor(satV, hueV, brightV, 255);
      testW = composeColor(satW, hueW, brightW, 255);
      colorMode(RGB, 255);
      break;
    }
    case BSH: {
      colorMode(HSB, 255);
      int hueV = Math.round(hue(v));
      int brightV = Math.round(brightness(v));
      int satV = Math.round(saturation(v));
      int hueW = Math.round(hue(w));
      int brightW = Math.round(brightness(w));
      int satW = Math.round(saturation(w));
      testV = composeColor(brightV, satV, hueV, 255);
      testW = composeColor(brightW, satW, hueW, 255);
      colorMode(RGB, 255);
      break;
    }
    case SBH: {
      colorMode(HSB, 255);
      int hueV = Math.round(hue(v));
      int brightV = Math.round(brightness(v));
      int satV = Math.round(saturation(v));
      int hueW = Math.round(hue(w));
      int brightW = Math.round(brightness(w));
      int satW = Math.round(saturation(w));
      testV = composeColor(satV, brightV, hueV, 255);
      testW = composeColor(satW, brightW, hueW, 255);
      colorMode(RGB, 255);
      break;
    }
    }
    count++;      
    if (isAscendingSort) return testV > testW;
    return testV < testW;
    // return v < w; 
  } 
  
  public void exch(int[] a, int i, int j) { 
    if (isSwapChannels) {
      switch (swap) {
      case RR: {
        a[i] = composeColor(compW[0], compV[1], compV[2], 255);
        a[j] = composeColor(compV[0], compW[1], compW[2], 255);
        break;
      }
      case RG: {
        a[i] = composeColor(compW[1], compV[1], compV[2], 255);
        a[j] = composeColor(compW[0], compV[0], compW[2], 255);
        break;
      }
      case RB: {
        a[i] = composeColor(compW[2], compV[1], compV[2], 255);
        a[j] = composeColor(compW[0], compW[1], compV[0], 255);
        break;
      }
      case GR: {
        a[i] = composeColor(compV[0], compW[0], compV[2], 255);
        a[j] = composeColor(compV[1], compW[1], compW[2], 255);
        break;
      }
      case GG: {
        a[i] = composeColor(compV[0], compW[1], compV[2], 255);
        a[j] = composeColor(compW[0], compV[1], compW[2], 255);
        break;
      }
      case GB: {
        a[i] = composeColor(compV[0], compW[2], compV[2], 255);
        a[j] = composeColor(compW[0], compW[1], compV[1], 255);
        break;
      }
      case BR: {
        a[i] = composeColor(compV[0], compV[1], compW[0], 255);
        a[j] = composeColor(compV[2], compW[1], compW[2], 255);
        break;
      }
      case BG: {
        a[i] = composeColor(compV[0], compV[1], compV[2], 255);
        a[j] = composeColor(compW[0], compW[1], compW[2], 255);
        break;
      }
      case BB: {
        a[i] = composeColor(compV[0], compV[1], compW[1], 255);
        a[j] = composeColor(compW[0], compW[2], compV[2], 255);
        break;
      }
      }
    }
    else {
//        the following two lines should also be equivalent to a swap
/*        a[i] = composeColor(compV[0], compV[1], compV[2], 255);
      a[j] = composeColor(compW[0], compW[1], compW[2], 255)
*/         // swap
      int t = a[i]; 
      a[i] = a[j]; 
      a[j] = t; 
    }
  } 

  public void compExch(int[] a, int i, int j) { 
    if (less(a[j], a[i])) exch (a, i, j); 
  } 

  /**
   * @return the isRandomBreak
   */
  public boolean isRandomBreak() {
    return isRandomBreak;
  }

  /**
   * @param isRandomBreak the isRandomBreak to set
   */
  public void setRandomBreak(boolean isRandomBreak) {
    this.isRandomBreak = isRandomBreak;
  }

  public float getBreakPoint() {
    return breakPoint;
  }

  public void setBreakPoint(float breakPoint) {
    this.breakPoint = breakPoint;
  }
  
  public boolean breakTest() {
    return (breakPoint < random(0, 1000));
  }

  public SorterType getSorterType() {
    return sorterType;
  }

  // this method is different for each algorithm
  public abstract void sort(int[] a, int l, int r);

  // this convenience method permits sorting of any arbitrary array of ints
  public void sort(int[] a) {
    sort(a, 0, a.length - 1);
  }
  
}

/**
 * Performs an insert sort on an array of ints. Insert sort proceeds through
 * the array from beginning to end, comparing every number against all remaining numbers. 
 * It is much slower than quick sort or shell sort.
 */
class InsertSorter extends AbstractSorter implements Sorter {
  
  public InsertSorter(float breakPoint) {
    this.breakPoint = breakPoint;
    this.sorterType = SorterType.INSERT;
  }
  public InsertSorter() {
    this(999.0f);
  }

  public void sort(int[] a, int l, int r) { 
    outerloop:
      for (int i = l+1; i <= r; i++) {
        for (int j = i; j > l; j--) {
          compExch(a, j-1, j); 
          if (this.isRandomBreak) {
            if (breakTest()) {
              // if (verbose) println("random break at "+ count);
              break outerloop;
            }
          }
        }
      }
  } 
  
}


/**
 * Performs a quick sort on an array of ints. Quicksort uses a divide and 
 * conquer approach to sorting. It partitions the array into smaller arrays, recursively.
 * With random breaks, it makes more interesting glitches than InsertSorter, since it operates 
 * over larger distances to exchange keys. It is also a very fast sorting method for disordered
 * arrays (most pictures, in other words) but will crawl if fed an array that is already sorted
 * or nearly sorted (or inverse sorted or nearly inverse sorted). 
 */
class QuickSorter extends AbstractSorter implements Sorter {

  public QuickSorter(float breakPoint) {
    this.breakPoint = breakPoint;
    this.sorterType = SorterType.QUICK;
  }
  public QuickSorter() {
    this(144.0f);
  }
  
  public void sort(int[] a, int l, int r) { 
    if (r <= l) return;
    int i = partition(a, l, r);
    if (this.isRandomBreak) {
      if (breakTest()) {
        // if (verbose) println("random break at "+ count);
        return;
      }
    }
    sort(a, l, i - 1);
    sort(a, i + 1, r);
  } 
  
  public int partition(int[] a, int l, int r) {
    int i = l-1;
    int j = r; 
    int v = a[r]; 
    for (;;) { 
      while (less(a[++i], v)); 
      while (less(v, a[--j])) if (j == l) break; 
      if (i >= j) break; 
      exch(a, i, j); 
    } 
    exch(a, i, r); 
    return i; 
  }
}


/**
 * Performs a shell sort on an array of ints. Shell sort uses a divide and 
 * conquer approach to sorting, partitioning the array into smaller arrays 
 * using a variable h to mark the boundaries of subarrays. With random breaks, 
 * it makes more interesting glitches than InsertSorter and different from QuickSorter.
 * Vary ratio and divisor to get different partitions of the pixels
 */
class ShellSorter extends AbstractSorter implements Sorter {
  int h;
  int ratio = 3;
  int divisor = 9;

  public ShellSorter(float breakPoint) {
    this.breakPoint = breakPoint;
    this.sorterType = SorterType.SHELL;
  }
  public ShellSorter() {
    this(996.0f);
  }
  
  public void sort(int[] a, int l, int r) {
    for (h = 1; h <= (r - l)/divisor; h = ratio * h + 1);
    outerloop:
    for ( ; h > 0; h /= ratio) {
      // perform an "h-sort" over the array, i.e., an insert sort of every h elements
      for (int i = l+h; i <= r; i++) { 
        int j = i; 
        int v = a[i]; 
        while (j >= l + h && less(v, a[j - h])) { 
          a[j] = a[j - h]; 
          j -= h; 
        } 
        a[j] = v; 
        if (this.isRandomBreak) {
          if (breakTest()) {
            // if (verbose) println("random break at "+ count);
            break outerloop;
          }
        }
      }
    }
  }

  /**
   * @param ratio the ratio to set
   */
  public void setRatio(int ratio) {
    this.ratio = ratio;
  }
  /**
   * @param divisor the divisor to set
   */
  public void setDivisor(int divisor) {
    this.divisor = divisor;
  }
  
}


/**
 * Performs a bubble sort on an array of int, such as pixel rows in an image.
 * Small keys percolate over to the left in bubble sort. As the sort moves from right to left, 
 * each key is exchanged with the one on its left until a smaller one is encountered.
 * Bubble sort is very slow, but the way it operates creates some interesting glitches. 
 * Color-swapping also looks good with this sorting method.
 */
class BubbleSorter extends AbstractSorter implements Sorter {

  public BubbleSorter(float breakPoint) {
    this.breakPoint = breakPoint;
    this.sorterType = SorterType.BUBBLE;
  }
  public BubbleSorter() {
    this(990.0f);
  }
  
  public void sort(int[]a, int l, int r) {
    outerloop:
      for (int i = l; i < r; i++) 
        for (int j = r; j > i; j--) {
          compExch(a, j-1, j);    
          if (this.isRandomBreak) {
            if (breakTest()) {
              // if (verbose) println("random break at "+ count);
              break outerloop;
            }
          }
        }
  }
}


