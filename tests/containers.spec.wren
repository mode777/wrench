import "augur" for Augur, Assert
import "containers" for Container

class A { 
  construct new(){} 
}

class B {
  construct new(a){}
}

Augur.describe(Container){
  Augur.it("registers instance"){
    var c = Container.new()
    var inst = []

    c.registerInstance("test", inst)
    var r = c.resolve("test")

    Assert.equal(inst, r) 
  }

  Augur.it("registers factory"){
    var c = Container.new()
    
    c.registerFactory("test"){ |c| "success" }
    var r = c.resolve("test")

    Assert.equal("success", r)
  }

  Augur.it("registers type only"){
    var c = Container.new()

    c.registerType(A)
    var a = c.resolve(A)

    Assert.instanceOf(a, A)
  }

  Augur.it("registers type instance"){
    var c = Container.new()

    c.registerType(A)
    var a = c.resolve(A)
    var aa = c.resolve(A)

    Assert.notEqual(a, aa)
  }

  Augur.it("registers type singleton"){
    var c = Container.new()

    c.registerType(A).asSingleton
    var a = c.resolve(A)
    var aa = c.resolve(A)

    Assert.equal(a, aa)
  }

  Augur.it("registers type with dependencies"){
    var c = Container.new()

    c.registerType(A)
    c.registerType(B, [A])
    var b = c.resolve(B)

    Assert.instanceOf(b, B)
  }

  Augur.it("registers type with name"){
    var c = Container.new()

    c.registerType("MyA", A, null)
    c.registerType(B, ["MyA"])
    var b = c.resolve(B)

    Assert.instanceOf(b, B)
  }
}