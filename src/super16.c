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
} UvLocAttribute;

typedef struct {
  UvLocAttribute corners[4];
} UvLocQuad;

typedef struct {
  GLushort sx;
  GLushort sy;
  GLushort r;
  GLushort padding;
  GLushort x;
  GLushort y;
} ScaleRotTransAttribute;

typedef struct {
  ScaleRotTransAttribute corners[4];
} ScaleRotTransQuad;

typedef struct {
  GLuint count;
  GLuint coordUvLoc;
  GLuint scaleRotLoc;
  GLuint transLoc;
  GLuint constBuffer;
  GLuint varBuffer;
  GLuint indexBuffer;
  UvLocQuad* varAttributes;
  ScaleRotTransQuad* constAttributes;
} SpriteBuffer;

static void init_const_attributes(SpriteBuffer* buffer){
  ScaleRotTransAttribute defaults = {0};
  defaults.sx = 4096;
  defaults.sy = 4096;
  for (size_t i = 0; i < buffer->count; i++)
  {
    for (size_t j = 0; j < 4; j++)
    {
      buffer->constAttributes[i].corners[j] = defaults;
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

  buffer->constAttributes = calloc(buffer->count, sizeof(ScaleRotTransQuad));
  buffer->varAttributes = calloc(buffer->count, sizeof(UvLocQuad));

  GLuint buffers[3];
  glGenBuffers(3, buffers);
  buffer->constBuffer = buffers[0];
  buffer->varBuffer = buffers[1];
  buffer->indexBuffer = buffers[2];

  glBindBuffer(GL_ARRAY_BUFFER, buffer->constBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(ScaleRotTransQuad)*buffer->count, NULL, GL_STREAM_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER, buffer->varBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(UvLocQuad)*buffer->count, NULL, GL_STREAM_DRAW);

  init_const_attributes(buffer);
  create_indices(buffer);
}

static void sprite_buffer_delete(void* data){
  SpriteBuffer* buffer = (SpriteBuffer*)data;
  free(buffer->varAttributes);
  free(buffer->constAttributes);
  GLuint buffers[3] = { buffer->constBuffer, buffer->varBuffer, buffer->indexBuffer };
  glDeleteBuffers(3, buffers);
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
  buffer->varAttributes[i].corners[0].x = x-ox;
  buffer->varAttributes[i].corners[0].y = y+h-oy;

  buffer->varAttributes[i].corners[1].x = x-ox;
  buffer->varAttributes[i].corners[1].y = y-oy;

  buffer->varAttributes[i].corners[2].x = x+w-ox;
  buffer->varAttributes[i].corners[2].y = y-oy;

  buffer->varAttributes[i].corners[3].x = x+w-ox;
  buffer->varAttributes[i].corners[3].y = y+h-oy;

  // printf("(%i, %i), (%i, %i), (%i,%i), (%i,%i)\n", 
  //   buffer->varAttributes[i].corners[0].x,
  //   buffer->varAttributes[i].corners[0].y,
  //   buffer->varAttributes[i].corners[1].x,
  //   buffer->varAttributes[i].corners[1].y,
  //   buffer->varAttributes[i].corners[2].x,
  //   buffer->varAttributes[i].corners[2].y,
  //   buffer->varAttributes[i].corners[3].x,
  //   buffer->varAttributes[i].corners[3].y
  // );
}

static void set_source(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  GLushort x = wrenGetSlotDouble(vm, 2);
  GLushort y = wrenGetSlotDouble(vm, 3);
  GLushort w = wrenGetSlotDouble(vm, 4);
  GLushort h = wrenGetSlotDouble(vm, 5);
  buffer->varAttributes[i].corners[0].u = y;
  buffer->varAttributes[i].corners[0].v = x;

  buffer->varAttributes[i].corners[1].u = y+h;
  buffer->varAttributes[i].corners[1].v = x;

  buffer->varAttributes[i].corners[2].u = y+h;
  buffer->varAttributes[i].corners[2].v = x+w;

  buffer->varAttributes[i].corners[3].u = y;
  buffer->varAttributes[i].corners[3].v = x+w;
}

static void set_translation(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  GLushort x = wrenGetSlotDouble(vm, 2);
  GLushort y = wrenGetSlotDouble(vm, 3);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->constAttributes[i].corners[j].x = x;
    buffer->constAttributes[i].corners[j].y = y;
  }  
}

static void set_rotation(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  double r = wrenGetSlotDouble(vm, 2);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->constAttributes[i].corners[j].r = (GLushort)(r * 10430);
  }  
}

static void set_scale(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  GLuint i = wrenGetSlotDouble(vm, 1);
  double sx = wrenGetSlotDouble(vm, 2);
  double sy = wrenGetSlotDouble(vm, 3);
  for (size_t j = 0; j < 4; j++)
  {
    buffer->constAttributes[i].corners[j].sx = (GLushort)(sx * 4096);
    buffer->constAttributes[i].corners[j].sy = (GLushort)(sy * 4096);
  }  
}

static void update(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
  glBindBuffer(GL_ARRAY_BUFFER, buffer->varBuffer);
  glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(UvLocQuad)*buffer->count, (const GLvoid*)buffer->varAttributes);
  glVertexAttribPointer(buffer->coordUvLoc, 4, GL_SHORT, false, 0, 0);
  glEnableVertexAttribArray(buffer->coordUvLoc);

  glBindBuffer(GL_ARRAY_BUFFER, buffer->constBuffer);
  glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(ScaleRotTransQuad)*buffer->count, (const GLvoid*)buffer->constAttributes);
  glVertexAttribPointer(buffer->scaleRotLoc, 4, GL_UNSIGNED_SHORT, false, sizeof(ScaleRotTransAttribute), 0);
  glVertexAttribPointer(buffer->transLoc, 2, GL_SHORT, false, sizeof(ScaleRotTransAttribute), (const GLvoid*)offsetof(ScaleRotTransAttribute, x));
  glEnableVertexAttribArray(buffer->scaleRotLoc);
  glEnableVertexAttribArray(buffer->transLoc);
}

static void draw(WrenVM* vm){
  SpriteBuffer* buffer = (SpriteBuffer*)wrenGetSlotForeign(vm, 0);
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
  wrt_bind_method("super16.SpriteBuffer.update()", update);
  wrt_bind_method("super16.SpriteBuffer.draw()", draw);
  wrt_bind_method("super16.SpriteBuffer.count", count);

}