import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import controlP5.*; 
import java.nio.file.Path; 
import java.net.InetAddress; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class wwSpider extends PApplet {






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
  image(fondoSetup, width/10, height/8, width/1.2f, height/1.5f);
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

public void draw() {

  background(0);
  router.update();
  Runtime.getRuntime().runFinalization();
}

public void keyPressed() {

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

class Menu {

  int x, y;

  String logPath = System.getProperty("user.dir");
  String IPV4;

  Menu(int x, int y) {
    this.x = x;
    this.y = y;
    this.IPV4 = router.currentHost;
  }

  public void display() {
    
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

  public void zeroToInactiveButtonDisplay() {

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

  public void sendZeroToInactive() {

    for (int i = 0; i < this.numberOfChannels; i++) {

      if (router.receive[i] == false || router.send[i] == false) {

        router.receive[i] = true;
        router.send[i] = true;
        this.outputSignal[i] = 0;
      }
    }
  }

  public void JSONUpdate() {

    this.JSONConfig = loadJSONObject("config/config.json");
    this.IPsAndPorts = this.JSONConfig.getJSONArray("IPsAndPorts");
    this.IPConstructor();
  }

  public void IPConstructor() {

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
      int port = PApplet.parseInt(this.remotePort[i]);

      this.OSCRemoteIP[i] = new NetAddress(ip, port);
    }
  }

  public void WWNormalizer(int i) {

    float a, b, sigI, sigO, gain_A, gain_B;
    a =  this.sliderMinValueLog[i];
    b =  this.sliderMaxValueLog[i];
    sigI =  this.inputSignal[i];

    gain_A = 0.1f*127/a;
    gain_B = 127*0.1f/(20000-sliderMaxValue[i]);

    if (sigI < a) {
      sigO  =  sigI * gain_A;
      if (sigO<0) sigO=0;
    } else if (sigI > b) {
      sigO  =  127 * 0.9f + (sigI - b) * gain_B;
      if ( sigO > 127) {
        sigO = 127;
      }
    } else {
      sigO =  127*0.1f + (( sigI - a ) / (b-a) )* 127 * 0.8f;
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

  public void sendToReaperBooleanSwitch() {

    this.sendToReaper =! this.sendToReaper;
  }
  public void updateValues() {

    for (int i = 0; i <  this.numberOfChannels; i++) {

      this.WWNormalizer(i);

      this.modulosOSC(i);

      this.receive[i] = PApplet.parseBoolean(PApplet.parseInt(cp5.getController(("receiveToggleName["+i+"]")).getValue()));
      this.send[i] =  PApplet.parseBoolean(PApplet.parseInt(cp5.getController(("sendToggleName["+i+"]")).getValue()));
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

  public void drawP5Modules() {

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

  public void update() {

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

  public int obetnerListaDeIPsTxtCantidad() {

    return this.IPsAndPorts.size();
  }

  public void menuDisplay() {

    this.onMenu = !this.onMenu;

    if (this.onMenu) {

      menu = new Menu(width/10, height/8);
    }
  }

  public void graficos(int canal) {

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

  public void graficosOut(int canal) {

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

  public void slidersMin(int canal) {

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

  public void slidersMax(int canal) {

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

  public void textFieldsToOut(int canal) {

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

  public void textFields(int canal) {

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

  public void toggles(int canal) {

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

  public void modulosOSC(int canal) {

    pushStyle();
    noFill();
    stroke(127 + round(inputSignal[canal]), 127, 127);
    rect(0, height/this.numberOfChannels*canal, width/2, height/this.numberOfChannels*canal);
    noStroke();

    fill(0);
    rect( width/2-width/5.5f, height/this.numberOfChannels*canal+10, 60, 20);

    fill(255, 255);
    text("["+(canal+1)+"]: "+round(inputSignal[canal]), width/2-width/5.5f, height/this.numberOfChannels*canal+24);
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

public void controlEvent(ControlEvent theEvent) {
  
  if (theEvent.getName().contains("channelIn") && frameCount > 6) {
    
    router.channelsModule.getJSONObject(theEvent.getId()).setString("channelInOSC", router.channelInValue[theEvent.getId()]);
    router.JSONConfig.setJSONArray("channels", router.channelsModule);
    saveJSONObject(router.JSONConfig, "./data/config/config.json");
    
  } 
  if (theEvent.getName().contains("channelOu") && frameCount > 6) {
    
    router.channelsModule.getJSONObject(theEvent.getId()).setString("channelOutOSC", router.channelOutValue[theEvent.getId()]);
    router.JSONConfig.setJSONArray("channels", router.channelsModule);
    saveJSONObject(router.JSONConfig, "./data/config/config.json");
    
  } 
  if (theEvent.getName().contains("send") && frameCount > 6) {
    
    boolean thisSendValue = (theEvent.getValue() > 0) ? true : false;
    router.channelsModule.getJSONObject(theEvent.getId()).setBoolean("sending", thisSendValue);
    router.JSONConfig.setJSONArray("channels", router.channelsModule);
    saveJSONObject(router.JSONConfig, "./data/config/config.json");
    
  } 
  if (theEvent.getName().contains("receiv") && frameCount > 6) {
    
    boolean thisReceiveValue = (theEvent.getValue() > 0) ? true : false;
    router.channelsModule.getJSONObject(theEvent.getId()).setBoolean("receive", thisReceiveValue);
    router.JSONConfig.setJSONArray("channels", router.channelsModule);
    saveJSONObject(router.JSONConfig, "./data/config/config.json");
    
  }
  if (theEvent.getName().contains("sliderMa") && frameCount > 6) {
    
    if ((exp(theEvent.getValue()/10)-1) <=    router.sliderMinValueLog[theEvent.getId()] ||    router.sliderMaxValue[theEvent.getId()] <=    router.sliderMinValue[theEvent.getId()]) {
      
      router.sliderMaxValue[theEvent.getId()] = router.sliderMinValue[theEvent.getId()] + 1;
      router.sliderMaxValueLog[theEvent.getId()] = router.sliderMinValueLog[theEvent.getId()] + 1;
      router.errorMode = true;
      image(icon, width/10, height/8, width/1.2f, height/1.5f);
      text("Error, corregir valores de MIN-MAX", mouseX, mouseY);
      
    } else {
      
      router.sliderMaxValueLog[theEvent.getId()] = (exp(theEvent.getValue()/10)-1);
      router.channelsModule.getJSONObject(theEvent.getId()).setFloat("sliderMax", theEvent.getValue());
      router.channelsModule.getJSONObject(theEvent.getId()).setFloat("sliderMaxLog", (exp(theEvent.getValue()/10)-1));
      router.JSONConfig.setJSONArray("channels", router.channelsModule);
      saveJSONObject(router.JSONConfig, "./data/config/config.json");
      
    }
  } 
  if (theEvent.getName().contains("sliderMi") && frameCount > 6) {
    
    if ((exp(theEvent.getValue()/10)-1) >=    router.sliderMaxValueLog[theEvent.getId()] || router.sliderMinValue[theEvent.getId()] >=    router.sliderMaxValue[theEvent.getId()]) {
      router.sliderMinValue[theEvent.getId()] = router.sliderMaxValue[theEvent.getId()]  - 1;
      router.sliderMinValueLog[theEvent.getId()] = router.sliderMaxValueLog[theEvent.getId()] - 1;
      router.errorMode = true;
      image(icon, width/10, height/8, width/1.2f, height/1.5f);
      text("Error, corregir valores de MIN-MAX", mouseX, mouseY);
      
    } else {
      
      router.sliderMinValueLog[theEvent.getId()] = (exp(theEvent.getValue()/10)-1);
      router.channelsModule.getJSONObject(theEvent.getId()).setFloat("sliderMin", theEvent.getValue());
      router.channelsModule.getJSONObject(theEvent.getId()).setFloat("sliderMinLog", (exp(theEvent.getValue()/10)-1));
      router.JSONConfig.setJSONArray("channels", router.channelsModule);
      saveJSONObject(router.JSONConfig, "./data/config/config.json");
      
    }
  }
}
NetAddress reaperAddress;
// 48 = DO // MI = 52 // SOL = 55 // SI = 59 //  

public void oscEvent(OscMessage mensaje) {

  // REGISTRAR TIEMPOS
  //<-- OBTENIENDO VALORES DE INPUT SEAN ENTEROS O FLOTANTES:

  for (int i = 0; i < router.numberOfChannels; i++) {

    if (mensaje.checkAddrPattern(router.channelInValue[i]) == true) {

      if (mensaje.checkTypetag("i")) {

        router.inputSignal[i] = mensaje.get(0).intValue();
      } else  if (mensaje.checkTypetag("f")) {

        router.inputSignal[i] = mensaje.get(0).floatValue();
      }
    }
  }

  //ENVIO --> MENSAJE A OTROS DISPOSITIVOS DE MANERA GENERICA:

  if (router.obetnerListaDeIPsTxtCantidad() > 0) {

    for (int IPIndex = 0; IPIndex < router.obetnerListaDeIPsTxtCantidad(); IPIndex++) {

      boolean isOnReaper = router.isOnReaper[IPIndex];

      if (isOnReaper == false) {

        for (int i = 0; i < router.numberOfChannels; i++) {

          if (router.receive[i] == true
            && router.send[i] == true
            && router.isOnReaper[i] == false
            && mensaje.checkAddrPattern(router.channelInValue[i]) == true) {

            OscMessage mensajeOutput = new OscMessage(router.channelOutValue[i]);
            mensajeOutput.add(router.outputSignal[i]);
            oscP5.send(mensajeOutput, router.OSCRemoteIP[IPIndex]);
            mensajeOutput.clear();
            
          }
        }
      } else if (isOnReaper == true) {

        for (int i = 0; i < router.numberOfChannels; i++) {

          if (router.send[i] == true 
            && router.receive[i] == true 
            && router.isOnReaper[i] == false
            && mensaje.checkAddrPattern(router.channelInValue[i]) == true) {

            OscMessage messageToReaper = new OscMessage("/vkb_midi/"+i+"/note/"+ router.notesToReaper[i] );
            messageToReaper.add(router.outputSignal[i]);
            oscP5.send(messageToReaper, router.OSCRemoteIP[IPIndex]);
            messageToReaper.clear();
            
          }
        }
      }
    }
  }
}


InetAddress inet;

public String currentHost() {
  
  try {
    
    inet = InetAddress.getLocalHost();
    String myIP = inet.getHostAddress();

    return  myIP;
  } 
  
  catch(Exception e) {

    return  "0.0.0.0";
  }
  
}

public void pre() {
  
  cursor();
  
  Runtime.getRuntime().runFinalization();
  
  if (width > 720 || height < 720) {

    if (router.containerWidth != width || router.containerHeight != height) {
      image(icon, width/10, height/8, width/1.2f, height/1.5f);
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
    
  }
  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "wwSpider" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
