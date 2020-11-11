import "./examples/podcast_player/command" for Command
import "tasks" for Task
import "wren-rapidxml" for XmlDocument
import "fetch" for FetchClient
import "wren-sdl" for SdlThread, SDL
import "wren-nanovg" for ImageData

class Resources {
  static http { __httpClient = __httpClient || FetchClient.new() }
}

class DownloadFeedCommand is Command {
  static name { "pc.feed.download" }

  url { args[1] }

  construct new(args){
    super(args)
  }
  construct create(url){
    args = [DownloadFeedCommand.name, url]
  }

  getTask(){
    return Task.new {
      var content = Resources.http.get(url).await()
      System.print("Got feed %(url)")
      var xml = XmlDocument.new(content)
      var channel = xml.firstNode("rss").firstNode("channel")
      var title = channel.firstNode("title").value()
      var description = channel.firstNode("description").value()
      var imgNode = channel.firstNode("image")
      var next = imgNode
      while(next){ 
        next = imgNode.nextSibling("image")
        imgNode = next || imgNode 
      }
      var image = imgNode.firstNode("url").value()
      Command.send(Command.new(["pc.feed.info", url, title, description, image]))
    }
  }
}
Command.register(DownloadFeedCommand)

class DownloadImageCommand is Command {
  static name { "pc.image.download" }

  url { args[1] }
  imageUrl { args[2] }
  width { args[3] }
  height { args[4] }

  construct new(args){
    super(args)
  }

  getTask(){
    return Task.new {
      var content = Resources.http.get(imageUrl).await()
      Command.send(Command.new(["pc.image.resize", url, content, width, height]))
    }
  }
}
Command.register(DownloadImageCommand)

class ResizeImageCommand is Command {
  static name { "pc.image.resize" }

  url { args[1] }
  data { args[2] }
  width { args[3] }
  height { args[4] }

  construct new(args){
    super(args)
  }

  getTask(){
    return Task.new {
      var id = ImageData.fromMemory(data)
      id.resize(width, height)
      Command.send(Command.new(["pc.rgba.loaded", url, id.bytes, width, height]))
    }
  }
}
Command.register(ResizeImageCommand)