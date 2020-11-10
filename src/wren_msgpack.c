#include <msgpack.h>
#include "wrt_plugin.h"

int plugin_handle;

static void pack_value(msgpack_packer* packer, WrenVM* vm, int slot);

static void pack_list(msgpack_packer* packer, WrenVM* vm, int slot){
  int count = wrenGetListCount(vm, slot);
  msgpack_pack_array(packer, count);
  wrenEnsureSlots(vm, slot+2);
  for (int i = 0; i < count; i++)
  {
    wrenGetListElement(vm, slot, i, slot+1);
    pack_value(packer, vm, slot+1);
  }  
}

static void pack_map(msgpack_packer* packer, WrenVM* vm, int slot){
  assert(false);
}

static void pack_value(msgpack_packer* packer, WrenVM* vm, int slot){
  int length;
  const char* bytes;

  switch(wrenGetSlotType(vm, slot)){
    case WREN_TYPE_BOOL:
      wrenGetSlotBool(vm ,slot) ? msgpack_pack_true(packer) : msgpack_pack_false(packer);
      break;
    case WREN_TYPE_NUM:
      msgpack_pack_double(packer, wrenGetSlotDouble(vm, slot));
      break;
    case WREN_TYPE_LIST:
      pack_list(packer, vm, slot);
      break;
    case WREN_TYPE_MAP:
      pack_map(packer, vm, slot);
      break;
    case WREN_TYPE_NULL:
      msgpack_pack_nil(packer);
      break;
    case WREN_TYPE_STRING:
      bytes = wrenGetSlotBytes(vm, slot, &length);
      msgpack_pack_bin(packer, length);
      msgpack_pack_bin_body(packer, (void*)bytes, length);
      break;
    case WREN_TYPE_FOREIGN:
    case WREN_TYPE_UNKNOWN:
      wren_runtime_error(vm, "Cannot serialize object. Only Bool, Num, List, Map, null and string are supported.");
  }
}

static void wren_msgpack_MessagePack_serialize_1(WrenVM* vm){

  msgpack_sbuffer sbuf;
  msgpack_sbuffer_init(&sbuf);

  /* serialize values into the buffer using msgpack_sbuffer_write callback function. */
  msgpack_packer pk;
  msgpack_packer_init(&pk, &sbuf, msgpack_sbuffer_write);

  pack_value(&pk, vm, 1);

  wrenSetSlotBytes(vm, 0, sbuf.data, sbuf.size);
  msgpack_sbuffer_destroy(&sbuf);
}

static void unpack_value(msgpack_object* obj, WrenVM* vm, int slot);

static void unpack_array(msgpack_object_array* obj, WrenVM* vm, int slot){
  int size = obj->size;
  wrenSetSlotNewList(vm, slot);
  wrenEnsureSlots(vm, slot+2);
  for (int i = 0; i < size; i++)
  {
    unpack_value(&obj->ptr[i], vm, slot+1);
    wrenInsertInList(vm, slot, -1, slot+1);
  }
}

static void unpack_value(msgpack_object* obj, WrenVM* vm, int slot){
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
      wrenSetSlotBytes(vm, slot, obj->via.bin.ptr, obj->via.bin.size);
      break;
    case MSGPACK_OBJECT_ARRAY:
      unpack_array(&obj->via.array, vm, slot);
      break;
    case MSGPACK_OBJECT_MAP:
      assert(false);
  }
}

static void wren_msgpack_MessagePack_deserialize_1(WrenVM* vm){
  int length;
  const char* bytes = wrenGetSlotBytes(vm, 1, &length);
  msgpack_unpacked msg;
  msgpack_unpacked_init(&msg);
  msgpack_unpack_return ret = msgpack_unpack_next(&msg, bytes, length, NULL);
  assert(ret == MSGPACK_UNPACK_SUCCESS);
  msgpack_object root = msg.data;
  unpack_value(&root, vm, 0);
  msgpack_unpacked_destroy(&msg);
}

void wrt_plugin_init(int handle){
  plugin_handle = handle;
  wrt_bind_method("wren-msgpack.MessagePack.serialize(_)", wren_msgpack_MessagePack_serialize_1);
  wrt_bind_method("wren-msgpack.MessagePack.deserialize(_)", wren_msgpack_MessagePack_deserialize_1);
}