import "./examples/podcast_player/command" for Command
import "tasks" for Task
import "wren-rapidxml" for XmlDocument
import "fetch" for FetchClient

// class FeedInfo is Command {
//   static name { "pc-fi" }

//   url { args[1] }
//   name { args[2] }
//   description { args[3] }
//   imageUrl { args[4] }

//   construct new(args){
//     super(args)
//   }
//   construct create(url, name, description, imageUrl){
//     args = [FeedInfo.name, url, name, description, imageUrl]
//   }

//   addState(state){
//     state["feeds"] = state["feeds"] || {}
//     state["feeds"][url] = { "id": url, "name": name, "description": description }
//     return true
//   }
// }
// Command.register(FeedInfo)

class DownloadFeedCommand is Command {
  static name { "pc.feed.download" }
  static http { __httpClient = __httpClient || FetchClient.new() }

  url { args[1] }

  construct new(args){
    super(args)
  }
  construct create(url){
    args = [DownloadFeedCommand.name, url]
  }

  getTask(){
    return Task.new {
      var content = DownloadFeedCommand.http.get(url).await()
      var xml = XmlDocument.new(content)
      var channel = xml.firstNode("rss").firstNode("channel")
      var title = channel.firstNode("title").value()
      var description = channel.firstNode("description").value()
      var image = channel.firstNode("image").firstNode("url").value()
      Command.send(Command.new(["pc.feed.info", url, title, description, image]))
    }
  }
}

Command.register(DownloadFeedCommand)

