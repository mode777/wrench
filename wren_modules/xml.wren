import "wren-rapidxml" for XmlDocument

class Xml {
  static parse(str){
    var map = {}
    var doc = XmlDocument.new()
    doc.parse(str)
    Xml.traverse(map, doc.firstNode())
    return map
  }

  static traverse(parent, node){
    var name = node.name()
    if(name == "") return
    
    var map = { "value": node.value() }
    var attr = node.firstAttribute()
    while(attr != null){
      map[attr.name()] = attr.value()
      attr = attr.nextAttribute()
    }

    if(parent[name] == null){
      parent[name] = [map]     
    } else {
      parent[name].add(map)
    }

    var c = node.firstNode()
    if(c != null) Xml.traverse(map, c)
    var s = node.nextSibling()
    if(s != null) Xml.traverse(parent, s)
  }
}
