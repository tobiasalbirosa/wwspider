class Menu {
  int x, y;
  String logPath =System.getProperty("user.dir");
  Menu(int x, int y) {
    this.x = x;
    this.y = y;
  }
  void display() {
    pushStyle();
    noStroke();
    fill(255, 225);
    textSize(16);
    rect(10, 10, width - 20, height-20);
    fill(0, 255);
    text("This host: "+currentHost()+":"+router.oscPort, this.x, this.y);
    text("FPS: " + frameRate, this.x, this.y+20);
    text("MB used: " + (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / router.toMB, this.x, this.y+40);
    text("MB free: " + Runtime.getRuntime().freeMemory() / router.toMB, this.x, this.y+60);
    text("Sending String for web: "+IPRemoto[0]+"/"+router.channelOutToWWW, this.x, this.y+80);
    text(this.logPath, this.x, this.y+100);
    for (int i = 1; i < router.obetnerListaDeIPsTxtCantidad(); i++) {
      text("Sending Directly OSC: "+IPRemoto[i]+":"+router.oscPort+"/"+router.channelInValue[0], this.x, this.y+100+i*20);
    }
    fill(0, 0, 255);
    text("| About", this.x, height-height/6);
    text(" | WWSpider v1.0 OSC Router 8 Channels 2021", this.x, height-height/7);
    text(" | Press 'D'  || 'd' to switch display ", this.x, height-height/8);
    text(" | Press 'I'  || 'i' to view the IPList.txt file", this.x, height-height/10);
    text(" | Press 'P'  || 'p' to update the IPList.txt file", this.x, height-height/10+20);
    popStyle();
  }
}
