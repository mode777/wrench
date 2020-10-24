import "fetch" for FetchClient
import "xml" for Xml

var http = FetchClient.new()

http.get("https://podcastd45a61.podigee.io/feed/mp3"){|status,content|
  if(status == 200){
    var xml = Xml.parse(content)
    for(item in xml["rss"][0]["channel"][0]["item"]){
      //System.print(item["title"][0]["value"])
    }
    System.print(xml["rss"][0]["channel"][0]["image"][0]["url"][0]["value"])
  } else {
    System.print("Error")
  }
}

while(http.requests > 0){
  http.update()
}