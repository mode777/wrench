import "augur" for Augur, Assert
import "observables" for ObservableMap, ObservableCollection, DataSource

Augur.describe(ObservableMap){
  Augur.it("informs about changes"){
    var m = ObservableMap.new()
    var changed = null
    m.onChange {|v| changed = v }

    m["key"] = "a"

    Assert.equal(changed, "key")
    Assert.equal(m[changed], "a")
  }
}

Augur.describe(ObservableCollection){
  Augur.it("informs about changes"){
    var l = ObservableCollection.new()
    var added = null
    var removed = null
    l.onAdd { |item| added = item }
    l.onRemove { |item| removed = item }

    l.add("test")
    var count = l.remove("test")

    Assert.equal(count, 1)
    Assert.notNull(added)
    Assert.notNull(removed)
    Assert.equal(added, removed)
    Assert.equal(l.count, 0)
  }

  Augur.it("clears"){
    var l = ObservableCollection.new()
    var removed = 0
    l.onRemove { |item| removed = removed+1 }

    l.add("test")
    l.add("test2")

    l.clear()
    Assert.equal(removed, 2)
  }
}

Augur.describe(DataSource){
  Augur.it("finds by key"){
    var s = DataSource.new("id")
    s.add({"id": 1})
    s.add({"id": 2})
    var first = s.find(1)
    var second = s.find(2)

    Assert.equal(first["id"], 1)
    Assert.equal(second["id"], 2)
  }

  Augur.it("removes by id"){
    var s = DataSource.new("id")
    s.add({"id": 1})
    s.removeById(1)
    var first = s.find(1)

    Assert.isNull(first)
  }

  Augur.it("removes by id"){
    var s = DataSource.new("id")
    var item = {"id": 1}
    s.add(item)
    s.remove(item)
    var first = s.find(1)

    Assert.isNull(first)
  }

}