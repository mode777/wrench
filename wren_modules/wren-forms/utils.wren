import "wren-nanovg" for NvgColor

class Guard {
  static againstNull(value, name) { 
    if(value == null) Fiber.abort("%(name) is null")
  }
}

class MapUtils {
  
  static clone(map){
    var m = {}
    for(kv in map){
      m[kv.key] = kv.value
    }
    return m
  }

  static mix(maps){
    var m = {}
    for(map in maps){
      for(kv in map){
        m[kv.key] = kv.value
      } 
    }
    return m
  }
}

class ColorUtils {
  
  static hexToDec(b){
    if(b == 48) return 0x0 
    if(b == 49) return 0x1 
    if(b == 50) return 0x2 
    if(b == 51) return 0x3 
    if(b == 52) return 0x4 
    if(b == 53) return 0x5 
    if(b == 54) return 0x6 
    if(b == 55) return 0x7 
    if(b == 56) return 0x8 
    if(b == 57) return 0x9
    if(b == 65 || b == 97) return 0xA 
    if(b == 66 || b == 98) return 0xB 
    if(b == 67 || b == 99) return 0xC 
    if(b == 68 || b == 100) return 0xD 
    if(b == 69 || b == 101) return 0xE 
    if(b == 70 || b == 102) return 0xF 
  }
  
  static parseColor(str){
    var bytes = str.bytes
    if(bytes.count != 9 || bytes[0] != 35) Fiber.abort("Invalid Color string. Use #RRGGBBAA") 
    var r = (hexToDec(bytes[1])<<4)|hexToDec(bytes[2])
    var g = (hexToDec(bytes[3])<<4)|hexToDec(bytes[4])
    var b = (hexToDec(bytes[5])<<4)|hexToDec(bytes[6])
    var a = (hexToDec(bytes[7])<<4)|hexToDec(bytes[8])
    return NvgColor.rgba(r,g,b,a)
  }
}
