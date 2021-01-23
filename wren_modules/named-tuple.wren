import "meta" for Meta

class NamedTuple {
  static create(name, fields) { Meta.compile("class %(name) {
  construct new(%(fields.join(", "))) {
    %(fields.map {|field| "_%(field) = %(field)" }.join("\n"))
  }
  %(fields.map {|field| "%(field) { _%(field) }" }.join("\n"))
  toString { \"%(name)(%(fields.map {|field| "\%(_%(field))" }.join(", ")))\" }
}
return %(name)").call() }
}