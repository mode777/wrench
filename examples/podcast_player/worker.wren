import "worker" for WorkerServer
import "./examples/podcast_player/handlers" for Handlers
import "wren-sdl" for SDL

var consumer = WorkerServer.new(Handlers)

while(true){
  consumer.perform()
  SDL.delay(30)
}

