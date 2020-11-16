#include <rapidxml.hpp>
#include <stdlib.h>
#include "./wrt_plugin.h"

// TODO: ERROR HANDLING!!!

extern "C" {


typedef struct {
  size_t size;
  char* data;
}  Buffer;

using namespace rapidxml;

#define FOREIGN_CLASS(WREN, C, INIT, DELETE) \
\
typedef struct {\
  C* obj;\
  WrenHandle* handle;\
  WrenVM* vm;\
} WREN##Data;\
\
static void wren_rapidxml_##WREN##_allocate(WrenVM* vm){ \
  WREN##Data* ptr = (WREN##Data*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(WREN##Data)); \
  ptr->vm = vm;\
  INIT\
} \
static void wren_rapidxml_##WREN##_delete(void* data){ \
  /*puts("Delete " #WREN);*/\
  WREN##Data* ptr = (WREN##Data*)data; \
  if(ptr->handle != NULL) wrenReleaseHandle(ptr->vm, ptr->handle);\
  DELETE \
} 

int plugin_id;

typedef struct {
  WrenHandle* xmlNodeClass;
  WrenHandle* xmlAttributeClass;
} RapidXmlData;

FOREIGN_CLASS(XmlAttribute, xml_attribute<>,,)

static XmlAttributeData* create_attribute_data(WrenVM* vm, xml_attribute<>* attr){
  RapidXmlData* rd = (RapidXmlData*)wrt_get_plugin_data(vm, plugin_id); 

  WrenHandle* handle = wrenGetSlotHandle(vm, 0);
  wrenSetSlotHandle(vm, 0, rd->xmlAttributeClass);
  wren_rapidxml_XmlAttribute_allocate(vm);
  XmlAttributeData* new_data = (XmlAttributeData*)wrenGetSlotForeign(vm, 0);
  new_data->handle = handle;
  new_data->obj = attr;
  return new_data;
}

static void wren_rapidxml_XmlAttribute_name_0(WrenVM* vm){
  XmlAttributeData* data = (XmlAttributeData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, data->obj->name());
}

static void wren_rapidxml_XmlAttribute_value_0(WrenVM* vm){
  XmlAttributeData* data = (XmlAttributeData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, data->obj->value());
}

static void wren_rapidxml_XmlAttribute_nextAttribute_0(WrenVM* vm){
  XmlAttributeData* data = (XmlAttributeData*)wrenGetSlotForeign(vm, 0);
  xml_attribute<>* next = data->obj->next_attribute();
  if(next == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_attribute_data(vm, next);
  }  
}

FOREIGN_CLASS(XmlNode, xml_node<>,,)

static XmlNodeData* create_node_data(WrenVM* vm, xml_node<>* node){
  RapidXmlData* rd = (RapidXmlData*)wrt_get_plugin_data(vm, plugin_id); 
  WrenHandle* handle = wrenGetSlotHandle(vm, 0);
  wrenSetSlotHandle(vm, 0, rd->xmlNodeClass);
  wren_rapidxml_XmlNode_allocate(vm);
  XmlNodeData* new_data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  new_data->handle = handle;
  new_data->obj = node;
  return new_data;
}

static void wren_rapidxml_XmlNode_name_0(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, data->obj->name());
}

static void wren_rapidxml_XmlNode_value_0(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotString(vm, 0, data->obj->value());
}

static void wren_rapidxml_XmlNode_firstNode_0(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  xml_node<>* first = data->obj->first_node();
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_node_data(vm, first);
  }  
}

static void wren_rapidxml_XmlNode_firstNode_1(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_node<>* first = data->obj->first_node(str);
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_node_data(vm, first);
  }  
}

static void wren_rapidxml_XmlNode_nextSibling_0(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  xml_node<>* next = data->obj->next_sibling();
  if(next == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_node_data(vm, next);
  }  
}

static void wren_rapidxml_XmlNode_nextSibling_1(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_node<>* next = data->obj->next_sibling(str);
  if(next == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_node_data(vm, next);
  }  
}

static void wren_rapidxml_XmlNode_firstAttribute_0(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  xml_attribute<>* first = data->obj->first_attribute();
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_attribute_data(vm, first);
  }  
}

static void wren_rapidxml_XmlNode_firstAttribute_1(WrenVM* vm){
  XmlNodeData* data = (XmlNodeData*)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_attribute<>* first = data->obj->first_attribute(str);
  if(first == NULL){
    wrenSetSlotNull(vm, 0);
  }
  else {
    create_attribute_data(vm, first);
  }  
}

FOREIGN_CLASS(XmlDocument, xml_document<>,ptr->obj = new xml_document<>;,if(ptr->obj != NULL) { ptr->obj->clear(); })

static void wren_rapidxml_XmlDocument_parse_1(WrenVM* vm){
  XmlDocumentData* data = (XmlDocumentData*)wrenGetSlotForeign(vm, 0);
  //lock buffer in place
  data->handle = wrenGetSlotHandle(vm, 1);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  data->obj->parse<0>(buffer->data);
}

static void wren_rapidxml_XmlDocument_firstNode_0(WrenVM* vm){
  XmlDocumentData* data = (XmlDocumentData*)wrenGetSlotForeign(vm, 0);
  xml_node<>* node = data->obj->first_node();
  create_node_data(vm, node);
}

static void wren_rapidxml_XmlDocument_firstNode_1(WrenVM* vm){
  XmlDocumentData* data = (XmlDocumentData*)wrenGetSlotForeign(vm, 0);
  char* str = (char*)wrenGetSlotString(vm, 1);
  xml_node<>* node = data->obj->first_node(str);
  create_node_data(vm, node);
}

static void wren_rapidxml_RapidXml_init__0(WrenVM* vm){
  RapidXmlData* rd = (RapidXmlData*)calloc(1, sizeof(RapidXmlData));

  wrenEnsureSlots(vm, 1);

  wrenGetVariable(vm, "wren-rapidxml", "XmlNode", 0);
  rd->xmlNodeClass = wrenGetSlotHandle(vm, 0);

  wrenGetVariable(vm, "wren-rapidxml", "XmlAttribute", 0);
  rd->xmlAttributeClass = wrenGetSlotHandle(vm, 0);

  wrt_set_plugin_data(vm, plugin_id, rd);
}

  void wrt_plugin_init(int handle){
    plugin_id = handle;

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
    wrt_bind_method("wren-rapidxml.XmlNode.nextSibling(_)", wren_rapidxml_XmlNode_nextSibling_1);
    wrt_bind_method("wren-rapidxml.XmlNode.firstAttribute()", wren_rapidxml_XmlNode_firstAttribute_0);
    wrt_bind_method("wren-rapidxml.XmlNode.firstAttribute(_)", wren_rapidxml_XmlNode_firstAttribute_1);
    
    wrt_bind_class("wren-rapidxml.XmlAttribute", wren_rapidxml_XmlAttribute_allocate, wren_rapidxml_XmlAttribute_delete);
    wrt_bind_method("wren-rapidxml.XmlAttribute.name()", wren_rapidxml_XmlAttribute_name_0);
    wrt_bind_method("wren-rapidxml.XmlAttribute.value()", wren_rapidxml_XmlAttribute_value_0);
    wrt_bind_method("wren-rapidxml.XmlAttribute.nextAttribute()", wren_rapidxml_XmlAttribute_nextAttribute_0);

    wrt_bind_method("wren-rapidxml.RapidXml.init_()", wren_rapidxml_RapidXml_init__0);
  }
}
