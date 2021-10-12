class Router {
  boolean onMenu;
  boolean [] receive, send;
  Chart [] grafico, graficoOut; 
  float [] sliderValue, originalValue, result;
  int containerWidth, containerHeight, numberOfChannels, oscPort, toMB;
  String channelOutToWWW, messageToWWW;
  String []
    channelInName, 
    channelInValue, 
    channelOutName, 
    channelOutValue, 
    IPList, 
    sliderName, 
    remoteIPList, 
    sendToggleName, 
    receiveToggleName;
  Router(int numberOfChannels) {
    this.IPConstructor();
    this.toMB = 1024 * 1024;
    this.numberOfChannels = numberOfChannels;
    this.oscPort = 53101;
    this.channelOutToWWW = "/message";
    this.containerWidth = width;
    this.containerHeight = height;
    this.receive = new boolean[this.numberOfChannels];
    this.send =  new boolean[this.numberOfChannels];
    this.grafico = new Chart[this.numberOfChannels];
    this.graficoOut = new Chart[this.numberOfChannels];
    this.sliderValue = new float[this.numberOfChannels];
    this.sliderName = new String[this.numberOfChannels];
    this.result =  new float[   this.numberOfChannels];
    this.originalValue =  new float[this.numberOfChannels];
    this.channelInName = new String[this.numberOfChannels];
    this.channelInValue = new String[this.numberOfChannels];
    this.channelOutName = new String[this.numberOfChannels];
    this.channelOutValue = new String[this.numberOfChannels];
    this.receiveToggleName = new String[ this.numberOfChannels];
    this.sendToggleName =  new String[this.numberOfChannels];
    for (int i = 0; i <    this.numberOfChannels; i++) {
      this.originalValue[i] = 0;
      this.result[i] = 0;
      this.sliderValue[i] = 1;
      this.sliderName[i] = "slider["+i+"]";
      this.channelInName[i] = "channelInName["+i+"]";
      this.channelInValue[i] =  "/wimumo001/emg/ch"+int(i+1);
      this.receiveToggleName[i] ="receiveToggleName["+i+"]";
      this.sendToggleName[i] =  "sendToggleName["+i+"]";
      this.send[i] = true;
      this.receive[i] = true;
      this.textFields(i);
      this.sliders(i);
      this.toggles(i);
      this.modulosOSC(i);
      this.graficos(i);
      this.graficosOut(i);
    }
  }
  void IPConstructor() {
    this.IPList  = loadStrings("IPList.txt");
    for (int i = 0; i <  this.IPList.length; i++) {
      IPRemoto[i] = new NetAddress(this.IPList[i], 53101);
    }
  }
  void WWWNormalizer(int i) {
    if (this.originalValue[i] * this.sliderValue[i] > 5000) {
      this.result[i] = 5000;
    } else {
      this.result[i] = this.originalValue[i] * this.sliderValue[i];
    }
    this.result[i] = map(this.result[i], 0, 5000, 0, 1);
    if (this.result[i] > 1) {
      this.result[i] = 1;
    }
  }
  void updateValues() {
    for (int i = 0; i <  this.numberOfChannels; i++) {
      modulosOSC(i);
      this.receive[i] =  boolean(int(cp5.getController(("receiveToggleName["+i+"]")).getValue()));
      this.send[i] =  boolean(int(cp5.getController(("sendToggleName["+i+"]")).getValue()));
      this.sliderValue[i] = cp5.getController(this.sliderName[i]).getValue();
      this.channelInValue[i] = cp5.get(Textfield.class, this.channelInName[i]).getText().toString();
      this.grafico[i].push(this.originalValue[i]);
      this.graficoOut[i].push(this.result[i]);
      this.WWWNormalizer(i);
    }
  }
  void drawP5Modules() {
    cp5.draw();
  }
  void update() {
    background(0);
    this.updateValues();
    this.drawP5Modules();
    if (this.onMenu) {
      menu.display();
    }
  }
  int obetnerListaDeIPsTxtCantidad() {
    return this.IPList.length;
  }
  void menuDisplay() {
    this.onMenu = !this.onMenu;
    if (this.onMenu) {
      menu = new Menu(width/10, height/8);
    }
  }
  void graficos(int canal) {
    this.grafico[canal] = cp5.addChart("grafico"+canal)
      .setPosition(width/10*3, height/this.numberOfChannels*canal)
      .setSize(width/5, height/this.numberOfChannels)
      .setRange(0, 5000)
      .setColorBackground(0)
      .setView(Chart.LINE)
      .setLabelVisible(false);
    this.grafico[canal].addDataSet("grafico"+canal);
    this.grafico[canal].setData("grafico"+canal, new float[360]);
    this.grafico[canal].setColors("grafico"+canal, color(255, 0, 0));
  }
  void graficosOut(int canal) {
    this.graficoOut[canal] = cp5.addChart("graficoOut"+canal)
      .setPosition(width/2+1, height/this.numberOfChannels*canal)
      .setSize(width/5, height/this.numberOfChannels)
      .setRange(0, 1)
      .setColorBackground(color(0))
      .setView(Chart.LINE)
      .setLabelVisible(false);
    this.graficoOut[canal].addDataSet("graficoOut"+canal);
    this.graficoOut[canal].setData("graficoOut"+canal, new float[360]);
    this.graficoOut[canal].setColors("graficoOut"+canal, color(0, 255, 0));
  }
  void sliders(int canal) {
    cp5.addSlider(this.sliderName[canal])
      .setPosition(width-width/3.4, height/this.numberOfChannels*canal+5)
      .setSize(width/6, 10)
      .setRange(0.0001, 10)
      .setValue(this.sliderValue[canal])
      .setColorActive(color(120))
      .setColorForeground(color(0, 255, 0))
      .setColorBackground(0);
  }
  void textFields(int canal) {
    cp5.addTextfield("channelInName["+canal+"]")
      .setLabelVisible(false)
      .setPosition(width/10+10, height/this.numberOfChannels*canal+5)
      .setSize(width/6, height/   this.numberOfChannels/5)
      .setText("/wimumo001/emg/ch"+int(canal+1))
      .setAutoClear(false)
      .setColorActive(color(120))
      .setColorForeground(color(255, 0, 0))
      .setColorBackground(0);
  }
  void toggles(int canal) {
    cp5.addToggle("receiveToggleName["+canal+"]")
      .setPosition(0, height/this.numberOfChannels*canal)
      .setSize(width  /10, height/this.numberOfChannels)
      .setLabelVisible(false)
      .setValue(true)
      .setColorActive(color(255, 0, 0))
      .setColorBackground(0)
      .setColorForeground(color(255));

    cp5.addToggle("sendToggleName["+canal+"]")
      .setPosition(width-width/10, height/this.numberOfChannels*canal)
      .setSize(width/10, height/this.numberOfChannels)
      .setLabelVisible(false)
      .setColorActive(color(0, 255, 0))
      .setColorBackground(0)
      .setColorForeground(color(255))
      .setValue(true);
  }
  void modulosOSC(int canal) {
    stroke(255, 0, 0, originalValue[canal]);
    fill(255, originalValue[canal]);
    if (!this.receive[canal]) {
      fill(40, originalValue[canal]);
    }
    noStroke();
    rect(width/10, height/this.numberOfChannels*canal, width/2-width/10, height/this.numberOfChannels-10);
    fill(255, 0, 0, originalValue[canal]);
    if (!this.receive[canal]) {
      fill(80, originalValue[canal]);
    }
    text("Routing: "+originalValue[canal], width/9, height/this.numberOfChannels*canal+60);
    fill(map(result[canal], 0, 1, 64, 0), 255);
    noStroke();
    rect( width-width/2, height/this.numberOfChannels*canal, width/2+width/5, height/this.numberOfChannels-10);
    fill(0, 255, 0, 255);
    text("WWWebSockets: "+result[canal], width-width/3.4, height/this.numberOfChannels*canal+60);
    stroke(255, 255, 0, 255);
    strokeWeight(2);
    line(width/2, 0, width/2, height);
  }
}
