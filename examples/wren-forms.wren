import "wren-forms" for FormsApplication, Control
import "wren-forms-gles2sdl" for Gles2SdlHost

Gles2SdlHost.use()
var rootControl = Control.new()
FormsApplication.runLoop(rootControl)