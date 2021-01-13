#include <stdlib.h>
#include "./wrt_plugin.h"
#include <SDL2/SDL.h>

int plugin_id;

typedef struct {
  WrenHandle* loopHandle;
  WrenHandle* callHandle_0;
} SdlData;

static void wren_start(WrenVM* vm){
  SdlData* sd = calloc(1, sizeof(SdlData));
  sd->callHandle_0 = wrenMakeCallHandle(vm, "call()");
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

static void wren_sdl_SdlWindow_width(WrenVM* vm){
  SDL_Window* window = *(SDL_Window**)wrenGetSlotForeign(vm, 0);
  int w,h;
  SDL_GetWindowSize(window, &w, &h);
  wrenSetSlotDouble(vm, 0, w);
}

static void wren_sdl_SdlWindow_height(WrenVM* vm){
  SDL_Window* window = *(SDL_Window**)wrenGetSlotForeign(vm, 0);
  int w,h;
  SDL_GetWindowSize(window, &w, &h);
  wrenSetSlotDouble(vm, 0, h);
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

#define WREN_SDL_EVENT_PROP(NAME, MEMBER) static void wren_sdl_SdlEvent_##NAME(WrenVM* vm){\
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);\
  wrenSetSlotDouble(vm, 0, (double)ev->MEMBER);\
}
#define WREN_SDL_EVENT_PROP_STR(NAME, MEMBER) static void wren_sdl_SdlEvent_##NAME(WrenVM* vm){\
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);\
  wrenSetSlotString(vm, 0, ev->MEMBER);\
}
#define WREN_SDL_EVENT_PROP_BOOL(NAME, MEMBER) static void wren_sdl_SdlEvent_##NAME(WrenVM* vm){\
  SDL_Event* ev = (SDL_Event*)wrenGetSlotForeign(vm, 0);\
  wrenSetSlotBool(vm, 0, ev->MEMBER > 0);\
}
#define WREN_SDL_EVENT_PROP_DEF(NAME) wrt_bind_method("wren-sdl.SdlEvent." #NAME, wren_sdl_SdlEvent_##NAME);

WREN_SDL_EVENT_PROP(type, type)
WREN_SDL_EVENT_PROP(timestamp, common.timestamp)
WREN_SDL_EVENT_PROP(display_display, display.display)
WREN_SDL_EVENT_PROP(display_event, display.event)
WREN_SDL_EVENT_PROP(display_data1, display.data1)
WREN_SDL_EVENT_PROP(window_event, window.event)
WREN_SDL_EVENT_PROP(window_data1, window.data1)
WREN_SDL_EVENT_PROP(window_data2, window.data2)
WREN_SDL_EVENT_PROP(key_state, key.state)
WREN_SDL_EVENT_PROP(key_sym, key.keysym.sym)
WREN_SDL_EVENT_PROP(key_scancode, key.keysym.scancode)
WREN_SDL_EVENT_PROP(key_mod, key.keysym.mod)
WREN_SDL_EVENT_PROP_BOOL(key_isRepeat, key.repeat)
WREN_SDL_EVENT_PROP_STR(edit_text, edit.text)
WREN_SDL_EVENT_PROP(edit_start, edit.start)
WREN_SDL_EVENT_PROP(edit_length, edit.length)
WREN_SDL_EVENT_PROP_STR(text_text, text.text)
WREN_SDL_EVENT_PROP(motion_which, motion.which)
WREN_SDL_EVENT_PROP(motion_state, motion.state)
WREN_SDL_EVENT_PROP(motion_x, motion.x)
WREN_SDL_EVENT_PROP(motion_y, motion.y)
WREN_SDL_EVENT_PROP(motion_xrel, motion.xrel)
WREN_SDL_EVENT_PROP(motion_yrel, motion.yrel)
WREN_SDL_EVENT_PROP(button_which, button.which)
WREN_SDL_EVENT_PROP(button_button, button.button)
WREN_SDL_EVENT_PROP(button_clicks, button.clicks)
WREN_SDL_EVENT_PROP(button_x, button.x)
WREN_SDL_EVENT_PROP(button_y, button.y)
WREN_SDL_EVENT_PROP(wheel_which, wheel.which)
WREN_SDL_EVENT_PROP(wheel_x, wheel.x)
WREN_SDL_EVENT_PROP(wheel_y, wheel.y)
WREN_SDL_EVENT_PROP(wheel_direction, wheel.direction)
WREN_SDL_EVENT_PROP(jaxis_which, jaxis.which)
WREN_SDL_EVENT_PROP(jaxis_axis, jaxis.axis)
WREN_SDL_EVENT_PROP(jaxis_value, jaxis.value)
WREN_SDL_EVENT_PROP(jball_which, jball.which)
WREN_SDL_EVENT_PROP(jball_ball, jball.ball)
WREN_SDL_EVENT_PROP(jball_xrel, jball.xrel)
WREN_SDL_EVENT_PROP(jball_yrel, jball.yrel)
WREN_SDL_EVENT_PROP(jhat_which, jhat.which)
WREN_SDL_EVENT_PROP(jhat_hat, jhat.hat)
WREN_SDL_EVENT_PROP(jhat_value, jhat.value)
WREN_SDL_EVENT_PROP(jbutton_which, jbutton.which)
WREN_SDL_EVENT_PROP(jbutton_button, jbutton.button)
WREN_SDL_EVENT_PROP(jbutton_state, jbutton.state)
WREN_SDL_EVENT_PROP(jdevice_which, jdevice.which)
WREN_SDL_EVENT_PROP(caxis_which, caxis.which)
WREN_SDL_EVENT_PROP(caxis_axis, caxis.axis)
WREN_SDL_EVENT_PROP(caxis_value, caxis.value)
WREN_SDL_EVENT_PROP(cbutton_which, cbutton.which)
WREN_SDL_EVENT_PROP(cbutton_button, cbutton.button)
WREN_SDL_EVENT_PROP(cbutton_state, cbutton.state)
WREN_SDL_EVENT_PROP(cdevice_which, cdevice.which)
WREN_SDL_EVENT_PROP(adevice_which, adevice.which)
WREN_SDL_EVENT_PROP_BOOL(adevice_isCapture, adevice.iscapture)
WREN_SDL_EVENT_PROP(tfinger_touchId, tfinger.touchId)
WREN_SDL_EVENT_PROP(tfinger_x, tfinger.x)
WREN_SDL_EVENT_PROP(tfinger_y, tfinger.y)
WREN_SDL_EVENT_PROP(tfinger_dx, tfinger.dx)
WREN_SDL_EVENT_PROP(tfinger_dy, tfinger.dy)
WREN_SDL_EVENT_PROP(tfinger_pressure, tfinger.pressure)
WREN_SDL_EVENT_PROP(mgesture_touchId, mgesture.touchId)
WREN_SDL_EVENT_PROP(mgesture_dTheta, mgesture.dTheta)
WREN_SDL_EVENT_PROP(mgesture_dDist, mgesture.dDist)
WREN_SDL_EVENT_PROP(mgesture_x, mgesture.x)
WREN_SDL_EVENT_PROP(mgesture_y, mgesture.y)
WREN_SDL_EVENT_PROP(mgesture_numFingers, mgesture.numFingers)
WREN_SDL_EVENT_PROP(dgesture_touchId, dgesture.touchId)
WREN_SDL_EVENT_PROP(dgesture_gestureId, dgesture.gestureId)
WREN_SDL_EVENT_PROP(dgesture_numFingers, dgesture.numFingers)
WREN_SDL_EVENT_PROP(dgesture_error, dgesture.error)
WREN_SDL_EVENT_PROP(dgesture_x, dgesture.x)
WREN_SDL_EVENT_PROP(dgesture_y, dgesture.y)
WREN_SDL_EVENT_PROP_STR(drop_file, drop.file)
WREN_SDL_EVENT_PROP(sensor_which, sensor.which)

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

static void wren_sdl_SDL_isKeyDown_1(WrenVM* vm){
  SDL_Keycode keycode = wrenGetSlotDouble(vm, 1);
  SDL_Scancode scancode = SDL_GetScancodeFromKey(keycode);
  const Uint8* arr = SDL_GetKeyboardState(NULL);
  wrenSetSlotBool(vm, 0, arr[scancode]);
}

void wrt_plugin_init(int handle){
  plugin_id = handle;
  SDL_Init(SDL_INIT_EVERYTHING);

  wrt_bind_class("wren-sdl.SdlWindow", wren_sdl_SdlWindow_allocate, wren_sdl_SdlWindow_finalize);
  wrt_bind_method("wren-sdl.SdlWindow.create_(_,_,_,_)", wren_sdl_SdlWindow_create_4);
  wrt_bind_method("wren-sdl.SdlWindow.makeCurrent(_)", wren_sdl_SdlWindow_glMakeCurrent_1);
  wrt_bind_method("wren-sdl.SdlWindow.swap()", wren_sdl_SdlWindow_glSwap_0);
  wrt_bind_method("wren-sdl.SdlWindow.width", wren_sdl_SdlWindow_width);
  wrt_bind_method("wren-sdl.SdlWindow.height", wren_sdl_SdlWindow_height);

  wrt_bind_class("wren-sdl.SdlGlContext", wren_sdl_SdlGlContext_allocate, wren_sdl_SdlGlContext_finalize);
  wrt_bind_method("wren-sdl.SdlGlContext.create_(_)", wren_sdl_SdlGlContext_create_1);

  wrt_bind_class("wren-sdl.SdlEvent", wren_sdl_SdlEvent_allocate, wren_sdl_SdlEvent_finalize);
  WREN_SDL_EVENT_PROP_DEF(type)
  WREN_SDL_EVENT_PROP_DEF(timestamp)
  WREN_SDL_EVENT_PROP_DEF(display_display)
  WREN_SDL_EVENT_PROP_DEF(display_event)
  WREN_SDL_EVENT_PROP_DEF(display_data1)
  WREN_SDL_EVENT_PROP_DEF(window_event)
  WREN_SDL_EVENT_PROP_DEF(window_data1)
  WREN_SDL_EVENT_PROP_DEF(window_data2)
  WREN_SDL_EVENT_PROP_DEF(key_state)
  WREN_SDL_EVENT_PROP_DEF(key_sym)
  WREN_SDL_EVENT_PROP_DEF(key_scancode)
  WREN_SDL_EVENT_PROP_DEF(key_mod)
  WREN_SDL_EVENT_PROP_DEF(key_isRepeat)
  WREN_SDL_EVENT_PROP_DEF(edit_text)
  WREN_SDL_EVENT_PROP_DEF(edit_start)
  WREN_SDL_EVENT_PROP_DEF(edit_length)
  WREN_SDL_EVENT_PROP_DEF(text_text)
  WREN_SDL_EVENT_PROP_DEF(motion_which)
  WREN_SDL_EVENT_PROP_DEF(motion_state)
  WREN_SDL_EVENT_PROP_DEF(motion_x)
  WREN_SDL_EVENT_PROP_DEF(motion_y)
  WREN_SDL_EVENT_PROP_DEF(motion_xrel)
  WREN_SDL_EVENT_PROP_DEF(motion_yrel)
  WREN_SDL_EVENT_PROP_DEF(button_which)
  WREN_SDL_EVENT_PROP_DEF(button_button)
  WREN_SDL_EVENT_PROP_DEF(button_clicks)
  WREN_SDL_EVENT_PROP_DEF(button_x)
  WREN_SDL_EVENT_PROP_DEF(button_y)
  WREN_SDL_EVENT_PROP_DEF(wheel_which)
  WREN_SDL_EVENT_PROP_DEF(wheel_x)
  WREN_SDL_EVENT_PROP_DEF(wheel_y)
  WREN_SDL_EVENT_PROP_DEF(wheel_direction)
  WREN_SDL_EVENT_PROP_DEF(jaxis_which)
  WREN_SDL_EVENT_PROP_DEF(jaxis_axis)
  WREN_SDL_EVENT_PROP_DEF(jaxis_value)
  WREN_SDL_EVENT_PROP_DEF(jball_which)
  WREN_SDL_EVENT_PROP_DEF(jball_ball)
  WREN_SDL_EVENT_PROP_DEF(jball_xrel)
  WREN_SDL_EVENT_PROP_DEF(jball_yrel)
  WREN_SDL_EVENT_PROP_DEF(jhat_which)
  WREN_SDL_EVENT_PROP_DEF(jhat_hat)
  WREN_SDL_EVENT_PROP_DEF(jhat_value)
  WREN_SDL_EVENT_PROP_DEF(jbutton_which)
  WREN_SDL_EVENT_PROP_DEF(jbutton_button)
  WREN_SDL_EVENT_PROP_DEF(jbutton_state)
  WREN_SDL_EVENT_PROP_DEF(jdevice_which)
  WREN_SDL_EVENT_PROP_DEF(caxis_which)
  WREN_SDL_EVENT_PROP_DEF(caxis_axis)
  WREN_SDL_EVENT_PROP_DEF(caxis_value)
  WREN_SDL_EVENT_PROP_DEF(cbutton_which)
  WREN_SDL_EVENT_PROP_DEF(cbutton_button)
  WREN_SDL_EVENT_PROP_DEF(cbutton_state)
  WREN_SDL_EVENT_PROP_DEF(cdevice_which)
  WREN_SDL_EVENT_PROP_DEF(adevice_which)
  WREN_SDL_EVENT_PROP_DEF(adevice_isCapture)
  WREN_SDL_EVENT_PROP_DEF(tfinger_touchId)
  WREN_SDL_EVENT_PROP_DEF(tfinger_x)
  WREN_SDL_EVENT_PROP_DEF(tfinger_y)
  WREN_SDL_EVENT_PROP_DEF(tfinger_dx)
  WREN_SDL_EVENT_PROP_DEF(tfinger_dy)
  WREN_SDL_EVENT_PROP_DEF(tfinger_pressure)
  WREN_SDL_EVENT_PROP_DEF(mgesture_touchId)
  WREN_SDL_EVENT_PROP_DEF(mgesture_dTheta)
  WREN_SDL_EVENT_PROP_DEF(mgesture_dDist)
  WREN_SDL_EVENT_PROP_DEF(mgesture_x)
  WREN_SDL_EVENT_PROP_DEF(mgesture_y)
  WREN_SDL_EVENT_PROP_DEF(mgesture_numFingers)
  WREN_SDL_EVENT_PROP_DEF(dgesture_touchId)
  WREN_SDL_EVENT_PROP_DEF(dgesture_gestureId)
  WREN_SDL_EVENT_PROP_DEF(dgesture_numFingers)
  WREN_SDL_EVENT_PROP_DEF(dgesture_error)
  WREN_SDL_EVENT_PROP_DEF(dgesture_x)
  WREN_SDL_EVENT_PROP_DEF(dgesture_y)
  WREN_SDL_EVENT_PROP_DEF(drop_file)
  WREN_SDL_EVENT_PROP_DEF(sensor_which)

  wrt_bind_method("wren-sdl.SDL.delay(_)", wren_sdl_SDL_delay_1);
  wrt_bind_method("wren-sdl.SDL.ticks", wren_sdl_SDL_ticks);
  wrt_bind_method("wren-sdl.SDL.setSwapInterval(_)", wren_sdl_SDL_glSetSwapInterval_1);
  wrt_bind_method("wren-sdl.SDL.setAttribute(_,_)", wren_sdl_SDL_glSetAttribute_2);
  wrt_bind_method("wren-sdl.SDL.setHint(_,_)", wren_sdl_SDL_setHint_2);
  wrt_bind_method("wren-sdl.SDL.pollEvent(_)", wren_sdl_SDL_pollEvent_1);
  wrt_bind_method("wren-sdl.SDL.runLoop(_)", wren_sdl_SDL_runLoop_1);
  wrt_bind_method("wren-sdl.SDL.getMouseState()", wren_sdl_SDL_getMouseState_0);
  wrt_bind_method("wren-sdl.SDL.isKeyDown(_)", wren_sdl_SDL_isKeyDown_1);

  wrt_wren_update_callback(wren_update);
}

void wrt_plugin_init_wren(WrenVM* vm){
  wren_start(vm);
}
