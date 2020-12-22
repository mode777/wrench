import "wren-sdl" for SdlEventType
import "wren-forms/events" for UiEvent  

var SdlEventToName = {
  SdlEventType.Quit : "quit",
  SdlEventType.Terminating : "terminating",
  SdlEventType.Lowmemory : "lowmemory",
  SdlEventType.Willenterbackground : "willenterbackground",
  SdlEventType.Didenterbackground : "didenterbackground",
  SdlEventType.Willenterforeground : "willenterforeground",
  SdlEventType.Didenterforeground : "didenterforeground",
  /* Display Events */
  SdlEventType.Displayevent : "displayevent",
  /* Window Events */
  SdlEventType.Windowevent : "windowevent",
  SdlEventType.Syswmevent : "syswmevent",
  /* Keyboard Events */
  SdlEventType.Keydown : "keydown",
  SdlEventType.Keyup : "keyup",
  SdlEventType.Textediting : "textediting",
  SdlEventType.Textinput : "textinput",
  SdlEventType.Keymapchanged : "keymapchanged",
  /* Mouse Events */
  SdlEventType.Mousemotion : "mousemotion",
  SdlEventType.Mousebuttondown : "mousebuttondown",
  SdlEventType.Mousebuttonup : "mousebuttonup",
  SdlEventType.Mousewheel : "mousewheel",
  /* Joystick Events */
  SdlEventType.Joyaxismotion : "joyaxismotion",
  SdlEventType.Joyballmotion : "joyballmotion",
  SdlEventType.Joyhatmotion : "joyhatmotion",
  SdlEventType.Joybuttondown : "joybuttondown",
  SdlEventType.Joybuttonup : "joybuttonup",
  SdlEventType.Joydeviceadded : "joydeviceadded",
  SdlEventType.Joydeviceremoved : "joydeviceremoved",
  /* Game Controller Events */
  SdlEventType.Controlleraxismotion : "controlleraxismotion",
  SdlEventType.Controllerbuttondown : "controllerbuttondown",
  SdlEventType.Controllerbuttonup : "controllerbuttonup",
  SdlEventType.Controllerdeviceadded : "controllerdeviceadded",
  SdlEventType.Controllerdeviceremoved : "controllerdeviceremoved",
  SdlEventType.Controllerdeviceremapped : "controllerdeviceremapped",
  /* Touch Events */
  SdlEventType.Fingerdown : "fingerdown",
  SdlEventType.Fingerup : "fingerup",
  SdlEventType.Fingermotion : "fingermotion",
  /* Gesture Events */
  SdlEventType.Dollargesture : "dollargesture",
  SdlEventType.Dollarrecord : "dollarrecord",
  SdlEventType.Multigesture : "multigesture",
  /* Clipboard Events */
  SdlEventType.Clipboardupdate : "clipboardupdate",
  /* Drag And Drop Events */
  SdlEventType.Dropfile : "dropfile",
  SdlEventType.Droptext : "droptext",
  SdlEventType.Dropbegin : "dropbegin",
  SdlEventType.Dropcomplete : "dropcomplete",
  /* Audio Hotplug Events */
  SdlEventType.Audiodeviceadded : "audiodeviceadded",
  SdlEventType.Audiodeviceremoved : "audiodeviceremoved",
  /* Sensor Events */
  SdlEventType.Sensorupdate : "sensorupdate",
  /* Render Events */
  SdlEventType.Rendertargetsreset : "rendertargetsreset",
  SdlEventType.Renderdevicereset : "renderdevicereset",
}

class SdlEventFactory {
  construct new(){}

  create(sdl){
    var name = SdlEventToName[sdl.type]
    if(sdl.type == SdlEventType.Mousemotion){
      return UiEvent.new(name, {
        "x": sdl.motion_x,
        "y": sdl.motion_y,
        "xrel": sdl.motion_xrel,
        "yrel": sdl.motion_yrel,
        "state": sdl.motion_state,
      })
    } else if(sdl.type == SdlEventType.Mousebuttondown || sdl.type == SdlEventType.Mousebuttonup){
      return UiEvent.new(name, {
        "x": sdl.button_x,
        "y": sdl.button_y,
        "button": sdl.button_button,
        "clicks": sdl.button_clicks,
      })
    } else if(sdl.type == SdlEventType.Mousewheel){
      return UiEvent.new(name, {
        "x": sdl.wheel_x,
        "y": sdl.wheel_y,
        "direction": sdl.wheel_direction
      })
    }
  } 
}

