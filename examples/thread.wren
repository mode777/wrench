import "threads" for Thread

var threads = (0...4).map{|i| Thread.new("./examples/thread_func.wren")}.toList

while(!threads.all{|x| x.isDone }){}