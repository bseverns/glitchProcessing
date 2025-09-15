// in Processing, you have to define an enum in a separate .java file

/**
 * List of different component orders for sorting pixels
 */
enum CompOrder {RGB, RBG, GBR, GRB, BRG, BGR, HSB, HBS, SBH, SHB, BHS, BSH;}

/**
 * List of possible channel swaps between source and target
 */
enum SwapChannel {RR, RG, RB, GR, GG, GB, BR, BG, BB;}

/**
 * List of available color channels
 */
enum ChannelNames {R, G, B, H, S, L;}

/**
 * List of available sorting methods
 */
enum SorterType {QUICK, SHELL, BUBBLE, INSERT;} 

/** 
 * ordering of pixels in subarray to be sorted, relative to source array
 */
enum SortFormat {ROW, SQUARE, DIAGONAL;}

/** 
 * List of possible zigzag sorting styles: aligned, random, or four different orientations permuted in blocks of four
 */
enum ZigzagStyle {RANDOM, ALIGN, PERMUTE;}

