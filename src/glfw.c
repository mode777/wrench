#include <stdlib.h>
#include "./wrt_plugin.h"
#include <GLFW/glfw3.h>

static WrenHandle* loopHandle;
static WrenHandle* callHandle_0;
static WrenHandle* callHandle_1;
static WrenHandle* callHandle_2;
static WrenHandle* callHandle_3;
static WrenHandle* callHandle_4;
static WrenHandle* callHandle_5;
static WrenHandle* callHandle_6;
static WrenHandle* callHandle_7;
static WrenHandle* callHandle_8;

typedef struct {
  WrenVM* vm;
  WrenHandle* keyCallback;
  WrenHandle* mouseCallback;
} WrenCallbacks;

static void wren_start(WrenVM* vm){
  callHandle_0 = wrenMakeCallHandle(vm, "call()");
  callHandle_1 = wrenMakeCallHandle(vm, "call(_)");
  callHandle_2 = wrenMakeCallHandle(vm, "call(_,_)");
  callHandle_3 = wrenMakeCallHandle(vm, "call(_,_,_)");
  callHandle_4 = wrenMakeCallHandle(vm, "call(_,_,_,_)");
  callHandle_5 = wrenMakeCallHandle(vm, "call(_,_,_,_,_)");
  callHandle_6 = wrenMakeCallHandle(vm, "call(_,_,_,_,_,_)");
  callHandle_7 = wrenMakeCallHandle(vm, "call(_,_,_,_,_,_,_)");
  callHandle_8 = wrenMakeCallHandle(vm, "call(_,_,_,_,_,_,_,_)");
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

  glfwPollEvents();

  wrenSetSlotBool(vm, 0, result == WREN_RESULT_SUCCESS && success);
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods){
  WrenCallbacks cbs = *(WrenCallbacks*)glfwGetWindowUserPointer(window);
  if(cbs.keyCallback != NULL){
    wrenEnsureSlots(cbs.vm, 5);
    wrenSetSlotHandle(cbs.vm, 0, cbs.keyCallback);
    wrenSetSlotDouble(cbs.vm, 1, (double)key);
    wrenSetSlotDouble(cbs.vm, 2, (double)scancode);
    wrenSetSlotDouble(cbs.vm, 3, (double)action);
    wrenSetSlotDouble(cbs.vm, 4, (double)mods);
    wrenCall(cbs.vm, callHandle_4);
  }
}

static void wren_glfw_Window_allocate(WrenVM* vm){
  GLFWwindow** ptr = (GLFWwindow**)wrenSetSlotNewForeign(vm, 0, 0, sizeof(GLFWwindow*));
  *ptr = NULL;
}

static void wren_GLFW_Window_delete(void* data){
  GLFWwindow* win = data;
  if(data != NULL){
    WrenCallbacks* cbs = glfwGetWindowUserPointer(win);
    if(cbs->keyCallback != NULL) wrenReleaseHandle(cbs->vm, cbs->keyCallback);
    if(cbs->mouseCallback != NULL) wrenReleaseHandle(cbs->vm, cbs->mouseCallback);
    free(cbs);
    glfwDestroyWindow(win);
  }
}

static void wren_glfw_Window_hint__2(WrenVM* vm){
  int hint = wrenGetSlotDouble(vm, 1);
  int value = wrenGetSlotDouble(vm, 2);
  glfwWindowHint(hint, value);
}

static void wren_glfw_Window_create__3(WrenVM* vm){
  GLFWwindow** win = (GLFWwindow**)wrenGetSlotForeign(vm, 0);
  int w = wrenGetSlotDouble(vm, 1);
  int h = wrenGetSlotDouble(vm, 2);
  const char* name = wrenGetSlotString(vm, 3);
  *win = glfwCreateWindow(w,h,name, NULL, NULL);  
  if(*win == NULL){
    const char* description;
    glfwGetError(&description);
    wren_runtime_error(vm, description);
    return;
  }
  WrenCallbacks* callbacks = calloc(sizeof(WrenCallbacks), 1);
  callbacks->vm = vm;
  glfwSetWindowUserPointer(*win, callbacks);
}

static void wren_glfw_Window_makeContextCurrent_0(WrenVM* vm){
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  glfwMakeContextCurrent(win);
}

static void wren_glfw_Window_shouldClose_0(WrenVM* vm){
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  wrenSetSlotBool(vm, 0, glfwWindowShouldClose(win) == GLFW_TRUE ? true : false);
}

static void wren_glfw_Window_shouldClose_1(WrenVM* vm){
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  glfwSetWindowShouldClose(win, wrenGetSlotBool(vm, 1));
}

static void wren_glfw_Window_swapBuffers_0(WrenVM* vm){
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  glfwSwapBuffers(win);
}

static void wren_glfw_Window_keyCallback_1(WrenVM* vm){
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  WrenHandle* cb = wrenGetSlotHandle(vm, 1);
  WrenCallbacks* cbs = (WrenCallbacks*)glfwGetWindowUserPointer(win);
  if(cbs->keyCallback != NULL){
    wrenReleaseHandle(vm, cbs->keyCallback);
  } 
  glfwSetKeyCallback(win, key_callback);
  cbs->keyCallback = cb;
}

static void wren_glfw_Window_mouseCallback_1(WrenVM* vm){
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  WrenHandle* cb = wrenGetSlotHandle(vm, 1);
  WrenCallbacks* cbs = (WrenCallbacks*)glfwGetWindowUserPointer(win);
  if(cbs->mouseCallback != NULL){
    wrenReleaseHandle(vm, cbs->mouseCallback);
  } 
  // TODO!!
  //glfwSetMouseCallback(win, mouse_callback);
  cbs->mouseCallback = cb;
}

static void wren_glfw_Window_cursorPos_0(WrenVM* vm){
  wrenEnsureSlots(vm, 2);
  GLFWwindow* win = *(GLFWwindow**)wrenGetSlotForeign(vm, 0);
  double w,h;
  glfwGetCursorPos(win, &w, &h);
  wrenSetSlotNewList(vm, 0);
  wrenSetSlotDouble(vm, 1, w);
  wrenInsertInList(vm, 0, -1, 1);
  wrenSetSlotDouble(vm, 1, h);
  wrenInsertInList(vm, 0, -1, 1);
}

static void errorcb(int error, const char* desc)
{
	printf("GLFW error %d: %s\n", error, desc);
}

static void wren_glfw_GLFW_runLoop_1(WrenVM* vm){
  if(loopHandle != NULL){
    wrenReleaseHandle(vm, loopHandle);
  }
  loopHandle = wrenGetSlotHandle(vm, 1);
}

static void wren_glfw_GLFW_swapInterval_1(WrenVM* vm){
  int interval = wrenGetSlotDouble(vm, 1);
  glfwSwapInterval(interval);
}

static void wren_glfw_GLFW_time(WrenVM* vm){
  wrenSetSlotDouble(vm, 0, glfwGetTime());
}

void wrt_plugin_init(){
  glfwInit();
  glfwSetErrorCallback(errorcb);
  wrt_bind_method("wren-glfw.GLFW.runLoop(_)", wren_glfw_GLFW_runLoop_1);
  wrt_bind_method("wren-glfw.GLFW.swapInterval(_)", wren_glfw_GLFW_swapInterval_1);
  wrt_bind_method("wren-glfw.GLFW.time", wren_glfw_GLFW_time);

  wrt_bind_class("wren-glfw.Window", wren_glfw_Window_allocate, wren_GLFW_Window_delete);
  wrt_bind_method("wren-glfw.Window.hint_(_,_)", wren_glfw_Window_hint__2);
  wrt_bind_method("wren-glfw.Window.create_(_,_,_)", wren_glfw_Window_create__3);
  wrt_bind_method("wren-glfw.Window.makeContextCurrent()", wren_glfw_Window_makeContextCurrent_0);
  wrt_bind_method("wren-glfw.Window.shouldClose", wren_glfw_Window_shouldClose_0);
  wrt_bind_method("wren-glfw.Window.shouldClose=(_)", wren_glfw_Window_shouldClose_1);
  wrt_bind_method("wren-glfw.Window.swapBuffers()", wren_glfw_Window_swapBuffers_0);
  wrt_bind_method("wren-glfw.Window.keyCallback(_)", wren_glfw_Window_keyCallback_1);
  wrt_bind_method("wren-glfw.Window.mouseCallback(_)", wren_glfw_Window_mouseCallback_1);
  wrt_bind_method("wren-glfw.Window.cursorPos()", wren_glfw_Window_cursorPos_0);

  wrt_wren_init_callback(wren_start);
  wrt_wren_update_callback(wren_update);
}