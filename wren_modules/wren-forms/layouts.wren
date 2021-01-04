class WrapLayoutStrategy {
  static perform(controls, innerBox, params){
    var gap = params["space-between"] || 0
    var height = 0
    var x = innerBox.x + gap 
    var y = innerBox.y + gap
    var xend = innerBox.right + gap
    for(c in controls){
      var exend = x + c.bounds.outer.w
      var eyend = y + c.bounds.outer.h
      height = eyend > height ? eyend : height
      if(exend > xend){
        x = innerBox.x + gap 
        y = height+gap
        height = 0 
      }
      c.attributes["position"] = [x,y]
      x = x + c.bounds.outer.w + gap
      c.bounds.update()
    }
  }
}