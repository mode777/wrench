import "fetch" for FetchClient
import "tasks" for Task

Task.new {|c|
  var client = FetchClient.new()

  var content = Task.combine([
    client.get("https://example.com").then {|x| System.print("Example downloaded") },
    client.get("https://alexklingenbeck.de/not-exisiting").catch {|x| System.print(x) },
    client.get("https://myflover.de").then {|x| System.print("MyFlover downloaded") } 
  ]).await()

  //System.print(content)

}.getResult()