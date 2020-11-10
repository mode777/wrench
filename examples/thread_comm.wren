import "wren-sdl" for SdlThread

class Helpers {
  static delay(s){
    var t = System.clock
    while(System.clock - t < s) {}
  }
}

var t = SdlThread.new("./examples/thread_comm_func.wren")
t.send("Hello")
t.send("World")
t.send("kill")
Helpers.delay(1)
System.print(t.waitMessage())
System.print(t.waitMessage())
t.wait()
