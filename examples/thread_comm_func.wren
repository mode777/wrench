import "wren-sdl" for SdlThread

var message
while(message != "kill"){
  message = SdlThread.waitParent()
  SdlThread.sendParent("You wrote: %(message)")
}
