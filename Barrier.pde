class Barrier {
  PGraphics pg;
  int w, h;
  color BG_COLOR = color(255);
  color FG_COLOR = color(0);
  Barrier(int w, int h) {
    this.w = w;
    this.h = h;
    pg = createGraphics(w, h);
  }

  void objStartDraw() {
    pg.beginDraw();
    pg.clear();
    pg.background(BG_COLOR);
    pg.fill(FG_COLOR);
  }

  void objEndDraw() {
    pg.endDraw();
  }



  void getCircle(Cell[][] array) {
    objStartDraw();
    pg.ellipse(w / 6, h / 2, w / 14.0, w / 14.0);
    objEndDraw();

    fillCells(array);


    //objStartDraw();
    //pg.ellipse(w / 6, h / 3, w / 12.0, w / 12.0);
    //pg.ellipse(w / 6, h - h / 3, w / 12.0, w / 12.0);
    //pg.ellipse(w / 3, h / 2, w / 12.0, w / 12.0);
    //objEndDraw();

    //fillCells(array);
  }

  void getTriangle(Cell[][] array) {
    objStartDraw();
    pg.triangle(w / 5, h / 2, w / 3, h / 3, w / 3, h - h / 3);
    objEndDraw();
    fillCells(array);
  }

  void getRectangle(Cell[][] array) {
    objStartDraw();
    pg.rectMode(CENTER);
    pg.rect(w / 5, pg.height / 2, w / 14.0, w / 14.0);
    objEndDraw();

    fillCells(array);
  }

  void getWing(Cell[][] array) {
    objStartDraw();
    float x0 = map(435, 0, 1000, 0, w);
    float y0 = map(198, 0, 400, 0, h);

    float x1 = map(179, 0, 1000, 0, w);
    float y1 = map(148, 0, 400, 0, h);

    float x2 = map(96, 0, 1000, 0, w);
    float y2 = map(200, 0, 400, 0, h);

    float x3 = map(187, 0, 1000, 0, w);
    float y3 = map(236, 0, 400, 0, h);
    pg.beginShape();
    pg.curveVertex(x0, y0);
    pg.curveVertex(x0, y0);

    pg.curveVertex(x0, y0);
    pg.curveVertex(x0, y0);

    pg.curveVertex(x1, y1);
    pg.curveVertex(x2, y2);

    pg.curveVertex(x3, y3);
    pg.curveVertex(x3, y3);
    pg.endShape();
    //    pg.curveVertex(x0, y0);
    //    pg.curveVertex(x0, y0);

    objEndDraw();

    fillCells(array);
  }

  void getLine(Cell[][] array) {
    objStartDraw();
    pg.line(w / 5, h - h / 3, w / 4, h / 3);
    objEndDraw();

    fillCells(array);
  }

  void fillCells(Cell[][] array) {
    pg.loadPixels();
    for (int i = 0; i < pg.width; ++i) { // iterate over the cols
      for (int j = 0; j < pg.height; ++j) { // iterate over the rows
        Cell cell = array[i][j];
        if (pg.pixels[i + j * w] == BG_COLOR) {
          cell.isObstacle = false;
        } else {
          cell.isObstacle = true;
        }
      }
    }
  }
}
