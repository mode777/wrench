import "wren-forms/resources" for ResourceCache, ResourceProvider, SharedResource
import "augur" for Assert, Augur

class MockProvider is ResourceProvider {
  
  construct new(){
    _createCalled = 0
    _destroyCalled = 0
  }

  create(id){
    _createCalled = _createCalled+1
    return "MyId"
  }

  destroy(value){
    Assert.equal("MyId", value)
    _destroyCalled = _destroyCalled+1
  }

  assert(numCreate, numDestroy){
    Assert.equal(numCreate, _createCalled)
    Assert.equal(numDestroy, _destroyCalled)
  }
}

Augur.describe(ResourceCache){
  Augur.it("loads and destroys resources"){
    var provider = MockProvider.new()
    var cache = ResourceCache.new(provider)

    cache.acquire("res1")
    cache.acquire("res2")
    cache.acquire("res1")

    cache.release("res1")
    cache.release("res2")

    provider.assert(2, 1)
  }
}

Augur.describe(SharedResource){
  Augur.it("allocates and frees resources"){
    var provider = MockProvider.new()
    var cache = ResourceCache.new(provider)
    var shared = SharedResource.new(cache)

    shared.get("a")
    shared.get("a")
    shared.get("b")
    
    provider.assert(2, 1)
  }

  Augur.it("frees resources on dispose"){
    var provider = MockProvider.new()
    var cache = ResourceCache.new(provider)
    var shared = SharedResource.new(cache)

    shared.get("a")
    shared.get("a")
    shared.get("b")
    shared.dispose()
    
    provider.assert(2, 2)
  }
}