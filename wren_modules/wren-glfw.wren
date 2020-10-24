foreign class Window {
  construct new(w,h,title,hints){
    for(k in hints.keys){
      hint_(k, hints[k])
    }
    create_(w,h,title)
  }

  foreign hint_(hint, value)
  foreign create_(w,h,title)

  foreign makeContextCurrent()
  foreign shouldClose
  foreign shouldClose=(v)
  foreign swapBuffers()
  foreign keyCallback(fn)

  foreign cursorPos()

  // foreign setKeyCallback(cb)
  // keyCallback_(key, scancode, action, mods, cb){
  //   cb.call(key, scancode, action, mods)
  // }
}

class GLFW {
  foreign static runLoop(fn)
  foreign static swapInterval(ms)
  foreign static time
}

class WindowHint {
  static GLFW_FOCUSED { 0x00020001 }
  static GLFW_ICONIFIED { 0x00020002 }
  static GLFW_RESIZABLE { 0x00020003 }
  static GLFW_VISIBLE { 0x00020004 }
  static GLFW_DECORATED { 0x00020005 }
  static GLFW_AUTO_ICONIFY { 0x00020006 }
  static GLFW_FLOATING { 0x00020007 }
  static GLFW_MAXIMIZED { 0x00020008 }
  static GLFW_CENTER_CURSOR { 0x00020009 }
  static GLFW_TRANSPARENT_FRAMEBUFFER { 0x0002000A }
  static GLFW_HOVERED { 0x0002000B }
  static GLFW_FOCUS_ON_SHOW { 0x0002000C }

  static GLFW_RED_BITS { 0x00021001 }
  static GLFW_GREEN_BITS { 0x00021002 }
  static GLFW_BLUE_BITS { 0x00021003 }
  static GLFW_ALPHA_BITS { 0x00021004 }
  static GLFW_DEPTH_BITS { 0x00021005 }
  static GLFW_STENCIL_BITS { 0x00021006 }
  static GLFW_ACCUM_RED_BITS { 0x00021007 }
  static GLFW_ACCUM_GREEN_BITS { 0x00021008 }
  static GLFW_ACCUM_BLUE_BITS { 0x00021009 }
  static GLFW_ACCUM_ALPHA_BITS { 0x0002100A }
  static GLFW_AUX_BUFFERS { 0x0002100B }
  static GLFW_STEREO { 0x0002100C }
  static GLFW_SAMPLES { 0x0002100D }
  static GLFW_SRGB_CAPABLE { 0x0002100E }
  static GLFW_REFRESH_RATE { 0x0002100F }
  static GLFW_DOUBLEBUFFER { 0x00021010 }

  static GLFW_CLIENT_API { 0x00022001 }
  static GLFW_CONTEXT_VERSION_MAJOR { 0x00022002 }
  static GLFW_CONTEXT_VERSION_MINOR { 0x00022003 }
  static GLFW_CONTEXT_REVISION { 0x00022004 }
  static GLFW_CONTEXT_ROBUSTNESS { 0x00022005 }
  static GLFW_OPENGL_FORWARD_COMPAT { 0x00022006 }
  static GLFW_OPENGL_DEBUG_CONTEXT { 0x00022007 }
  static GLFW_OPENGL_PROFILE { 0x00022008 }
  static GLFW_CONTEXT_RELEASE_BEHAVIOR { 0x00022009 }
  static GLFW_CONTEXT_NO_ERROR { 0x0002200A }
  static GLFW_CONTEXT_CREATION_API { 0x0002200B }
  static GLFW_SCALE_TO_MONITOR { 0x0002200C }
  static GLFW_COCOA_RETINA_FRAMEBUFFER { 0x00023001 }
  static GLFW_COCOA_FRAME_NAME { 0x00023002 }
  static GLFW_COCOA_GRAPHICS_SWITCHING { 0x00023003 }
  static GLFW_X11_CLASS_NAME { 0x00024001 }
  static GLFW_X11_INSTANCE_NAME { 0x00024002 }
}

class GlApi {
  static GLFW_NO_API { 0 }
  static GLFW_OPENGL_API { 0x00030001 }
  static GLFW_OPENGL_ES_API { 0x00030002 }
}

class ContextRobustness{
  static GLFW_NO_ROBUSTNESS { 0 }
  static GLFW_NO_RESET_NOTIFICATION { 0x00031001 }
  static GLFW_LOSE_CONTEXT_ON_RESET { 0x00031002 }
}

class GlProfile {
  static GLFW_CURSOR { 0x00033001 }
  static GLFW_STICKY_KEYS { 0x00033002 }
  static GLFW_STICKY_MOUSE_BUTTONS { 0x00033003 }
  static GLFW_LOCK_KEY_MODS { 0x00033004 }
  static GLFW_RAW_MOUSE_MOTION { 0x00033005 }
}

class CursorBehaviour {
  static GLFW_CURSOR_NORMAL { 0x00034001 }
  static GLFW_CURSOR_HIDDEN { 0x00034002 }
  static GLFW_CURSOR_DISABLED { 0x00034003 }
}

class ReleaseBehaviour {
  static GLFW_ANY_RELEASE_BEHAVIOR { 0 }
  static GLFW_RELEASE_BEHAVIOR_FLUSH { 0x00035001 }
  static GLFW_RELEASE_BEHAVIOR_NONE { 0x00035002 }
}

class GlContextApi {
  static GLFW_NATIVE_CONTEXT_API { 0x00036001 }
  static GLFW_EGL_CONTEXT_API { 0x00036002 }
  static GLFW_OSMESA_CONTEXT_API { 0x00036003 }
}

class CursorStyle {
  static GLFW_ARROW_CURSOR { 0x00036001 }
  static GLFW_IBEAM_CURSOR { 0x00036002 }
  static GLFW_CROSSHAIR_CURSOR { 0x00036003 }
  static GLFW_HAND_CURSOR { 0x00036004 }
  static GLFW_HRESIZE_CURSOR { 0x00036005 }
  static GLFW_VRESIZE_CURSOR { 0x00036006 }
}

class Key {
  static GLFW_KEY_UNKNOWN { -1 }
  static GLFW_KEY_SPACE { 32 }
  static GLFW_KEY_APOSTROPHE { 39  /* ' */ }
  static GLFW_KEY_COMMA { 44  /* , */ }
  static GLFW_KEY_MINUS { 45  /* - */ }
  static GLFW_KEY_PERIOD { 46  /* . */ }
  static GLFW_KEY_SLASH { 47  /* / */ }
  static GLFW_KEY_0 { 48 }
  static GLFW_KEY_1 { 49 }
  static GLFW_KEY_2 { 50 }
  static GLFW_KEY_3 { 51 }
  static GLFW_KEY_4 { 52 }
  static GLFW_KEY_5 { 53 }
  static GLFW_KEY_6 { 54 }
  static GLFW_KEY_7 { 55 }
  static GLFW_KEY_8 { 56 }
  static GLFW_KEY_9 { 57 }
  static GLFW_KEY_SEMICOLON { 59  /* ; */ }
  static GLFW_KEY_EQUAL { 61  /* = */ }
  static GLFW_KEY_A { 65 }
  static GLFW_KEY_B { 66 }
  static GLFW_KEY_C { 67 }
  static GLFW_KEY_D { 68 }
  static GLFW_KEY_E { 69 }
  static GLFW_KEY_F { 70 }
  static GLFW_KEY_G { 71 }
  static GLFW_KEY_H { 72 }
  static GLFW_KEY_I { 73 }
  static GLFW_KEY_J { 74 }
  static GLFW_KEY_K { 75 }
  static GLFW_KEY_L { 76 }
  static GLFW_KEY_M { 77 }
  static GLFW_KEY_N { 78 }
  static GLFW_KEY_O { 79 }
  static GLFW_KEY_P { 80 }
  static GLFW_KEY_Q { 81 }
  static GLFW_KEY_R { 82 }
  static GLFW_KEY_S { 83 }
  static GLFW_KEY_T { 84 }
  static GLFW_KEY_U { 85 }
  static GLFW_KEY_V { 86 }
  static GLFW_KEY_W { 87 }
  static GLFW_KEY_X { 88 }
  static GLFW_KEY_Y { 89 }
  static GLFW_KEY_Z { 90 }
  static GLFW_KEY_LEFT_BRACKET { 91  /* [ */ }
  static GLFW_KEY_BACKSLASH { 92  /* \ */ }
  static GLFW_KEY_RIGHT_BRACKET { 93  /* ] */ }
  static GLFW_KEY_GRAVE_ACCENT { 96  /* ` */ }
  static GLFW_KEY_WORLD_1 { 161 /* non-US #1 */ }
  static GLFW_KEY_WORLD_2 { 162 /* non-US #2 */ }
  static GLFW_KEY_ESCAPE { 256 }
  static GLFW_KEY_ENTER { 257 }
  static GLFW_KEY_TAB { 258 }
  static GLFW_KEY_BACKSPACE { 259 }
  static GLFW_KEY_INSERT { 260 }
  static GLFW_KEY_DELETE { 261 }
  static GLFW_KEY_RIGHT { 262 }
  static GLFW_KEY_LEFT { 263 }
  static GLFW_KEY_DOWN { 264 }
  static GLFW_KEY_UP { 265 }
  static GLFW_KEY_PAGE_UP { 266 }
  static GLFW_KEY_PAGE_DOWN { 267 }
  static GLFW_KEY_HOME { 268 }
  static GLFW_KEY_END { 269 }
  static GLFW_KEY_CAPS_LOCK { 280 }
  static GLFW_KEY_SCROLL_LOCK { 281 }
  static GLFW_KEY_NUM_LOCK { 282 }
  static GLFW_KEY_PRINT_SCREEN { 283 }
  static GLFW_KEY_PAUSE { 284 }
  static GLFW_KEY_F1 { 290 }
  static GLFW_KEY_F2 { 291 }
  static GLFW_KEY_F3 { 292 }
  static GLFW_KEY_F4 { 293 }
  static GLFW_KEY_F5 { 294 }
  static GLFW_KEY_F6 { 295 }
  static GLFW_KEY_F7 { 296 }
  static GLFW_KEY_F8 { 297 }
  static GLFW_KEY_F9 { 298 }
  static GLFW_KEY_F10 { 299 }
  static GLFW_KEY_F11 { 300 }
  static GLFW_KEY_F12 { 301 }
  static GLFW_KEY_F13 { 302 }
  static GLFW_KEY_F14 { 303 }
  static GLFW_KEY_F15 { 304 }
  static GLFW_KEY_F16 { 305 }
  static GLFW_KEY_F17 { 306 }
  static GLFW_KEY_F18 { 307 }
  static GLFW_KEY_F19 { 308 }
  static GLFW_KEY_F20 { 309 }
  static GLFW_KEY_F21 { 310 }
  static GLFW_KEY_F22 { 311 }
  static GLFW_KEY_F23 { 312 }
  static GLFW_KEY_F24 { 313 }
  static GLFW_KEY_F25 { 314 }
  static GLFW_KEY_KP_0 { 320 }
  static GLFW_KEY_KP_1 { 321 }
  static GLFW_KEY_KP_2 { 322 }
  static GLFW_KEY_KP_3 { 323 }
  static GLFW_KEY_KP_4 { 324 }
  static GLFW_KEY_KP_5 { 325 }
  static GLFW_KEY_KP_6 { 326 }
  static GLFW_KEY_KP_7 { 327 }
  static GLFW_KEY_KP_8 { 328 }
  static GLFW_KEY_KP_9 { 329 }
  static GLFW_KEY_KP_DECIMAL { 330 }
  static GLFW_KEY_KP_DIVIDE { 331 }
  static GLFW_KEY_KP_MULTIPLY { 332 }
  static GLFW_KEY_KP_SUBTRACT { 333 }
  static GLFW_KEY_KP_ADD { 334 }
  static GLFW_KEY_KP_ENTER { 335 }
  static GLFW_KEY_KP_EQUAL { 336 }
  static GLFW_KEY_LEFT_SHIFT { 340 }
  static GLFW_KEY_LEFT_CONTROL { 341 }
  static GLFW_KEY_LEFT_ALT { 342 }
  static GLFW_KEY_LEFT_SUPER { 343 }
  static GLFW_KEY_RIGHT_SHIFT { 344 }
  static GLFW_KEY_RIGHT_CONTROL { 345 }
  static GLFW_KEY_RIGHT_ALT { 346 }
  static GLFW_KEY_RIGHT_SUPER { 347 }
  static GLFW_KEY_MENU { 348 }
}

class KeyMod {
  static GLFW_MOD_SHIFT { 0x0001 }
  static GLFW_MOD_CONTROL { 0x0002 }
  static GLFW_MOD_ALT { 0x0004 }
  static GLFW_MOD_SUPER { 0x0008 }
  static GLFW_MOD_CAPS_LOCK { 0x0010 }
  static GLFW_MOD_NUM_LOCK { 0x0020 }
}

class GamepadButton {
  static GLFW_GAMEPAD_BUTTON_A { 0 }
  static GLFW_GAMEPAD_BUTTON_B { 1 }
  static GLFW_GAMEPAD_BUTTON_X { 2 }
  static GLFW_GAMEPAD_BUTTON_Y { 3 }
  static GLFW_GAMEPAD_BUTTON_LEFT_BUMPER { 4 }
  static GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER { 5 }
  static GLFW_GAMEPAD_BUTTON_BACK { 6 }
  static GLFW_GAMEPAD_BUTTON_START { 7 }
  static GLFW_GAMEPAD_BUTTON_GUIDE { 8 }
  static GLFW_GAMEPAD_BUTTON_LEFT_THUMB { 9 }
  static GLFW_GAMEPAD_BUTTON_RIGHT_THUMB { 10 }
  static GLFW_GAMEPAD_BUTTON_DPAD_UP { 11 }
  static GLFW_GAMEPAD_BUTTON_DPAD_RIGHT { 12 }
  static GLFW_GAMEPAD_BUTTON_DPAD_DOWN { 13 }
  static GLFW_GAMEPAD_BUTTON_DPAD_LEFT { 14 }
}

class GamepadAxis {
  static GLFW_GAMEPAD_AXIS_LEFT_X { 0 }
  static GLFW_GAMEPAD_AXIS_LEFT_Y { 1 }
  static GLFW_GAMEPAD_AXIS_RIGHT_X { 2 }
  static GLFW_GAMEPAD_AXIS_RIGHT_Y { 3 }
  static GLFW_GAMEPAD_AXIS_LEFT_TRIGGER { 4 }
  static GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER { 5 }
}

class Action {
 static GLFW_RELEASE { 0 }
 static GLFW_PRESS { 1 }
 static GLFW_REPEAT { 2 }
}