#include "wrt_plugin.h"
#include<stdio.h>
#include<stdlib.h>
#include<assert.h>

int plugin_handle;

typedef struct {
  size_t size;
  char* data;
}  Buffer;


METHOD(fileOpen_3){
  const char* path = wrenGetSlotString(vm, 2);
  const char* mode = wrenGetSlotString(vm, 3);
  FILE* file = fopen(path, mode);
  if(file == NULL) wren_runtime_error(vm, "File not found");
  FILE** ptr = (FILE**)wrenSetSlotNewForeign(vm, 0, 1, sizeof(FILE*));
  *ptr = file;
}

METHOD(fileDelete_1){
  const char* path = wrenGetSlotString(vm, 1);
  int result = remove(path);
  wrenSetSlotBool(vm, 0, result == 0);
}

METHOD(fileExists_1){
  const char* path = wrenGetSlotString(vm, 1);
  FILE* file = fopen(path, "rb");
  wrenSetSlotBool(vm, 0, file != NULL);
  if(file == NULL) return; 
  fclose(file);
}

CONSTRUCTOR(fileStreamAllocate){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(FILE*));
}

#define GETFILE FILE* file = *(FILE**)wrenGetSlotForeign(vm ,0);\
  if(file == NULL) {\
    wren_runtime_error(vm, "File is closed");\
    return;\
  }\

inline static FILE* getFile(WrenVM* vm){
  FILE* file = *(FILE**)wrenGetSlotForeign(vm ,0);
  if(file == NULL) wren_runtime_error(vm, "File is closed");
  return file;
}

DESTRUCTOR(fileStreamDelete){
  FILE* file = *(FILE**)data;
  if(file != NULL) fclose(file);
}

METHOD(fileStreamSize){
  GETFILE
  long old = ftell(file);
  long numbytes;
  fseek(file, 0L, SEEK_END);
  numbytes = ftell(file);
  fseek(file, old, SEEK_SET);
  wrenSetSlotDouble(vm, 0, (double)numbytes);
}

METHOD(fileStreamPosition){
  GETFILE
  wrenSetSlotDouble(vm, 0, (double)ftell(file));
}

METHOD(fileStreamSeek_2){
  GETFILE
  long offset = wrenGetSlotDouble(vm, 1);
  int pos = wrenGetSlotDouble(vm, 2);
  fseek(file, offset, pos);
}

METHOD(fileStreamWrite_1){
  GETFILE
  int length;
  const char* bytes = wrenGetSlotBytes(vm, 1, &length);
  int written = (int)fwrite((const void*)bytes, sizeof(char), (size_t)length, file);
  wrenSetSlotDouble(vm, 0, written);
}

METHOD(fileStreamRead_1){
  GETFILE
  int size = wrenGetSlotDouble(vm, 1);
  if(size == 0){
    wrenSetSlotNull(vm, 0);
    return;
  }
  const char* mem = calloc((size_t)size, sizeof(char));
  if(mem == NULL){
    wren_runtime_error(vm, "Out of memory");
    return;
  }
  int read = (int)fread((void*)mem, sizeof(char), (size_t)size, file);
  wrenSetSlotBytes(vm, 0, mem, (size_t)read);
  free((void*)mem);
}

METHOD(fileStreamWriteBuffer_1){
  GETFILE
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  fwrite((const void*)buffer->data, sizeof(char), buffer->size, file);
}

METHOD(fileStreamReadBuffer_1){
  GETFILE
  rewind(file);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  size_t actual = fread((void*)buffer->data, sizeof(char), buffer->size, file);
}

METHOD(fileStreamClose_0){
  FILE** ptr = (FILE**)wrenGetSlotForeign(vm ,0);
  int ret = fclose(*ptr);
  if(ret != 0) {
    wren_runtime_error(vm, "Could not close file");
    return;
  }
  *ptr = NULL;
}

void wrt_plugin_init(int handle){
  plugin_handle = handle;
  wrt_bind_method("file.File.open_(_,_,_)", fileOpen_3);
  wrt_bind_method("file.File.delete(_)", fileDelete_1);
  wrt_bind_method("file.File.exists(_)", fileExists_1);
  wrt_bind_class("file.FileStream", fileStreamAllocate, fileStreamDelete);
  wrt_bind_method("file.FileStream.size", fileStreamSize);
  wrt_bind_method("file.FileStream.position", fileStreamPosition);
  wrt_bind_method("file.FileStream.seek(_,_)", fileStreamSeek_2);
  wrt_bind_method("file.FileStream.write(_)", fileStreamWrite_1);
  wrt_bind_method("file.FileStream.read(_)", fileStreamRead_1);
  wrt_bind_method("file.FileStream.writeBuffer_(_)", fileStreamWriteBuffer_1);
  wrt_bind_method("file.FileStream.readBuffer_(_)", fileStreamReadBuffer_1);
  wrt_bind_method("file.FileStream.close()", fileStreamClose_0);
}