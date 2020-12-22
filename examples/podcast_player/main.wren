import "tasks" for Task, TaskDriver, DefaultCanceller
import "wren-forms" for FormsApplication

import "./examples/podcast_player/services" for WorkerService
import "./examples/podcast_player/models" for FeedsModel, NavigationState
import "./examples/podcast_player/controllers" for FeedController
import "./examples/podcast_player/ui" for PodcastForm

class PodcastPlayer is FormsApplication {
  construct new(){
    super(800,480,"Podcast Player")
    setBackground(0.3, 0.3, 0.32)
    init()
  }

  compose(root){
    super.compose(root)
    root.registerType(WorkerService, [FormsApplication]).asSingleton
    root.registerType(FeedsModel).asSingleton
    root.registerType(FeedController, [FormsApplication, FeedsModel, PodcastForm, WorkerService]).asSingleton
    root.registerType(PodcastForm, [FormsApplication, FeedsModel]).asSingleton
  }

  init(){
    _worker = container.resolve(WorkerService)

    _controller = container.resolve(FeedController)
    _controller.addFeed("https://gamenotover.de/feed/podcast/")
    _controller.addFeed("https://podcastd45a61.podigee.io/feed/mp3")
    _controller.addFeed("https://feeds.soundcloud.com/users/soundcloud:users:21436304/sounds.rss")
    _controller.addFeed("https://okcool.podigee.io/feed/mp3")
    _controller.addFeed("https://buchpodcast.libsyn.com/rss")
    _controller.addFeed("http://younginthe80s.de/feed/")
  }
}
var pp = PodcastPlayer.new()
pp.run(PodcastForm)