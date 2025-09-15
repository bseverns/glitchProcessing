/********************************************/
/*                                          */
/*           >>> RANGE MANAGER <<<          */
/*                                          */
/********************************************/

public void testRangeManager() {
  int lower = (int)random(10, 100);
  lower = 0;
  int upper = lower + (int)random(50, 1000);
  int count = (int)random(2, 13);
  RangeManager rm = new RangeManager(lower, upper, count);
  println(rm.toString());
}

/**
 * Mini-class for storing bounds of an integer range.
 *
 */
class IntRange {
  int lower;
  int upper;
  
  public IntRange(int lower, int upper) {
    this.lower = lower;
    this.upper = upper;
  }
  
  public IntRange() {
    this(0, 0);
  }
      
  public String toString() {
    return "("+ lower +", "+ upper +")";
  }

  /* (non-Javadoc)
   * @see java.lang.Object#equals(java.lang.Object)
   */
  public boolean equals(Object o) {
    return o instanceof IntRange && (((IntRange) o).lower == this.lower) && (((IntRange) o).upper == this.upper);
  }

  /* (non-Javadoc)
   * @see java.lang.Object#hashCode()
   */
  public int hashCode() {
    // cf. Effective Java, 2nd edition, ch. 3, item 9.
    int result = 17;
    result = 31 * result + Float.floatToIntBits(lower);
    result = 31 * result + Float.floatToIntBits(upper);
    return result;
  }
  
}

/**
 * Mini-class for storing bounds of an integer range.
 *
 */
class FloatRange {
  float lower;
  float upper;
  
  public FloatRange(float lower, float upper) {
    this.lower = lower;
    this.upper = upper;
  }
  
  public FloatRange() {
    this(0, 0);
  }
      
  public String toString() {
    return "("+ lower +", "+ upper +")";
  }
  
  /* (non-Javadoc)
   * @see java.lang.Object#equals(java.lang.Object)
   */
  public boolean equals(Object o) {
    return o instanceof FloatRange && (((FloatRange) o).lower == this.lower) && (((FloatRange) o).upper == this.upper);
  }

  /* (non-Javadoc)
   * @see java.lang.Object#hashCode()
   */
  public int hashCode() {
    // cf. Effective Java, 2nd edition, ch. 3, item 9.
    int result = 17;
    result = 31 * result + Float.floatToIntBits(lower);
    result = 31 * result + Float.floatToIntBits(upper);
    return result;
  }

}


/**
 * A utility class to assist in stepping through a array divided into a specified number of equal segments.
 *
 */
class RangeManager {
  ArrayList<IntRange> intervals;
  Iterator<IntRange> iter;
  IntRange intRange;
  int numberOfIntervals;
  int currentIndex;
  
  /**
   * Divides an intRange of integers, from a lower bound up to but not including an upper bound,
   * into a given number of equal intervals. 
   * 
   * @param lower   lower index of intRange
   * @param upper   upper index of intRange
   * @param count   number of intervals in which to divide the intRange
   */
  public RangeManager(int lower, int upper, int count) {
    this.intervals = new ArrayList<IntRange>(count);
    this.intRange = new IntRange(lower, upper);
    this.setNumberOfIntervals(count);
  }
  
  /**
   * Divides a intRange of integers from 0 up to but not including an upper bound
   * into a given number of equal intervals. The upper bound would typically be 
   * the length of an array.
   * 
   * @param length
   * @param count
   */
  public RangeManager(int upper, int count) {
    this(0, upper, count);
  }
  
  public Iterator<IntRange> getIter() {
    if (null == iter) {
      iter = intervals.iterator();
    }
    return iter;
  }
  
  public IntRange get(int i) {
    return intervals.get(i);
  }
  public IntRange getNext() {
    return intervals.get(currentIndex++);
  }
  public boolean hasNext() {
    return currentIndex < numberOfIntervals;
  }

  public int getCurrentIndex() {
    return currentIndex;
  }
  public void resetCurrentIndex() {
    currentIndex = 0;
  }

  public int getUpper() {
    return intRange.upper;
  }   
  public int getLower() {
    return intRange.lower;
  }
  
  /**
   * @return the numberOfIntervals
   */
  public int getNumberOfIntervals() {
    return numberOfIntervals;
  }

  /**
   * Sets the value of numberOfIntervals and creates a new series of intervals.
   * @param numberOfIntervals the numberOfIntervals to set
   */
  public void setNumberOfIntervals(int numberOfIntervals) {
    this.numberOfIntervals = numberOfIntervals;
    adjustIntervals();
    resetCurrentIndex();
  }

  public void adjustIntervals() {
    this.intervals.clear();
    int u = 0;
    int l = getLower();
    float pos = l;
    float delta = (getUpper() - l) / (float) this.numberOfIntervals;
    for (int i = 1; i <= numberOfIntervals; i++) {
      pos += delta;
      u = Math.round(pos) - 1;
      intervals.add(new IntRange(l, u));
      l = u + 1;
    }
  }
  
  public void setRange(int lower, int upper) {
    this.intRange = new IntRange(lower, upper);
    adjustIntervals();
    resetCurrentIndex();
  }
  public void setRange(int upper) {
    setRange(0, upper);
  }

  public String toString() {
    StringBuffer buf = new StringBuffer();
    Iterator<IntRange> it = this.getIter();
    buf.append("RangeManager: " + intervals.size() +" intervals from "+ intRange.lower +" to "+ intRange.upper + "\n  ");
    while (it.hasNext()) {
      IntRange r = it.next();
      buf.append(r.toString() + ", ");
    }
    buf.delete(buf.length() - 2, buf.length() - 1);
    return buf.toString();
  }
  
}


