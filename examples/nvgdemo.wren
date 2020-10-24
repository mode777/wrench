import "wren-nanovg" for NvgContext, NvgColor, NvgPaint, TextAlign, NvgTextRow, NvgImage, NvgFont, NvgGlyphPosition, Winding, Solidity, Cap, NvgMath
//http://web.archive.org/web/20140912210715/http://entypo.com/characters/
// nvg([^\(]+)\(ctx,([^\)]+)\)
//nvg([^\(]+)\(ctx,?\s?
var Images = []
var Font = null
var FontBold = null
var FontEmoji = null
var FontIcons = null

class NvgDemo {
  static clamp(a, mn, mx) { a < mn ? mn : (a > mx ? mx : a) }
  static loadData(ctx){
    for(i in 0...12){
      Images.add(NvgImage.fromFile(ctx, "./nanovg/example/images/image%(i+1).jpg"))
    }
    FontIcons = NvgFont.fromFile(ctx, "./nanovg/example/entypo.ttf")
    Font = NvgFont.fromFile(ctx, "./nanovg/example/Roboto-Regular.ttf")
    FontBold = NvgFont.fromFile(ctx, "./nanovg/example/Roboto-Bold.ttf")
    FontEmoji = NvgFont.fromFile(ctx, "./nanovg/example/NotoEmoji-Regular.ttf")
    ctx.fallbackFont(Font, FontEmoji)
    ctx.fallbackFont(FontBold, FontEmoji)
  }

  static renderDemo(ctx, mx, my, w, h, t, blowup){
    drawEyes(ctx, w-250, 50, 150, 100, mx, my, t)
    drawParagraph(ctx, w-450, 50, 150, 100, mx, my)
    drawGraph(ctx, 0, h/2, w, h/2, t)
    drawColorWheel(ctx, w-300, h-300, 250, 250, t)
    drawLines(ctx, 120, h-50, 600, 50, t)

    drawCaps(ctx, 10, 50, 30)

    drawScissor(ctx, 50, h-80, t)

    ctx.save()

    if (blowup) {
      ctx.rotate((t*0.3).sin*5.0/180.0*Num.pi)
      ctx.scale(2.0, 2.0)
    }

    // Widgets
    drawWindow(ctx, "Widgets `n Stuff", 50, 50, 300, 400)
    var x = 60 
    var y = 95
    drawSearchBox(ctx, "Search", x,y,280,25)
    y = y + 40
    drawDropDown(ctx, "Effects", x,y,280,28)
    var popy = y + 14
    y = y + 45

    // Form
    drawLabel(ctx, "Login", x,y, 280,20)
    y = y + 25
    drawEditBox(ctx, "Email",  x,y, 280,28)
    y = y + 35
    drawEditBox(ctx, "Password", x,y, 280,28)
    y = y + 38
    drawCheckBox(ctx, "Remember me", x,y, 140,28)
    drawButton(ctx, "\uE740", "Sign in", x+138, y, 140, 28, NvgColor.rgba(0,96,128,255))
    y = y + 45

    // Slider
    drawLabel(ctx, "Diameter", x,y, 280,20)
    y = y + 25
    drawEditBoxNum(ctx, "123.00", "px", x+180,y, 100,28)
    drawSlider(ctx, 0.4, x,y, 170,28)
    y = y + 55

    drawButton(ctx, "\uE729", "Delete", x, y, 160, 28, NvgColor.rgba(128,16,8,255))
    drawButton(ctx, 0, "Cancel", x+170, y, 110, 28, NvgColor.rgba(0,0,0,0))

    // // Thumbnails box
    drawThumbnails(ctx, 365, popy-30, 160, 300, Images, t)

    ctx.restore()
  }

  static drawEyes(ctx, x, y, w, h, mx, my, t){
    var ex = w *0.23
    var ey = h * 0.5
    var lx = x + ex
    var ly = y + ey
    var rx = x + w - ex
    var ry = y + ey
    
    var br = (ex < ey ? ex : ey) * 0.5
    var blink = 1 - ((t*0.5).sin.pow(200))*0.8

    var bg = NvgPaint.linearGradient(ctx,x,y+h*0.5,x+w*0.1,y+h, NvgColor.rgba(0,0,0,32), NvgColor.rgba(0,0,0,16))
    ctx.beginPath()
    ctx.ellipse(lx+3.0,ly+16.0, ex,ey)
    ctx.ellipse(rx+3.0,ry+16.0, ex,ey)
    ctx.fillPaint(bg)
    ctx.fill()

    bg = NvgPaint.linearGradient(ctx, x,y+h*0.25,x+w*0.1,y+h, NvgColor.rgba(220,220,220,255), NvgColor.rgba(128,128,128,255))
    ctx.beginPath()
    ctx.ellipse(lx,ly, ex,ey)
    ctx.ellipse(rx,ry, ex,ey)
    ctx.fillPaint(bg)
    ctx.fill()

    var dx = (mx - rx) / (ex * 10)
    var dy = (my - ry) / (ey * 10)
    var d =  (dx*dx+dy*dy).sqrt
    if (d > 1) {
       dx = dx / d
       dy = dy / d
    }
    dx = dx * ex * 0.4
    dy = dy * ey * 0.5
    ctx.beginPath()
    ctx.ellipse(lx+dx,ly+dy+ey*0.25*(1-blink), br,br*blink)
    ctx.fillColor(NvgColor.rgba(32,32,32,255))
    ctx.fill()

    dx = (mx - rx) / (ex * 10)
    dy = (my - ry) / (ey * 10)
    d = (dx*dx+dy*dy).sqrt
    if (d > 1.0) {
       dx = dx / d
       dy = dy / d
    }
    dx = dx * ex*0.4
    dy = dy * ey*0.5
    ctx.beginPath()
    ctx.ellipse(rx+dx,ry+dy+ey*0.25*(1-blink), br,br*blink)
    ctx.fillColor(NvgColor.rgba(32,32,32,255))
    ctx.fill()

    var gloss = NvgPaint.radialGradient(ctx,lx-ex*0.25,ly-ey*0.5, ex*0.1,ex*0.75, NvgColor.rgba(255,255,255,128), NvgColor.rgba(255,255,255,0))
    ctx.beginPath()
    ctx.ellipse(lx,ly, ex,ey)
    ctx.fillPaint(gloss)
    ctx.fill()

    gloss = NvgPaint.radialGradient(ctx, rx-ex*0.25,ry-ey*0.5, ex*0.1,ex*0.75, NvgColor.rgba(255,255,255,128), NvgColor.rgba(255,255,255,0))
    ctx.beginPath()
    ctx.ellipse(rx,ry, ex,ey)
    ctx.fillPaint(gloss)
    ctx.fill()
  }

  static drawParagraph(ctx, x, y, w, h, mx, my){
    var text = "This is 💋longer chunk of text.\n  \n  Would have used lorem 💩👀 ipsum but she    was busy jumping over the lazy dog with the fox and all the men who came to the aid of the party.🎉"
    var lnum = 0
    var bounds = [0,0,0,0]
    var hoverText = "Hover your mouse over the text to see calculated caret position."
    var gutter = 0
    var boxText = "Testing\nsome multiline\ntext."
    
    ctx.save()
    
    ctx.fontSize(15)
    ctx.fontFace(Font)
    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_TOP)
    var metrics = ctx.textMetrics()
    var lineh = metrics[2]
    
    var gx
    var gy

    var row = NvgTextRow.new()
    while(ctx.textBreakLine(text, row.next, w, row)){
        var hit = mx > x && mx < (x+w) && my >= y && my < (y+lineh)

        ctx.beginPath()
        ctx.fillColor(NvgColor.rgba(255,255,255,hit?64:16))
        ctx.rect(x + row.minx, y, row.maxx - row.minx, lineh)
        ctx.fill()

        ctx.fillColor(NvgColor.rgba(255,255,255,255))
        ctx.text(x, y, text, row.start, row.end)

        if(hit) {
          var caretx = (mx < x+row.width/2) ? x : x+row.width
          var px = x
          var glyphs = ctx.textGlyphPositions(x,y,text,row.start,row.end)
          for(glyph in glyphs){
            var gx = glyph.x
            if (mx >= px && mx < gx){
              caretx = glyph.x
            }
            px = gx
          }
          ctx.beginPath()
          ctx.fillColor(NvgColor.rgba(255,192,0,255))
          ctx.rect(caretx, y, 1, lineh)
          ctx.fill()

          gutter = lnum+1
          gx = x - 10
          gy = y + lineh/2
        }
        lnum = lnum + 1
        y = y + lineh
    }
    
    if (gutter > 0) {
      ctx.fontSize(12)
      ctx.textAlign(TextAlign.ALIGN_RIGHT|TextAlign.ALIGN_MIDDLE)
      bounds = ctx.textBounds(gx,gy,gutter.toString)

      ctx.beginPath()
      ctx.fillColor(NvgColor.rgba(255,192,0,255))
      ctx.roundedRect(bounds[0]-4,bounds[1]-2, bounds[2]-bounds[0]+8, bounds[3]-bounds[1]+4, (bounds[3]-bounds[1]+4)/2-1)
      ctx.fill()

      ctx.fillColor(NvgColor.rgba(32,32,32,255))
      ctx.text(gx,gy, gutter.toString)
    }

    y = y+20.0

    ctx.fontSize(11.0)
    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_TOP)
    ctx.textLineHeight(1.2)

    bounds = ctx.textBoxBounds(x,y, 150, hoverText)

    // // Fade the tooltip out when close to it.
    gx = clamp(mx, bounds[0], bounds[2]) - mx
    gy = clamp(my, bounds[1], bounds[3]) - my
    var a = (gx*gx + gy*gy).sqrt / 30.0
    a = clamp(a, 0, 1)
    ctx.globalAlpha(a)

    ctx.beginPath()
    ctx.fillColor(NvgColor.rgba(220,220,220,255))
    ctx.roundedRect(bounds[0]-2,bounds[1]-2, (bounds[2]-bounds[0]).floor+4, (bounds[3]-bounds[1]).floor+4, 3)
    var px = ((bounds[2]+bounds[0])/2).floor
    ctx.moveTo(px,bounds[1] - 10)
    ctx.lineTo(px+7,bounds[1]+1)
    ctx.lineTo(px-7,bounds[1]+1)
    ctx.fill()

    ctx.fillColor(NvgColor.rgba(0,0,0,220))
    ctx.textBox(x,y, 150, hoverText)

    ctx.restore()
  }

  static drawGraph(ctx, x, y, w, h, t){
    var bg
    var samples = List.filled(6, 0)
    var sx = List.filled(6, 0)
    var sy = List.filled(6, 0)
    var dx = w/5.0
    var i

    samples[0] = (1+(t*1.2345+(t*0.33457).cos*0.44).sin)*0.5
    samples[1] = (1+(t*0.68363+(t*1.3).cos*1.55).sin)*0.5
    samples[2] = (1+(t*1.1642+(t*0.33457).cos*1.24).sin)*0.5
    samples[3] = (1+(t*0.56345+(t*1.63).cos*0.14).sin)*0.5
    samples[4] = (1+(t*1.6245+(t*0.254).cos*0.3).sin)*0.5
    samples[5] = (1+(t*0.345+(t*0.03).cos*0.6).sin)*0.5

    for (i in 0...6) {
      sx[i] = x+i*dx
      sy[i] = y+h*samples[i]*0.8
    }

    // Graph background
    bg = NvgPaint.linearGradient(ctx,x,y,x,y+h, NvgColor.rgba(0,160,192,0), NvgColor.rgba(0,160,192,64))
    ctx.beginPath()
    ctx.moveTo( sx[0], sy[0])
    for (i in 1...6){
      ctx.bezierTo(sx[i-1]+dx*0.5,sy[i-1], sx[i]-dx*0.5,sy[i], sx[i],sy[i])
    }
    ctx.lineTo(x+w, y+h)
    ctx.lineTo(x, y+h)
    ctx.fillPaint(bg)
    ctx.fill()

    // Graph line
    ctx.beginPath()
    ctx.moveTo( sx[0], sy[0]+2)
    for (i in 1...6){
      ctx.bezierTo( sx[i-1]+dx*0.5,sy[i-1]+2, sx[i]-dx*0.5,sy[i]+2, sx[i],sy[i]+2)
    }
    ctx.strokeColor(NvgColor.rgba(0,0,0,32))
    ctx.strokeWidth(3.0)
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo( sx[0], sy[0])
    for (i in 1...6){
      ctx.bezierTo( sx[i-1]+dx*0.5,sy[i-1], sx[i]-dx*0.5,sy[i], sx[i],sy[i])
    }
    ctx.strokeColor( NvgColor.rgba(0,160,192,255))
    ctx.strokeWidth(3.0)
    ctx.stroke()

    // Graph sample pos
    for (i in 0...6) {
      bg = NvgPaint.radialGradient(ctx, sx[i],sy[i]+2, 3.0,8.0, NvgColor.rgba(0,0,0,32), NvgColor.rgba(0,0,0,0))
      ctx.beginPath()
      ctx.rect(sx[i]-10, sy[i]-10+2, 20,20)
      ctx.fillPaint(bg)
      ctx.fill()
    }

    ctx.beginPath()
    for (i in 0...6){
      ctx.circle( sx[i], sy[i], 4.0)
    }
    ctx.fillColor( NvgColor.rgba(0,160,192,255))
    ctx.fill()
    ctx.beginPath()
    for (i in 0...6){
      ctx.circle( sx[i], sy[i], 2.0)
    }
    ctx.fillColor( NvgColor.rgba(220,220,220,255))
    ctx.fill()

    ctx.strokeWidth( 1.0)
  }

  static drawColorWheel(ctx, x, y, w, h, t){
    var i
    var r0
    var r1
    var ax
    var ay
    var bx
    var by
    var cx
    var cy
    var aeps
    var r
    var hue = (t * 0.12).sin
    var paint
    ctx.save()

    cx = x + w*0.5
    cy = y + h*0.5
    r1 = (w < h ? w : h) * 0.5 - 5.0
    r0 = r1 - 20.0
    aeps = 0.5 / r1	// half a pixel arc length in radians (2pi cancels out).

    for (i in 0...6) {
      var a0 = i / 6.0 * Num.pi * 2.0 - aeps
      var a1 = (i+1.0) / 6.0 * Num.pi * 2.0 + aeps
      ctx.beginPath()
      ctx.arc(cx,cy, r0, a0, a1, Winding.NVG_CW)
      ctx.arc(cx,cy, r1, a1, a0, Winding.NVG_CCW)
      ctx.closePath()
      ax = cx + (a0).cos * (r0+r1)*0.5
      ay = cy + (a0).sin * (r0+r1)*0.5
      bx = cx + (a1).cos * (r0+r1)*0.5
      by = cy + (a1).sin * (r0+r1)*0.5
      paint = NvgPaint.linearGradient(ctx,ax,ay, bx,by, NvgColor.hsla(a0/(Num.pi*2),1.0,0.55,255), NvgColor.hsla(a1/(Num.pi*2),1.0,0.55,255))
      ctx.fillPaint(paint)
      ctx.fill()
    }

    ctx.beginPath()
    ctx.circle(cx,cy, r0-0.5)
    ctx.circle(cx,cy, r1+0.5)
    ctx.strokeColor(NvgColor.rgba(0,0,0,64))
    ctx.strokeWidth(1.0)
    ctx.stroke()

    // Selector
    ctx.save()
    ctx.translate(cx,cy)
    ctx.rotate(hue*Num.pi*2)

    // Marker on
    ctx.strokeWidth(2.0)
    ctx.beginPath()
    ctx.rect(r0-1,-3,r1-r0+2,6)
    ctx.strokeColor(NvgColor.rgba(255,255,255,192))
    ctx.stroke()

    paint = NvgPaint.boxGradient(ctx, r0-3,-5,r1-r0+6,10, 2,4, NvgColor.rgba(0,0,0,128), NvgColor.rgba(0,0,0,0))
    ctx.beginPath()
    ctx.rect(r0-2-10,-4-10,r1-r0+4+20,8+20)
    ctx.rect(r0-2,-4,r1-r0+4,8)
    ctx.pathWinding(Solidity.NVG_HOLE)
    ctx.fillPaint(paint)
    ctx.fill()

    // Center triangle
    r = r0 - 6
    ax = (120.0/180.0*Num.pi).cos * r
    ay = (120.0/180.0*Num.pi).sin * r
    bx = (-120.0/180.0*Num.pi).cos * r
    by = (-120.0/180.0*Num.pi).sin * r
    ctx.beginPath()
    ctx.moveTo(r,0)
    ctx.lineTo(ax,ay)
    ctx.lineTo(bx,by)
    ctx.closePath()
    paint = NvgPaint.linearGradient(ctx, r,0, ax,ay, NvgColor.hsla(hue,1.0,0.5,255), NvgColor.rgba(255,255,255,255))
    ctx.fillPaint(paint)
    ctx.fill()
    paint = NvgPaint.linearGradient(ctx, (r+ax)*0.5,(0+ay)*0.5, bx,by, NvgColor.rgba(0,0,0,0), NvgColor.rgba(0,0,0,255))
    ctx.fillPaint(paint)
    ctx.fill()
    ctx.strokeColor(NvgColor.rgba(0,0,0,64))
    ctx.stroke()

    // Select circle on triangle
    ax = (120.0/180.0*Num.pi).cos * r*0.3
    ay = (120.0/180.0*Num.pi).sin * r*0.4
    ctx.strokeWidth(2.0)
    ctx.beginPath()
    ctx.circle(ax,ay,5)
    ctx.strokeColor(NvgColor.rgba(255,255,255,192))
    ctx.stroke()

    paint = NvgPaint.radialGradient(ctx, ax,ay, 7,9, NvgColor.rgba(0,0,0,64), NvgColor.rgba(0,0,0,0))
    ctx.beginPath()
    ctx.rect(ax-20,ay-20,40,40)
    ctx.circle(ax,ay,7)
    ctx.pathWinding(Solidity.NVG_HOLE)
    ctx.fillPaint(paint)
    ctx.fill()

    ctx.restore()

    ctx.restore()
  }

  static drawLines(ctx, x, y, w, h, t){
    var i
    var j
    var pad = 5.0
    var s = w/9.0 - pad*2
    var pts = List.filled(8,0)
    var fx
    var fy
    var joins = [Cap.NVG_MITER, Cap.NVG_ROUND, Cap.NVG_BEVEL]
    var caps = [Cap.NVG_BUTT, Cap.NVG_ROUND, Cap.NVG_SQUARE]
    
    ctx.save()
    pts[0] = -s*0.25 + (t*0.3).cos * s*0.5
    pts[1] = (t*0.3).sin * s*0.5
    pts[2] = -s*0.25
    pts[3] = 0
    pts[4] = s*0.25
    pts[5] = 0
    pts[6] = s*0.25 + (-t*0.3).cos * s*0.5
    pts[7] = (-t*0.3).sin * s*0.5

    for(i in 0...3) {
      for (j in 0...3) {
        fx = x + s*0.5 + (i*3+j)/9.0*w + pad
        fy = y - s*0.5 + pad

        ctx.lineCap(caps[i])
        ctx.lineJoin(joins[j])

        ctx.strokeWidth(s*0.3)
        ctx.strokeColor(NvgColor.rgba(0,0,0,160))
        ctx.beginPath()
        ctx.moveTo(fx+pts[0], fy+pts[1])
        ctx.lineTo(fx+pts[2], fy+pts[3])
        ctx.lineTo(fx+pts[4], fy+pts[5])
        ctx.lineTo(fx+pts[6], fy+pts[7])
        ctx.stroke()

        ctx.lineCap(Cap.NVG_BUTT)
        ctx.lineJoin(Cap.NVG_BEVEL)

        ctx.strokeWidth(1.0)
        ctx.strokeColor(NvgColor.rgba(0,192,255,255))
        ctx.beginPath()
        ctx.moveTo(fx+pts[0], fy+pts[1])
        ctx.lineTo(fx+pts[2], fy+pts[3])
        ctx.lineTo(fx+pts[4], fy+pts[5])
        ctx.lineTo(fx+pts[6], fy+pts[7])
        ctx.stroke()
      }
    }


    ctx.restore()
  }

  static drawWindow(ctx, title, x, y, w, h){
    var cornerRadius = 3.0
    var shadowPaint
    var headerPaint

    ctx.save()
    //	ctx.clearState()

    // Window
    ctx.beginPath()
    ctx.roundedRect(x,y, w,h, cornerRadius)
    ctx.fillColor(NvgColor.rgba(28,30,34,192))
  //	ctx.fillColor(NvgColor.rgba(0,0,0,128))
    ctx.fill()

    // Drop shadow
    shadowPaint = NvgPaint.boxGradient(ctx, x,y+2, w,h, cornerRadius*2, 10, NvgColor.rgba(0,0,0,128), NvgColor.rgba(0,0,0,0))
    ctx.beginPath()
    ctx.rect(x-10,y-10, w+20,h+30)
    ctx.roundedRect(x,y, w,h, cornerRadius)
    ctx.pathWinding(Solidity.NVG_HOLE)
    ctx.fillPaint(shadowPaint)
    ctx.fill()

    // Header
    headerPaint = NvgPaint.linearGradient(ctx, x,y,x,y+15, NvgColor.rgba(255,255,255,8), NvgColor.rgba(0,0,0,16))
    ctx.beginPath()
    ctx.roundedRect(x+1,y+1, w-2,30, cornerRadius-1)
    ctx.fillPaint(headerPaint)
    ctx.fill()
    ctx.beginPath()
    ctx.moveTo(x+0.5, y+0.5+30)
    ctx.lineTo(x+0.5+w-1, y+0.5+30)
    ctx.strokeColor(NvgColor.rgba(0,0,0,32))
    ctx.stroke()

    ctx.fontSize(15.0)
    ctx.fontFace(FontBold)
    ctx.textAlign(TextAlign.ALIGN_CENTER|TextAlign.ALIGN_MIDDLE)

    ctx.fontBlur(2)
    ctx.fillColor(NvgColor.rgba(0,0,0,128))
    ctx.text(x+w/2,y+16+1, title)

    ctx.fontBlur(0)
    ctx.fillColor(NvgColor.rgba(220,220,220,160))
    ctx.text(x+w/2,y+16, title)

    ctx.restore()
  }

  static drawSearchBox(ctx, text, x, y, w, h){
    var bg
    var cornerRadius = h/2-1

    // Edit
    bg = NvgPaint.boxGradient(ctx, x,y+1.5, w,h, h/2,5, NvgColor.rgba(0,0,0,16), NvgColor.rgba(0,0,0,92))
    ctx.beginPath()
    ctx.roundedRect(x,y, w,h, cornerRadius)
    ctx.fillPaint(bg)
    ctx.fill()

  /*	ctx.beginPath()
    ctx.roundedRect(x+0.5,y+0.5, w-1,h-1, cornerRadius-0.5)
    ctx.strokeColor(NvgColor.rgba(0,0,0,48))
    ctx.stroke()*/

    ctx.fontSize(h*1.3)
    ctx.fontFace(FontIcons)
    ctx.fillColor(NvgColor.rgba(255,255,255,64))
    ctx.textAlign(TextAlign.ALIGN_CENTER|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+h*0.55, y+h*0.55, "🔍")

    ctx.fontSize(17.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,32))

    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+h*1.05,y+h*0.5,text)

    ctx.fontSize(h*1.3)
    ctx.fontFace(FontIcons)
    ctx.fillColor(NvgColor.rgba(255,255,255,32))
    ctx.textAlign(TextAlign.ALIGN_CENTER|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+w-h*0.55, y+h*0.55, "✖")
  }

  static drawDropDown(ctx, text, x, y, w, h) {
    var bg
    var cornerRadius = 4.0

    bg = NvgPaint.linearGradient(ctx, x,y,x,y+h, NvgColor.rgba(255,255,255,16), NvgColor.rgba(0,0,0,16))
    ctx.beginPath()
    ctx.roundedRect(x+1,y+1, w-2,h-2, cornerRadius-1)
    ctx.fillPaint(bg)
    ctx.fill()

    ctx.beginPath()
    ctx.roundedRect(x+0.5,y+0.5, w-1,h-1, cornerRadius-0.5)
    ctx.strokeColor(NvgColor.rgba(0,0,0,48))
    ctx.stroke()

    ctx.fontSize(17.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,160))
    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+h*0.3,y+h*0.5,text)

    ctx.fontSize(h*1.3)
    ctx.fontFace(FontIcons)
    ctx.fillColor(NvgColor.rgba(255,255,255,64))
    ctx.textAlign(TextAlign.ALIGN_CENTER|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+w-h*0.5, y+h*0.5, "\uE75E")
  }

  static drawLabel(ctx, text, x, y, w, h){
    ctx.fontSize(15.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,128))

    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x,y+h*0.5,text)
  }

  static drawEditBoxBase(ctx, x, y, w, h){
    var bg
    // Edit
    bg = NvgPaint.boxGradient(ctx, x+1,y+1+1.5, w-2,h-2, 3,4, NvgColor.rgba(255,255,255,32), NvgColor.rgba(32,32,32,32))
    ctx.beginPath()
    ctx.roundedRect(x+1,y+1, w-2,h-2, 4-1)
    ctx.fillPaint(bg)
    ctx.fill()

    ctx.beginPath()
    ctx.roundedRect(x+0.5,y+0.5, w-1,h-1, 4-0.5)
    ctx.strokeColor(NvgColor.rgba(0,0,0,48))
    ctx.stroke()
  }

  static drawEditBox(ctx, text, x, y, w, h){

    drawEditBoxBase(ctx, x,y, w,h)

    ctx.fontSize(17.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,64))
    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+h*0.3,y+h*0.5,text)
  }

  static drawEditBoxNum(ctx,text, units, x, y, w, h){
    var uw

    drawEditBoxBase(ctx, x,y, w,h)

    uw = ctx.textWidth(0,0, units)

    ctx.fontSize(15.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,64))
    ctx.textAlign(TextAlign.ALIGN_RIGHT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+w-h*0.3,y+h*0.5,units)

    ctx.fontSize(17.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,128))
    ctx.textAlign(TextAlign.ALIGN_RIGHT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+w-uw-h*0.5,y+h*0.5,text)
  }

  static drawCheckBox(ctx, text, x, y, w, h) {
    var bg
    var icon = List.filled(8,0)
    
    ctx.fontSize(15.0)
    ctx.fontFace(Font)
    ctx.fillColor(NvgColor.rgba(255,255,255,160))

    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+28,y+h*0.5,text)

    bg = NvgPaint.boxGradient(ctx, x+1,y+(h*0.5).floor-9+1, 18,18, 3,3, NvgColor.rgba(0,0,0,32), NvgColor.rgba(0,0,0,92))
    ctx.beginPath()
    ctx.roundedRect(x+1,y+(h*0.5).floor-9, 18,18, 3)
    ctx.fillPaint(bg)
    ctx.fill()

    ctx.fontSize(33)
    ctx.fontFace(FontIcons)
    ctx.fillColor(NvgColor.rgba(255,255,255,128))
    ctx.textAlign(TextAlign.ALIGN_CENTER|TextAlign.ALIGN_MIDDLE)
    ctx.text(x+9+2, y+h*0.5, "\u2713")
  }

  static isBlack(col){
    return col.r == 0 && col.g == 0 && col.b == 0
  }

  static drawButton(ctx, preicon, text, x, y, w, h, col) {
    var bg
    var cornerRadius = 4.0
    var tw = 0
    var iw = 0

    bg = NvgPaint.linearGradient(ctx, x,y,x,y+h, NvgColor.rgba(255,255,255,isBlack(col)?16:32), NvgColor.rgba(0,0,0,isBlack(col)?16:32))
    ctx.beginPath()
    ctx.roundedRect(x+1,y+1, w-2,h-2, cornerRadius-1)
    if (!isBlack(col)) {
      ctx.fillColor(col)
      ctx.fill()
    }
    ctx.fillPaint(bg)
    ctx.fill()

    ctx.beginPath()
    ctx.roundedRect(x+0.5,y+0.5, w-1,h-1, cornerRadius-0.5)
    ctx.strokeColor(NvgColor.rgba(0,0,0,48))
    ctx.stroke()

    ctx.fontSize(17.0)
    ctx.fontFace(FontBold)
    tw = ctx.textWidth(0,0, text)
    if (preicon != 0) {
      ctx.fontSize(h*1.3)
      ctx.fontFace(FontIcons)
      iw = ctx.textWidth(0,0, preicon)
      iw = iw + h* 0.15
    }

    if (preicon != 0) {
      ctx.fontSize(h*1.3)
      ctx.fontFace(FontIcons)
      ctx.fillColor(NvgColor.rgba(255,255,255,96))
      ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
      ctx.text(x+w*0.5-tw*0.5-iw*0.75, y+h*0.5, preicon)
    }

    ctx.fontSize(17.0)
    ctx.fontFace(FontBold)
    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)
    ctx.fillColor(NvgColor.rgba(0,0,0,160))
    ctx.text(x+w*0.5-tw*0.5+iw*0.25,y+h*0.5-1,text)
    ctx.fillColor(NvgColor.rgba(255,255,255,160))
    ctx.text(x+w*0.5-tw*0.5+iw*0.25,y+h*0.5,text)
  }

  static drawSlider(ctx, pos, x, y, w, h) {
    var bg
    var knob
    var cy = y+(h*0.5).floor
    var kr = (h*0.25).floor

    ctx.save()
  //	ctx.clearState()

    // Slot
    bg = NvgPaint.boxGradient(ctx, x,cy-2+1, w,4, 2,2, NvgColor.rgba(0,0,0,32), NvgColor.rgba(0,0,0,128))
    ctx.beginPath()
    ctx.roundedRect(x,cy-2, w,4, 2)
    ctx.fillPaint(bg)
    ctx.fill()

    // Knob Shadow
    bg = NvgPaint.radialGradient(ctx, x+(pos*w).floor,cy+1, kr-3,kr+3, NvgColor.rgba(0,0,0,64), NvgColor.rgba(0,0,0,0))
    ctx.beginPath()
    ctx.rect(x+(pos*w).floor-kr-5,cy-kr-5,kr*2+5+5,kr*2+5+5+3)
    ctx.circle(x+(pos*w).floor,cy, kr)
    ctx.pathWinding(Solidity.NVG_HOLE)
    ctx.fillPaint(bg)
    ctx.fill()

    // Knob
    knob = NvgPaint.linearGradient(ctx, x,cy-kr,x,cy+kr, NvgColor.rgba(255,255,255,16), NvgColor.rgba(0,0,0,16))
    ctx.beginPath()
    ctx.circle(x+(pos*w).floor,cy, kr-1)
    ctx.fillColor(NvgColor.rgba(40,43,48,255))
    ctx.fill()
    ctx.fillPaint(knob)
    ctx.fill()

    ctx.beginPath()
    ctx.circle(x+(pos*w).floor,cy, kr-0.5)
    ctx.strokeColor(NvgColor.rgba(0,0,0,92))
    ctx.stroke()

    ctx.restore()
  }
  
  static drawSpinner(ctx, cx, cy, r, t) {
    var a0 = 0.0 + t*6
    var a1 = Num.pi + t*6
    var r0 = r
    var r1 = r * 0.75
    var ax
    var ay
    var bx
    var by
    var paint

    ctx.save()

    ctx.beginPath()
    ctx.arc(cx,cy, r0, a0, a1, Winding.NVG_CW)
    ctx.arc(cx,cy, r1, a1, a0, Winding.NVG_CCW)
    ctx.closePath()
    ax = cx + (a0).cos * (r0+r1)*0.5
    ay = cy + (a0).sin * (r0+r1)*0.5
    bx = cx + (a1).cos * (r0+r1)*0.5
    by = cy + (a1).sin * (r0+r1)*0.5
    paint = NvgPaint.linearGradient(ctx, ax,ay, bx,by, NvgColor.rgba(0,0,0,0), NvgColor.rgba(0,0,0,128))
    ctx.fillPaint(paint)
    ctx.fill()

    ctx.restore()
  }

  static drawThumbnails(ctx, x, y, w, h, images, t){
    var cornerRadius = 3.0
    var shadowPaint
    var imgPaint
    var fadePaint
    var ix
    var iy
    var iw
    var ih
    var thumb = 60.0
    var arry = 30.5
    var imgw
    var imgh
    var stackh = (images.count/2) * (thumb+10) + 10
    var i
    var u = (1+(t*0.5).cos)*0.5
    var u2 = (1-(t*0.2).sin)*0.5
    var scrollh
    var dv

    ctx.save()
  //	ctx.clearState()

    // Drop shadow
    shadowPaint = NvgPaint.boxGradient(ctx, x,y+4, w,h, cornerRadius*2, 20, NvgColor.rgba(0,0,0,128), NvgColor.rgba(0,0,0,0))
    ctx.beginPath()
    ctx.rect(x-10,y-10, w+20,h+30)
    ctx.roundedRect(x,y, w,h, cornerRadius)
    ctx.pathWinding(Solidity.NVG_HOLE)
    ctx.fillPaint(shadowPaint)
    ctx.fill()

    // Window
    ctx.beginPath()
    ctx.roundedRect(x,y, w,h, cornerRadius)
    ctx.moveTo(x-10,y+arry)
    ctx.lineTo(x+1,y+arry-11)
    ctx.lineTo(x+1,y+arry+11)
    ctx.fillColor(NvgColor.rgba(200,200,200,255))
    ctx.fill()

    ctx.save()
    ctx.scissor(x,y,w,h)
    ctx.translate(0, -(stackh - h)*u)

    dv = 1.0 / (images.count-1)

    for(i in 0...images.count) {
      var tx
      var ty
      var v
      var a
      tx = x+10
      ty = y+10
      tx = tx + (i%2) * (thumb+10)
      ty = ty + (i/2) * (thumb+10)
      var imgw = images[i].width
      var imgh = images[i].height
      //System.print([imgw,imgh])
      if (imgw < imgh) {
        iw = thumb
        ih = iw * imgh/imgw
        ix = 0
        iy = -(ih-thumb)*0.5
      } else {
        ih = thumb
        iw = ih * imgw/imgh
        ix = -(iw-thumb)*0.5
        iy = 0
      }

      v = i * dv
      a = clamp((u2-v) / dv, 0, 1)

      if (a < 1.0) drawSpinner(ctx, tx+thumb/2,ty+thumb/2, thumb*0.25, t)

      imgPaint = NvgPaint.imagePattern(ctx, tx+ix, ty+iy, iw,ih, 0.0/180.0*Num.pi, images[i], a)
      ctx.beginPath()
      ctx.roundedRect(tx,ty, thumb,thumb, 5)
      ctx.fillPaint(imgPaint)
      ctx.fill()

      shadowPaint = NvgPaint.boxGradient(ctx, tx-1,ty, thumb+2,thumb+2, 5, 3, NvgColor.rgba(0,0,0,128), NvgColor.rgba(0,0,0,0))
      ctx.beginPath()
      ctx.rect(tx-5,ty-5, thumb+10,thumb+10)
      ctx.roundedRect(tx,ty, thumb,thumb, 6)
      ctx.pathWinding(Solidity.NVG_HOLE)
      ctx.fillPaint(shadowPaint)
      ctx.fill()

      ctx.beginPath()
      ctx.roundedRect(tx+0.5,ty+0.5, thumb-1,thumb-1, 4-0.5)
      ctx.strokeWidth(1.0)
      ctx.strokeColor(NvgColor.rgba(255,255,255,192))
      ctx.stroke()
    }
    ctx.restore()

    // Hide fades
    fadePaint = NvgPaint.linearGradient(ctx, x,y,x,y+6, NvgColor.rgba(200,200,200,255), NvgColor.rgba(200,200,200,0))
    ctx.beginPath()
    ctx.rect(x+4,y,w-8,6)
    ctx.fillPaint(fadePaint)
    ctx.fill()

    fadePaint = NvgPaint.linearGradient(ctx, x,y+h,x,y+h-6, NvgColor.rgba(200,200,200,255), NvgColor.rgba(200,200,200,0))
    ctx.beginPath()
    ctx.rect(x+4,y+h-6,w-8,6)
    ctx.fillPaint(fadePaint)
    ctx.fill()

    // Scroll bar
    shadowPaint = NvgPaint.boxGradient(ctx, x+w-12+1,y+4+1, 8,h-8, 3,4, NvgColor.rgba(0,0,0,32), NvgColor.rgba(0,0,0,92))
    ctx.beginPath()
    ctx.roundedRect(x+w-12,y+4, 8,h-8, 3)
    ctx.fillPaint(shadowPaint)
  //	ctx.fillColor(NvgColor.rgba(255,0,0,128))
    ctx.fill()

    scrollh = (h/stackh) * (h-8)
    shadowPaint = NvgPaint.boxGradient(ctx, x+w-12-1,y+4+(h-8-scrollh)*u-1, 8,scrollh, 3,4, NvgColor.rgba(220,220,220,255), NvgColor.rgba(128,128,128,255))
    ctx.beginPath()
    ctx.roundedRect(x+w-12+1,y+4+1 + (h-8-scrollh)*u, 8-2,scrollh-2, 2)
    ctx.fillPaint(shadowPaint)
  //	ctx.fillColor(NvgColor.rgba(0,0,0,128))
    ctx.fill()

    ctx.restore()
  }

  // static drawWidths(ctx, x, y, width)
  // {
  //   var i

  //   ctx.save()

  //   ctx.strokeColor(NvgColor.rgba(0,0,0,255))

  //   for(i in 0...20) {
  //     w = (i+0.5)*0.1
  //     ctx.strokeWidth(w)
  //     ctx.beginPath()
  //     ctx.moveTo(x,y)
  //     ctx.lineTo(x+width,y+width*0.3)
  //     ctx.stroke()
  //     y = y + 10
  //   }

  //   ctx.restore()
  // }

  static drawCaps(ctx, x, y, width) {
    var i
    var caps = [Cap.NVG_BUTT, Cap.NVG_ROUND, Cap.NVG_SQUARE]
    var lineWidth = 8.0

    ctx.save()

    ctx.beginPath()
    ctx.rect(x-lineWidth/2, y, width+lineWidth, 40)
    ctx.fillColor(NvgColor.rgba(255,255,255,32))
    ctx.fill()

    ctx.beginPath()
    ctx.rect(x, y, width, 40)
    ctx.fillColor(NvgColor.rgba(255,255,255,32))
    ctx.fill()

    ctx.strokeWidth(lineWidth)
    for(i in 0...3) {
      ctx.lineCap(caps[i])
      ctx.strokeColor(NvgColor.rgba(0,0,0,255))
      ctx.beginPath()
      ctx.moveTo(x, y + i*10 + 5)
      ctx.lineTo(x+width, y + i*10 + 5)
      ctx.stroke()
    }

    ctx.restore()
  }

  static drawScissor(ctx, x, y, t){
    ctx.save()

    // Draw first rect and set scissor to it's area.
    ctx.translate(x, y)
    ctx.rotate(NvgMath.degToRad(5))
    ctx.beginPath()
    ctx.rect(-20,-20,60,40)
    ctx.fillColor(NvgColor.rgba(255,0,0,255))
    ctx.fill()
    ctx.scissor(-20,-20,60,40)

    // Draw second rectangle with offset and rotation.
    ctx.translate(40,0)
    ctx.rotate(t)

    // Draw the intended second rectangle without any scissoring.
    ctx.save()
    ctx.resetScissor()
    ctx.beginPath()
    ctx.rect(-20,-10,60,30)
    ctx.fillColor(NvgColor.rgba(255,128,0,64))
    ctx.fill()
    ctx.restore()

    // Draw second rectangle with combined scissoring.
    ctx.intersectScissor(-20,-10,60,30)
    ctx.beginPath()
    ctx.rect(-20,-10,60,30)
    ctx.fillColor(NvgColor.rgba(255,128,0,255))
    ctx.fill()

    ctx.restore()
  }
}