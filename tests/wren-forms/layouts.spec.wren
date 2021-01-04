import "augur" for Augur, Assert
import "wren-forms/layouts" for WrapLayoutStrategy
import "wren-forms/controls" for Control
import "shapes" for Rectangle
import "./tests/wren-forms/controls.spec" for MockComponent

Augur.describe(WrapLayoutStrategy){

  var controlOfSize = Fn.new { |w,h|
    var control = Control.new({ "render": MockComponent.new() })
    control.attributes["size"] = [w, h]
    control.attach(null)
    return control
  }

  Augur.it("performs"){
    var c = controlOfSize
    var list = [c.call(20,30), c.call(10, 10), c.call(10, 40), c.call(40,10)]
    var inner = Rectangle.new(100,100, 70, 60)
    var params = { "space-between":  10 }

    WrapLayoutStrategy.perform(list, inner, params)

    Assert.equal(list[0].bounds.box.x, 110)
    Assert.equal(list[1].bounds.box.x, 140)
    Assert.equal(list[3].bounds.box.y, 160)
  }
}