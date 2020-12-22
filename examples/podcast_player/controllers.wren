import "tasks" for Task, TaskDriver, DefaultCanceller
import "./examples/podcast_player/models" for Feed

class FeedController {
  construct new(app, feedModel, view, workerService){
    _model = feedModel
    _worker = workerService
    _view = view
    _driver = TaskDriver.new(DefaultCanceller)

    app.registerUpdate { _driver.task.step() }
  }

  addFeedAsync(url){
    return Task.new {
      var feed = Feed.new(url)
      var data = _worker.downloadFeed(url).await()
      System.print("Done %(url)")
      feed["title"] = data["title"]
      feed["description"] = data["description"]
      for(fi in data["items"]){
        feed.addItem(fi)
      }
      _model.add(feed)
      if(data["imageUrl"]){
        var filename = _worker.downloadImage(data["imageUrl"]).await()
        var filenameResized = _worker.resizeImage(filename, 256, 256).await()
        feed["image"] = filenameResized
      }
    } 
  }

  addFeed(url){
    _driver.add(addFeedAsync(url))
  }

}