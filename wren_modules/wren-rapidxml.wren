
foreign class XmlDocument {
  construct fromBuffer(buffer){
    parseBuffer(buffer)
  }
  foreign parseBuffer(buffer)
  foreign firstNode()
  foreign firstNode(name)
  foreign dispose()
}

foreign class XmlNode{
  foreign name()
  foreign value()
  foreign firstNode()
  foreign firstNode(name)
  foreign nextSibling()
  foreign nextSibling(name)
  foreign firstAttribute()
  foreign firstAttribute(name)
}

foreign class XmlAttribute{
  foreign value()
  foreign name()
  foreign nextAttribute()
}

class RapidXml {
  foreign static init_()
}

RapidXml.init_()