import "images" for Image

var img = Image.fromFile("./examples/podcast_player/cache/e83938d18fababaa1e4b1adc28064044")
//var img = Image.fromFile("assets/logo.jpg")
System.print([img.width, img.height])
var img2 = img.resize(256,256)
img2.save("assets/resized.jpg")
img2.save("assets/resized.png")