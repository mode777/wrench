import "file" for File

var path = "./examples/podcast_player/cache/5ecdd5ee7d3e3753e0255283cd21c6b3.xml"
var content = File.readBuffer(path)
System.gc()
