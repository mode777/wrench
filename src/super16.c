#include <stddef.h>
#include <stdlib.h>
#include <GLES2/gl2.h>
#include "wrt_plugin.h"

int plugin_handle;

typedef struct {
  GLshort x;
  GLshort y;
  GLushort u;
  GLushort v;
  GLushort sx;
  GLushort sy;
  GLushort r;
  GLushort prio;
  GLshort tx;
  GLshort ty;
} Attribute;

typedef struct {
  Attribute corners[4];
} Quad;

typedef struct {
  GLuint count;
  GLuint coordUvLoc;
  GLuint scaleRotLoc;
  GLuint transLoc;
  GLuint prioLoc;
  GLuint quadBuffer;
  GLuint indexBuffer;
  Quad* quads;
} SpriteBuffer;

static void init_const_attributes(SpriteBuffer* buffer){
  Attribute defaults = {0};
  defaults.sx = 4096;
  defaults.sy = 4096;
  for (size_t i = 0; i < buffer->count; i++)
  {
    for (size_t j = 0; j < 4; j++)
    {
      buffer->quads[i].corners[j] = defaults;
    }
  }
}

static void create_indices(SpriteBuffer* buffer){
  GLushort* indices = malloc(buffer->count*6*sizeof(GLushort));
  for (size_t i = 0; i < buffer->count; i++)
  {
    GLuint index = i*4;
    GLuint offset = i*6;
    indices[offset] = index+3;
    indices[offset+1] = index+2;
    indices[offset+2] = index+1;
    indices[offset+3] = index+3;
    indices[offset+4] = index+1;
    indices[offset+5] = index+0;
  }
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer->indexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, buffer->count*6*sizeof(GLushort), (const GLvoid*)indices, GL_STATIC_DRAW);
  free(indices);   
}

static void sprite_buffer_init(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(SpriteBuffer));
  GLuint program = *(GLuint*)wrenGetSlotForeign(vm, 1);

  buffer->count = wrenGetSlotDouble(vm, 2);
  buffer->coordUvLoc = glGetAttribLocation(program, "coordUv");
  buffer->scaleRotLoc = glGetAttribLocation(program, "scaleRot");
  buffer->transLoc = glGetAttribLocation(program, "trans");
  buffer->prioLoc = glGetUniformLocation(program, "prio");

  buffer->quads = calloc(buffer->count, sizeof(Quad));

  GLuint buffers[2];
  glGenBuffers(2, buffers);
  buffer->quadBuffer = buffers[0];
  buffer->indexBuffer = buffers[1];

  glBindBuffer(GL_ARRAY_BUFFER, buffer->quadBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(Quad)*buffer->count, NULL, GL_STREAM_DRAW);

  init_const_attributes(buffer);
  create_indices(buffer);
}

static void sprite_buffer_delete(void* data){
  SpriteBuffer* buffer = (SpriteBuffer*)data;
  free(buffer->quads);
  GLuint buffers[2] = { buffer->quadBuffer, buffer->indexBuffer };
  glDeleteBuffers(2, buffers);
}

static void set_shape(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  GLshort x = wrenGetSlotDouble(vm, 2);
  GLshort y = wrenGetSlotDouble(vm, 3);
  GLushort w = wrenGetSlotDouble(vm, 4);
  GLushort h = wrenGetSlotDouble(vm, 5);
  GLshort ox = wrenGetSlotDouble(vm, 6);
  GLshort oy = wrenGetSlotDouble(vm, 7);
  buffer->quads[i].corners[0].x = x-ox;
  buffer->quads[i].corners[0].y = y+h-oy;

  buffer->quads[i].corners[1].x = x-ox;
  buffer->quads[i].corners[1].y = y-oy;

  buffer->quads[i].corners[2].x = x+w-ox;
  buffer->quads[i].corners[2].y = y-oy;

  buffer->quads[i].corners[3].x = x+w-ox;
  buffer->quads[i].corners[3].y = y+h-oy;

  // printf("(%i, %i), (%i, %i), (%i,%i), (%i,%i)\n", 
  //   buffer->quads[i].corners[0].x,
  //   buffer->quads[i].corners[0].y,
  //   buffer->quads[i].corners[1].x,
  //   buffer->quads[i].corners[1].y,
  //   buffer->quads[i].corners[2].x,
  //   buffer->quads[i].corners[2].y,
  //   buffer->quads[i].corners[3].x,
  //   buffer->quads[i].corners[3].y
  // );
}

static void set_source(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  GLushort x = wrenGetSlotDouble(vm, 2);
  GLushort y = wrenGetSlotDouble(vm, 3);
  GLushort w = wrenGetSlotDouble(vm, 4);
  GLushort h = wrenGetSlotDouble(vm, 5);
  buffer->quads[i].corners[0].v = y+h;
  buffer->quads[i].corners[0].u = x;

  buffer->quads[i].corners[1].v = y;
  buffer->quads[i].corners[1].u = x;

  buffer->quads[i].corners[2].v = y;
  buffer->quads[i].corners[2].u = x+w;

  buffer->quads[i].corners[3].v = y+h;
  buffer->quads[i].corners[3].u = x+w;
}

static void set_translation(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  GLushort x = wrenGetSlotDouble(vm, 2);
  GLushort y = wrenGetSlotDouble(vm, 3);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->quads[i].corners[j].tx = x;
    buffer->quads[i].corners[j].ty = y;
  }  
}

static void set_rotation(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  double r = wrenGetSlotDouble(vm, 2);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->quads[i].corners[j].r = (GLushort)(r * 10430);
  }  
}

static void set_scale(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  double sx = wrenGetSlotDouble(vm, 2);
  double sy = wrenGetSlotDouble(vm, 3);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->quads[i].corners[j].sx = (GLushort)(sx * 4096);
    buffer->quads[i].corners[j].sy = (GLushort)(sy * 4096);
  }  
}

static void set_prio(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  GLushort p = wrenGetSlotDouble(vm, 2);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->quads[i].corners[j].prio = p;
  }
}

static void update(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);

  glBindBuffer(GL_ARRAY_BUFFER, buffer->quadBuffer);
  glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(Quad)*buffer->count, (const GLvoid*)buffer->quads);
  glVertexAttribPointer(buffer->coordUvLoc, 4, GL_SHORT, false, sizeof(Attribute), (const GLvoid*)offsetof(Attribute, x));
  glVertexAttribPointer(buffer->scaleRotLoc, 4, GL_UNSIGNED_SHORT, false, sizeof(Attribute), (const GLvoid*)offsetof(Attribute, sx));
  glVertexAttribPointer(buffer->transLoc, 2, GL_SHORT, false, sizeof(Attribute), (const GLvoid*)offsetof(Attribute, tx));
  glEnableVertexAttribArray(buffer->coordUvLoc);
  glEnableVertexAttribArray(buffer->scaleRotLoc);
  glEnableVertexAttribArray(buffer->transLoc);
}

static void draw(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLfloat prio = (GLint)wrenGetSlotDouble(vm, 1);
  glUniform1f(buffer->prioLoc, prio);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer->indexBuffer);
  glDrawElements(GL_TRIANGLES, buffer->count*6, GL_UNSIGNED_SHORT, 0);
}

static void count(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, buffer->count);
}

void wrt_plugin_init(int handle){
  plugin_handle = handle;
  wrt_bind_class("super16.SpriteBuffer", sprite_buffer_init, sprite_buffer_delete);
  wrt_bind_method("super16.SpriteBuffer.setShape(_,_,_,_,_,_,_)", set_shape);
  wrt_bind_method("super16.SpriteBuffer.setSource(_,_,_,_,_)", set_source);
  wrt_bind_method("super16.SpriteBuffer.setTranslation(_,_,_)", set_translation);
  wrt_bind_method("super16.SpriteBuffer.setRotation(_,_)", set_rotation);
  wrt_bind_method("super16.SpriteBuffer.setScale(_,_,_)", set_scale);
  wrt_bind_method("super16.SpriteBuffer.setPrio(_,_)", set_prio);
  wrt_bind_method("super16.SpriteBuffer.update()", update);
  wrt_bind_method("super16.SpriteBuffer.draw(_)", draw);
  wrt_bind_method("super16.SpriteBuffer.count", count);

}