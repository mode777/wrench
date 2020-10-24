import "fetch" for FetchClient
import "wren-curl" for CURL

var client = FetchClient.new()

client.get("https://example.com"){|status, content|
  System.print("Example.com %(status)")
}

client.get("https://alexklingenbeck.de"){|status, content|
  System.print("alexklingenbeck.de %(status)")
  client.get("https://myflover.de"){|s,c|
    System.print("myflover.de %(status)")
  }
}

while(client.requests > 0){
  client.update()
  CURL.sleep(100)
}
