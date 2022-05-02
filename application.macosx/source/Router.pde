class Router {

  boolean onMenu, sendToReaper, errorMode;
  int [] deviceID, remotePort, notesToReaper;
  boolean [] receive, send, isOnReaper;
  Chart [] grafico, graficoOut; 
  float [] sliderMaxValue, 
    sliderMinValue, 
    sliderMaxValueLog, 
    sliderMinValueLog, 
    inputSignal, 
    outputSignal;
  int containerWidth, containerHeight, numberOfChannels, oscPort, toMB;
  JSONObject JSONConfig, item;
  JSONArray IPsAndPorts = new JSONArray();
  JSONArray channelsModule;
  JSONArray notes;
  NetAddress [] OSCRemoteIP = new NetAddress[255];
  String currentHost;
  String []
    channelInName, 
    channelInValue, 
    channelOutName, 
    channelOutValue, 
    sliderMaxName, 
    sliderMinName, 
    sendToggleName, 
    receiveToggleName, 
    remoteJSONIPList, 
    remoteIP, 
    remoteDomain;

  Router(int numberOfChannels) {

    this.toMB = 1024 * 1024;
    this.numberOfChannels = numberOfChannels;
    this.oscPort = 53101;
    this.containerWidth = width;
    this.containerHeight = height;
    this.receive = new boolean[this.numberOfChannels];
    this.send =  new boolean[this.numberOfChannels];
    this.notesToReaper = new int[this.numberOfChannels];
    this.grafico = new Chart[this.numberOfChannels];
    this.graficoOut = new Chart[this.numberOfChannels];
    this.sliderMaxValue = new float[this.numberOfChannels];
    this.sliderMinValue = new float[this.numberOfChannels];
    this.sliderMaxValueLog = new float[this.numberOfChannels];
    this.sliderMinValueLog = new float[this.numberOfChannels];
    this.sliderMaxName = new String[this.numberOfChannels];
    this.sliderMinName = new String[this.numberOfChannels];
    this.outputSignal =  new float[this.numberOfChannels];
    this.inputSignal =  new float[this.numberOfChannels];
    this.channelInName = new String[this.numberOfChannels];
    this.isOnReaper = new boolean[this.numberOfChannels];
    this.channelInValue = new String[this.numberOfChannels];
    this.channelOutName = new String[this.numberOfChannels];
    this.channelOutValue = new String[this.numberOfChannels];
    this.receiveToggleName = new String[ this.numberOfChannels];
    this.sendToggleName =  new String[this.numberOfChannels];
    this.remoteIP = new String [255];
    this.deviceID =  new int [255];
    this.remoteDomain =  new String [255];
    this.remotePort =  new int [255];
    this.JSONConfig = loadJSONObject("config/config.json");
    this.IPsAndPorts = JSONConfig.getJSONArray("IPsAndPorts");
    this.notes = JSONConfig.getJSONArray("notes");
    this.channelsModule = JSONConfig.getJSONArray("channels");
    this.currentHost = currentHost();
    this.sendToReaper = true;
    this.errorMode = false;

    for (int i = 0; i < this.channelsModule.size(); i++) {

      this.item = this.channelsModule.getJSONObject(i);

      this.notesToReaper[i] = this.notes.getInt(i);

      this.channelInValue[i] = this.item.getString("channelInOSC");
      this.channelOutValue[i] = this.item.getString("channelOutOSC");
      this.receive[i] = this.item.getBoolean("receive");
      this.send[i] = this.item.getBoolean("sending");
      this.sliderMaxValue[i] = this.item.getFloat("sliderMax");
      this.sliderMinValue[i] = this.item.getFloat("sliderMin");
      this.sliderMaxValueLog[i] = this.item.getFloat("sliderMaxLog");
      this.inputSignal[i] = 0;
      this.outputSignal[i] = 0;
      this.sliderMaxName[i] = "sliderMax["+i+"]";
      this.sliderMinName[i] = "sliderMin["+i+"]";
      this.channelInName[i] = "channelInName["+i+"]";
      this.channelOutName[i] = "channelOutName["+i+"]";
      this.receiveToggleName[i] = "receiveToggleName["+i+"]";
      this.sendToggleName[i] = "sendToggleName["+i+"]";
      this.textFields(i);
      this.textFieldsToOut(i);
      this.graficos(i);
      this.graficosOut(i);
      this.toggles(i);
      this.modulosOSC(i);
      this.slidersMax(i);
      this.slidersMin(i);
    }

    this.IPConstructor();
  }

  void zeroToInactiveButtonDisplay() {

    if (mouseX > width/2 &&
      mouseX < width/2 + width/10 &&
      mouseY > 0 &&
      mouseY < height/32) {

      pushStyle();
      fill(0);
      stroke(255);
      rect(width/2, 0, width/10, height/32);
      fill(255);
      text("Send 0", width/2, 18);
      popStyle();
      if (mousePressed) {

        this.sendZeroToInactive();
      }
    } else {

      pushStyle();
      fill(255);
      stroke(127);
      rect(width/2, 0, width/10, height/32);
      fill(0);
      text("Send 0", width/2, 18);
      popStyle();
    }
  }

  void sendZeroToInactive() {

    for (int i = 0; i < this.numberOfChannels; i++) {

      if (router.receive[i] == false || router.send[i] == false) {

        router.receive[i] = true;
        router.send[i] = true;
        this.outputSignal[i] = 0;
      }
    }
  }

  void JSONUpdate() {

    this.JSONConfig = loadJSONObject("config/config.json");
    this.IPsAndPorts = this.JSONConfig.getJSONArray("IPsAndPorts");
    this.IPConstructor();
  }

  void IPConstructor() {

    this.JSONConfig = loadJSONObject("config/config.json");
    this.IPsAndPorts = this.JSONConfig.getJSONArray("IPsAndPorts");

    for (int i = 0; i<IPsAndPorts.size(); i++) {

      this.item = this.IPsAndPorts.getJSONObject(i);

      this.remoteIP[i] = this.item.getString("ip");

      this.isOnReaper[i] = this.item.getBoolean("isOnReaper");

      this.deviceID[i] = this.item.getInt("id");
      this.remoteDomain[i] = this.item.getString("domain");
      this.remotePort[i] = this.item.getInt("port");

      String ip =  this.remoteIP[i];
      int port = int(this.remotePort[i]);

      this.OSCRemoteIP[i] = new NetAddress(ip, port);
    }
  }

  void WWNormalizer(int i) {

    float a, b, sigI, sigO, gain_A, gain_B;
    a =  this.sliderMinValueLog[i];
    b =  this.sliderMaxValueLog[i];
    sigI =  this.inputSignal[i];

    gain_A = 0.1*127/a;
    gain_B = 127*0.1/(20000-sliderMaxValue[i]);

    if (sigI < a) {
      sigO  =  sigI * gain_A;
      if (sigO<0) sigO=0;
    } else if (sigI > b) {
      sigO  =  127 * 0.9 + (sigI - b) * gain_B;
      if ( sigO > 127) {
        sigO = 127;
      }
    } else {
      sigO =  127*0.1 + (( sigI - a ) / (b-a) )* 127 * 0.8;
    }
    this.outputSignal[i] =  sigO;

    /*
    float a, b, x, xt, sigO, gain_A, gain_B;
     a =  this.sliderMinValueLog[i];
     b =  this.sliderMaxValueLog[i];
     x =  this.inputSignal[i];
     float pc = 0.05;
     
     float eta = 127*(1-2*pc)/(b-a);
     if(eta>127) eta = 127;
     float t = a/(eta*a/(pc*127)-1);
     if(x<a){
     sigO = pc*127*x/a*exp( (x-a)/t );
     }
     else if(x>b){
     xt = a-(x-b);
     sigO =127-pc*127*xt/a*exp( (xt-a)/t );
     }
     else{
     sigO = 127*pc+(x-a)/(b-a)*127*(1-2*pc);
     }
     this.outputSignal[i] =  sigO;
     */
  }

  void sendToReaperBooleanSwitch() {

    this.sendToReaper =! this.sendToReaper;
  }
  void updateValues() {

    for (int i = 0; i <  this.numberOfChannels; i++) {

      this.WWNormalizer(i);

      this.modulosOSC(i);

      this.receive[i] = boolean(int(cp5.getController(("receiveToggleName["+i+"]")).getValue()));
      this.send[i] =  boolean(int(cp5.getController(("sendToggleName["+i+"]")).getValue()));
      this.channelInValue[i] = cp5.get(Textfield.class, this.channelInName[i]).getText().toString();
      this.channelOutValue[i] = cp5.get(Textfield.class, this.channelOutName[i]).getText().toString();

      this.grafico[i].push(this.inputSignal[i]);
      this.graficoOut[i].push(this.outputSignal[i]);
    }
    if (keyPressed) { 

      if (keyCode == 16) {

        this.zeroToInactiveButtonDisplay();
      }
    }
  }

  void drawP5Modules() {

    cp5.draw();
    pushStyle();
    noStroke();
    textSize(width/20);

    for (int i =0; i < this.numberOfChannels; i ++) {

      if (this.receive[i]) {

        fill(0);
      } else {

        fill(255);
      }

      text(i+1, 20, height/this.numberOfChannels*i-8+ height /10);

      if (this.send[i] == true) {

        fill(0);
      } else {

        fill(255);
      }

      text(i+1, width-48, height/this.numberOfChannels*i-8 + height /10);
    }

    popStyle();
  }

  void update() {

    if (this.errorMode == true) {

      this.updateValues();
    } else {

      this.drawP5Modules();    
      this.updateValues();

      if (this.onMenu) {

        menu.display();
      }

      OscMessage myMessage = new OscMessage("/message");

      String m = this.outputSignal[0]+"/"+this.outputSignal[1]+"/"+this.outputSignal[2]+"/"+this.outputSignal[3] + "/" + this.outputSignal[4]+"/"+this.outputSignal[5]+"/"+this.outputSignal[6]+"/"+this.outputSignal[7];

      myMessage.add(m);
      oscP5.send(myMessage, OSCRemoteIP[0]);
    }

    this.errorMode = false;
  }

  int obetnerListaDeIPsTxtCantidad() {

    return this.IPsAndPorts.size();
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
      .setSize(width/5, height/12)
      .setRange(0, 5000)
      .setColorBackground(color(0))
      .setView(Chart.LINE)
      .setLabelVisible(false);
    this.grafico[canal].addDataSet("grafico"+canal);
    this.grafico[canal].setData("grafico"+canal, new float[360]);
    this.grafico[canal].setColors("grafico"+canal, color(255, 0, 0));
  }

  void graficosOut(int canal) {

    this.graficoOut[canal] = cp5.addChart("graficoOut"+canal)
      .setPosition(width-width/4, height/this.numberOfChannels*canal)
      .setSize(width/5, height/12)
      .setRange(0, 127)
      .setColorBackground(color(0))
      .setView(Chart.LINE)
      .setLabelVisible(false);
    this.graficoOut[canal].addDataSet("graficoOut"+canal);
    this.graficoOut[canal].setData("graficoOut"+canal, new float[360]);
    this.graficoOut[canal].setColors("graficoOut"+canal, color(0, 255, 0));
  }

  void slidersMin(int canal) {

    cp5.addSlider(this.sliderMinName[canal])
      .setPosition(width/2, height/this.numberOfChannels*canal)
      .setSize(width/4, height/16)
      .setRange(0, 100)
      .setId(canal)
      .setLabelVisible(false)
      .setValue(this.sliderMinValue[canal])
      .setColorBackground(190)
      .setColorActive(color(200, 0, 200))
      .setColorForeground(color(255, 0, 255))
      .setLabelVisible(false);
  }

  void slidersMax(int canal) {

    cp5.addSlider(this.sliderMaxName[canal])
      .setPosition(width/2, height/this.numberOfChannels*canal+height/16)
      .setSize(width/4, height/16)
      .setRange(0, 100)
      .setId(canal)
      .setValue(this.sliderMaxValue[canal])
      .setColorBackground(190)
      .setColorActive(color(200, 0, 0))
      .setColorForeground(color(255, 0, 0))
      .setLabelVisible(false)
      ;
  }

  void textFieldsToOut(int canal) {

    cp5.addTextfield("channelOutName["+canal+"]")
      .setLabelVisible(false)
      .setPosition(width/10+10, height/this.numberOfChannels*canal+height/16)
      .setSize(width/6, height/this.numberOfChannels/5)
      .setId(canal)
      .setText(this.channelOutValue[canal])
      .setAutoClear(false)
      .setColorBackground(190)
      .setColorActive(color(0, 255, 0))
      .setColorForeground(color(255, 0, 0))
      .setLabelVisible(false);
  }

  void textFields(int canal) {

    cp5.addTextfield("channelInName["+canal+"]")
      .setLabelVisible(false)
      .setPosition(width/10+10, height/this.numberOfChannels*canal+1)
      .setSize(width/6, height/   this.numberOfChannels/5)
      .setId(canal)
      .setText(this.channelInValue[canal])
      .setAutoClear(false)
      .setColorBackground(190)
      .setColorActive(color(0, 255, 0))
      .setColorForeground(color(255, 0, 0))
      .setLabelVisible(false);
  }

  void toggles(int canal) {

    cp5.addToggle("receiveToggleName["+canal+"]")
      .setPosition(0, height/this.numberOfChannels*canal)
      .setSize(width  /10, height/8)
      .setLabelVisible(false)
      .setId(canal)
      .setColorActive(color(255, 0, 0))
      .setColorBackground(0)
      .setColorForeground(color(255))
      .setValue(this.receive[canal]);

    cp5.addToggle("sendToggleName["+canal+"]")
      .setPosition(width-width/10, height/this.numberOfChannels*canal)
      .setSize(width/10, height/8)
      .setLabelVisible(false)
      .setId(canal)
      .setColorActive(color(0, 255, 0))
      .setColorBackground(0)
      .setColorForeground(color(255))
      .setValue(this.send[canal]);
  }

  void modulosOSC(int canal) {

    pushStyle();
    noFill();
    stroke(127 + round(inputSignal[canal]), 127, 127);
    rect(0, height/this.numberOfChannels*canal, width/2, height/this.numberOfChannels*canal);
    noStroke();

    fill(0);
    rect( width/2-width/5.5, height/this.numberOfChannels*canal+10, 60, 20);

    fill(255, 255);
    text("["+(canal+1)+"]: "+round(inputSignal[canal]), width/2-width/5.5, height/this.numberOfChannels*canal+24);
    popStyle();


    pushStyle();
    noFill();
    stroke(127, 127 + round(outputSignal[canal]), 127);
    rect( width-width/2, height/this.numberOfChannels*canal, width/2, height/this.numberOfChannels*canal);

    noStroke();
    fill(0);
    rect(width-width/4, height/this.numberOfChannels*canal+10, 60, 20);
    fill(255, 255);
    text("["+(canal+1)+"]: "+round(outputSignal[canal]), width-width/4, height/this.numberOfChannels*canal+height/32);  
    stroke(255, 255, 0, 255);
    strokeWeight(2);
    line(width/2, 0, width/2, height);
    popStyle();

    pushStyle();
    fill(255);
    text("MIN:"+round(this.sliderMinValueLog[canal]), width/2, height/this.numberOfChannels*canal+height/24);
    text("MAX:"+round(this.sliderMaxValueLog[canal]), width/2, height/this.numberOfChannels*canal+height/10);
    popStyle();
  }
}
