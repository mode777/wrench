import "buffers" for Buffer

foreign class CurlHandle {
  construct new(url){
    this.url = url
    this.caInfo = "./curl-ca-bundle.crt"
    this.followRedirects = true
    this.timeout = 30
    this.writeMemory()
  }
  construct download(url, path){
    this.url = url
    this.caInfo = "./curl-ca-bundle.crt"
    this.followRedirects = true
    this.writeFile(path)
  }
  foreign url=(v)
  foreign caInfo=(v)
  foreign followRedirects=(v)
  foreign timeout=(v)
  foreign id
  foreign writeFile(path)
  foreign writeMemory()
  foreign getData_(buffer)
  getData(){ 
    var buffer = Buffer.new(0)
    getData_(buffer)
    return buffer 
  }
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