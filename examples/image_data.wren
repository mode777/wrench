import "nanovg-app" for NanovgApp
import "wren-nanovg" for NvgColor, NvgImage, NvgPaint, ImageData
import "fetch" for FetchClient
import "wren-rapidxml" for XmlDocument

class MyApp is NanovgApp{
  construct new(){
    super(640, 480, "MyApp")
    _http = FetchClient.new()
    _image = null
    _imgPaint = null
    _box = 300
    downloadImage()

    _r = 0
  }

  downloadImage(){
    var content = _http.get("https://podcastd45a61.podigee.io/feed/mp3").getResult()
    var xml = XmlDocument.new(content)
    var imageUrl = xml.firstNode("rss").firstNode("channel").firstNode("image").firstNode("url").value()
    var image = _http.get(imageUrl).getResult()
    var imageData = ImageData.fromMemory(image)
    imageData.resize(200,200)
    _image = NvgImage.fromRgba(context, imageData.width, imageData.height, imageData.bytes)
    _imagePaint = NvgPaint.imagePattern(context, 0,0,_box,_box, 0, _image, 1)
  }

  update(ctx){
    _http.update()

    ctx.save()   
    
    _r = _r + 0.02
    ctx.translate(width/2,height/2)
    ctx.rotate(_r)
    ctx.scale(0.75 + ((System.clock*4).sin/8), 0.75 + ((System.clock*4).sin/8))
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
  }
}

var app = MyApp.new()