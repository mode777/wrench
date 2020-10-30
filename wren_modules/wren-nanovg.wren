class NvgMath {
  static degToRad(deg){ deg/180 * Num.pi }
  static radToDeg(rad){ rad / Num.pi * 180 }
}

foreign class NvgColor {
  construct rgba(r,g,b,a){
    rgba_(r,g,b,a)
  }
  construct hsla(h,s,l,a){
    hsla_(h,s,l,a)
  }

  foreign rgba_(r,g,b,a)
  foreign hsla_(h,s,l,a)
  foreign r
  foreign g
  foreign b
  foreign a
}

foreign class NvgPaint {
  construct linearGradient(ctx, sx, sy, ex, ey, icol, ocol){
    linearGradient_(ctx, sx, sy, ex, ey, icol, ocol)
  }
  construct radialGradient(ctx, cx, cy, inr, outr, icol, ocol){
    radialGradient_(ctx, cx, cy, inr, outr, icol, ocol)
  }
  construct boxGradient(ctx, x, y, w, h, r, f, icol, ocol){
    boxGradient_(ctx, x, y, w, h, r, f, icol, ocol)
  }  
  construct imagePattern(ctx, x, y, w, h, angle, image, alpha){
    imagePattern_(ctx, x, y, w, h, angle, image, alpha)
  }

  foreign linearGradient_(ctx, sx, sy, ex, ey, icol, ocol)
  foreign radialGradient_(ctx, cx, cy, inr, outr, icol, ocol)
  foreign boxGradient_(ctx, x, y, w, h, r, f, icol, ocol)
  foreign imagePattern_(ctx, x, y, w, h, angle, image, alpha)
}

foreign class NvgTextRow {
  construct new() {}
  foreign start
  foreign end
  foreign next
  foreign width
  foreign minx
  foreign maxx
}

foreign class NvgGlyphPosition {
  construct new() {}
  foreign position
  foreign x
  foreign minx
  foreign maxx
}

foreign class NvgImage{
  construct fromFile(ctx, path){
    fromFile_(ctx, path)
  }
  construct fromMemory(ctx, mem){
    fromMemory_(ctx, mem)
  }
  construct fromImageData(ctx, id){
    fromImageData_(ctx, id)
  }
  foreign fromFile_(ctx,path)
  foreign fromMemory_(ctx,mem)
  foreign fromImageData_(ctx,id)
  foreign width
  foreign height
}

foreign class NvgFont{
  construct fromFile(ctx, path){
    fromFile_(ctx, path)
  }
  foreign fromFile_(ctx, path)
}

foreign class NvgContext {
  construct new(flags){
    create_(flags)
  }

  foreign create_(flags)
  foreign beginFrame(w,h,ratio)
  foreign endFrame()
  foreign beginPath()

  foreign rect(x,y,w,h)
  foreign ellipse(cx, cy, rx, ry)
  foreign circle(cx, cy, r)
  
  foreign fillColor(color)
  foreign fillPaint(paint)
  foreign fill()
  foreign save()
  foreign restore()

  foreign fontSize(size)
  foreign fontFace(nvgFont)
  foreign fontBlur(v)

  foreign globalAlpha(v)

  foreign moveTo(x,y)
  foreign roundedRect(x,y,w,h,r)
  foreign lineTo(x,y)
  foreign bezierTo(cx1, cy1, cx2, cy2, x,y)
  foreign arc(cx,cy, r0, a0, a1, winding)
  foreign closePath()
  foreign pathWinding(winding)

  foreign translate(x,y)
  foreign rotate(r)
  foreign scale(x,y)

  foreign textLineHeight(height)
  foreign textGlyphPositions(x, y, string, start, end)
  foreign textBounds(x,y,str)
  foreign textWidth(x,y,str)
  foreign textBoxBounds(x,y,w,str)
  foreign textBox(x,y,w,text)
  foreign textAlign(align)
  foreign textMetrics()
  foreign textBreakLine(text, start, width, nvgTextRow)
  foreign fallbackFont(srcFont, dstFont)
  foreign text(x,y,text,start,end)
  text(x,y,text) { 
    this.text(x,y,text,0,-1)
  }
  foreign strokeWidth(w)
  foreign strokeColor(nvgColor)
  foreign stroke()

  foreign lineCap(cap)
  foreign lineJoin(cap)

  foreign scissor(x,y,w,h)
  foreign intersectScissor(x,y,w,h)
  foreign resetScissor()
}

foreign class ImageData {
  construct fromFile(path){
    fromFile_(path)
  }
  construct fromMemory(data){
    fromMemory_(data)
  }
  construct new(w,h){
    init_(w,h)
  }

  foreign init_(w,h)
  foreign fromFile_(p)
  foreign fromMemory_(d)
  foreign resize(w,h)
  foreign width
  foreign height
}

class TextAlign {
  // Horizontal align
	static ALIGN_LEFT { 1<<0 }	// Default, align text horizontally to left.
	static ALIGN_CENTER { 1<<1 }	// Align text horizontally to center.
	static ALIGN_RIGHT { 1<<2 }	// Align text horizontally to right.
	// Vertical align
	static ALIGN_TOP { 1<<3 }	// Align text vertically to top.
	static ALIGN_MIDDLE { 1<<4 }	// Align text vertically to middle.
	static ALIGN_BOTTOM { 1<<5 }	// Align text vertically to bottom.
	static ALIGN_BASELINE { 1<<6 } // Default, align text vertically to baseline.
}

class Winding {
	static NVG_CCW { 1 }			// Winding for solid shapes
	static NVG_CW { 2 }				// Winding for holes
}

class Solidity {
	static NVG_SOLID { 1 }			// CCW
	static NVG_HOLE { 2 }				// CW
}

class Cap {
	static NVG_BUTT { 0 }
	static NVG_ROUND { 1 }
	static NVG_SQUARE { 2 }
	static NVG_BEVEL { 3 }
	static NVG_MITER { 4 }
}

class CreateFlags {
  static NONE { 0 }
  static ANTIALIAS { 1 }
  static STENCIL_STROKES { 2 }
  static DEBUG { 4 }
}

class NanoVG {
  foreign static init()
}

NanoVG.init()