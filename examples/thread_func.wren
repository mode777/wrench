import "wren-nanovg" for ImageData
import "fetch" for FetchClient
import "wren-rapidxml" for XmlDocument

var http = FetchClient.new()

http.get("https://podcastd45a61.podigee.io/feed/mp3") {|status, content|
  var xml = XmlDocument.new(content)
  var imageUrl = xml.firstNode("rss").firstNode("channel").firstNode("image").firstNode("url").value()
  http.get(imageUrl){|s,c|
    var image = ImageData.fromMemory(c)
    image.resize(512,512)
    System.print("Image resized")
  }
}

while(http.requests > 0){
  http.update()
}

