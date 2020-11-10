#include <stdlib.h>
#include "./wrt_plugin.h"
#include <SDL2/SDL.h>
#include "readfile.h"

// --- Queue
typedef struct {
  int length;
  const char* message;
} Message;

typedef struct {
  int front;
  int back;
  int size;
  int capacity;
  SDL_mutex * mutex;
  Message* messages;
} Queue;

static Queue* queue_create(int capacity){
  Queue* q = calloc(1, sizeof(Queue));
  q->messages = calloc(capacity, sizeof(Message));
  q->capacity = capacity;
  q->mutex = SDL_CreateMutex();
  return q;
}

static bool queue_enqueue(Queue* q, char* message, int len) {
  SDL_LockMutex(q->mutex);
  if(q->size >= q->capacity){
    return false;
  }
  q->messages[q->front].message = message;
  q->messages[q->front].length = len;
  q->front = (q->front+1) % q->capacity;
  q->size++;
  SDL_UnlockMutex(q->mutex);
  return true;
}

static bool queue_dequeue(Queue* q, char** str, int* length){
  SDL_LockMutex(q->mutex);
  if(q->size == 0){
    return false;
  }
  *str = q->messages[q->back].message;
  *length = q->messages[q->back].length;
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

typedef struct {
  WrenHandle* loopHandle;
  WrenHandle* callHandle_0;
  WrenThreadData* threadInfo;
} SdlData;

static void wren_start(WrenVM* vm){
  SdlData* sd = calloc(1, sizeof(SdlData));
  sd->callHandle_0 = wrenMakeCallHandle(vm, "call()");
  // todo: avoid using this hack
  WrenThreadData* threadData = wrt_get_plugin_data(vm, plugin_id);
  if(threadData != NULL){
    sd->threadInfo = threadData;
  }
  wrt_set_plugin_data(vm, plugin_id, sd);
}

static bool success;
static WrenInterpretResult result = WREN_RESULT_COMPILE_ERROR;

static void wren_update(WrenVM* vm){
  SdlData* sd = wrt_get_plugin_data(vm, plugin_id);

  wrenEnsureSlots(vm, 1);

  if(sd->loopHandle == NULL){
    wrenSetSlotBool(vm, 0, false);
    return;
  }

  wrenSetSlotHandle(vm, 0, sd->loopHandle);
  result = wrenCall(vm, sd->callHandle_0);
  success = wrenGetSlotBool(vm, 0);

  wrenSetSlotBool(vm, 0, result == WREN_RESULT_SUCCESS && success);
}

static void wren_sdl_SdlWindow_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(SDL_Window*));
}

static void wren_sdl_SdlWindow_finalize(void* window){
  SDL_Window* win = *(SDL_Window**)window;
  if(win != NULL){
    SDL_DestroyWindow(win);
  }
}

static void wren_sdl_SdlWindow_create_4(WrenVM* vm){
  SDL_Window** window = (SDL_Window**)wrenGetSlotForeign(vm, 0);
  int w = wrenGetSlotDouble(vm,1);
  int h = wrenGetSlotDouble(vm,2);
  const char* name = wrenGetSlotString(vm, 3);
  SDL_WindowFlags flags = wrenGetSlotDouble(vm, 4);

  *window = SDL_CreateWindow(name, 
    SDL_WINDOWPOS_CENTERED, 
    SDL_WINDOWPOS_CENTERED, 
    w, 
    h,
    flags);

  if(*window == NULL){
    wren_runtime_error(vm, "Error creating Window");
  }
}

static void wren_sdl_SdlWindow_glMakeCurrent_1(WrenVM* vm){
  SDL_Window* window = *(SDL_Window**)wrenGetSlotForeign(vm, 0);
  SDL_GLContext* context = *(SDL_GLContext**)wrenGetSlotForeign(vm, 1);
  SDL_GL_MakeCurrent(window, context);
}

static void wren_sdl_SdlWindow_glSwap_0(WrenVM* vm){
  SDL_Window* window = *(SDL_Window**)wrenGetSlotForeign(vm, 0);
  SDL_GL_SwapWindow(window);
}

static void wren_sdl_SdlGlContext_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(SDL_GLContext*));
}

static void wren_sdl_SdlGlContext_finalize(void* window){
  SDL_DestroyWindow(*(SDL_Window**)window);
}

static void wren_sdl_SdlGlContext_create_1(WrenVM* vm){
  SDL_GLContext** context = (SDL_GLContext**)wrenGetSlotForeign(vm, 0);
  SDL_Window* window = *(SDL_Window**)wrenGetSlotForeign(vm, 1);
  
  *context = SDL_GL_CreateContext(window);

  if(*context == NULL){
    wren_runtime_error(vm, "Error creating context");
  }
}

static void wren_sdl_SdlEvent_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(SDL_Event));
}

static void wren_sdl_SdlEvent_finalize(void* window){
  // OK
}

static void wren_sdl_SdlEvent_type(WrenVM* vm){
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, ev->type);
}

static void wren_sdl_SdlEvent_key_isRepeat(WrenVM* vm){
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotBool(vm, 0, ev->key.repeat > 0);
}

static void wren_sdl_SdlEvent_key_sym(WrenVM* vm){
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)ev->key.keysym.sym);
}

static void wren_sdl_SdlEvent_touch_x(WrenVM* vm){
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)ev->tfinger.x);
}

static void wren_sdl_SdlEvent_touch_y(WrenVM* vm){
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)ev->tfinger.y);
}

static void wren_sdl_SDL_delay_1(WrenVM* vm){
  int delay = wrenGetSlotDouble(vm,1);
  SDL_Delay(delay);
}

static void wren_sdl_SDL_ticks(WrenVM* vm){
  wrenSetSlotDouble(vm, 0, (double)SDL_GetTicks());
}

static void wren_sdl_SDL_glSetSwapInterval_1(WrenVM* vm){
  int interval = wrenGetSlotDouble(vm,1);
  SDL_GL_SetSwapInterval(interval);
}

static void wren_sdl_SDL_glSetAttribute_2(WrenVM* vm){
  SDL_GLattr key = wrenGetSlotDouble(vm,1);
  int val = wrenGetSlotDouble(vm,2);
  SDL_GL_SetAttribute(key, val);
}

static void wren_sdl_SDL_setHint_2(WrenVM* vm){
  const char* key = wrenGetSlotString(vm,1);
  const char* value = wrenGetSlotString(vm,2);
  SDL_SetHint(key, value);
}

static void wren_sdl_SDL_pollEvent_1(WrenVM* vm){
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 1);
  bool success = SDL_PollEvent(ev);
  wrenSetSlotBool(vm, 0, success);
}

static void wren_sdl_SDL_runLoop_1(WrenVM* vm){
  SdlData* sd = wrt_get_plugin_data(vm, plugin_id);

  if(sd->loopHandle != NULL){
    wrenReleaseHandle(vm, sd->loopHandle);
  }
  sd->loopHandle = wrenGetSlotHandle(vm, 1);
}

static void wren_sdl_SDL_getMouseState_0(WrenVM* vm){
  int x,y;
  wrenEnsureSlots(vm, 2);
  SDL_GetMouseState(&x, &y);
  wrenSetSlotNewList(vm, 0);
  wrenSetSlotDouble(vm, 1, x);
  wrenInsertInList(vm, 0, -1, 1);
  wrenSetSlotDouble(vm, 1, y);
  wrenInsertInList(vm, 0, -1, 1);
}


int threadFunction( void* data )
{
  WrenThreadData* thread = (WrenThreadData*)data;
  WrenInterpretResult result = wrenInterpret(thread->threadVm, thread->path, thread->script);
  thread->result = result;
  free(thread->script);
  // todo: Cleanup client
  return result;
}

static void wren_sdl_SdlThread_allocate(WrenVM* vm){
  WrenThreadData* data = calloc(1, sizeof(WrenThreadData));
  WrenThreadData** ptr = wrenSetSlotNewForeign(vm, 0,0, sizeof(WrenThreadData*));
  *ptr = data;
}

static void wren_sdl_SdlThread_delete(WrenVM* vm){
  // Creator is no longer interested in this thread. Release all resources on creator side
  // todo: Cleanup server part
}

static void wren_sdl_SdlThread_create_1(WrenVM* vm){
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
  // todo: Avoid using this hack
  wrt_set_plugin_data(thread->threadVm, plugin_id, (void*)thread);  

  thread->sdlThread = SDL_CreateThread( threadFunction, "WrenThread", (void*)thread );
}

static void wren_sdl_SdlThread_isDone(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  wrenSetSlotBool(vm, 0, thread->result != -1);
}

static void wren_sdl_SdlThread_result(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  wrenSetSlotDouble(vm, 0, thread->result);
}

static void wren_sdl_SdlThread_sendParent_1(WrenVM* vm){
  WrenThreadData* vmData = ((SdlData*)wrt_get_plugin_data(vm, plugin_id))->threadInfo;
  int len;
  const char* bytes = wrenGetSlotBytes(vm, 1, &len);
  char* copy = malloc(len);
  memcpy(copy, bytes, len);
  wrenSetSlotBool(vm, 0, queue_enqueue(vmData->creatorQueue, copy, len));
}

static void wren_sdl_SdlThread_send_1(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  int len;
  const char* bytes = wrenGetSlotBytes(vm, 1, &len);
  char* copy = malloc(len);
  memcpy(copy, bytes, len);
  wrenSetSlotBool(vm, 0, queue_enqueue(thread->threadQueue, copy, len));
}

static void wren_sdl_SdlThread_receiveParent_0(WrenVM* vm){
  WrenThreadData* vmData = ((SdlData*)wrt_get_plugin_data(vm, plugin_id))->threadInfo;
  int len;
  char* msg;
  bool success = queue_dequeue(vmData->threadQueue, &msg, &len);
  if(success){
    wrenSetSlotBytes(vm, 0, msg, len);
    free(msg);
  } else {
    wrenSetSlotNull(vm, 0);
  }
}

static void wren_sdl_SdlThread_receive_0(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  int len;
  char* msg;
  bool success = queue_dequeue(thread->creatorQueue, &msg, &len);
  if(success){
    wrenSetSlotBytes(vm, 0, msg, len);
    free(msg);
  } else {
    wrenSetSlotNull(vm, 0);
  }
}

static void wren_sdl_SdlThread_countParent(WrenVM* vm){
  WrenThreadData* vmData = ((SdlData*)wrt_get_plugin_data(vm, plugin_id))->threadInfo;
  wrenSetSlotDouble(vm, 0, vmData->threadQueue->size);
}

static void wren_sdl_SdlThread_messageCount(WrenVM* vm){
  WrenThreadData* thread = *(WrenThreadData**)wrenGetSlotForeign(vm ,0);
  wrenSetSlotDouble(vm, 0, thread->creatorQueue->size);
}

void wrt_plugin_init(int handle){
  plugin_id = handle;
  SDL_Init(SDL_INIT_EVERYTHING);

  wrt_bind_class("wren-sdl.SdlWindow", wren_sdl_SdlWindow_allocate, wren_sdl_SdlWindow_finalize);
  wrt_bind_method("wren-sdl.SdlWindow.create_(_,_,_,_)", wren_sdl_SdlWindow_create_4);
  wrt_bind_method("wren-sdl.SdlWindow.makeCurrent(_)", wren_sdl_SdlWindow_glMakeCurrent_1);
  wrt_bind_method("wren-sdl.SdlWindow.swap()", wren_sdl_SdlWindow_glSwap_0);

  wrt_bind_class("wren-sdl.SdlGlContext", wren_sdl_SdlGlContext_allocate, wren_sdl_SdlGlContext_finalize);
  wrt_bind_method("wren-sdl.SdlGlContext.create_(_)", wren_sdl_SdlGlContext_create_1);

  wrt_bind_class("wren-sdl.SdlEvent", wren_sdl_SdlEvent_allocate, wren_sdl_SdlEvent_finalize);
  wrt_bind_method("wren-sdl.SdlEvent.type", wren_sdl_SdlEvent_type);
  wrt_bind_method("wren-sdl.SdlEvent.key_isRepeat", wren_sdl_SdlEvent_key_isRepeat);
  wrt_bind_method("wren-sdl.SdlEvent.key_sym", wren_sdl_SdlEvent_key_sym);
  wrt_bind_method("wren-sdl.SdlEvent.touch_x", wren_sdl_SdlEvent_touch_x);
  wrt_bind_method("wren-sdl.SdlEvent.touch_y", wren_sdl_SdlEvent_touch_y);

  wrt_bind_method("wren-sdl.SDL.delay(_)", wren_sdl_SDL_delay_1);
  wrt_bind_method("wren-sdl.SDL.ticks", wren_sdl_SDL_ticks);
  wrt_bind_method("wren-sdl.SDL.setSwapInterval(_)", wren_sdl_SDL_glSetSwapInterval_1);
  wrt_bind_method("wren-sdl.SDL.setAttribute(_,_)", wren_sdl_SDL_glSetAttribute_2);
  wrt_bind_method("wren-sdl.SDL.setHint(_,_)", wren_sdl_SDL_setHint_2);
  wrt_bind_method("wren-sdl.SDL.pollEvent(_)", wren_sdl_SDL_pollEvent_1);
  wrt_bind_method("wren-sdl.SDL.runLoop(_)", wren_sdl_SDL_runLoop_1);
  wrt_bind_method("wren-sdl.SDL.getMouseState()", wren_sdl_SDL_getMouseState_0);

  wrt_bind_class("wren-sdl.SdlThread", wren_sdl_SdlThread_allocate, wren_sdl_SdlThread_delete);
  wrt_bind_method("wren-sdl.SdlThread.create(_)", wren_sdl_SdlThread_create_1);
  wrt_bind_method("wren-sdl.SdlThread.isDone", wren_sdl_SdlThread_isDone);
  wrt_bind_method("wren-sdl.SdlThread.result", wren_sdl_SdlThread_result);
  wrt_bind_method("wren-sdl.SdlThread.sendParent(_)", wren_sdl_SdlThread_sendParent_1);
  wrt_bind_method("wren-sdl.SdlThread.send(_)", wren_sdl_SdlThread_send_1);
  wrt_bind_method("wren-sdl.SdlThread.receiveParent()", wren_sdl_SdlThread_receiveParent_0);
  wrt_bind_method("wren-sdl.SdlThread.receive()", wren_sdl_SdlThread_receive_0);
  wrt_bind_method("wren-sdl.SdlThread.countParent", wren_sdl_SdlThread_countParent);
  wrt_bind_method("wren-sdl.SdlThread.messageCount", wren_sdl_SdlThread_messageCount);

  wrt_wren_update_callback(wren_update);
}

void wrt_plugin_init_wren(WrenVM* vm){
  wren_start(vm);
}
