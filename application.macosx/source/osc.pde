NetAddress reaperAddress;
// 48 = DO // MI = 52 // SOL = 55 // SI = 59 //  

void oscEvent(OscMessage mensaje) {

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
