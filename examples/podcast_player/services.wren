import "threads" for Thread
import "worker" for WorkerClient
import "wren-curl" for MD5
import "tasks" for Task
import "file" for File
import "wren-rapidxml" for XmlDocument


class WorkerService {
  construct new(app){
    _downloader = WorkerClient.new(Thread.new("./examples/podcast_player/worker.wren"))
    _resizer = WorkerClient.new(Thread.new("./examples/podcast_player/worker.wren"))

    app.registerUpdate { perform() }
  }

  downloadFeed(url){ 
    return Task.new {

      var md5 = MD5.fromString(url)
      var path = "./examples/podcast_player/cache/%(md5).xml"
      if(!File.exists(path)){
        _downloader.request("pc.download", {"path": path, "url": url }).await()
      }
      System.print(path)
      var content = File.readBuffer(path)
      var xml = XmlDocument.fromBuffer(content)
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
      var response = {
        "url": url,
        "title": title,
        "description": description,
        "imageUrl": image,
        "items": []
      }

      var item = channel.firstNode("item")
      while(item){
        var title = item.firstNode("title").value()
        var description = item.firstNode("description").value()
        var link = item.firstNode("link").value()
        var map = {"title": title, "description": description, "url": link}
        response["items"].add(map)
        item = item.nextSibling("item")
      }

      xml.dispose()
      content.dispose()
      return response
    }
  }

  downloadImage(url){
    return Task.new {
      var md5 = MD5.fromString(url)
      var path = "./examples/podcast_player/cache/%(md5)"
      if(!File.exists(path)){
        _downloader.request("pc.download", {"path": path, "url": url }).await()
      }
      return path
    }
  }

  resizeImage(path, w, h){
    return Task.new {
      var target = "%(path)_%(w)x%(h).png"
      if(!File.exists(target)){
        _resizer.request("pc.resize.image", {"path": path, "target": target, "width": w, "height": h}).await()
      }
      return target
    }
  }

  perform(){
    _downloader.perform()
    _resizer.perform()
  }
}