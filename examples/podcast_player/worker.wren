import "wren-sdl" for SdlThread, SDL
import "tasks" for Task, TaskDriver, DefaultCanceller
import "./examples/podcast_player/command" for Command
import "./examples/podcast_player/commands/all"

var queue = TaskDriver.new(DefaultCanceller)

var messageLoop = Task.repeat{|c|
  var cmd = Command.receiveAsync().await()
  queue.add(cmd.getTask().catch{|e| System.print("Error in command %(cmd.args[0]):'%(e)'")})
}

while(true){
  messageLoop.step()
  queue.task.step()
  SDL.delay(1)
}