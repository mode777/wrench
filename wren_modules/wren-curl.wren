foreign class CurlHandle {
  construct new(url){
    this.url = url
    this.caInfo = "./curl-ca-bundle.crt"
    this.writeMemory()
  }
  construct download(url, path){
    this.url = url
    this.caInfo = "./curl-ca-bundle.crt"
    this.writeFile(path)
  }
  foreign url=(v)
  foreign caInfo=(v)
  foreign id
  foreign writeFile(path)
  foreign writeMemory()
  foreign getData()
  foreign dispose()

  foreign responseCode
}

foreign class CurlMultiHandle{
  construct new(){}
  foreign addHandle(ch)
  foreign removeHandle(ch)
  foreign perform()
  foreign wait(timeout)
  foreign readInfo(msg)
}

foreign class CurlMessage{
  construct new(){}
  foreign getHandle()
  foreign isDone
}

class CURL {
  foreign static runLoop_(fn)
  static runLoop(fn){
    if(__loop == null){
      __callbacks = [fn]
      __remove = []
      __loop = Fn.new {
        for(i in 0...__callbacks.count){
          var cb = __callbacks[i]
          if(!cb.call()){
            __remove.add(i)
          }
        }
        for(i in __remove){
          __callbacks.removeAt(i)
        } 
        __remove.clear()
        return __callbacks.count > 0  
      }
      CURL.runLoop_(__loop)
    } else {
      __callbacks.add(fn)
    }
  }
  foreign static sleep(ms)
  foreign static clock
}