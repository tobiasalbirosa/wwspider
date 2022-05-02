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
      image(icon, width/10, height/8, width/1.2, height/1.5);
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
      image(icon, width/10, height/8, width/1.2, height/1.5);
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
