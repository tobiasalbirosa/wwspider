void oscEvent(OscMessage mensaje) {
  if (router.obetnerListaDeIPsTxtCantidad() > 0) {
    for (int IPIndex = 1; IPIndex < router.obetnerListaDeIPsTxtCantidad(); IPIndex++) {
      obj[IPIndex] = router.IPList[IPIndex];
      oscP5.send(mensaje, IPRemoto[IPIndex]);
    }
  }
  for (int i = 0; i < router.numberOfChannels; i++) {
    if (mensaje.checkAddrPattern(router.channelInValue[i]) == true  && router.receive[i] == true) {
      router.originalValue[i] = mensaje.get(0).floatValue();
    }
  }
  router.messageToWWW = 
    router.result[0]+
    "/"+router.result[1]+
    "/"+router.result[2]+
    "/"+router.result[3]+
    "/"+router.result[4]+
    "/"+router.result[5]+
    "/"+router.result[6]+
    "/"+router.result[7]+
    "/"+router.result[3]+
    "/"+ router.result[4];
  myMessage.add(router.messageToWWW);
  oscP5.send(myMessage, IPRemoto[0]);
  myMessage.clear();
}
