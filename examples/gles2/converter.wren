import "wren-rapidxml" for XmlDocument
import "file" for File

var buffer = File.readBuffer("./assets/tiles.tmx")
var doc = XmlDocument.fromBuffer(buffer)

var map = doc.firstNode("map")

var width = map.firstAttribute("width").value()
var height = map.firstAttribute("height").value()

System.print([width, height])

var layer = map.firstNode("layer")
while(layer){
  var name = layer.firstAttribute("name").value()
  System.print(name)
  var data = layer.firstNode("data").value()
  System.print(data)
  layer = layer.nextSibling("layer")
}


