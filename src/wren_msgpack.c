#include <msgpack.h>
#include "wrt_plugin.h"

int plugin_handle;

typedef struct {
  msgpack_sbuffer buffer;
  msgpack_packer packer;
} Serializer;

typedef struct {
  size_t size;
  char* data;
} Buffer;

static void unpack_value(msgpack_object* obj, WrenVM* vm, int slot, WrenHandle* bufferClass);

static void unpack_array(msgpack_object_array* obj, WrenVM* vm, int slot, WrenHandle* bufferClass){
  int size = obj->size;
  wrenSetSlotNewList(vm, slot);
  wrenEnsureSlots(vm, slot+2);
  for (int i = 0; i < size; i++)
  {
    unpack_value(&obj->ptr[i], vm, slot+1, bufferClass);
    wrenInsertInList(vm, slot, -1, slot+1);
  }
}

static void unpack_map(msgpack_object_map* obj, WrenVM* vm, int slot, WrenHandle* bufferClass){
  int size = obj->size;
  wrenSetSlotNewMap(vm, slot);
  wrenEnsureSlots(vm, slot+3);
  for (int i = 0; i < size; i++)
  {
    unpack_value(&obj->ptr[i].key, vm, slot+1, bufferClass);
    unpack_value(&obj->ptr[i].val, vm, slot+2, bufferClass);
    wrenSetMapValue(vm, slot, slot+1, slot+2);
  }
}

static void unpack_value(msgpack_object* obj, WrenVM* vm, int slot, WrenHandle* bufferClass){
  switch(obj->type){
    case MSGPACK_OBJECT_NIL:
    case MSGPACK_OBJECT_EXT:
      wrenSetSlotNull(vm, slot);
      break;
    case MSGPACK_OBJECT_BOOLEAN:
      wrenSetSlotBool(vm, slot, obj->via.boolean);
      break;
    case MSGPACK_OBJECT_POSITIVE_INTEGER:
      wrenSetSlotDouble(vm, slot, (double)obj->via.u64);
      break;
    case MSGPACK_OBJECT_NEGATIVE_INTEGER:
      wrenSetSlotDouble(vm, slot, (double)obj->via.i64);
      break;
    case MSGPACK_OBJECT_FLOAT32:
    case MSGPACK_OBJECT_FLOAT64:
      wrenSetSlotDouble(vm, slot, (double)obj->via.f64);
      break;
    case MSGPACK_OBJECT_STR:
      wrenSetSlotBytes(vm, slot, obj->via.str.ptr, obj->via.str.size);
      break;
    case MSGPACK_OBJECT_BIN:
      wrenSetSlotHandle(vm, slot, bufferClass);
      Buffer* buffer = (Buffer*)wrenSetSlotNewForeign(vm, slot, slot, sizeof(Buffer));
      buffer->data = (char*)obj->via.bin.ptr;
      buffer->size = obj->via.bin.size;
      break;
    case MSGPACK_OBJECT_ARRAY:
      unpack_array(&obj->via.array, vm, slot, bufferClass);
      break;
    case MSGPACK_OBJECT_MAP:
      unpack_map(&obj->via.map, vm, slot, bufferClass);
      break;
    default:
      wren_runtime_error(vm, "Cannot deserialize unsupported object");
  }
}

static void serializer_init(Serializer* s){
  msgpack_sbuffer_init(&s->buffer);
  msgpack_packer_init(&s->packer, &s->buffer, msgpack_sbuffer_write);
}

static void serializer_allocate(WrenVM* vm){
  Serializer* serializer = (Serializer*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(Serializer));
  serializer_init(serializer);
}

static void serializer_delete(void* data){
  Serializer* serializer = (Serializer*)data;
  if(serializer->buffer.data != NULL) free(serializer->buffer.data);
}

static void serializer_getBuffer_1(WrenVM* vm){
  Serializer* serializer = (Serializer*)wrenGetSlotForeign(vm, 0);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  // Be aware that the amount of memory allocated might be larger than size
  // however the surplus will be cleared when the buffer is freed.
  // Alternative would be to copy the memory before putting it into the buffer.
  buffer->data = serializer->buffer.data;
  buffer->size = serializer->buffer.size;
  serializer_init(serializer);
}

static void serializer_packList_1(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  size_t size = wrenGetSlotDouble(vm, 1);
  msgpack_pack_array(packer, size);
}

static void serializer_packMap_1(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  size_t size = wrenGetSlotDouble(vm, 1);
  msgpack_pack_map(packer, size);
}

static void serializer_packBool_1(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  bool val = wrenGetSlotBool(vm, 1);
  val ? msgpack_pack_true(packer) : msgpack_pack_false(packer);
}

static void serializer_packDouble_1(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  double val = wrenGetSlotDouble(vm, 1);
  msgpack_pack_double(packer, val);
}

static void serializer_packNull_0(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  msgpack_pack_nil(packer);
}

static void serializer_packBuffer_1(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  msgpack_pack_bin(packer, buffer->size);
  msgpack_pack_bin_body(packer, buffer->data, buffer->size);
}

static void serializer_packString_1(WrenVM* vm){
  msgpack_packer* packer = &((Serializer*)wrenGetSlotForeign(vm, 0))->packer;
  int size;
  const char* str = wrenGetSlotBytes(vm, 1, &size);
  msgpack_pack_str(packer, size);
  msgpack_pack_str_body(packer, str, (size_t)size);
}

static void deserializer_allocate(WrenVM* vm){
  msgpack_unpacked* unpacked = (msgpack_unpacked*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(msgpack_unpacked));
  msgpack_unpacked_init(unpacked);
}

static void deserializer_delete(void* data){
  msgpack_unpacked_destroy((msgpack_unpacked*)data);
}

static void deserializer_deserialize_2(WrenVM* vm){
  msgpack_unpacked* unpacked = (msgpack_unpacked*)wrenGetSlotForeign(vm, 0);
  WrenHandle* handle = wrenGetSlotHandle(vm, 1);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 2);
  msgpack_unpack_return ret = msgpack_unpack_next(unpacked, buffer->data, buffer->size, NULL);
  if(ret != MSGPACK_UNPACK_SUCCESS){
    wren_runtime_error(vm, "Unable to deserialize data");
    wrenReleaseHandle(vm, handle);
  }
  unpack_value(&unpacked->data, vm, 0, handle);
  wrenReleaseHandle(vm, handle);
}

void wrt_plugin_init(int handle){
  plugin_handle = handle;
  
  wrt_bind_class("wren-msgpack.Serializer", serializer_allocate, serializer_delete);
  wrt_bind_method("wren-msgpack.Serializer.getBuffer_(_)", serializer_getBuffer_1);
  wrt_bind_method("wren-msgpack.Serializer.packList_(_)", serializer_packList_1);
  wrt_bind_method("wren-msgpack.Serializer.packMap_(_)", serializer_packMap_1);
  wrt_bind_method("wren-msgpack.Serializer.packBool_(_)", serializer_packBool_1);
  wrt_bind_method("wren-msgpack.Serializer.packDouble_(_)", serializer_packDouble_1);
  wrt_bind_method("wren-msgpack.Serializer.packNull_()", serializer_packNull_0);
  wrt_bind_method("wren-msgpack.Serializer.packBuffer_(_)", serializer_packBuffer_1);
  wrt_bind_method("wren-msgpack.Serializer.packString_(_)", serializer_packString_1);

  wrt_bind_class("wren-msgpack.Deserializer", deserializer_allocate, deserializer_delete);
  wrt_bind_method("wren-msgpack.Deserializer.deserialize_(_,_)", deserializer_deserialize_2);

}