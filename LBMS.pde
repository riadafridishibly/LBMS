static final int GRID_SIZE = 5;
static final int WINDOW_WIDTH = 1000;
static final int WINDOW_HEIGHT = 400;
static final int SIM_WIDTH = WINDOW_WIDTH / GRID_SIZE;
static final int SIM_HEIGHT = WINDOW_HEIGHT / GRID_SIZE;

ArrayList<Button> buttons;

Button bViewMode, bObstacle;
Button bDummyViscocity, bDummyFlowSpeed;
Button bViscocityDec, bViscocityInc;
Button bSpeedDec, bSpeedInc;
Button saveIt;
LatticeBoltzmanSim lbmsim;

PGraphics colorMap;

void setup() {
  // window size
  size(1000, 500);
  colorMode(HSB, 255, 255, 255);
  buttons = new ArrayList<Button>();
  //frameRate(120);
  // disable stroke
  noStroke();
  colorMap = drawColorMap();
  lbmsim = new LatticeBoltzmanSim(SIM_WIDTH, SIM_HEIGHT);
  createButtons();
  init(0);
}

void createButtons() {
  int xstart = 80;
  int ystart = WINDOW_HEIGHT + 20;
  int buttonSizeX = 150;
  int buttonSizeY = 40;
  bViewMode = new Button(xstart, ystart, buttonSizeX, buttonSizeY, "View Mode");
  buttons.add(bViewMode);

  xstart += 180;
  bObstacle = new Button(xstart, ystart, buttonSizeX, buttonSizeY, "Obstacle");
  buttons.add(bObstacle);

  xstart += 180;
  bViscocityDec = new Button(xstart, ystart, buttonSizeY, buttonSizeY, "");
  bViscocityDec.setText("-");
  bViscocityDec.setBGColor(#FF3434);

  buttons.add(bViscocityDec);

  xstart += buttonSizeY + 10;
  bDummyViscocity = new Button(xstart, ystart, buttonSizeX, buttonSizeY, "Viscocity");
  bDummyViscocity.setBGColor(#A6D7F5);
  bDummyViscocity.setText(String.format("%.4f", lbmsim.viscosity));
  buttons.add(bDummyViscocity);

  xstart += buttonSizeX + 10;
  bViscocityInc = new Button(xstart, ystart, buttonSizeY, buttonSizeY, "");
  bViscocityInc.setText("+");
  bViscocityInc.setBGColor(#68E089);
  buttons.add(bViscocityInc);

  xstart += buttonSizeY + 40;
  bSpeedDec = new Button(xstart, ystart, buttonSizeY, buttonSizeY, "");
  bSpeedDec.setText("-");
  bSpeedDec.setBGColor(#FF3434);
  buttons.add(bSpeedDec);

  xstart += buttonSizeY + 10;
  bDummyFlowSpeed = new Button(xstart, ystart, buttonSizeX, buttonSizeY, "Flow Speed");
  bDummyFlowSpeed.setBGColor(#A6D7F5);
  bDummyFlowSpeed.setText(String.format("%.4f", lbmsim.u));
  buttons.add(bDummyFlowSpeed);

  xstart += buttonSizeX + 10;
  bSpeedInc = new Button(xstart, ystart, buttonSizeY, buttonSizeY, "");
  bSpeedInc.setText("+");
  bSpeedInc.setBGColor(#68E089);
  buttons.add(bSpeedInc);

  saveIt = new Button(20, ystart + 30, 40, 40, "");
  saveIt.setBGColor(color(75));
  saveIt.setTextColor(color(204));
  saveIt.setText("S");
  buttons.add(saveIt);
}

int opCodeViewMode = 0;
final int numOfViewMode = 2;

int opCodeObstacle = 0;
final int numOfObstacle = 5;

void draw() {
  background(0);
  lbmsim.collide();
  lbmsim.stream();
  lbmsim.bounceBack();
  show(opCodeViewMode);
  lbmsim.showFlowVector();
  lbmsim.showBarrier();

  fill(255);
  textSize(14);
  text(str(int(frameRate)), 40, height - 70);
  for (Button b : buttons) {
    b.show();
  }
  if (opCodeViewMode == 0)
    image(colorMap, width - 50, 80);


  //saveFrame("./vid/frame-######.tif");
}

void mousePressed() {
  if (bViewMode.isOnButton(mouseX, mouseY)) {
    opCodeViewMode = (opCodeViewMode + 1) % numOfViewMode;
  }
  if (bObstacle.isOnButton(mouseX, mouseY)) {
    opCodeObstacle = (opCodeObstacle + 1) % numOfObstacle;
    init(opCodeObstacle);
  }
  if (bSpeedDec.isOnButton(mouseX, mouseY)) {
    lbmsim.decreaseFlowSpeed(0.002);
    bDummyFlowSpeed.setText(String.format("%.4f", lbmsim.u));
  }
  if (bSpeedInc.isOnButton(mouseX, mouseY)) {
    lbmsim.increaseFlowSpeed(0.002);
    bDummyFlowSpeed.setText(String.format("%.4f", lbmsim.u));
  }

  if (bViscocityDec.isOnButton(mouseX, mouseY)) {
    lbmsim.decreaseViscocity(0.02);
    bDummyViscocity.setText(String.format("%.4f", lbmsim.viscosity));
  }

  if (bViscocityInc.isOnButton(mouseX, mouseY)) {
    lbmsim.increaseViscocity(0.02);
    bDummyViscocity.setText(String.format("%.4f", lbmsim.viscosity));
  }

  if (saveIt.isOnButton(mouseX, mouseY)) {
    saveFrame("frames/frame-####.png");
  }
}

void show(int n) {
  switch (n) {
  case 0:
    lbmsim.showXVelocity();
    bViewMode.setText("Velocity");
    bViewMode.setBGColor(#5FB9D1); // becareful with colors. color mode is set to HSB
    break;
  case 1:
    lbmsim.showRotation();
    bViewMode.setText("Rotation");
    bViewMode.setBGColor(#D15FB8);
    break;
  }
}


void init(int n) {
  switch (n) {
  case 0:
    lbmsim.createObstacle("circle");
    bObstacle.setText("Circle");
    bObstacle.setBGColor(#F78911);
    break;
  case 1:
    lbmsim.createObstacle("triangle");
    bObstacle.setText("Triangle");
    bObstacle.setBGColor(#11D7F7);
    break;
  case 2:
    lbmsim.createObstacle("rectangle");
    bObstacle.setText("Rectangle");
    bObstacle.setBGColor(#5FD195);
    break;
  case 3:
    lbmsim.createObstacle("line");
    bObstacle.setText("Line");
    bObstacle.setBGColor(#9D6EBC);
    break;
  case 4:
    lbmsim.createObstacle("wing");
    bObstacle.setText("Wing");
    bObstacle.setBGColor(#9D6EBC);
    break;
  }
  lbmsim.initialize();
}

PGraphics drawColorMap() {
  PGraphics pg = createGraphics(40, 250);

  pg.beginDraw();
  pg.background(0);
  pg.colorMode(HSB, 255, 255, 255);
  for (int i = 220; i >= 0; --i) {
    pg.stroke(i, 255, 255);
    pg.line(10, 235 - i, pg.width - 10, 235 - i);
  }
  pg.endDraw();
  return pg;
}
