import java.net.InetAddress;

InetAddress inet;

String currentHost() {

  try {

    inet = InetAddress.getLocalHost();
    String myIP = inet.getHostAddress();

    return  myIP;
  } 

  catch(Exception e) {

    return  "0.0.0.0";
  }
}

void pre() {

  cursor();

  Runtime.getRuntime().runFinalization();

  if (width > 240 && height > 180) {

    if (router.containerWidth != width || router.containerHeight != height) {
      image(icon, width/10, height/8, width/1.2, height/1.5);
      text("wwWaveing .net again, Please wwWait", 20, 20);
      noCursor();
      frameCount = 0;
      router.containerWidth = width;
      router.containerHeight = height;
      cp5.controlWindow.clear();
      cp5 = new ControlP5(this);
      cp5.setAutoDraw(false);
      router = new Router(8);
    }
  } else {
    if (width < 240) {
      width= 180;
    }
    if (height < 180) {
      height = 180;
    }
  }
}
