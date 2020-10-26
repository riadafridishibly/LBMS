class LatticeBoltzmanSim {
  int xdimension;
  int ydimension;

  int gridSize = GRID_SIZE;

  int step;

  float u = 0.075;                             // initial flow rate
  float usq = u * u;                           // squared initial flow velocity
  float viscosity = 0.05;                      // viscosity
  float omega = 1.0 / (3.0 * viscosity + 0.5); // single time relaxation coefficient

  final static float four9ths = 4.0 / 9.0;
  final static float one9th = 1.0 / 9;
  final static float one36th = 1.0 / 36;

  Barrier b;

  Cell[][] cells;

  LatticeBoltzmanSim(int x_, int y_) {
    xdimension = x_;
    ydimension = y_;

    b = new Barrier(xdimension, ydimension);
    cells = new Cell[xdimension][ydimension];

    for (int x = 0; x < xdimension; x++) {
      for (int y = 0; y < ydimension; y++) {
        cells[x][y] = new Cell(x * gridSize, y * gridSize);
      }
    }
  }

  void initialize() {
    step = 0;
    for (int x = 0; x < xdimension; x++) {
      for (int y = 0; y < ydimension; y++) {
        Cell curr = cells[x][y];
        if (curr.isObstacle == true) {
          clearCell(x, y);
        } else {
          // usq = u^2
          curr.f0      = four9ths * (1 - 1.5 * usq);
          curr.fN      = one9th   * (1 - 1.5 * usq);
          curr.fS      = one9th   * (1 - 1.5 * usq);
          curr.fE      = one9th   * (1 + 3   * u + 3 * usq);
          curr.fW      = one9th   * (1 - 3   * u + 3 * usq);
          curr.fNE     = one36th  * (1 + 3   * u + 3 * usq);
          curr.fSE     = one36th  * (1 + 3   * u + 3 * usq);
          curr.fNW     = one36th  * (1 - 3   * u + 3 * usq);
          curr.fSW     = one36th  * (1 - 3   * u + 3 * usq);
          curr.xVelocity    = u;
          curr.yVelocity    = 0;
        }
      }
    }
  }


  void clearCell(int x, int y) {
    Cell curr = cells[x][y];
    curr.f0 = 0;
    curr.fE = 0;
    curr.fW = 0;
    curr.fN = 0;
    curr.fS = 0;
    curr.fNE = 0;
    curr.fNW = 0;
    curr.fSE = 0;
    curr.fSW = 0;
    curr.xVelocity = 0;
    curr.yVelocity = 0;
  }

  void createObstacle(String name) {
    if ("triangle".equals(name)) {
      b.getTriangle(cells);
    } else if ("circle".equals(name)) {
      b.getCircle(cells);
    } else if ("rectangle".equals(name)) {
      b.getRectangle(cells);
    } else if ("line".equals(name)) {
      b.getLine(cells);
    } else if ("wing".equals(name)) {
      b.getWing(cells);
    }
  }

  void clearObstacle() {
    for (int x = 0; x < xdimension; x++) {
      for (int y = 0; y < ydimension; y++) {
        cells[x][y].isObstacle = false;
      }
    }
  }

  void decreaseFlowSpeed(float amount) {
    u -= amount;
    u = constrain(u, 0.05, 0.1);
    usq = u * u;
  }
  void increaseFlowSpeed(float amount) {
    u += amount;
    u = constrain(u, 0.05, 0.1);
    usq = u * u;
  }

  void increaseViscocity(float amount) {
    viscosity += amount;
    viscosity = constrain(viscosity, 0.005, 1.0);
    omega = 1.0 / (3.0 * viscosity + 0.5);
  }

  void decreaseViscocity(float amount) {
    viscosity -= amount;
    viscosity = constrain(viscosity, 0.005, 1.0);
    omega = 1.0 / (3.0 * viscosity + 0.5);
  }

  // collision of each particle
  void collide() {
    float vx, vy, vxx, vyy, vx3, vy3, vxy, vsq, vsq15;
    for (int x = 0; x < xdimension; x++) {
      for (int y = 0; y < ydimension; y++) {
        Cell curr = cells[x][y];
        // when there are no obstacles
        if (!curr.isObstacle) {
          // total number of particles in the lattice = Density ρ
          float rho = curr.f0 + curr.fN + curr.fS + curr.fE + curr.fW + curr.fNW + curr.fNE + curr.fSW + curr.fSE;
          // density (macroscopic density) (Since it is within unit space, it is equal to the number)
          float one9thRho = one9th * rho;   // ρ/9
          float one36thRho = one36th * rho; // ρ/36
          float Irho = 1 / rho;             // inverse rho :reciprocal of ρ
          if (rho > 0) {
            vx = (curr.fE + curr.fNE + curr.fSE - curr.fW - curr.fNW - curr.fSW) * Irho;
            vy = (curr.fN + curr.fNE + curr.fNW - curr.fS - curr.fSE - curr.fSW) * Irho;
          } else {
            vx = 0;
            vy = 0;
          }
          curr.xVelocity = vx; // speed in x direction
          curr.yVelocity = vy; // speed in y direction

          vx3 = 3 * vx;
          vy3 = 3 * vy;
          vxx = vx * vx;
          vyy = vy * vy;
          vxy = 2 * vx * vy;
          vsq = vxx + vyy;
          vsq15 = 1.5 * vsq;
          curr.f0  += omega * (four9ths  *   rho * (1 - vsq15) - curr.f0);
          curr.fE  += omega * (one9thRho *   (1 + vx3 + 4.5 * vxx - vsq15) - curr.fE);
          curr.fW  += omega * (one9thRho *   (1 - vx3 + 4.5 * vxx - vsq15) - curr.fW);
          curr.fN  += omega * (one9thRho *   (1 + vy3 + 4.5 * vyy - vsq15) - curr.fN);
          curr.fS  += omega * (one9thRho *   (1 - vy3 + 4.5 * vyy - vsq15) - curr.fS);
          curr.fNE += omega * (one36thRho  * (1 + vx3 + vy3 + 4.5 * (vsq + vxy) - vsq15) - curr.fNE);
          curr.fNW += omega * (one36thRho  * (1 - vx3 + vy3 + 4.5 * (vsq - vxy) - vsq15) - curr.fNW);
          curr.fSE += omega * (one36thRho  * (1 + vx3 - vy3 + 4.5 * (vsq - vxy) - vsq15) - curr.fSE);
          curr.fSW += omega * (one36thRho  * (1 - vx3 - vy3 + 4.5 * (vsq + vxy) - vsq15) - curr.fSW);
        }
      }
    }
  }

  // particle movement
  void stream() {
    for (int x = 0; x < xdimension - 1; x++) {
      for (int y = ydimension - 1; y > 0; y--) {
        cells[x][y].fN = cells[x][y - 1].fN;
        cells[x][y].fNW = cells[x + 1][y - 1].fNW;
      }
    }
    for (int x = xdimension - 1; x > 0; x--) {
      for (int y = ydimension - 1; y > 0; y--) {
        cells[x][y].fE = cells[x - 1][y].fE;
        cells[x][y].fNE = cells[x - 1][y - 1].fNE;
      }
    }
    for (int x = xdimension - 1; x > 0; x--) {
      for (int y = 0; y < ydimension - 1; y++) {
        cells[x][y].fS = cells[x][y + 1].fS;
        cells[x][y].fSE = cells[x - 1][y + 1].fSE;
      }
    }
    for (int x = 0; x < xdimension - 1; x++) {
      for (int y = 0; y < ydimension - 1; y++) {
        cells[x][y].fW = cells[x + 1][y].fW;
        cells[x][y].fSW = cells[x + 1][y + 1].fSW;
      }
    }
    for (int y = 0; y < ydimension - 1; y++) {
      cells[0][y].fS = cells[0][y + 1].fS;
    }
    for (int y = ydimension - 1; y > 0; y--) {
      cells[xdimension - 1][y].fN = cells[xdimension - 1][y - 1].fN;
    }

    // Bring newly from the left end
    for (int y = 0; y < ydimension; y++) {
      Cell curr = cells[0][y];
      if (curr.isObstacle == false) {
        curr.fE  = one9th * (1 + 3 * u + 3 * usq);
        curr.fNE = one36th * (1 + 3 * u + 3 * usq);
        curr.fSE = curr.fNE;
      }
    }

    // make the upper and lower boundary the same as the initial flow to make it out of calculation
    for (int x = 0; x < xdimension; x++) {

      Cell up = cells[x][0];

      up.f0  = four9ths * (1 - 1.5 * usq);
      up.fE  = one9th   * (1 + 3 * u + 3 * usq);
      up.fW  = one9th   * (1 - 3 * u + 3 * usq);
      up.fN  = one9th   * (1 - 1.5 * usq);
      up.fS  = one9th   * (1 - 1.5 * usq);
      up.fNE = one36th  * (1 + 3 * u + 3 * usq);
      up.fSE = one36th  * (1 + 3 * u + 3 * usq);
      up.fNW = one36th  * (1 - 3 * u + 3 * usq);
      up.fSW = one36th  * (1 - 3 * u + 3 * usq);

      Cell down = cells[x][ydimension - 1];

      down.f0  = four9ths * (1 - 1.5 * usq);
      down.fE  = one9th   * (1 + 3 * u + 3 * usq);
      down.fW  = one9th   * (1 - 3 * u + 3 * usq);
      down.fN  = one9th   * (1 - 1.5 * usq);
      down.fS  = one9th   * (1 - 1.5 * usq);
      down.fNE = one36th  * (1 + 3 * u + 3 * usq);
      down.fSE = one36th  * (1 + 3 * u + 3 * usq);
      down.fNW = one36th  * (1 - 3 * u + 3 * usq);
      down.fSW = one36th  * (1 - 3 * u + 3 * usq);
    }

    // The outflow edge is assumed to be the same as the distribution on the left one next (unstable if there is not this)
    for (int y = 0; y < ydimension; y++) {
      if (cells[xdimension - 1][y].isObstacle == false) {
        cells[xdimension - 1][y].fW  = cells[xdimension - 2][y].fW;
        cells[xdimension - 1][y].fNW = cells[xdimension - 2][y].fNW;
        cells[xdimension - 1][y].fSW = cells[xdimension - 2][y].fSW;
      }
    }
  }

  // flow velocity in x direction
  void showXVelocity() {
    for (int x = 1; x < xdimension - 1; x++) {
      for (int y = 1; y < ydimension - 1; y++) {
        cells[x][y].showXVelocity();
      }
    }
  }

  // calculation of rotation
  void calculateRotation() {
    for (int x = 1; x < xdimension - 1; x++) {
      for (int y = 1; y < ydimension - 1; y++) {
        Cell cell = cells[x][y];
        cell.rotation = (cells[x + 1][y].yVelocity - cells[x - 1][y].yVelocity) -
          (cells[x][y + 1].xVelocity - cells[x][y - 1].xVelocity);
      }
    }

    // endpoints
    for (int y = 1; y < ydimension - 1; y++) {
      cells[0][y].rotation = 2 * (cells[1][y].yVelocity - cells[0][y].yVelocity) -
        (cells[0][y + 1].xVelocity - cells[0][y - 1].xVelocity);
      cells[xdimension - 1][y].rotation = 2 * (cells[xdimension - 1][y].yVelocity - cells[xdimension - 2][y].yVelocity) -
        (cells[xdimension - 1][y + 1].xVelocity - cells[xdimension - 1][y - 1].xVelocity);
    }
  }

  void showRotation() {
    calculateRotation();
    noStroke();
    for (int x = 1; x < xdimension - 1; x++) {
      for (int y = 1; y < ydimension - 1; y++) {
        cells[x][y].showRotation();
      }
    }
  }

  void showFlowVector() {
    for (int i = 1; i < xdimension - 1; ++i) {
      for (int j = 1; j < ydimension - 1; ++j) {
        cells[i][j].showFlowVector();
      }
    }
  }

  // bounce back
  void bounceBack() {
    // bounce back condition, simply rotate 180 degrees
    for (int x = 0; x < xdimension; x++) {
      for (int y = 0; y < ydimension; y++) {
        if (cells[x][y].isObstacle == true) {
          if (cells[x][y].fN > 0) {
            cells[x][y - 1].fS += cells[x][y].fN;
            cells[x][y].fN = 0;
          }
          if (cells[x][y].fS > 0) {
            cells[x][y + 1].fN += cells[x][y].fS;
            cells[x][y].fS = 0;
          }
          if (cells[x][y].fE > 0) {
            cells[x - 1][y].fW += cells[x][y].fE;
            cells[x][y].fE = 0;
          }
          if (cells[x][y].fW > 0) {
            cells[x + 1][y].fE += cells[x][y].fW;
            cells[x][y].fW = 0;
          }
          if (cells[x][y].fNW > 0) {
            cells[x + 1][y - 1].fSE += cells[x][y].fNW;
            cells[x][y].fNW = 0;
          }
          if (cells[x][y].fNE > 0) {
            cells [x - 1][y - 1].fSW += cells[x][y].fNE;
            cells[x][y].fNE = 0;
          }
          if (cells[x][y].fSW > 0) {
            cells [x + 1][y + 1].fNE += cells[x][y].fSW;
            cells [x][y].fSW = 0;
          }
          if (cells[x][y].fSE > 0) {
            cells[x - 1][y + 1].fNW += cells[x][y].fSE;
            cells[x][y].fSE = 0;
          }
        }
      }
    }
  }

  // display obstacles
  void showBarrier() {
    for (int x = 1; x < xdimension - 1; x++) {
      for (int y = 1; y < ydimension - 1; y++) {
        cells[x][y].showBarrier();
      }
    }
  }
}
