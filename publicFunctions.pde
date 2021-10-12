String currentHost() {
  try {
    return java.net.InetAddress.getLocalHost().getHostAddress();
  } 
  catch(Exception e) {
    return  "0.0.0.0";
  }
}
void pre() {
  cursor();
  Runtime.getRuntime().runFinalization();
  if (router.containerWidth != width || router.containerHeight != height) {
    noCursor();
    image(fondoSetup, width/4, height/4, width/2, height/3);
    image(icon, mouseX, mouseY, 50, 50);
    delay(3000);
    router.containerWidth = width;
    router.containerHeight = height;
    cp5.controlWindow.clear();
    cp5 = new ControlP5(this);
    cp5.setAutoDraw(false);
    router = new Router(8);
  }
}
