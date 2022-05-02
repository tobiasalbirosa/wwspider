class Menu {

  int x, y;

  String logPath = System.getProperty("user.dir");
  String IPV4;

  Menu(int x, int y) {
    this.x = x;
    this.y = y;
    this.IPV4 = router.currentHost;
  }

  void display() {
    
    pushStyle();
    noStroke();
    fill(255, 225);
    rect(10, 10, width-20, height-20);
    fill(0, 255);
    text("This host: "+this.IPV4+":"+router.oscPort, this.x, this.y);
    text("FPS: " + frameRate, this.x, this.y+20);
    text("MB used: " + (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / router.toMB, this.x, this.y+40);
    text("MB free: " + Runtime.getRuntime().freeMemory() / router.toMB, this.x, this.y+60);
    text("Sending String for web: "+router.OSCRemoteIP[0], this.x, this.y+80);
    text("This dir: "+this.logPath, this.x, this.y+100);
    
    for (int i = 1; i < router.obetnerListaDeIPsTxtCantidad(); i++) {
      
      text("Sending outpuSingal OSC: "+router.OSCRemoteIP[i]+":"+router.channelInValue[i]+router.channelInValue[i], this.x, this.y+100+i*20);
    
    }
    
    fill(0, 0, 255);
    text("| About", this.x, height-height/6);
    text(" | WWSpider v1.0 OSC Router 8 Channels 2021", this.x, height-height/7);
    text(" | Press '+' to switch display ", this.x, height-height/8);
    text(" | Press 'I'  || 'i' to view the IPList.txt file", this.x, height-height/10);
    text(" | Press 'P'  || 'p' to update the IPList.txt file", this.x, height-height/10+20);
    text(" | Press 'R'  || 'r' to switch send to Reaper on "+ router.currentHost+":53104 ", this.x, height-height/10+40);

    popStyle();
    
  }
  
}
