import "nanovg-app" for NanovgApp
import "wren-sdl" for SdlKeyCode, SdlThread
import "wren-nanovg" for NvgColor, NvgImage, NvgPaint, ImageData
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
    _downloader = SdlThread.new("./examples/podcast_player/worker.wren")
    _resizer = SdlThread.new("./examples/podcast_player/worker.wren")
    _driver = TaskDriver.new(DefaultCanceller)
    _downloaderTask = _driver.add(Task.repeat {|c| messageLoop(_downloader) })
    _resizerTask = _driver.add(Task.repeat {|c| messageLoop(_resizer) })
    _garbageCollect = _driver.add(Task.intervall(1000){ |c| System.gc() })
    _events = EventQueue.new(256)
    _ui = PodcastUI.new(_events)
    _t = 0
    //_state = {}
    _events.subscribe("pc.feed.download"){ |e| Command.send(_downloader, Command.new(e)) }
    _events.subscribe("pc.image.download"){ |e| Command.send(_downloader, Command.new(e)) }
    _events.subscribe("pc.image.resize"){ |e| Command.send(_resizer, Command.new(e)) }

    _events.add(["pc.feed.download","https://gamenotover.de/feed/podcast/"])
    _events.add(["pc.feed.download","https://podcastd45a61.podigee.io/feed/mp3"])
    _events.add(["pc.feed.download","https://feeds.soundcloud.com/users/soundcloud:users:21436304/sounds.rss"])
  }

  messageLoop(thread){
    var cmd = Command.receiveAsync(thread).await()
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


// class RssItem {
//   construct new(node){
//     _node = node
//   }

//   node {  _node }
//   imageUrl { _node.firstNode("image").firstNode("url").value() }
//   title { _node.firstNode("title").value() }

//   nextItem() {
//     var n = _node.nextSibling()
//     if(n == null) return null
//     return RssItem.new(n)
//   }
// }

// class RssChannel {
//   construct new(xml){
//     _xml = xml
//     _node = xml.firstNode("rss").firstNode("channel")
//   }

//   imageUrl { _node.firstNode("image").firstNode("url").value() }
//   firstItem() { RssItem.new(_node.firstNode("item")) }
// }

// class MyApp is NanovgApp{
//   construct new(){
//     super(800, 480, "MyApp")
//     _http = FetchClient.new()
//     _image = null
//     _imgPaint = null
//     _box = 400
//     _channel = null
//     _r = 0
//     _t = 0
//     _last = 0
//     _http.get("https://podcastd45a61.podigee.io/feed/mp3") {|status, content|
//       var xml = XmlDocument.new(content)
//       _channel = RssChannel.new(xml)
//       _item = _channel.firstItem()
//       _http.get(_item.imageUrl){|s,c| setImage(c)}
//     }
//   }

//   update(ctx){
//     _t = _t+0.015
//     _last = _last+0.015
//     _http.update()

//     ctx.save()   
    
//     //_r = _r + 0.02
//     ctx.translate(width/2,height/2)
//     //ctx.rotate(_r)
//     ctx.scale(0.75 + ((_t*4).sin/8), 0.75 + ((_t*4).sin/8))
//     ctx.translate(-_box/2,-_box/2)
    
//     ctx.beginPath()
//     ctx.roundedRect(0,0, _box,_box, _box / 32)
    
//     if(_imagePaint == null){
//       ctx.fillColor(NvgColor.rgba(255,192,0,255))
//     } else {
//       ctx.fillPaint(_imagePaint)  
//     }
    
//     ctx.fill()
    
//     ctx.restore()

//     if(_last > 2){
//       _last = 0
//       next()
//     }
    
//     //System.gc()
//   }

//   onKey(sym, isUp){
//     if(isUp && sym == SdlKeyCode.Right){
//       next()
//     }
//   }

//   setImage(c){
//     var id = ImageData.fromMemory(c)
//     id.resize(_box,_box)
//     _image = NvgImage.fromImageData(context, id)
//     _imagePaint = NvgPaint.imagePattern(context, 0,0,_box,_box, 0, _image, 1)
//   }

//   next(){
//     if(_item == null) return
//     _item = _item.nextItem()
//     if(_item == null) return
//     _http.get(_item.imageUrl){|s,c|
//       setImage(c) 
//     }
//   }
// }

// var app = MyApp.new()