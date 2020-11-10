import "wren-sdl" for SdlThread, SDL
import "fetch" for FetchClient
import "wren-curl" for CURL
import "tasks" for Task, TaskDriver, DefaultCanceller
import "./examples/podcast_player/command" for Command
import "./examples/podcast_player/commands/all"

var queue = TaskDriver.new(DefaultCanceller)
var http = FetchClient.new()

var messageLoop = Task.repeat{|c|
  var cmd = Command.receiveAsync().await()
  queue.add(cmd.getTask())
}

while(true){
  messageLoop.step()
  queue.task.step()
  //SDL.delay(100)
}