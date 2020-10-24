
// #define GL_([^\s]+)\s+([0-9,A-F,x]+)
class ClearFlag {
  static DEPTH_BUFFER_BIT { 0x00000100 }
  static STENCIL_BUFFER_BIT { 0x00000400 }
  static COLOR_BUFFER_BIT { 0x00004000 }
}

class EnableCap {
  static TEXTURE_2D { 0x0DE1 }
  static CULL_FACE { 0x0B44 }
  static BLEND { 0x0BE2 }
  static DITHER { 0x0BD0 }
  static STENCIL_TEST { 0x0B90 }
  static DEPTH_TEST { 0x0B71 }
  static SCISSOR_TEST { 0x0C11 }
  static POLYGON_OFFSET_FILL { 0x8037 }
  static SAMPLE_ALPHA_TO_COVERAGE { 0x809E }
  static SAMPLE_COVERAGE { 0x80A0 }
}

class BlendFacDst {
  static ZERO { 0 }
  static ONE { 1 }
  static SRC_COLOR { 0x0300 }
  static ONE_MINUS_SRC_COLOR { 0x0301 }
  static SRC_ALPHA { 0x0302 }
  static ONE_MINUS_SRC_ALPHA { 0x0303 }
  static DST_ALPHA { 0x0304 }
  static ONE_MINUS_DST_ALPHA { 0x0305 }
}

class BlendFacSrc {
  static DST_COLOR { 0x0306 }
  static ONE_MINUS_DST_COLOR { 0x0307 }
  static SRC_ALPHA_SATURATE { 0x0308 }
}

class ErrorCode {
  static NO_ERROR { 0 }
  static INVALID_ENUM { 0x0500 }
  static INVALID_VALUE { 0x0501 }
  static INVALID_OPERATION { 0x0502 }
  static OUT_OF_MEMORY { 0x0505 }
}

class GL {
  foreign static clear(clearflags)
  foreign static clearColor(r,g,b,a)
  foreign static enable(enableCap)
  foreign static disable(enableCap)
  foreign static blendFunc(blendfacsrc, blendfacdst)
  foreign static getError()
  foreign static viewport(x,y,w,h)
}