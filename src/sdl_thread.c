#include <stdlib.h>
#include "./wrt_plugin.h"
#include <SDL2/SDL.h>
#include "readfile.h"

typedef struct {
  size_t size;
  char* data;
}  Buffer;

// --- Queue

typedef struct {
  int front;
  int back;
  int size;
  int capacity;
  SDL_mutex * mutex;
  Buffer* messages;
} Queue;

static Queue* queue_create(int capacity){
  Queue* q = calloc(1, sizeof(Queue));
  q->messages = calloc(capacity, sizeof(Buffer));
  q->capacity = capacity;
  q->mutex = SDL_CreateMutex();
  return q;
}

static bool queue_enqueue(Queue* q, Buffer* buffer) {
  SDL_LockMutex(q->mutex);
  if(q->size >= q->capacity){
    return false;
  }
  q->messages[q->front].data = buffer->data;
  q->messages[q->front].size = buffer->size;
  q->front = (q->front+1) % q->capacity;
  q->size++;
  SDL_UnlockMutex(q->mutex);
  return true;
}

static bool queue_dequeue(Queue* q, Buffer* buffer){
  SDL_LockMutex(q->mutex);
  if(q->size == 0){
    return false;
  }
  buffer->data = q->messages[q->back].data;
  buffer->size = q->messages[q->back].size;
  q->back = (q->back+1) % q->capacity;
  q->size--;
  SDL_UnlockMutex(q->mutex);
  return true;
}
// ----

int plugin_id;

typedef struct {
  WrenVM* creatorVm;
  WrenVM* threadVm;
  SDL_Thread* sdlThread;
  const char* script;
  const char* path;
  WrenInterpretResult result;
  Queue* creatorQueue;
  Queue* threadQueue;
} WrenThreadData;

int threadFunction( void* data )
{
  WrenThreadData* thread = (WrenThreadData*)data;
  WrenInterpretResult result = wrenInterpret(thread->threadVm, thread->path, thread->script);
  thread->result = result;
  free((void*)thread->script);
  // todo: Cleanup client
  return result;
}

static void thread_allocate(WrenVM* vm){
  WrenThreadData* data = calloc(1, sizeof(WrenThreadData));
  WrenThreadData** ptr = (WrenThreadData**)wrenSetSlotNewForeign(vm, 0,0, sizeof(WrenThreadData*));
  *ptr = data;
}

static void thread_delete(WrenVM* vm){
  // Creator is no longer interested in this thread. Release all resources on creator side
  // todo: Cleanup server part
}

static void thread_create_1(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  thread->result = (WrenInterpretResult)-1;
  thread->path = wrenGetSlotString(vm, 1);
  thread->script = read_file_string(thread->path);
  thread->creatorQueue = queue_create(BUFSIZ);
  thread->threadQueue = queue_create(BUFSIZ);
  if(thread->script == NULL){
    wren_runtime_error(vm, "Module not found");
    return;
  }
  thread->creatorVm = vm;
  thread->threadVm = wrt_new_wren_vm();
  wrt_set_plugin_data(thread->threadVm, plugin_id, (void*)thread);  

  thread->sdlThread = SDL_CreateThread( threadFunction, "WrenThread", (void*)thread );
}

static void thread_isDone(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  wrenSetSlotBool(vm, 0, thread->result != -1);
}

static void thread_result(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  wrenSetSlotDouble(vm, 0, thread->result);
}

static void parent_send_1(WrenVM* vm){
  WrenThreadData* vmData = (WrenThreadData*)wrt_get_plugin_data(vm, plugin_id);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  wrenSetSlotBool(vm, 0, queue_enqueue(vmData->creatorQueue, buffer));
  buffer->data = NULL;
  buffer->size = 0;  
}

static void thread_send_1(WrenVM* vm){
  WrenThreadData* vmData = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  wrenSetSlotBool(vm, 0, queue_enqueue(vmData->threadQueue, buffer));
  buffer->data = NULL;
  buffer->size = 0;  
}

static void parent_receive_1(WrenVM* vm){
  WrenThreadData* vmData = (WrenThreadData*)wrt_get_plugin_data(vm, plugin_id);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  bool success = queue_dequeue(vmData->threadQueue, buffer);
  wrenSetSlotBool(vm, 0, success);
}

static void thread_receive_1(WrenVM* vm){
  WrenThreadData* vmData = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  bool success = queue_dequeue(vmData->creatorQueue, buffer);
  wrenSetSlotBool(vm, 0, success);
}

static void parent_count(WrenVM* vm){
  WrenThreadData* vmData = (WrenThreadData*)wrt_get_plugin_data(vm, plugin_id);
  wrenSetSlotDouble(vm, 0, vmData->threadQueue->size);
}

static void thread_count(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  wrenSetSlotDouble(vm, 0, thread->creatorQueue->size);
}

void wrt_plugin_init(int handle){
  plugin_id = handle;
  wrt_bind_class("threads.Thread", thread_allocate, thread_delete);
  wrt_bind_method("threads.Thread.create_(_)", thread_create_1);
  wrt_bind_method("threads.Thread.isDone", thread_isDone);
  wrt_bind_method("threads.Thread.result", thread_result);
  wrt_bind_method("threads.Thread.send(_)", thread_send_1);
  wrt_bind_method("threads.Thread.receive_(_)", thread_receive_1);
  wrt_bind_method("threads.Thread.count", thread_count);
  wrt_bind_method("threads.Parent.send(_)", parent_send_1);
  wrt_bind_method("threads.Parent.receive_(_)", parent_receive_1);
  wrt_bind_method("threads.Parent.count", parent_count);
}
