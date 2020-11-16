import "nanovg-app" for NanovgApp
import "wren-sdl" for SdlKeyCode
import "threads" for Thread
import "wren-nanovg" for NvgColor, NvgImage, NvgPaint
import "fetch" for FetchClient
import "wren-rapidxml" for XmlDocument
import "./examples/podcast_player/command" for Command
import "./examples/podcast_player/commands/all" for DownloadFeedCommand
import "./examples/podcast_player/ui" for PodcastUI
import "tasks" for Task, TaskDriver, DefaultCanceller
import "event-queue" for EventQueue

class MyApp is NanovgApp{
  construct new(){
    super(800, 480, "MyApp")
    _driver = TaskDriver.new(DefaultCanceller)
    
    _downloader = Thread.new("./examples/podcast_player/worker.wren")
    _downloaderTask = _driver.add(Task.repeat {|c| messageLoop(_downloader) })
    
    _resizer = Thread.new("./examples/podcast_player/worker.wren")
    _resizerTask = _driver.add(Task.repeat {|c| messageLoop(_resizer) })
    
    _garbageCollect = _driver.add(Task.intervall(200){ |c| System.gc() })

    _events = EventQueue.new(256)
    _ui = PodcastUI.new(_events)
    _t = 0

    _events.subscribe("pc.feed.download"){ |e| Command.send(_downloader, Command.new(e)) }
    _events.subscribe("pc.image.download"){ |e| Command.send(_downloader, Command.new(e)) }
    _events.subscribe("pc.image.resize"){ |e|
      var data = e["data"]
      e["data"] = null
      e["hasBody"] = true  
      Command.send(_resizer, Command.new(e))
      Command.sendBinary(_resizer, data)
    }

    _events.add({"id": "pc.feed.download", "url": "https://gamenotover.de/feed/podcast/"})
    _events.add({"id": "pc.feed.download", "url": "https://podcastd45a61.podigee.io/feed/mp3"})
    _events.add({"id": "pc.feed.download", "url": "https://feeds.soundcloud.com/users/soundcloud:users:21436304/sounds.rss"})
    _events.add({"id": "pc.feed.download", "url": "https://okcool.podigee.io/feed/mp3"})
    _events.add({"id": "pc.feed.download", "url": "https://buchpodcast.libsyn.com/rss"})
    _events.add({"id": "pc.feed.download", "url": "http://younginthe80s.de/feed/"})
  }

  messageLoop(thread){
    var cmd = Command.receiveAsync(thread).await()
    if(cmd.args["hasBody"]){
      cmd.args["data"] = thread.wait()
    }
    _events.add(cmd.args)
  }

  update(ctx){
    _t = _t + 0.015
    _driver.task.step()

    var count = _events.count
    for(i in 0...count){
      _events.dispatchNext()
    }

    _ui.draw(context,0,0,width,height,_t)
  }

  
}

var app = MyApp.new()