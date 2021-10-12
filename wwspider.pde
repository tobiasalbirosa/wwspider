import oscP5.*;
import netP5.*;
import controlP5.*;
import java.nio.file.Path;
import java.nio.file.Paths;
ControlP5 cp5;
NetAddress [] IPRemoto = new NetAddress[10];
Object [] obj = new Object[10];
OscP5 oscP5;
Router router;
Menu menu;
OscMessage myMessage  = new OscMessage("/message");
PImage fondoSetup;
PFont bodoni;
PImage icon;
public void settings() {
  size(displayWidth/2, displayHeight-100);
  fondoSetup = loadImage("./images/setupBackground.png");
  icon = loadImage("./images/icon.png");
}
public void setup() { 
  background(0);
  image(fondoSetup, width/4, height/4, width/2, height/3);
  bodoni = createFont("./fonts/bodonixt.ttf", 18);
  surface.setResizable(true);
  surface.setIcon(icon);
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  router = new Router(8);
  oscP5 = new OscP5(this, router.oscPort);
  registerMethod("pre", this);
  textFont(bodoni);
  frameRate(12);
  delay(3000);
}
void draw() {
  background(0);
  router.update();
  Runtime.getRuntime().runFinalization();
}
void keyPressed() {
  if ( key == 'D' || key == 'd') {
    router.menuDisplay();
  }
  if ( key == 'I' || key == 'i') {
    if (router.onMenu) {
      launch("notepad "+System.getProperty("user.dir")+"/data/IPList.txt");
    }
  }
  if (key == 'P' || key == 'p') {
    router.IPConstructor();
  }
}
