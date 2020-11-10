import "./examples/podcast_player/command" for Command
import "tasks" for Task

class SayCommand is Command {
  static name { "pc-say" }

  text { args[1] }

  construct new(args){
    super(args)
  }
  construct create(text){
    args = [SayCommand.name, text]
  }

  getTask(){
    return Task.new {
      System.print(text)
    }
  }
}

Command.register(SayCommand)

