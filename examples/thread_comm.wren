import "threads" for Thread

class Helpers {
  static delay(s){
    var t = System.clock
    while(System.clock - t < s) {}
  }
}

var t = Thread.new("./examples/thread_comm_func.wren")
t.sendString("Hello")
t.sendString("World")
t.sendString("kill")
Helpers.delay(1)
System.print(t.waitString())
System.print(t.waitString())
t.wait()
