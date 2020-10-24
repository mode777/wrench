#include "./wrt_plugin.h"
#include <SDL2/SDL.h>

static WrenHandle* loopHandle;
static WrenHandle* callHandle_0;

static void wren_start(WrenVM* vm){
  callHandle_0 = wrenMakeCallHandle(vm, "call()");
}

static bool success;
static WrenInterpretResult result = WREN_RESULT_COMPILE_ERROR;

static void wren_update(WrenVM* vm){
  wrenEnsureSlots(vm, 1);

  if(loopHandle == NULL){
    wrenSetSlotBool(vm, 0, false);
    return;
  }

  wrenSetSlotHandle(vm, 0, loopHandle);
  result = wrenCall(vm, callHandle_0);
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
  if(loopHandle != NULL){
    wrenReleaseHandle(vm, loopHandle);
  }
  loopHandle = wrenGetSlotHandle(vm, 1);
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


void wrt_plugin_init(){
  SDL_Init(SDL_INIT_EVERYTHING);

  wrt_bind_class("wren-sdl.SdlWindow", wren_sdl_SdlWindow_allocate, wren_sdl_SdlWindow_finalize);
  wrt_bind_method("wren-sdl.SdlWindow.create_(_,_,_,_)", wren_sdl_SdlWindow_create_4);
  wrt_bind_method("wren-sdl.SdlWindow.makeCurrent(_)", wren_sdl_SdlWindow_glMakeCurrent_1);
  wrt_bind_method("wren-sdl.SdlWindow.swap()", wren_sdl_SdlWindow_glSwap_0);

  wrt_bind_class("wren-sdl.SdlGlContext", wren_sdl_SdlGlContext_allocate, wren_sdl_SdlGlContext_finalize);
  wrt_bind_method("wren-sdl.SdlGlContext.create_(_)", wren_sdl_SdlGlContext_create_1);

  wrt_bind_class("wren-sdl.SdlEvent", wren_sdl_SdlEvent_allocate, wren_sdl_SdlEvent_finalize);
  wrt_bind_method("wren-sdl.SdlEvent.type", wren_sdl_SdlEvent_type);

  wrt_bind_method("wren-sdl.SDL.delay(_)", wren_sdl_SDL_delay_1);
  wrt_bind_method("wren-sdl.SDL.ticks", wren_sdl_SDL_ticks);
  wrt_bind_method("wren-sdl.SDL.setSwapInterval(_)", wren_sdl_SDL_glSetSwapInterval_1);
  wrt_bind_method("wren-sdl.SDL.setAttribute(_,_)", wren_sdl_SDL_glSetAttribute_2);
  wrt_bind_method("wren-sdl.SDL.setHint(_,_)", wren_sdl_SDL_setHint_2);
  wrt_bind_method("wren-sdl.SDL.pollEvent(_)", wren_sdl_SDL_pollEvent_1);
  wrt_bind_method("wren-sdl.SDL.runLoop(_)", wren_sdl_SDL_runLoop_1);
  wrt_bind_method("wren-sdl.SDL.getMouseState()", wren_sdl_SDL_getMouseState_0);

  wrt_wren_init_callback(wren_start);
  wrt_wren_update_callback(wren_update);
}