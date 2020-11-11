import "wren-nanovg" for NvgColor, NvgImage, NvgPaint, ImageData, Winding, NvgFont, TextAlign
import "tasks" for TaskQueue, DefaultCanceller
import "tween" for Tween, TweenEaseOutCubic, TweenLinear, TweenEaseOutQuad 

class Resources {
  static getRegularFont(ctx) { __font = __font || NvgFont.fromFile(ctx, "./examples/podcast_player/res/Roboto-Regular.ttf") }
  static getBoldFont(ctx) { __font = __font || NvgFont.fromFile(ctx, "./examples/podcast_player/res/Roboto-Bold.ttf") }
}

class Spinner {

  static draw(ctx, cx, cy, r) {
    var t = System.clock
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
}

class Feed {
  construct new(ev, url){
    _events = ev
    _url = url
    _animationQueue = TaskQueue.new(16, DefaultCanceller)
    _alpha = 0
    _textAlpha = 0
    _imageAlpha = 0
  }

  draw(ctx,x,y,w,h,t){
    _ctx = ctx
    _animationQueue.task.step()

    ctx.save()
    y = y + (5 + (t*4+(x/5)).sin*10)
    
    ctx.globalAlpha(_alpha)

    ctx.beginPath()
    ctx.roundedRect(x, y, w, h, w*0.03)
    ctx.fillColor(NvgColor.rgba(180,180,180,255))
    ctx.fill()

    if(_image){
      var imgPaint = NvgPaint.imagePattern(ctx, x,y,w,h, 0, _image, _imageAlpha)
      ctx.fillPaint(imgPaint)
      ctx.fill()
    }

    if(!_title) {
      Spinner.draw(ctx, x+w/2, y+h/2, w/4)
    } else {
      drawTitle(ctx, x+w*0.05, y, w*0.9, h)
    }
    ctx.restore()
  }

  drawTitle(ctx, x, y, w, h){
    ctx.fontSize(18)
    ctx.fontFace(Resources.getBoldFont(ctx))
    ctx.textAlign(TextAlign.ALIGN_LEFT|TextAlign.ALIGN_MIDDLE)

    ctx.fontBlur(1)
    ctx.fillColor(NvgColor.rgba(0,0,0,255))
    var bounds = ctx.textBoxBounds(x,y,w,_title)
    ctx.textBox(x, y + w*0.1, w, _title)

    ctx.fontBlur(0)
    ctx.fillColor(NvgColor.rgba(255,255,255,_textAlpha))
    ctx.textBox(x, y + w*0.1, w, _title)
  }

  addInfo(title, description){
    _title = title
    _description = description
    fadeText(1, 1)
  }

  addImage(w,h,data){
    _image = NvgImage.fromRgba(_ctx, w, h, data)
    fadeImage(1,2)
  }

  fade(alpha, sec){
    _animationQueue.add(Tween.create([_alpha], [alpha], sec, TweenLinear){|v| _alpha = v[0]})
  }
  fadeText(alpha, sec){
    _animationQueue.add(Tween.create([_textAlpha], [alpha * 255], sec, TweenLinear){|v| _textAlpha = v[0]})
  }
  fadeImage(alpha,sec){
    _animationQueue.add(Tween.create([_imageAlpha], [alpha], sec, TweenLinear){|v| _imageAlpha = v[0]})
  }  
}

class FeedList {
  construct new(ev){
    _feeds = []
    _have = {}
    _events = ev
    ev.subscribe("pc.feed.info"){ |ev| onFeedInfo(ev) }
    ev.subscribe("pc.feed.download"){ |ev| onFeedDownload(ev) }
    ev.subscribe("pc.rgba.loaded"){ |ev| onImage(ev) }
    _size = 175
  }

  onImage(ev){
    var feed = _have[ev[1]]
    if(feed){
      feed.addImage(ev[3],ev[4],ev[2])
    }
  }
  
  onFeedInfo(ev){
    var feed = _have[ev[1]]
    feed.addInfo(ev[2], ev[3])
    _events.add(["pc.image.download", ev[1], ev[4], 256, 256])
  }

  onFeedDownload(ev){
    var feed = Feed.new(_events, ev[1])
    feed.fade(1, 1)
    _feeds.add(feed)
    _have[ev[1]] = feed
  }

  draw(ctx,x,y,w,h,t){
    var gap = _size * 0.1
    var ex = x + gap
    var ey = y + gap
    var ew = _size
    var eh = _size
    var i = 0
    while(ey <= h) {
      while(ex+ew <= w){
        if(i >= _feeds.count) return
        _feeds[i].draw(ctx, ex, ey, ew, eh, t)
        i = i+1
        ex = ex + gap + ew
      }
      ex = gap
      ey = ey + eh + gap
    }
  }
}

class MainLayout {
  construct new(ev){
    _feedList = FeedList.new(ev)
    _events = ev

  }

  draw(ctx,x,y,w,h,t){
    _feedList.draw(ctx, x,y,w,h,t)
  }
}

class PodcastUI {
  construct new(ev){
    _mainLayout = MainLayout.new(ev)
    _events = ev
    _currentLayout = _mainLayout
  }

  draw(ctx,x,y,w,h,t){
    _mainLayout.draw(ctx,x,y,w,h,t)
  }

}