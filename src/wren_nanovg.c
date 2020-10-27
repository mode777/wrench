#include <GLES2/gl2.h>
#define NANOVG_GLES2_IMPLEMENTATION
#include "nanovg.h"
#include "nanovg_gl.h"
#include "stb_image.h"
#define STB_IMAGE_RESIZE_IMPLEMENTATION
#include "stb_image_resize.h"

#include "wrt_plugin.h"

typedef struct {
  unsigned char* pixels;
  int width;
  int height;
} ImageData;

static void wren_nanovg_NvgContext_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(NVGcontext*));
}

static void wren_nanovg_NvgContext_delete(void* ctx){
  if(ctx != NULL){
    nvgDeleteGLES2((NVGcontext*)ctx);
  }
}

static void wren_nanovg_NvgContext_create__1(WrenVM* vm){
  int flags = wrenGetSlotDouble(vm, 1);
  NVGcontext** ctx = (NVGcontext**)wrenGetSlotForeign(vm,0);
  *ctx = nvgCreateGLES2(flags);
  if(*ctx == NULL){
    wren_runtime_error(vm, "Error initializing NanoVG context\n");
  }
}

static void wren_nanovg_NvgContext_beginFrame_3(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float w = wrenGetSlotDouble(vm, 1);
  float h = wrenGetSlotDouble(vm, 2);
  float ratio = wrenGetSlotDouble(vm, 3);

  nvgBeginFrame(ctx, w, h, ratio);
}

static void wren_nanovg_NvgContext_endFrame_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgEndFrame(ctx);
}

static void wren_nanovg_NvgContext_beginPath_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgBeginPath(ctx);
}

static void wren_nanovg_NvgContext_closePath_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgClosePath(ctx);
}

static void wren_nanovg_NvgContext_fillColor_1(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  NVGcolor* col = (NVGcolor*)wrenGetSlotForeign(vm, 1);
  nvgFillColor(ctx, *col);
}

static void wren_nanovg_NvgContext_fillPaint_1(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  NVGpaint* paint = (NVGpaint*)wrenGetSlotForeign(vm, 1);
  nvgFillPaint(ctx, *paint);
}

static void wren_nanovg_NvgContext_fill_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgFill(ctx);
}

static void wren_nanovg_NvgContext_rect_4(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  float w = wrenGetSlotDouble(vm, 3);
  float h = wrenGetSlotDouble(vm, 4);
  nvgRect(ctx,x,y,w,h);
}

static void wren_nanovg_NvgContext_scissor_4(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  float w = wrenGetSlotDouble(vm, 3);
  float h = wrenGetSlotDouble(vm, 4);
  nvgScissor(ctx,x,y,w,h);
}

static void wren_nanovg_NvgContext_intersectScissor_4(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  float w = wrenGetSlotDouble(vm, 3);
  float h = wrenGetSlotDouble(vm, 4);
  nvgIntersectScissor(ctx,x,y,w,h);
}

static void wren_nanovg_NvgContext_resetScissor_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgResetScissor(ctx);
}

static void wren_nanovg_NvgContext_ellipse_4(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float cx = wrenGetSlotDouble(vm, 1);
  float cy = wrenGetSlotDouble(vm, 2);
  float ex = wrenGetSlotDouble(vm, 3);
  float ey = wrenGetSlotDouble(vm, 4);
  nvgEllipse(ctx, cx, cy, ex, ey);
}

static void wren_nanovg_NvgContext_circle_3(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float cx = wrenGetSlotDouble(vm, 1);
  float cy = wrenGetSlotDouble(vm, 2);
  float r = wrenGetSlotDouble(vm, 3);
  nvgCircle(ctx, cx, cy, r);
}

static void wren_nanovg_NvgContext_save_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgSave(ctx);
}

static void wren_nanovg_NvgContext_restore_0(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgRestore(ctx);
}

static void wren_nanovg_NvgContext_fontSize_1(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float size = wrenGetSlotDouble(vm, 1);
  nvgFontSize(ctx, size);
}

static void wren_nanovg_NvgContext_fontBlur_1(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float size = wrenGetSlotDouble(vm, 1);
  nvgFontBlur(ctx, size);
}

static void wren_nanovg_NvgContext_fontFace_1(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  int face = *(int*)wrenGetSlotForeign(vm, 1);
  nvgFontFaceId(ctx, face);
}

static void wren_nanovg_NvgContext_textAlign_1(WrenVM* vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  enum NVGalign align = wrenGetSlotDouble(vm, 1);
  nvgTextAlign(ctx, align);
}

static void wren_nanovg_NvgContext_textMetrics_0(WrenVM* vm){
  wrenEnsureSlots(vm, 2);  
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float asc, desc, lheight;
  nvgTextMetrics(ctx, &asc, &desc, &lheight);  
  wrenSetSlotNewList(vm, 0);
  wrenSetSlotDouble(vm, 1, asc);
  wrenInsertInList(vm, 0, -1, 1);
  wrenSetSlotDouble(vm, 1, desc);
  wrenInsertInList(vm, 0, -1, 1);
  wrenSetSlotDouble(vm, 1, lheight);
  wrenInsertInList(vm, 0, -1, 1);
}

static void wren_nanovg_NvgContext_textBreakLine_4(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  const char* text = wrenGetSlotString(vm, 1);
  int start = wrenGetSlotDouble(vm, 2);
  float width = wrenGetSlotDouble(vm, 3);
  NVGtextRow* row =  (NVGtextRow*)wrenGetSlotForeign(vm, 4);

  bool more = (bool)nvgTextBreakLines(ctx, text+start, NULL, width, row, 1);
  if(more){
    row->start = (const char*)((row->start) - text);
    row->end = (const char*)((row->end) - text);
    row->next = (const char*)((row->next) - text);
  }

  wrenSetSlotBool(vm, 0, more);
}

static NVGglyphPosition glyphs[BUFSIZ];
static WrenHandle* glyphPositionClassHandle;

static void wren_nanovg_NvgContext_textGlyphPosition_5(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  int x = wrenGetSlotDouble(vm, 1);
  int y = wrenGetSlotDouble(vm, 2);
  const char* text = wrenGetSlotString(vm, 3);
  int start = wrenGetSlotDouble(vm, 4);
  int end = wrenGetSlotDouble(vm, 5);

  wrenSetSlotNewList(vm, 0);

  if(end - start <= 0){
    return;
  }

  int found = nvgTextGlyphPositions(ctx, x, y, text+start, text+end, glyphs, BUFSIZ);
  
  if(found > BUFSIZ){
    wren_runtime_error(vm, "Text to large (Max size 512)");
  }

  wrenSetSlotHandle(vm, 1, glyphPositionClassHandle);

  for (int i = 0; i < found; i++)
  {
    NVGglyphPosition glyph = glyphs[i];
    glyph.str = (const char*)((glyph.str) - text);
    NVGglyphPosition* element = (NVGglyphPosition*)wrenSetSlotNewForeign(vm, 2, 1, sizeof(NVGglyphPosition));
    *element = glyph;
    wrenInsertInList(vm, 0, -1, 2);
  }
}

static void wren_nanovg_NvgContext_textBounds_3(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  const char* str = wrenGetSlotString(vm, 3);
  float bounds[4];
  nvgTextBounds(ctx, x, y, str, NULL, bounds);
  wrenSetSlotNewList(vm, 0);
  for (int i = 0; i < 4; i++)
  {
    wrenSetSlotDouble(vm, 1, bounds[i]);
    wrenInsertInList(vm, 0, -1, 1);
  }  
}

static void wren_nanovg_NvgContext_textWidth_3(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  const char* str = wrenGetSlotString(vm, 3);
  float width = nvgTextBounds(ctx, x, y, str, NULL, NULL);
  wrenSetSlotDouble(vm, 0, width);    
}

static void wren_nanovg_NvgContext_textBoxBounds_4(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  float w = wrenGetSlotDouble(vm, 3);
  const char* str = wrenGetSlotString(vm, 4);
  float bounds[4];
  nvgTextBoxBounds(ctx, x, y, w, str, NULL, bounds);
  wrenSetSlotNewList(vm, 0);
  for (int i = 0; i < 4; i++)
  {
    wrenSetSlotDouble(vm, 1, bounds[i]);
    wrenInsertInList(vm, 0, -1, 1);
  }  
}


static void wren_nanovg_NvgContext_roundedRect_5(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  float w = wrenGetSlotDouble(vm, 3);
  float h = wrenGetSlotDouble(vm, 4);
  float r = wrenGetSlotDouble(vm, 5);
  nvgRoundedRect(ctx, x, y, w, h, r);
}

static void wren_nanovg_NvgContext_globalAlpha_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float v = wrenGetSlotDouble(vm, 1);
  nvgGlobalAlpha(ctx, v);
}

static void wren_nanovg_NvgContext_fallbackFont_2(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  int src =  *(int*)wrenGetSlotForeign(vm, 1);
  int dst =  *(int*)wrenGetSlotForeign(vm, 2);
  nvgAddFallbackFontId(ctx, src, dst);
}

static void wren_nanovg_NvgContext_text_5(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  const char* text = wrenGetSlotString(vm, 3);
  int start = wrenGetSlotDouble(vm, 4);
  int end = wrenGetSlotDouble(vm, 5);
  nvgText(ctx, x, y, &text[start], end == -1 ? NULL : &text[end]);
}

static void wren_nanovg_NvgContext_textBox_4(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  float w = wrenGetSlotDouble(vm, 3);
  const char* text = wrenGetSlotString(vm, 4);
  nvgTextBox(ctx, x, y, w, text, NULL);
}

static void wren_nanovg_NvgContext_textLineHeight_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float h = wrenGetSlotDouble(vm, 1);
  nvgTextLineHeight(ctx, h);
}

static void wren_nanovg_NvgContext_moveTo_2(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  nvgMoveTo(ctx, x, y);
}

static void wren_nanovg_NvgContext_lineTo_2(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  nvgLineTo(ctx, x, y);
}

static void wren_nanovg_NvgContext_translate_2(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  nvgTranslate(ctx, x, y);
}

static void wren_nanovg_NvgContext_scale_2(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float x = wrenGetSlotDouble(vm, 1);
  float y = wrenGetSlotDouble(vm, 2);
  nvgScale(ctx, x, y);
}

static void wren_nanovg_NvgContext_rotate_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float r = wrenGetSlotDouble(vm, 1);
  nvgRotate(ctx, r);
}

static void wren_nanovg_NvgContext_bezierTo_6(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float c1x = wrenGetSlotDouble(vm, 1);
  float c1y = wrenGetSlotDouble(vm, 2);
  float c2x = wrenGetSlotDouble(vm, 3);
  float c2y = wrenGetSlotDouble(vm, 4);
  float x = wrenGetSlotDouble(vm, 5);
  float y = wrenGetSlotDouble(vm, 6);
  nvgBezierTo(ctx, c1x, c1y, c2x, c2y, x, y);
}

static void wren_nanovg_NvgContext_arc_6(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float cx = wrenGetSlotDouble(vm, 1);
  float cy = wrenGetSlotDouble(vm, 2);
  float r0 = wrenGetSlotDouble(vm, 3);
  float a0 = wrenGetSlotDouble(vm, 4);
  float a1 = wrenGetSlotDouble(vm, 5);
  enum NVGwinding winding = wrenGetSlotDouble(vm, 6);
  nvgArc(ctx, cx,cy, r0, a0, a1, winding);
}

static void wren_nanovg_NvgContext_lineCap_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  enum NVGlineCap cap = wrenGetSlotDouble(vm, 1);
  nvgLineCap(ctx, cap);
}

static void wren_nanovg_NvgContext_lineJoin_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  enum NVGlineCap cap = wrenGetSlotDouble(vm, 1);
  nvgLineJoin(ctx, cap);
}

static void wren_nanovg_NvgContext_strokeWidth_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  float w = wrenGetSlotDouble(vm, 1);
  nvgStrokeWidth(ctx, w);
}

static void wren_nanovg_NvgContext_pathWinding_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  enum NVGwinding w = wrenGetSlotDouble(vm, 1);
  nvgPathWinding(ctx, w);
}

static void wren_nanovg_NvgContext_strokeColor_1(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  NVGcolor* c =  (NVGcolor*)wrenGetSlotForeign(vm, 1);
  nvgStrokeColor(ctx, *c);
}

static void wren_nanovg_NvgContext_stroke_0(WrenVM* vm){
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 0);
  nvgStroke(ctx);
}

static void wren_nanovg_NvgColor_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(NVGcolor));
}

static void wren_nanovg_NvgColor_rgba__4(WrenVM* vm){
  NVGcolor* color = (NVGcolor*)wrenGetSlotForeign(vm, 0);
  unsigned char r = wrenGetSlotDouble(vm, 1);
  unsigned char g = wrenGetSlotDouble(vm, 2);
  unsigned char b = wrenGetSlotDouble(vm, 3);
  unsigned char a = wrenGetSlotDouble(vm, 4);
  *color = nvgRGBA(r,g,b,a);
}

static void wren_nanovg_NvgColor_hsla__4(WrenVM* vm){
  NVGcolor* color = (NVGcolor*)wrenGetSlotForeign(vm, 0);
  float h = wrenGetSlotDouble(vm, 1);
  float s = wrenGetSlotDouble(vm, 2);
  float l = wrenGetSlotDouble(vm, 3);
  float a = wrenGetSlotDouble(vm, 4);
  *color = nvgHSLA(h,s,l,a);
}

static void wren_nanovg_NvgColor_r(WrenVM* vm){
  NVGcolor* color = (NVGcolor*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, color->r * 255);
}

static void wren_nanovg_NvgColor_g(WrenVM* vm){
  NVGcolor* color = (NVGcolor*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, color->g * 255);
}

static void wren_nanovg_NvgColor_b(WrenVM* vm){
  NVGcolor* color = (NVGcolor*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, color->b * 255);
}

static void wren_nanovg_NvgColor_a(WrenVM* vm){
  NVGcolor* color = (NVGcolor*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, color->a * 255);
}

static void wren_nanovg_NvgColor_delete(void* data){
  // ok
}

static void wren_nanovg_NvgPaint_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(NVGpaint));
}

static void wren_nanovg_NvgPaint_delete(void* data){
  // ok
}

static void wren_nanovg_NvgPaint_radialGradient__7(WrenVM* vm){
  NVGpaint* paint = (NVGpaint*)wrenGetSlotForeign(vm, 0);
  NVGcontext** ctx = (NVGcontext**)wrenGetSlotForeign(vm, 1);
  float cx = wrenGetSlotDouble(vm,2); 
  float cy = wrenGetSlotDouble(vm,3); 
  float inr = wrenGetSlotDouble(vm,4); 
  float outr = wrenGetSlotDouble(vm,5); 
  NVGcolor* icol = (NVGcolor*)wrenGetSlotForeign(vm, 6);
  NVGcolor* ocol = (NVGcolor*)wrenGetSlotForeign(vm, 7);
  *paint = nvgRadialGradient(*ctx, cx, cy, inr, outr, *icol, *ocol);
}

static void wren_nanovg_NvgPaint_boxGradient__9(WrenVM* vm){
  NVGpaint* paint = (NVGpaint*)wrenGetSlotForeign(vm, 0);
  NVGcontext** ctx = (NVGcontext**)wrenGetSlotForeign(vm, 1);
  float x = wrenGetSlotDouble(vm,2); 
  float y = wrenGetSlotDouble(vm,3); 
  float w = wrenGetSlotDouble(vm,4); 
  float h = wrenGetSlotDouble(vm,5); 
  float r = wrenGetSlotDouble(vm,6); 
  float f = wrenGetSlotDouble(vm,7); 
  NVGcolor* icol = (NVGcolor*)wrenGetSlotForeign(vm, 8);
  NVGcolor* ocol = (NVGcolor*)wrenGetSlotForeign(vm, 9);
  *paint = nvgBoxGradient(*ctx, x, y, w, h, r, f, *icol, *ocol);
}

static void wren_nanovg_NvgPaint_imagePattern__8(WrenVM* vm){
  NVGpaint* paint = (NVGpaint*)wrenGetSlotForeign(vm, 0);
  NVGcontext** ctx = (NVGcontext**)wrenGetSlotForeign(vm, 1);
  float x = wrenGetSlotDouble(vm,2); 
  float y = wrenGetSlotDouble(vm,3); 
  float w = wrenGetSlotDouble(vm,4); 
  float h = wrenGetSlotDouble(vm,5); 
  float r = wrenGetSlotDouble(vm,6); 
  int* img = (int*)wrenGetSlotForeign(vm, 7);
  float a = wrenGetSlotDouble(vm,8); 
  *paint = nvgImagePattern(*ctx, x, y, w,h, r, *img, a);
}

static void wren_nanovg_NvgPaint_linearGradient__7(WrenVM* vm){
  NVGpaint* paint = (NVGpaint*)wrenGetSlotForeign(vm, 0);
  NVGcontext** ctx = (NVGcontext**)wrenGetSlotForeign(vm, 1);
  float sx = wrenGetSlotDouble(vm,2); 
  float sy = wrenGetSlotDouble(vm,3); 
  float ex = wrenGetSlotDouble(vm,4); 
  float ey = wrenGetSlotDouble(vm,5); 
  NVGcolor* icol = (NVGcolor*)wrenGetSlotForeign(vm, 6);
  NVGcolor* ocol = (NVGcolor*)wrenGetSlotForeign(vm, 7);
  *paint = nvgLinearGradient(*ctx, sx, sy, ex, ey, *icol, *ocol);
}

static void wren_nanovg_NvgTextRow_allocate(WrenVM*vm){
  wrenSetSlotNewForeign(vm,0,0,sizeof(NVGtextRow));
}

static void wren_nanovg_NvgTextRow_delete(void* data){
  //ok
}

static void wren_nanovg_NvgTextRow_start(WrenVM*vm){
  NVGtextRow* row = (NVGtextRow*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, (int)row->start);
}

static void wren_nanovg_NvgTextRow_end(WrenVM*vm){
  NVGtextRow* row = (NVGtextRow*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, (int)row->end);
}

static void wren_nanovg_NvgTextRow_next(WrenVM*vm){
  NVGtextRow* row = (NVGtextRow*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, (int)row->next);
}

static void wren_nanovg_NvgTextRow_width(WrenVM*vm){
  NVGtextRow* row = (NVGtextRow*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, row->width);
}

static void wren_nanovg_NvgTextRow_minx(WrenVM*vm){
  NVGtextRow* row = (NVGtextRow*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, row->minx);
}

static void wren_nanovg_NvgTextRow_maxx(WrenVM*vm){
  NVGtextRow* row = (NVGtextRow*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, row->maxx);
}

static void wren_nanovg_NvgGlyphPosition_allocate(WrenVM*vm){
  wrenSetSlotNewForeign(vm,0,0,sizeof(NVGglyphPosition));
}

static void wren_nanovg_NvgGlyphPosition_delete(void* data){
  //ok
}

static void wren_nanovg_NvgGlyphPosition_position(WrenVM*vm){
  NVGglyphPosition* row = (NVGglyphPosition*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, (int)row->str);
}

static void wren_nanovg_NvgGlyphPosition_x(WrenVM*vm){
  NVGglyphPosition* row = (NVGglyphPosition*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, row->x);
}

static void wren_nanovg_NvgGlyphPosition_minx(WrenVM*vm){
  NVGglyphPosition* row = (NVGglyphPosition*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, row->minx);
}

static void wren_nanovg_NvgGlyphPosition_maxx(WrenVM*vm){
  NVGglyphPosition* row = (NVGglyphPosition*)wrenGetSlotForeign(vm,0);
  wrenSetSlotDouble(vm, 0, row->maxx);
}

typedef struct {
  int handle;
  NVGcontext* ctx;
} WrenImage;

static void wren_nanovg_NvgImage_allocate(WrenVM*vm){
  NVGcontext* ctx = *(NVGcontext**)wrenGetSlotForeign(vm, 1);
  WrenImage* img = (WrenImage*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(WrenImage));
  img->ctx = ctx;
}

static void wren_nanovg_NvgImage_delete(void* d){
  // ok
}

static void wren_nanovg_NvgImage_fromFile__2(WrenVM*vm){
  WrenImage* handle = (WrenImage*)wrenGetSlotForeign(vm, 0);
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 1);
  const char* filename = wrenGetSlotString(vm, 2);
  handle->handle = nvgCreateImage(ctx, filename, 0);
  if(handle->handle == 0){
    wren_runtime_error(vm, "Image not found or invalid format");
  }
}

static void wren_nanovg_NvgImage_fromMemory__2(WrenVM*vm){
  WrenImage* handle = (WrenImage*)wrenGetSlotForeign(vm, 0);
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 1);
  int length;
  const char* data = wrenGetSlotBytes(vm, 2, &length);
  handle->handle = nvgCreateImageMem(ctx, 0, (unsigned char*)data, length);
  if(handle->handle == 0){
    wren_runtime_error(vm, "Image not found or invalid format");
  }
}

static void wren_nanovg_NvgImage_fromImageData__2(WrenVM*vm){
  WrenImage* handle = (WrenImage*)wrenGetSlotForeign(vm, 0);
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 1);
  ImageData* img =  (ImageData*)wrenGetSlotForeign(vm, 2);
  handle->handle = nvgCreateImageRGBA(ctx, img->width, img->height, 0, img->pixels);
  if(handle->handle == 0){
    wren_runtime_error(vm, "Image not found or invalid format");
  }
}

static void wren_nanovg_NvgImage_width(WrenVM*vm){
  WrenImage* handle = (WrenImage*)wrenGetSlotForeign(vm, 0);
  int w, h;
  nvgImageSize(handle->ctx, handle->handle, &w, &h);
  wrenSetSlotDouble(vm, 0, w);
}

static void wren_nanovg_NvgImage_height(WrenVM*vm){
  WrenImage* handle = (WrenImage*)wrenGetSlotForeign(vm, 0);
  int w, h;
  nvgImageSize(handle->ctx, handle->handle, &w, &h);
  wrenSetSlotDouble(vm, 0, h);
}

static void wren_nanovg_NvgFont_allocate(WrenVM*vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(int));
}

static void wren_nanovg_NvgFont_delete(void* d){
  // ok
}

static void wren_nanovg_NvgFont_fromFile__2(WrenVM*vm){
  int* handle = (int*)wrenGetSlotForeign(vm, 0);
  NVGcontext* ctx =  *(NVGcontext**)wrenGetSlotForeign(vm, 1);
  const char* filename = wrenGetSlotString(vm, 2);
  *handle = nvgCreateFont(ctx, "font", filename);
  if(*handle == -1){
    wren_runtime_error(vm, "File not found or invalid font");
  }
}

static void init_wren(WrenVM* vm){
  wrenEnsureSlots(vm, 1);
  wrenGetVariable(vm, "wren-nanovg", "NvgGlyphPosition", 0);
  glyphPositionClassHandle = wrenGetSlotHandle(vm, 0);
}

static void wren_nanovg_ImageData_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(ImageData));
}

static void wren_nanovg_ImageData_delete(void* data){
  ImageData* img = (ImageData*)data;
  if(img->pixels != NULL){
    free(img->pixels);
  }
}

static void wren_nanovg_ImageData_fromFile__1(WrenVM* vm){
  ImageData* img = (ImageData*)wrenGetSlotForeign(vm, 0);
  const char* str = wrenGetSlotString(vm, 1);
  img->pixels = stbi_load(str, &img->width, &img->height, NULL, 4);
  if(img->pixels == NULL){ 
    wren_runtime_error(vm, "Error loading image");
  }
}

static void wren_nanovg_ImageData_fromMemory__1(WrenVM* vm){
  ImageData* img = (ImageData*)wrenGetSlotForeign(vm, 0);
  int length;
  const unsigned char* buffer = wrenGetSlotBytes(vm, 1, &length);
  img->pixels = stbi_load_from_memory(buffer, length, &img->width, &img->height, NULL, 4);
  if(img->pixels == NULL){ 
    wren_runtime_error(vm, "Error loading image");
  }
}

static void wren_nanovg_ImageData_init__2(WrenVM* vm){
  ImageData* img = (ImageData*)wrenGetSlotForeign(vm, 0);
  img->width = wrenGetSlotDouble(vm, 1);
  img->height = wrenGetSlotDouble(vm, 2);
  img->pixels = calloc(img->width*img->height, sizeof(unsigned char));
}

static void wren_nanovg_ImageData_width(WrenVM* vm){
  ImageData* img = (ImageData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, img->width);
}

static void wren_nanovg_ImageData_height(WrenVM* vm){
  ImageData* img = (ImageData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, img->height);
}

static void wren_nanovg_ImageData_resize_2(WrenVM* vm){
  ImageData* img = (ImageData*)wrenGetSlotForeign(vm, 0);
  int nw = wrenGetSlotDouble(vm, 1);
  int nh = wrenGetSlotDouble(vm, 2);
  unsigned char* newPixels = malloc(nw*nh*sizeof(unsigned char)*4);
  int err = stbir_resize_uint8(img->pixels, img->width, img->height, 0, newPixels, nw, nh, 0, 4);
  if(err == 0){
    wren_runtime_error(vm, "Error resizing");
  }
  free(img->pixels);
  img->pixels = newPixels;
  img->width = nw;
  img->height = nh;
}


void wrt_plugin_init(){
  wrt_bind_class("wren-nanovg.NvgContext", wren_nanovg_NvgContext_allocate, wren_nanovg_NvgContext_delete);
  wrt_bind_method("wren-nanovg.NvgContext.create_(_)", wren_nanovg_NvgContext_create__1);
  wrt_bind_method("wren-nanovg.NvgContext.beginFrame(_,_,_)", wren_nanovg_NvgContext_beginFrame_3);
  wrt_bind_method("wren-nanovg.NvgContext.endFrame()", wren_nanovg_NvgContext_endFrame_0);
  wrt_bind_method("wren-nanovg.NvgContext.beginPath()", wren_nanovg_NvgContext_beginPath_0);
  wrt_bind_method("wren-nanovg.NvgContext.closePath()", wren_nanovg_NvgContext_closePath_0);
  wrt_bind_method("wren-nanovg.NvgContext.rect(_,_,_,_)", wren_nanovg_NvgContext_rect_4);
  wrt_bind_method("wren-nanovg.NvgContext.scissor(_,_,_,_)", wren_nanovg_NvgContext_scissor_4);
  wrt_bind_method("wren-nanovg.NvgContext.intersectScissor(_,_,_,_)", wren_nanovg_NvgContext_intersectScissor_4);
  wrt_bind_method("wren-nanovg.NvgContext.resetScissor()", wren_nanovg_NvgContext_resetScissor_0);
  wrt_bind_method("wren-nanovg.NvgContext.ellipse(_,_,_,_)", wren_nanovg_NvgContext_ellipse_4);
  wrt_bind_method("wren-nanovg.NvgContext.circle(_,_,_)", wren_nanovg_NvgContext_circle_3);
  wrt_bind_method("wren-nanovg.NvgContext.fillColor(_)", wren_nanovg_NvgContext_fillColor_1);
  wrt_bind_method("wren-nanovg.NvgContext.fillPaint(_)", wren_nanovg_NvgContext_fillPaint_1);
  wrt_bind_method("wren-nanovg.NvgContext.fill()", wren_nanovg_NvgContext_fill_0);
  wrt_bind_method("wren-nanovg.NvgContext.save()", wren_nanovg_NvgContext_save_0);
  wrt_bind_method("wren-nanovg.NvgContext.restore()", wren_nanovg_NvgContext_restore_0);
  wrt_bind_method("wren-nanovg.NvgContext.fontSize(_)", wren_nanovg_NvgContext_fontSize_1);
  wrt_bind_method("wren-nanovg.NvgContext.fontBlur(_)", wren_nanovg_NvgContext_fontBlur_1);
  wrt_bind_method("wren-nanovg.NvgContext.fontFace(_)", wren_nanovg_NvgContext_fontFace_1);
  wrt_bind_method("wren-nanovg.NvgContext.textAlign(_)", wren_nanovg_NvgContext_textAlign_1);
  wrt_bind_method("wren-nanovg.NvgContext.textMetrics()", wren_nanovg_NvgContext_textMetrics_0);
  wrt_bind_method("wren-nanovg.NvgContext.textBreakLine(_,_,_,_)", wren_nanovg_NvgContext_textBreakLine_4);
  wrt_bind_method("wren-nanovg.NvgContext.textGlyphPositions(_,_,_,_,_)", wren_nanovg_NvgContext_textGlyphPosition_5);
  wrt_bind_method("wren-nanovg.NvgContext.fallbackFont(_,_)", wren_nanovg_NvgContext_fallbackFont_2);
  wrt_bind_method("wren-nanovg.NvgContext.text(_,_,_,_,_)", wren_nanovg_NvgContext_text_5);
  wrt_bind_method("wren-nanovg.NvgContext.textLineHeight(_)", wren_nanovg_NvgContext_textLineHeight_1);
  wrt_bind_method("wren-nanovg.NvgContext.textBounds(_,_,_)", wren_nanovg_NvgContext_textBounds_3);
  wrt_bind_method("wren-nanovg.NvgContext.textWidth(_,_,_)", wren_nanovg_NvgContext_textWidth_3);
  wrt_bind_method("wren-nanovg.NvgContext.textBoxBounds(_,_,_,_)", wren_nanovg_NvgContext_textBoxBounds_4);
  wrt_bind_method("wren-nanovg.NvgContext.textBox(_,_,_,_)", wren_nanovg_NvgContext_textBox_4);
  wrt_bind_method("wren-nanovg.NvgContext.roundedRect(_,_,_,_,_)", wren_nanovg_NvgContext_roundedRect_5);
  wrt_bind_method("wren-nanovg.NvgContext.globalAlpha(_)", wren_nanovg_NvgContext_globalAlpha_1);
  wrt_bind_method("wren-nanovg.NvgContext.moveTo(_,_)", wren_nanovg_NvgContext_moveTo_2);
  wrt_bind_method("wren-nanovg.NvgContext.lineTo(_,_)", wren_nanovg_NvgContext_lineTo_2);
  wrt_bind_method("wren-nanovg.NvgContext.translate(_,_)", wren_nanovg_NvgContext_translate_2);
  wrt_bind_method("wren-nanovg.NvgContext.scale(_,_)", wren_nanovg_NvgContext_scale_2);
  wrt_bind_method("wren-nanovg.NvgContext.rotate(_)", wren_nanovg_NvgContext_rotate_1);
  wrt_bind_method("wren-nanovg.NvgContext.bezierTo(_,_,_,_,_,_)", wren_nanovg_NvgContext_bezierTo_6);
  wrt_bind_method("wren-nanovg.NvgContext.arc(_,_,_,_,_,_)", wren_nanovg_NvgContext_arc_6);
  wrt_bind_method("wren-nanovg.NvgContext.lineCap(_)", wren_nanovg_NvgContext_lineCap_1);
  wrt_bind_method("wren-nanovg.NvgContext.lineJoin(_)", wren_nanovg_NvgContext_lineJoin_1);
  wrt_bind_method("wren-nanovg.NvgContext.strokeWidth(_)", wren_nanovg_NvgContext_strokeWidth_1);
  wrt_bind_method("wren-nanovg.NvgContext.strokeColor(_)", wren_nanovg_NvgContext_strokeColor_1);
  wrt_bind_method("wren-nanovg.NvgContext.stroke()", wren_nanovg_NvgContext_stroke_0);
  wrt_bind_method("wren-nanovg.NvgContext.pathWinding(_)", wren_nanovg_NvgContext_pathWinding_1);
  
  wrt_bind_class("wren-nanovg.NvgColor", wren_nanovg_NvgColor_allocate, wren_nanovg_NvgColor_delete);
  wrt_bind_method("wren-nanovg.NvgColor.rgba_(_,_,_,_)", wren_nanovg_NvgColor_rgba__4);
  wrt_bind_method("wren-nanovg.NvgColor.hsla_(_,_,_,_)", wren_nanovg_NvgColor_hsla__4);
  wrt_bind_method("wren-nanovg.NvgColor.r", wren_nanovg_NvgColor_r);
  wrt_bind_method("wren-nanovg.NvgColor.g", wren_nanovg_NvgColor_g);
  wrt_bind_method("wren-nanovg.NvgColor.b", wren_nanovg_NvgColor_b);
  wrt_bind_method("wren-nanovg.NvgColor.a", wren_nanovg_NvgColor_a);

  wrt_bind_class("wren-nanovg.NvgPaint", wren_nanovg_NvgPaint_allocate, wren_nanovg_NvgPaint_delete);
  wrt_bind_method("wren-nanovg.NvgPaint.linearGradient_(_,_,_,_,_,_,_)", wren_nanovg_NvgPaint_linearGradient__7);
  wrt_bind_method("wren-nanovg.NvgPaint.radialGradient_(_,_,_,_,_,_,_)", wren_nanovg_NvgPaint_radialGradient__7);
  wrt_bind_method("wren-nanovg.NvgPaint.boxGradient_(_,_,_,_,_,_,_,_,_)", wren_nanovg_NvgPaint_boxGradient__9);
  wrt_bind_method("wren-nanovg.NvgPaint.imagePattern_(_,_,_,_,_,_,_,_)", wren_nanovg_NvgPaint_imagePattern__8);
  
  wrt_bind_class("wren-nanovg.NvgTextRow", wren_nanovg_NvgTextRow_allocate, wren_nanovg_NvgTextRow_delete);
  wrt_bind_method("wren-nanovg.NvgTextRow.start", wren_nanovg_NvgTextRow_start);
  wrt_bind_method("wren-nanovg.NvgTextRow.end", wren_nanovg_NvgTextRow_end);
  wrt_bind_method("wren-nanovg.NvgTextRow.next", wren_nanovg_NvgTextRow_next);
  wrt_bind_method("wren-nanovg.NvgTextRow.width", wren_nanovg_NvgTextRow_width);
  wrt_bind_method("wren-nanovg.NvgTextRow.minx", wren_nanovg_NvgTextRow_minx);
  wrt_bind_method("wren-nanovg.NvgTextRow.maxx", wren_nanovg_NvgTextRow_maxx);

  wrt_bind_class("wren-nanovg.NvgGlyphPosition", wren_nanovg_NvgGlyphPosition_allocate, wren_nanovg_NvgGlyphPosition_delete);
  wrt_bind_method("wren-nanovg.NvgGlyphPosition.position", wren_nanovg_NvgGlyphPosition_position);
  wrt_bind_method("wren-nanovg.NvgGlyphPosition.x", wren_nanovg_NvgGlyphPosition_x);
  wrt_bind_method("wren-nanovg.NvgGlyphPosition.minx", wren_nanovg_NvgGlyphPosition_minx);
  wrt_bind_method("wren-nanovg.NvgGlyphPosition.maxx", wren_nanovg_NvgGlyphPosition_maxx);

  wrt_bind_class("wren-nanovg.NvgImage", wren_nanovg_NvgImage_allocate, wren_nanovg_NvgImage_delete);
  wrt_bind_method("wren-nanovg.NvgImage.fromFile_(_,_)", wren_nanovg_NvgImage_fromFile__2);
  wrt_bind_method("wren-nanovg.NvgImage.fromMemory_(_,_)", wren_nanovg_NvgImage_fromMemory__2);
  wrt_bind_method("wren-nanovg.NvgImage.fromImageData_(_,_)", wren_nanovg_NvgImage_fromImageData__2);
  wrt_bind_method("wren-nanovg.NvgImage.width", wren_nanovg_NvgImage_width);
  wrt_bind_method("wren-nanovg.NvgImage.height", wren_nanovg_NvgImage_height);

  wrt_bind_class("wren-nanovg.NvgFont", wren_nanovg_NvgFont_allocate, wren_nanovg_NvgFont_delete);
  wrt_bind_method("wren-nanovg.NvgFont.fromFile_(_,_)", wren_nanovg_NvgFont_fromFile__2);

  wrt_bind_class("wren-nanovg.ImageData", wren_nanovg_ImageData_allocate, wren_nanovg_ImageData_delete);
  wrt_bind_method("wren-nanovg.ImageData.fromFile_(_)", wren_nanovg_ImageData_fromFile__1);
  wrt_bind_method("wren-nanovg.ImageData.fromMemory_(_)", wren_nanovg_ImageData_fromMemory__1);
  wrt_bind_method("wren-nanovg.ImageData.init_(_,_)", wren_nanovg_ImageData_init__2);
  wrt_bind_method("wren-nanovg.ImageData.resize(_,_)", wren_nanovg_ImageData_resize_2);
  wrt_bind_method("wren-nanovg.ImageData.width", wren_nanovg_ImageData_width);
  wrt_bind_method("wren-nanovg.ImageData.height", wren_nanovg_ImageData_height);

  wrt_wren_init_callback(init_wren);
}
