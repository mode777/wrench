import "augur" for Augur, Assert
import "wren-forms/utils" for Guard, MapUtils, ColorUtils

Augur.describe(MapUtils){
  
  Augur.it("clones map"){
    var m = { "a": 1, "b": 2 }
    var clone = MapUtils.clone(m)
    m["a"] = 3
    m["b"] = 4
    Assert.equal(clone["a"], 1)
    Assert.equal(clone["b"], 2)
  }

  Augur.it("mixes map"){
    var m1 = { "a": 1, "b": 2 }
    var m2 = { "b": 3, "c": 4 }

    var clone = MapUtils.mix([m1,m2])

    Assert.equal(clone["a"], 1)
    Assert.equal(clone["b"], 3)
    Assert.equal(clone["c"], 4)
  }

}

Augur.describe(ColorUtils){
  Augur.it("parses color"){
    var c1 = "#0088FFFF"
    var c2 = "#ffffff88"
    var col1 = ColorUtils.parseColor(c1)
    var col2 = ColorUtils.parseColor(c2)

    Assert.equal(col1[0], 0)
    Assert.equal(col1[1], 136)
    Assert.equal(col1[2], 255)
    Assert.equal(col1[3], 255)
    Assert.equal(col2[3], 136)
  }
}