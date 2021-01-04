import "augur" for Augur, Assert
import "wren-forms/controls" for ControlAttributes, ControlEvents, ControlBounds, Control, ControlLayout, ControlList, ControlRenderer
import "wren-forms/utils" for MapUtils
import "wren-forms/events" for UiEvent
import "wren-forms/configuration" for Configuration 
import "shapes" for Rectangle
import "wren-forms/layouts" for WrapLayoutStrategy
import "wren-forms" for DefaultAttributes


class MockComponent {

  isAttached { _isAttached }
  isConfigured { _isConfigured }

  construct new(){}

  attach(c){_isAttached = true}
  configure(cfg){_isConfigured=true}

}

class MockAttributeComponent is MockComponent {
  defaults { _def }

  construct new(){}

  setDefaults(def){_def=def}
}

class MockLayoutComponent is MockComponent {
  performed { _performed }
  
  construct new(){}
  
  perform(){ _performed = true }
}

class MockControl is Control {
  
  construct new(components){
    super()
    _components = components
  }

  createAttributes(){ _components["attributes"] ? _components["attributes"].call(this) : ControlAttributes.new(this) }
  createBounds(){ _components["bounds"] ? _components["bounds"].call(this) : ControlBounds.new(this) }
  createEvents(){ _components["events"] ? _components["events"].call(this) : ControlEvents.new(this) }
  createRenderer() { _components["renderer"] ? _components["renderer"].call(this) : ControlRenderer.new(this) }
  createList() { _components["controls"] ? _components["controls"].call(this) : ControlList.new(this) }
  createLayout() { _components["layout"] ? _components["layout"].call(this) : ControlLayout.new(this) }

  defaultAttributes(){ _components["defaults"] || DefaultAttributes }
}

Augur.describe(Configuration){
  
  Augur.it("configures property"){
    var conf = Configuration.new({
      "simple": 1,
      "complex": {
        "simple": 2
      }
    })
    var called = 0

    conf.property("simple"){|v| 
      Assert.equal(v, 1)
      called = called+1 
    }
    conf.property("complex"){|v| v.property("simple"){|w|
      Assert.equal(w, 2)
      called = called+1
    } }

    conf.property("undefined"){|v| Assert.fail() }

    Assert.equal(called, 2)
  }
}

Augur.describe(ControlAttributes){
  
  Augur.it("inherits attributes"){
    var attr = ControlAttributes.new(null)
    attr.setDefaults(MapUtils.mix([{ "a": 1 }, { "b": 2 }]))
    attr["b"] = 3

    Assert.equal(attr["a"], 1)
    Assert.equal(attr["b"], 3)
  }

  Augur.it("informs about changes"){
    var attr = ControlAttributes.new()
    attr.setDefaults(MapUtils.mix([{ "a": 1 }, { "b": 2 }]))

    var changed = null
    attr.onChange.subscribe {|k|
      changed = k
    }
    attr["b"] = 3

    Assert.equal(changed, "b")
  }

  Augur.it("configures"){
    var attr = ControlAttributes.new()
    attr.configure(Configuration.new({"a": 1, "b": 2}))
    attr["b"] = 3
    
    Assert.equal(attr["a"], 1)
    Assert.equal(attr["b"], 3)
  }
}

Augur.describe(ControlEvents){
  Augur.it("configures"){
    var ev = ControlEvents.new()
    var ctrl = Control.new({ "render": MockComponent.new(), "events": ev })
    ctrl.attach(null)
    ctrl.attributes["size"] = [100,100]
    var evMock = UiEvent.new("mousebuttondown", { "x": 0, "y": 0 }) 

    var called = false
    
    ev.configure(Configuration.new({
      "mousebuttondown": Fn.new {|e| called = true }
    }))
    ev.capture(evMock)
    
    Assert.isTrue(called)
  }

  Augur.it("adds a handler"){
    var ev = ControlEvents.new()
    var ctrl = Control.new({ "render": MockComponent.new(), "events": ev })
    ctrl.attach(null)
    ctrl.configure({"attributes": { 
      "size": [50,50],
      "position": [50,50]
     }})
    var evMock = UiEvent.new("mousebuttondown", { "x": 75, "y": 75 }) 
    var called = false

    ev.addHandler("mousebuttondown"){|e| called = true }

    ev.capture(evMock)
    Assert.isTrue(called)
  }

  Augur.it("triggers click"){
    var ev = ControlEvents.new()
    var ctrl = Control.new({ "render": MockComponent.new(), "events": ev })
    ctrl.attach(null)
    ctrl.configure({"attributes": { "size": [50,50] }})
    var ev1 = UiEvent.new("mousebuttondown", { "x": 25, "y": 25 }) 
    var ev2 = UiEvent.new("mousebuttonup", { "x": 25, "y": 25 }) 
    var called = false

    ev.addHandler("click"){|e| called = true }
    ev.capture(ev1)
    ev.capture(ev2)

    Assert.isTrue(called)
  }

  Augur.it("does not trigger click"){
    var ev = ControlEvents.new()
    var ctrl = Control.new({ "render": MockComponent.new(), "events": ev })
    ctrl.attach(null)
    ctrl.configure({"attributes": { "size": [50,50] }})
    var ev1 = UiEvent.new("mousebuttondown", { "x": 25, "y": 25 }) 
    var ev2 = UiEvent.new("mousebuttonup", { "x": 51, "y": 51 }) 
    var called = false

    ev.addHandler("click"){|e| called = true }
    ev.capture(ev1)
    ev.capture(ev2)

    Assert.isFalse(called)
  }

  Augur.it("does trigger mouseover"){
    var ev = ControlEvents.new()
    var ctrl = Control.new({ "render": MockComponent.new(), "events": ev })
    ctrl.attach(null)
    ctrl.configure({"attributes": { "size": [50,50] }})
    var ev1 = UiEvent.new("mousemotion", { "x": 25, "y": 25 }) 
    var called = 0

    ev.addHandler("mouseover"){|e| called = called + 1 }
    ev.capture(ev1)
    ev.capture(ev1)

    Assert.equal(called, 1)
  }

  Augur.it("does trigger mouseout"){
    var ev = ControlEvents.new()
    var ctrl = Control.new({ "render": MockComponent.new(), "events": ev })
    ctrl.configure({"attributes": { "size": [50,50] }})
    ctrl.attach(null)
    var ev1 = UiEvent.new("mousemotion", { "x": 25, "y": 25 }) 
    var ev2 = UiEvent.new("mousemotion", { "x": 75, "y": 75 }) 
    var called = 0

    ev.addHandler("mouseout"){|e| called = called + 1 }
    ev.capture(ev1)
    ev.capture(ev2)

    Assert.equal(called, 1)
  }

  Augur.it("bubbles up event"){
    var parent = Control.new({ "render": MockComponent.new(), "events": ControlEvents.new() })
    parent.attach(null)
    parent.configure({"attributes": { "size": [100,100] }})
    var child = Control.new({ "render": MockComponent.new(), "events": ControlEvents.new() })
    child.configure({"attributes": { "size": [50,50] }})

    var received = null
    parent.controls.add(child)

    parent.events.addHandler("click"){|e| received = e }
    
    var ev1 = UiEvent.new("mousebuttondown", { "x": 25, "y": 25 }) 
    var ev2 = UiEvent.new("mousebuttonup", { "x": 25, "y": 25 }) 

    parent.events.capture(ev1)
    parent.events.capture(ev2)

    Assert.notNull(received)
    Assert.equal(received.target, child)
  }
}

Augur.describe(ControlBounds){
  Augur.it("reports sizes"){
    var ctrl = MockControl.new({
      "position": [50, 50],
      "size": [50, 50],
      "padding": [5,5],
      "margin": [10,10]
    })
    var bounds = ControlBounds.new()
    bounds.attach(ctrl)

    Assert.equal(bounds.outer.width, 70)
    Assert.equal(bounds.inner.height, 40)
    Assert.equal(bounds.outer.x, 40)
    Assert.equal(bounds.inner.y, 55)
    Assert.equal(bounds.box.h, 50)
  }

  Augur.it("updates"){
    var ctrl = Control.new({ "render": MockComponent.new() })
    ctrl.attributes["size"] = [100, 100]
    ctrl.attach(null)

    Assert.equal(ctrl.bounds.outer.width, 100)
    Assert.equal(ctrl.bounds.outer.height, 100)
  }
}

Augur.describe(ControlLayout){
  
  Augur.it("configures"){
    var layout = ControlLayout.new()
    
    layout.configure(Configuration.new({
      "strategy": "wrap"
    }))

    Assert.equal(layout.strategy, WrapLayoutStrategy)
  }

  Augur.it("triggers layout on change"){

    var layout = ControlLayout.new()
    var parentMock = MockLayoutComponent.new()

    var parent = Control.new({ "render": MockComponent.new(), "layout": parentMock })
    parent.attach(null)
    var ctrl = Control.new({ "render": MockComponent.new(), "layout": layout })
    parent.controls.add(ctrl)
    
    ctrl.attributes["size"] = [100,100]

    Assert.isTrue(parentMock.performed)
  }

}

Augur.describe(ControlList){
  Augur.it("adds control"){
    var list = ControlList.new()
    var layout = MockLayoutComponent.new()
    var parent = Control.new({ "render": MockComponent.new(), "controls": list, "layout": layout })
    parent.attach(null)
    var child = Control.new({ "render": MockComponent.new() })

    list.add(child)
    
    Assert.equal(list.count, 1)
    Assert.equal(child.parent, parent)
    Assert.isTrue(layout.performed)
  }

}

Augur.describe(Control){
  Augur.it("configures"){
    var defaults = {}

    var ctrl = Control.new({
      "attributes": MockAttributeComponent.new(),
      "defaults": defaults,
      "bounds": MockComponent.new(),
      "render": MockComponent.new(),
      "controls": MockComponent.new(),
      "layout": MockComponent.new(),
      "events": MockComponent.new()
    })
    ctrl.attach(null)

    ctrl.configure({
      "attributes": {},
      "bounds": {},
      "render": {},
      "controls": {},
      "layout": {},
      "events": {}
    })

    Assert.isTrue(ctrl.attributes.isAttached)
    Assert.isTrue(ctrl.attributes.isConfigured)
    Assert.equal(ctrl.attributes.defaults, defaults)
    Assert.isTrue(ctrl.bounds.isAttached)
    Assert.isTrue(ctrl.bounds.isConfigured)
    Assert.isTrue(ctrl.events.isAttached)
    Assert.isTrue(ctrl.events.isConfigured)
    Assert.isTrue(ctrl.renderer.isAttached)
    Assert.isTrue(ctrl.renderer.isConfigured)
    Assert.isTrue(ctrl.controls.isAttached)
    Assert.isTrue(ctrl.controls.isConfigured)
    Assert.isTrue(ctrl.layout.isAttached)
    Assert.isTrue(ctrl.layout.isConfigured)
  }
}
