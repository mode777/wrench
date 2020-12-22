class Registration {

  name { _name }

  construct new(name){
    _name = name.toString
  }

  resolve(container){ null }
}

class InstanceRegistration is Registration {
  construct new(name, inst){
    super(name)
    _inst = inst
  }

  resolve(container){ _inst }
}

class FactoryRegistration is Registration {
  
  asSingleton { _singleton = true }
  
  construct new(name, factory){
    super(name)
    _factory = factory
    _instance = null
    _singleton = false
  }

  resolve(container){ _singleton ? _instance = (_instance || createInstance(container)) : createInstance(container) }

  createInstance(container){ _factory.call(container) }
}

class TypeRegistration is FactoryRegistration {

  static createFactory(type, arg){
    if(arg == null || arg.count == 0) return Fn.new {|c| type.new() }
    if(arg.count == 1) return Fn.new {|c| type.new(c.resolve(arg[0])) }
    if(arg.count == 2) return Fn.new {|c| type.new(c.resolve(arg[0]), c.resolve(arg[1])) }
    if(arg.count == 3) return Fn.new {|c| type.new(c.resolve(arg[0]), c.resolve(arg[1]), c.resolve(arg[2])) }
    if(arg.count == 4) return Fn.new {|c| type.new(c.resolve(arg[0]), c.resolve(arg[1]), c.resolve(arg[2]), c.resolve(arg[3])) }
    if(arg.count == 5) return Fn.new {|c| type.new(c.resolve(arg[0]), c.resolve(arg[1]), c.resolve(arg[2]), c.resolve(arg[3]), c.resolve(arg[4])) }
    if(arg.count == 6) return Fn.new {|c| type.new(c.resolve(arg[0]), c.resolve(arg[1]), c.resolve(arg[2]), c.resolve(arg[3]), c.resolve(arg[4]), c.resolve(arg[5])) }
  }

  construct new(type){
    var f = TypeRegistration.createFactory(type, null)
    super(type, f)
  }

  construct new(type, args){
    var f = TypeRegistration.createFactory(type, args)
    super(type, f)  
  }
  
  construct new(name, type, args){
    var f = TypeRegistration.createFactory(type, args)
    super(name, f)
  }
}

class Container {
  
  construct new() {
    _registry = {}
    registerInstance(Container, this)
  }

  registerInstance(type, inst){ addRegistration(InstanceRegistration.new(type, inst)) }
  registerFactory(type, fact){ addRegistration(FactoryRegistration.new(type, fact)) }
  registerType(type){ addRegistration(TypeRegistration.new(type)) }
  registerType(type, args){ addRegistration(TypeRegistration.new(type, args)) }
  registerType(name, type, args){ addRegistration(TypeRegistration.new(name, type, args)) }

  addRegistration(r){
    _registry[r.name] = r
    return r
  }
  
  resolve(name){ 
    name = name.toString
    if(!_registry.containsKey(name)) Fiber.abort("Cannot resolve '%(name)'")
    return _registry[name].resolve(this)
  }

  resolveAll(list) { list.map{|x| resolve(x)}.toList }
}