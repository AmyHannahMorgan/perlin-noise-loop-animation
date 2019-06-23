int setFrameRate = 60;
float transitionTimeFrame = 2;

int transitionFrames = round(setFrameRate * transitionTimeFrame);

color[] colors = {color(85, 205, 252), color(247, 168, 184)};//trans blue, trans pink
int colorIndex = 1;

int hSections = 15; // number of vertexes per line
int vSections = 6; // number of lines
int loopSize = 10; // number of perlin noise vales to generate per vertex
int totalFrames = transitionFrames * loopSize; 

int maxPYOffset = 40; // max positive y offset (farthest up a vertex can go from it's baseline)
int maxNYOffset = 40; // max positive y offset (farthest down a vertex can go from it's baseline);

int yPadding = 20; // number of pixels padding between lines/edges (vertically)
int xPadding = 40; // padding between edges and outer vertexes 

//float[][][] perlinArray = new float[vSections][hSections][loopSize]; // array for storing perlin noise values for each vertex
Line[] lineHolder = new Line[vSections];

void setup() {
  size(1920, 1080);
  frameRate(setFrameRate);
  
  int yOffset = (height - yPadding) / vSections;
  int xOffset = (width - xPadding) / hSections;
  for(int y = 0; y < vSections; y++) {
    Point[] currPointArray = new Point[hSections];
    int yPos = (yOffset / 2 + yOffset * y) + yPadding / 2;
    float t = 0.0;
    for(int x = 0; x < hSections; x++){
      float[] perlinArray = new float[loopSize];
      for(int p = 0; p < loopSize; p++) {
        perlinArray[p] = map(noise(x, y, p), 0, 1, -maxNYOffset, maxPYOffset);
        //t += 1;
      }
      Point currPoint = new Point(xOffset / 2 + xOffset * x, perlinArray);
      currPointArray[x] = currPoint;
    }
    //int yPos;
    //if( y == 0 ) {
    //  yPos = (yOffset / 2 + yOffset * y) + yPadding / 2;
    //}
    //else {
    //  yPos = yOffset / 2 + yOffset * y;
    //}
    lineHolder[y] = new Line(yPos, colors[colorIndex], currPointArray);
    
    if(colorIndex + 1 >= colors.length) {
      colorIndex = 0;
    }
    else {
      colorIndex += 1;
    }
  }
  
}

void draw() {
  clear();
  background(85, 205, 252);
  smooth();
  for(int y = 0; y < lineHolder.length; y++) {
    fill(lineHolder[y].col);
    beginShape();
    vertex(0, lineHolder[y].baseline);
    
    for(int x = 0; x < lineHolder[y].points.length; x++) {
      //println(lineHolder[y].baseline + lineHolder[y].points[x].currPos);
      vertex(lineHolder[y].points[x].xPos, lineHolder[y].baseline + lineHolder[y].points[x].currPos);
    }
    
    vertex(width, lineHolder[y].baseline);
    vertex(width, height);
    vertex(0, height);
    endShape();
  }
  stroke(255);
  noFill();
  strokeWeight(10);
  for(int y = 0; y < lineHolder.length; y++) {
    beginShape();
    vertex(0, lineHolder[y].baseline);
    
    for(int x = 0; x < lineHolder[y].points.length; x++) {
      //println(lineHolder[y].baseline + lineHolder[y].points[x].currPos);
      vertex(lineHolder[y].points[x].xPos, lineHolder[y].baseline + lineHolder[y].points[x].currPos);
      lineHolder[y].points[x].update();
    }
    
    vertex(width, lineHolder[y].baseline);
    endShape();
  }
  
  if(frameCount >= totalFrames){
    noLoop();
  }
  else {
    saveFrame("Animation-Frame-############.png");
  }
}

class Line {
  Point[] points;
  color col;
  int baseline;
  Line(int y, color rgb, Point[] array) {
    baseline = y;
    col = rgb;
    points = new Point[array.length];
    arrayCopy(array, points);
  }
}

class Point {
  float[] yOffsets;
  int yOffsetI = 0;
  int xPos;
  float startPos;
  float endPos;
  float currPos;
  int animStartFrame;
  Point(int x, float[] array){
    xPos = x;
    yOffsets = new float[array.length];
    arrayCopy(array, yOffsets);
    currPos = yOffsets[0];
    startPos = currPos;
    endPos = currPos;
    yOffsetI++;
    animStartFrame = 0;
  }
  
  void update() {
    if(frameCount >= animStartFrame + transitionFrames || animStartFrame == 0) {
      println(frameCount);
      animStartFrame = frameCount;
      startPos = currPos;
      endPos = yOffsets[yOffsetI];
      if(yOffsetI + 1 >= yOffsets.length) {
        yOffsetI = 0;
      }
      else {
        yOffsetI++;
      }
    }
    
    currPos = -(endPos - startPos) / 2 * ((float)cos(PI * (frameCount - animStartFrame) / transitionFrames) - 1) + startPos;
  }
}
