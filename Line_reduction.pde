final static int LT_EPSILON_FLAG = -1;
final static int DRAW_MODE = 0;
final static int REDUCE_MODE = 1;
int mode = REDUCE_MODE;

float epsilon = 0;
ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<PVector> keptPoints = new ArrayList<PVector>();
  
//customise function being reduced
void drawFunc(){
  for(int x=0; x<width; x++){
    float X = map(x, 0, width, 0, 5);
    float Y = exp(-X) * cos(TWO_PI*X);
    float y = map(Y, -1, 1, height, 0);
    points.add(new PVector(x,y));
    
  }
}

void mousePressed(){
  points = new ArrayList<PVector>(); //clear array
  mode = DRAW_MODE;
  epsilon = 0;
}

void mouseReleased(){
  mode = REDUCE_MODE;
}

void setup(){
  size(800,800);
  noFill();
  textSize(16);
  drawFunc();
}

void draw(){
  background(0);
  stroke(255);
  
  if(mode == REDUCE_MODE){
    //draw full line
    stroke(255);
    strokeWeight(10);
    beginShape();
    for(PVector p : points){ 
      vertex(p.x, p.y);
    }
    endShape();
    
    //draw reduced line
    keptPoints = new ArrayList<PVector>(); //clear array
    
    keptPoints.add(points.get(0)); //add start
    reduce(0, points.size()-1);
    keptPoints.add(points.get(points.size()-1)); //add end
    
    stroke(255,0,0);
    beginShape();
    strokeWeight(10);
    for(PVector p : keptPoints){ 
      vertex(p.x, p.y);
      point(p.x, p.y);
    }
    strokeWeight(5);
    endShape();
    
    String t1 = "Original line: " + points.size() + " points";
    String t2 = "Reduced line: " + keptPoints.size() + " points";
    String t3 = "Epsilon: " + nf(epsilon, 0, 2) + " pixels";
    text(t1,32,32);
    text(t2,32,64);
    text(t3,32,96);
    
    epsilon += 0.05;
  
  } else if(mode == DRAW_MODE){
    //add mouse position to line
    points.add(new PVector(mouseX, mouseY));
    //draw line so far
    stroke(255);
    strokeWeight(10);
    beginShape();
    for(PVector p : points){ 
      vertex(p.x, p.y);
    }
    endShape();
  }
}


void reduce(int startIndex, int endIndex){
  int pivotIndex = getFurthest(points, startIndex, endIndex);
  if(pivotIndex != LT_EPSILON_FLAG){ //only deal with point when dist > epsilon
    
    if(startIndex != pivotIndex){
      reduce(startIndex, pivotIndex);
    }
    
    keptPoints.add(points.get(pivotIndex));
    
    if(pivotIndex != endIndex){
      reduce(pivotIndex, endIndex);
    }
    
  }
}

//returns index of point in segment furthest from line segment, segment[a]->segment[b]
int getFurthest(ArrayList<PVector> segment, int a, int b){
  float maxDist = -1;
  int furthest = -1;
  PVector start = segment.get(a);
  PVector end = segment.get(b);
  
  for(int i=a+1; i<b; i++){
    PVector curPoint = segment.get(i);
    float d = distToLine(curPoint, start, end);
    if(d > maxDist){
      maxDist = d;
      furthest = i;
    }
  }
  if(maxDist > epsilon){
    return furthest;
  }else{
    return LT_EPSILON_FLAG; //flag in calling function
  }
}

//returns perpendicular (shortest) distance between point and line AB
float distToLine(PVector point, PVector lineA, PVector lineB){
  PVector AP = PVector.sub(point, lineA);
  PVector AB = PVector.sub(lineB, lineA);
  AB.normalize();
  AB.mult(AP.dot(AB));
  PVector proj = PVector.add(lineA, AB); //project point onto line AB
  
  return PVector.dist(point,proj);
}
