#include "wrt_plugin.h"
#include <GLES2/gl2.h>

int plugin_handle;

static void wren_gles2_GL_clear_1(WrenVM* vm){
  unsigned int mask = wrenGetSlotDouble(vm,1);
  glClear(mask);
}

static void wren_gles2_GL_clearColor_4(WrenVM* vm){
  GLclampf r = wrenGetSlotDouble(vm, 1);
  GLclampf g = wrenGetSlotDouble(vm, 2);
  GLclampf b = wrenGetSlotDouble(vm, 3);
  GLclampf a = wrenGetSlotDouble(vm, 4);
  glClearColor(r,g,b,a);
}

static void wren_gles2_GL_enable_1(WrenVM* vm){
  GLuint value = wrenGetSlotDouble(vm, 1);
  glEnable(value);
}

static void wren_gles2_GL_disable_1(WrenVM* vm){
  GLenum value = wrenGetSlotDouble(vm, 1);
  glDisable(value);
}

static void wren_gles2_GL_blendFunc_2(WrenVM* vm){
  GLenum sfactor = wrenGetSlotDouble(vm, 1);
  GLenum dfactor = wrenGetSlotDouble(vm, 2);
  glBlendFunc(sfactor, dfactor);
}

static void wren_gles2_GL_getError_0(WrenVM* vm){
  GLenum e = glGetError();  
  wrenSetSlotDouble(vm, 0, (double)e);
}

static void wren_gles2_GL_viewport_4(WrenVM* vm){
  GLint x = wrenGetSlotDouble(vm, 1);
  GLint y = wrenGetSlotDouble(vm, 2);
  GLsizei w = wrenGetSlotDouble(vm, 3);
  GLsizei h = wrenGetSlotDouble(vm, 4);
  glViewport(x,y,w,h);
}

void wrt_plugin_init(int handle){
  plugin_handle = handle;
  wrt_bind_method("wren-gles2.GL.clear(_)", wren_gles2_GL_clear_1);
  wrt_bind_method("wren-gles2.GL.clearColor(_,_,_,_)", wren_gles2_GL_clearColor_4);
  wrt_bind_method("wren-gles2.GL.enable(_)", wren_gles2_GL_enable_1);
  wrt_bind_method("wren-gles2.GL.disable(_)", wren_gles2_GL_disable_1);
  wrt_bind_method("wren-gles2.GL.blendFunc(_,_)", wren_gles2_GL_blendFunc_2);
  wrt_bind_method("wren-gles2.GL.getError()", wren_gles2_GL_getError_0);
  wrt_bind_method("wren-gles2.GL.viewport(_,_,_,_)", wren_gles2_GL_viewport_4);
}