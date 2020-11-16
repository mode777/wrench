import "threads" for Parent

var message
while(message != "kill"){
  message = Parent.waitString()
  Parent.sendString("You wrote: %(message)")
}
