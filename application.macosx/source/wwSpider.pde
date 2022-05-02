import oscP5.*;
import netP5.*;
import controlP5.*;
import java.nio.file.Path;

ControlP5 cp5;
Object obj = new Object();
OscP5 oscP5;
Router router;
Menu menu;

PImage fondoSetup;
PFont bodoni;
PImage icon;

public void settings() {
  size(displayWidth/2, displayHeight/2);
  fondoSetup = loadImage("images/setupBackground.png");
  icon = loadImage("images/icon.png");
  registerMethod("pre", this);
}

public void setup() {

  background(0);
  image(fondoSetup, width/10, height/8, width/1.2, height/1.5);
  textSize(18);
  frameRate(12);
  bodoni = createFont("fonts/bodonixt.ttf", 14);
  textFont(bodoni);

  surface.setIcon(icon);
  surface.setResizable(true);

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  router = new Router(8);

  oscP5 = new OscP5(this, router.oscPort);
  router.currentHost = currentHost();
}

void draw() {

  background(0);
  router.update();
  Runtime.getRuntime().runFinalization();
}

void keyPressed() {

  if ( key == ' ') {
    router.menuDisplay();
  }
  if (key == 'I' || key == 'i') {
    router.IPConstructor();
  }
  if (key == 'R' || key == 'r') {
    router.sendToReaperBooleanSwitch();
  }
  if (key == 'U' || key == 'u') {
    router.JSONUpdate();
  }
}
