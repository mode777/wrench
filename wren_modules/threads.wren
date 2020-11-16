import "buffers" for Buffer

foreign class Thread {
  construct new(path){
    create_(path)
  }
  foreign create_(path)
  foreign isDone
  foreign result
  foreign count
  foreign send(buffer)
  sendString(str){
    send(Buffer.fromString(str))
  }
  foreign receive_(buffer)
  receive(){ 
    var b = Buffer.new(0)
    var success = receive_(b)
    return success ? b : null
  }
  receiveString(){
    return receive().readString(0)
  }
  wait(){
    while(count == 0){}
    return receive()
  }
  waitString(){ wait().readString(0) }
}

class Parent {
  foreign static send(buffer)
  static sendString(str){
    send(Buffer.fromString(str))
  }
  foreign static receive_(buffer)
  static receive(){ 
    var b = Buffer.new(0)
    var success = receive_(b)
    return success ? b : null
  }
  static receiveString(){
    return receive().readString(0)
  }
  foreign static count
  static wait(){
    while(count == 0){}
    return receive()
  }
  static waitString(){ wait().readString(0) }
}