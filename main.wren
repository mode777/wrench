import "named-tuple" for NamedTuple
import "wren-sdl" for SDL

var C = NamedTuple.create("C", ["a","b","c"])
var c = C.new("a","b","c") 

System.print(c)