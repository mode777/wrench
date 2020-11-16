import "./examples/podcast_player/command" for Command
import "tasks" for Task
import "wren-rapidxml" for XmlDocument
import "fetch" for FetchClient
import "threads" for Parent
import "images" for Image

class Resources {
  static http { __httpClient = __httpClient || FetchClient.new() }
}

class DownloadFeedCommand is Command {
  static name { "pc.feed.download" }

  url { args["url"] }

  construct new(args){
    super(args)
  }
  construct create(url){
    args = { "id": DownloadFeedCommand.name, "url" : url }
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
      var image = imgNode != null ? imgNode.firstNode("url").value() : null
      Command.send(Command.new({ "id": "pc.feed.info", "url": url, "title": title, "description": description, "imageUrl": image}))
    }
  }
}
Command.register(DownloadFeedCommand)

class DownloadImageCommand is Command {
  static name { "pc.image.download" }

  url { args["url"] }
  imageUrl { args["imageUrl"] }
  width { args["width"] }
  height { args["height"] }

  construct new(args){
    super(args)
  }

  getTask(){
    return Task.new {
      var content = Resources.http.get(imageUrl).await()
      Command.send(Command.new({ "id":"pc.image.resize", "url": url, "hasBody": true, "width": width, "height": height}))
      Command.sendBinary(content)
    }
  }
}
Command.register(DownloadImageCommand)

class ResizeImageCommand is Command {
  static name { "pc.image.resize" }

  url { args["url"] }
  width { args["width"] }
  height { args["height"] }

  construct new(args){
    super(args)
  }

  getTask(data){
    return Task.new {
      var id = Image.fromBuffer(data)
      var resized = id.resize(width, height)
      id.dispose()
      Command.send(Command.new({ "id": "pc.rgba.loaded", "url": url, "hasBody": true, "width": width, "height": height}))
      Command.sendBinary(resized.buffer)
    }
  }
}
Command.register(ResizeImageCommand)