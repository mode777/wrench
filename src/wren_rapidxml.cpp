#include "./wrt_plugin.h"
#include <rapidxml.hpp>

// TODO: ERROR HANDLING!!!

extern "C" {

using namespace rapidxml;

#define FOREIGN_CLASS(WREN, C, INIT, DELETE) \
static void wren_rapidxml_##WREN##_allocate(WrenVM* vm){ \
  C** ptr = (C**)wrenSetSlotNewForeign(vm, 0, 0, sizeof(C*)); \
  INIT\
} \
static void wren_rapidxml_##WREN##_delete(void* data){ \
  C** ptr = (C**)data; \
  DELETE \
} 

static WrenHandle* xmlNodeClass;
static WrenHandle* xmlAttributeClass;

FOREIGN_CLASS(XmlAttribute, xml_attribute<>,,)

static xml_attribute<>** create_attribute(WrenVM* vm){
  wrenSetSlotHandle(vm, 0, xmlAttributeClass);
  wren_rapidxml_XmlAttribute_allocate(vm);
  return (xml_attribute<>**)wrenGetSlotForeign(vm, 0);
}

static void wren_rapidxml_XmlAttribute_name_0(WrenVM* vm){
  xml_attribute<>* attribute = *(xml_attribute<>**)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, attribute->name());
}

static void wren_rapidxml_XmlAttribute_value_0(WrenVM* vm){
  xml_attribute<>* attribute = *(xml_attribute<>**)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, attribute->value());
}

static void wren_rapidxml_XmlAttribute_nextAttribute_0(WrenVM* vm){
  xml_attribute<>* attribute = *(xml_attribute<>**)wrenGetSlotForeign(vm, 0);
  xml_attribute<>* next = attribute->next_attribute();
  if(next == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    xml_attribute<>** attributePtr = create_attribute(vm);
    *attributePtr = next;
  }  
}

FOREIGN_CLASS(XmlNode, xml_node<>,,)

static xml_node<>** create_node(WrenVM* vm){
  wrenSetSlotHandle(vm, 0, xmlNodeClass);
  wren_rapidxml_XmlNode_allocate(vm);
  return (xml_node<>**)wrenGetSlotForeign(vm, 0);
}

static void wren_rapidxml_XmlNode_name_0(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, node->name());
}

static void wren_rapidxml_XmlNode_value_0(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, node->value());
}

static void wren_rapidxml_XmlNode_firstNode_0(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  xml_node<>* first = node->first_node();
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    xml_node<>** nodePtr = create_node(vm);
    *nodePtr = first;
  }  
}

static void wren_rapidxml_XmlNode_firstNode_1(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_node<>* first = node->first_node(str);
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    xml_node<>** nodePtr = create_node(vm);
    *nodePtr = first;
  }  
}

static void wren_rapidxml_XmlNode_nextSibling_0(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  xml_node<>* next = node->next_sibling();
  if(next == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    xml_node<>** nodePtr = create_node(vm);
    *nodePtr = next;
  }  
}

static void wren_rapidxml_XmlNode_firstAttribute_0(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  xml_attribute<>* first = node->first_attribute();
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    xml_attribute<>** attributePtr = create_attribute(vm);
    *attributePtr = first;
  }  
}

static void wren_rapidxml_XmlNode_firstAttribute_1(WrenVM* vm){
  xml_node<>* node = *(xml_node<>**)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_attribute<>* first = node->first_attribute(str);
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    xml_attribute<>** attributePtr = create_attribute(vm);
    *attributePtr = first;
  }  
}

FOREIGN_CLASS(XmlDocument, xml_document<>,*ptr = new xml_document<>;,if(*ptr != NULL) { (*ptr)->clear(); })

static void wren_rapidxml_XmlDocument_parse_1(WrenVM* vm){
  xml_document<>* doc = *(xml_document<>**)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  doc->parse<0>(str);
}

static void wren_rapidxml_XmlDocument_firstNode_0(WrenVM* vm){
  xml_document<>* doc = *(xml_document<>**)wrenGetSlotForeign(vm, 0);
  xml_node<>** nodePtr = create_node(vm);
  *nodePtr = doc->first_node();
}

static void wren_rapidxml_XmlDocument_firstNode_1(WrenVM* vm){
  xml_document<>* doc = *(xml_document<>**)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_node<>** nodePtr = create_node(vm);
  *nodePtr = doc->first_node(str);
}

static void wren_rapidxml_RapidXml_init__0(WrenVM* vm){
  wrenEnsureSlots(vm, 1);

  wrenGetVariable(vm, "wren-rapidxml", "XmlNode", 0);
  xmlNodeClass = wrenGetSlotHandle(vm, 0);

  wrenGetVariable(vm, "wren-rapidxml", "XmlAttribute", 0);
  xmlAttributeClass = wrenGetSlotHandle(vm, 0);
}

  void wrt_plugin_init(){
    wrt_bind_class("wren-rapidxml.XmlDocument", wren_rapidxml_XmlDocument_allocate, wren_rapidxml_XmlDocument_delete);
    wrt_bind_method("wren-rapidxml.XmlDocument.parse(_)", wren_rapidxml_XmlDocument_parse_1);
    wrt_bind_method("wren-rapidxml.XmlDocument.firstNode()", wren_rapidxml_XmlDocument_firstNode_0);
    wrt_bind_method("wren-rapidxml.XmlDocument.firstNode(_)", wren_rapidxml_XmlDocument_firstNode_1);

    wrt_bind_class("wren-rapidxml.XmlNode", wren_rapidxml_XmlNode_allocate, wren_rapidxml_XmlNode_delete);
    wrt_bind_method("wren-rapidxml.XmlNode.name()", wren_rapidxml_XmlNode_name_0);
    wrt_bind_method("wren-rapidxml.XmlNode.value()", wren_rapidxml_XmlNode_value_0);
    wrt_bind_method("wren-rapidxml.XmlNode.firstNode()", wren_rapidxml_XmlNode_firstNode_0);
    wrt_bind_method("wren-rapidxml.XmlNode.firstNode(_)", wren_rapidxml_XmlNode_firstNode_1);
    wrt_bind_method("wren-rapidxml.XmlNode.nextSibling()", wren_rapidxml_XmlNode_nextSibling_0);
    wrt_bind_method("wren-rapidxml.XmlNode.firstAttribute()", wren_rapidxml_XmlNode_firstAttribute_0);
    wrt_bind_method("wren-rapidxml.XmlNode.firstAttribute(_)", wren_rapidxml_XmlNode_firstAttribute_1);
    
    wrt_bind_class("wren-rapidxml.XmlAttribute", wren_rapidxml_XmlAttribute_allocate, wren_rapidxml_XmlAttribute_delete);
    wrt_bind_method("wren-rapidxml.XmlAttribute.name()", wren_rapidxml_XmlAttribute_name_0);
    wrt_bind_method("wren-rapidxml.XmlAttribute.value()", wren_rapidxml_XmlAttribute_value_0);
    wrt_bind_method("wren-rapidxml.XmlAttribute.nextAttribute()", wren_rapidxml_XmlAttribute_nextAttribute_0);

    wrt_bind_method("wren-rapidxml.RapidXml.init_()", wren_rapidxml_RapidXml_init__0);

  }
}
