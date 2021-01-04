import "wren-forms/resources" for ResourceProvider 

class MockProvider is ResourceProvider {
  construct new(){}
  create(id){ }
  destroy(res){  }
}

class MockEventSource {
  construct new(){
    _events = []
  }

  // mock helpers
  enqueue(ev){
    _events.add(ev)
  }

  // public
  poll(){ 
    return _events.count > 0 ? _events.removeAt(0) : null 
  }

}

class MockWindow {

  width { _w }
  height { _h }

  construct new(w,h,name){
    _w = w
    _h = h
  }

  present(){}
}

class MockWindowFactory {

  construct new(){}

  createWindow(w,h,name){
    return MockWindow.new(w,h,name)
  }
}

class MockRenderer {

  construct new(){}

  beginDraw(){}

  finishDraw(){}
}

class MockHost {
  static host(app){
    var c = app.container
    c.registerType("FontProvider", MockProvider, [])
    c.registerType("ColorProvider", MockProvider, [])
    c.registerType("ImageProvider", MockProvider, [])
    c.registerType("EventSource", MockEventSource, []).asSingleton
    c.registerType("WindowFactory", MockWindowFactory, []).asSingleton
    c.registerType("Renderer", MockRenderer, []).asSingleton
  }
}

