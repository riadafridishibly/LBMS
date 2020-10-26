class Cell {
  int x; // x position in the window
  int y; // y position in the window

  // velocity distribution function
  float f0;
  float fN;
  float fS;
  float fE;
  float fW;
  float fNW;
  float fNE;
  float fSW;
  float fSE;

  // physical quantity calculated from distribution function
  float xVelocity;
  float yVelocity;
  float rotation;

  final int gridSize = GRID_SIZE;

  boolean isObstacle;

  Cell(int x_, int y_) {
    x = x_;
    y = y_;

    f0 = fN = fS = fE = fW = fNW = fNE = fSW = fSE = 0;
    xVelocity = yVelocity = rotation = 0;

    isObstacle = false;
  }

  void showRotation() {
    int col = constrain(int(rotation * 4000), -255, 255);
    
    if (col > 0) {
      fill(0, col, 255);
    } else if (col < 0) {
      fill(160, -col, 255);
    } else if (col == 0) {
      fill(255);
    }
    noStroke();
    rect(x, y, gridSize, gridSize);
  }

  void showXVelocity() {
    int col = constrain(int((xVelocity * 20) * 100), 0, 220);
    fill(col, 200, 255);
    noStroke();
    rect(x, y, gridSize, gridSize);
  }

  void showFlowVector() {
    int mod = gridSize * 3;
    float multiplier = 50;

    if (int(x) % mod == 0 && int(y) % mod == 0) {
      float cx = x + gridSize / 2.0;
      float cy = y + gridSize / 2.0;
      stroke(0);
      strokeWeight(1);
      line(cx - xVelocity * multiplier, cy - yVelocity * multiplier, 
        cx + xVelocity * multiplier, cy + yVelocity * multiplier);
    }
  }
  
  void showBarrier() {
    if (isObstacle) {
      fill(0);
      rect(x, y, gridSize, gridSize);
    }
  }
}
