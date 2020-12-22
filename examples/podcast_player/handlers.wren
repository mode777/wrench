import "tasks" for Task
import "fetch" for FetchClient
import "images" for Image

class Resources {
  static http { __httpClient = __httpClient || FetchClient.new() }
}

var Download = Fn.new { |params| 
  return Task.new {
    Resources.http.download(params["url"], params["path"]).await()
    return params["path"]
  }
}

var ResizeImage = Fn.new { |params| 
  return Task.new {
    var path = params["path"]
    var w = params["width"]
    var h = params["height"]
    var target = params["target"]
    var image = Image.fromFile(path)
    var resized = image.resize(w, h)
    resized.save(target)
    image.dispose()
    resized.dispose()
    return target
  }
}

  var Handlers = {
    "pc.download": Download,
    "pc.resize.image": ResizeImage
  }