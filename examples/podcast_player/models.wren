import "observables" for ObservableMap, ObservableCollection

class NavigationState is ObservableMap {
  construct new(){
    super({ "view": "feed" })
  }

  changeView(name){ this["view"] = name }
} 

class Feed is ObservableMap {
  construct new(url){
    super({"url": url, "items": ObservableCollection.new([], "url")})
  }

  addItem(item){
    this["items"].add(item)
  }
}

class FeedsModel is ObservableCollection {
  construct new(){
    super([], "url")
  }
  
}