class Button {
  int x, y;
  int w, h;
  String name;
  String text = "";
  color clr = color(255);
  color tclr = color(0);
  
  Button(int x_, int y_, int w_, int h_, String name_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    name = name_;
  }

  void setText(String text_) {
    text = text_;
  }
  
  void setBGColor(color c) {
    clr = c;
  }
  
  void setTextColor(color c) {
    tclr = c;  
  }

  void show() {
    pushMatrix();
    translate(x, y);
    fill(clr);
    rect(0, 0, w, h);
    translate(w / 2, h / 2);
    textAlign(CENTER, CENTER);
    textSize(18);
    fill(tclr);
    text(text, 0, 0);
    fill(255);
    textSize(20);
    text(name, 0, 35);
    popMatrix();
  }

  boolean isOnButton(int x_, int y_) {
    return x_ > x && x_ < (x + w) && y_ > y && y_ < (y + h);
  }
  
  void sendClick() {
  }
}
