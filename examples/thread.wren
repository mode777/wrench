import "wren-sdl" for SdlThread

var threads = (0...4).map{|i| SdlThread.new("./examples/thread_func.wren")}.toList

while(!threads.all{|x| x.isDone }){}