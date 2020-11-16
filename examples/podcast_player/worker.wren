import "threads" for Parent
import "wren-sdl" for SDL
import "tasks" for Task, TaskDriver, DefaultCanceller
import "./examples/podcast_player/command" for Command
import "./examples/podcast_player/commands/all"

var queue = TaskDriver.new(DefaultCanceller)

var messageLoop = Task.repeat{|c|
  var cmd = Command.receiveAsync().await()
  var task
  if(cmd.args["hasBody"]){
    task = cmd.getTask(Parent.wait())
  } else {
    task = cmd.getTask()
  }
  queue.add(task.catch{|e| System.print("Error in command %(cmd.args["id"]):'%(e)'")})
}

while(true){
  messageLoop.step()
  queue.task.step()
  SDL.delay(15)
  System.gc()
}