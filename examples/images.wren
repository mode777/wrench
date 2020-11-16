import "images" for Image

var img = Image.fromFile("assets/logo.jpg")
System.print([img.width, img.height])
var img2 = img.resize(256,256)
img2.save("assets/resized.jpg")
img2.save("assets/resized.png")