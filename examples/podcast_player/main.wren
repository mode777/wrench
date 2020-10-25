import "nanovg-app" for NanovgApp
import "wren-sdl" for SdlKeyCode
import "wren-nanovg" for NvgColor, NvgImage, NvgPaint
import "fetch" for FetchClient
import "wren-rapidxml" for XmlDocument

class RssItem {
  construct new(node){
    _node = node
  }

  imageUrl { _node.firstNode("image").firstNode("url").value() }

  nextItem() {
    var n = _node.nextSibling()
    if(n == null) return null
    return RssItem.new(n)
  }
}

class RssChannel {
  construct new(xml){
    _xml = xml
    _node = xml.firstNode("rss").firstNode("channel")
  }

  imageUrl { _node.firstNode("image").firstNode("url").value() }
  firstItem() { RssItem.new(_node.firstNode("item")) }
}

class MyApp is NanovgApp{
  construct new(){
    super(800, 480, "MyApp")
    _http = FetchClient.new()
    _image = null
    _imgPaint = null
    _box = 400
    _channel = null
    _r = 0
    _t = 0
    _http.get("https://podcastd45a61.podigee.io/feed/mp3") {|status, content|
      var xml = XmlDocument.new(content)
      _channel = RssChannel.new(xml)
      _item = _channel.firstItem()
      _http.get(_item.imageUrl){|s,c| setImage(c)}
    }
  }

  update(ctx){
    _t = _t+0.015
    _http.update()

    ctx.save()   
    
    //_r = _r + 0.02
    ctx.translate(width/2,height/2)
    //ctx.rotate(_r)
    ctx.scale(0.75 + ((_t*4).sin/8), 0.75 + ((_t*4).sin/8))
    ctx.translate(-_box/2,-_box/2)
    
    ctx.beginPath()
    ctx.roundedRect(0,0, _box,_box, _box / 32)
    
    if(_imagePaint == null){
      ctx.fillColor(NvgColor.rgba(255,192,0,255))
    } else {
      ctx.fillPaint(_imagePaint)  
    }
    
    ctx.fill()
    
    ctx.restore()
    //System.gc()
  }

  onKey(sym, isUp){
    if(isUp && sym == SdlKeyCode.Right){
      next()
    }
  }

  setImage(c){
    _image = NvgImage.fromMemory(context, c)
    _imagePaint = NvgPaint.imagePattern(context, 0,0,_box,_box, 0, _image, 1)
  }

  next(){
    if(_item == null) return
    _item = _item.nextItem()
    if(_item == null) return
    _http.get(_item.imageUrl){|s,c| setImage(c) }
  }
}

var app = MyApp.new()