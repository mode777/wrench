import "wren-nanovg" for ImageData
import "fetch" for FetchClient
import "wren-rapidxml" for XmlDocument

var http = FetchClient.new()

var content = http.get("https://podcastd45a61.podigee.io/feed/mp3").getResult()
var xml = XmlDocument.new(content)
var imageUrl = xml.firstNode("rss").firstNode("channel").firstNode("image").firstNode("url").value()
var c = http.get(imageUrl).getResult()
var image = ImageData.fromMemory(c)
image.resize(512,512)
System.print("Image resized")
