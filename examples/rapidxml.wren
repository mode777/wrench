import "wren-rapidxml" for XmlDocument
import "fetch" for FetchClient

class XmlUtils {
  static traverse(node){
    if(node.name() == "") return
    System.print("Node: %(node.name()), %(node.value())")
    var attr = node.firstAttribute()
    while(attr != null){
      System.print("Attribute: %(attr.name()), %(attr.value())")
      attr = attr.nextAttribute()
    }
    var c = node.firstNode()
    if(c != null) XmlUtils.traverse(c)
    var s = node.nextSibling()
    if(s != null) XmlUtils.traverse(s)
  }
}

var http = FetchClient.new()
var content = http.get("https://podcastd45a61.podigee.io/feed/mp3").getResult()
var doc = XmlDocument.new(content)
XmlUtils.traverse(doc.firstNode())

