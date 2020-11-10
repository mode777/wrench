import "tasks" for Task, DefaultCanceller

foreign class SdlWindow {
  construct new(width, height, title, hints){
    create_(width, height, title, hints)
  }

  foreign create_(width, height, title, hints)
  foreign makeCurrent(glContext)
  foreign swap()
}

foreign class SdlGlContext {
  construct new(win){
    create_(win)
  }

  foreign create_(win)
}

foreign class SdlEvent {
  construct new(){
  }

  foreign type
  foreign key_isRepeat
  foreign key_sym
  foreign touch_x
  foreign touch_y
}

foreign class SdlThread {
  static waitParent(){
    while(countParent == 0){}
    return receiveParent()
  }
  static waitParentAsync(cancel){
    return Task.new(cancel) {|c|
      while(countParent == 0 && !c.isCancelled){
        Fiber.yield()
      }
      var p = receiveParent() 
      return p
    }
  }
  static waitParentAsync(){ waitParentAsync(DefaultCanceller) }
  foreign static sendParent(msg)
  foreign static receiveParent()
  foreign static countParent

  construct new(path){
    create(path)
  }
  foreign create(name)
  foreign isDone
  foreign result
  foreign send(mgs)
  foreign receive()
  foreign messageCount
  waitMessage(){
    while(messageCount == 0){}
    return receive()
  }
  waitMessageAsync(cancel){
    return Task.new {|c|
      while(messageCount == 0 && !c.isCancelled){
        Fiber.yield()
      }
      if(c.isCancelled) return null
      return receive()
    }
  }
  waitMessageAsync(){ waitMessageAsync(DefaultCanceller) }
  wait(){
    while(!isDone){}
  }
  waitAsync(cancel){
    return Task.new {
      while(!isDone && !cancel.isCancelled){ Fiber.yield() }
    }
  }
  waitAsync(){ waitAsync(DefaultCanceller) }
}

class SDL {
  foreign static delay(ms)
  foreign static runLoop(fn)
  foreign static pollEvent(ev)
  foreign static setAttribute(attr, val)
  foreign static setHint(attr, val)
  foreign static setSwapInterval(i)
  foreign static ticks
  foreign static getMouseState()
}

// static ]+([^\s]+)\s+= { 0 } ([^,\n\s]+),?
// static \u\L$1 { $2 }

// static ([^_\{]+)_([^_\s\{]+)
// static $1\u\L$2

class SdlWindowFlag {
  static Fullscreen { 0x00000001 }         /**< fullscreen window */
  static Opengl { 0x00000002 }             /**< window usable with OpenGL context */
  static Shown { 0x00000004 }              /**< window is visible */
  static Hidden { 0x00000008 }             /**< window is not visible */
  static Borderless { 0x00000010 }         /**< no window decoration */
  static Resizable { 0x00000020 }          /**< window can be resized */
  static Minimized { 0x00000040 }          /**< window is minimized */
  static Maximized { 0x00000080 }          /**< window is maximized */
  static InputGrabbed { 0x00000100 }      /**< window has grabbed input focus */
  static InputFocus { 0x00000200 }        /**< window has input focus */
  static MouseFocus { 0x00000400 }        /**< window has mouse focus */
  static FullscreenDesktop { SdlWindowFlag.Fullscreen | 0x00001000 }
  static Foreign { 0x00000800 }            /**< window not created by SDL */
  static AllowHighdpi { 0x00002000 }      /**< window should be created in high-DPI mode if supported.
                                                    On macOS NSHighResolutionCapable must be set true in the
                                                    application's Info.plist for this to have any effect. */
  static MouseCapture { 0x00004000 }      /**< window has mouse captured (unrelated to INPUT_GRABBED) */
  static AlwaysOnTop { 0x00008000 }      /**< window should always be above others */
  static SkipTaskbar { 0x00010000 }      /**< window should not be added to the taskbar */
  static Utility { 0x00020000 }      /**< window should be treated as a utility window */
  static Tooltip { 0x00040000 }      /**< window should be treated as a tooltip */
  static PopupMenu { 0x00080000 }      /**< window should be treated as a popup menu */
  static Vulkan { 0x10000000 }       /**< window usable for Vulkan surface */
}

class SdlGlAttribute {
  static RedSize { 0 }
  static GreenSize { 1 }
  static BlueSize { 2 }
  static AlphaSize { 3 }
  static BufferSize { 4 }
  static Doublebuffer { 5 }
  static DepthSize { 6 }
  static StencilSize { 7 }
  static AccumRedSize { 8 }
  static AccumGreenSize { 9 }
  static AccumBlueSize { 10 }
  static AccumAlphaSize { 11 }
  static Stereo { 12 }
  static Multisamplebuffers { 13 }
  static Multisamplesamples { 14 }
  static AcceleratedVisual { 15 }
  static RetainedVacking { 16 }
  static ContextMajorVersion { 17 }
  static ContextMinorVersion { 18 }
  static ContextEgl { 19 }
  static ContextFlags { 20 }
  static ContextProfileMask { 21 }
  static ShareWithCurrentContext { 22 }
  static FramebufferSrgbCapable { 23 }
  static ContextReleaseBehavior { 24 }
  static ContextResetNotification { 25 }
  static ContextNoError { 26 }
}

class SdlGlProfile {

  static Core { 0x0001 }
  static Compatibility { 0x0002 }
  static Es { 0x0004 } /**< GLX_CONTEXT_ES2_PROFILE_BIT_EXT */
}

class SdlHint {
  static FramebufferAcceleration { "SDL_FRAMEBUFFER_ACCELERATION" }
  static RenderDriver { "SDL_RENDER_DRIVER" }
  static RenderOpenglShaders { "SDL_RENDER_OPENGL_SHADERS" }
  static RenderDirect3dThreadsafe { "SDL_RENDER_DIRECT3D_THREADSAFE" }
  static RenderDirect3d11Debug { "SDL_RENDER_DIRECT3D11_DEBUG" }
  static RenderLogicalSizeMode { "SDL_RENDER_LOGICAL_SIZE_MODE" }
  static RenderScaleQuality { "SDL_RENDER_SCALE_QUALITY" }
  static RenderVsync { "SDL_RENDER_VSYNC" }
  static VideoAllowScreensaver { "SDL_VIDEO_ALLOW_SCREENSAVER" }
  static VideoX11Xvidmode { "SDL_VIDEO_X11_XVIDMODE" }
  static VideoX11Xinerama { "SDL_VIDEO_X11_XINERAMA" }
  static VideoX11Xrandr { "SDL_VIDEO_X11_XRANDR" }
  static VideoX11NetWmPing { "SDL_VIDEO_X11_NET_WM_PING" }
  static VideoX11NetWmBypassCompositor { "SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR" }
  static WindowFrameUsableWhileCursorHidden { "SDL_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN" }
  static WindowsIntresourceIcon { "SDL_WINDOWS_INTRESOURCE_ICON" }
  static WindowsIntresourceIconSmall { "SDL_WINDOWS_INTRESOURCE_ICON_SMALL" }
  static WindowsEnableMessageloop { "SDL_WINDOWS_ENABLE_MESSAGELOOP" }
  static GrabKeyboard { "SDL_GRAB_KEYBOARD" }
  static MouseDoubleClickTime { "SDL_MOUSE_DOUBLE_CLICK_TIME" }
  static MouseDoubleClickRadius { "SDL_MOUSE_DOUBLE_CLICK_RADIUS" }
  static MouseNormalSpeedScale { "SDL_MOUSE_NORMAL_SPEED_SCALE" }
  static MouseRelativeSpeedScale { "SDL_MOUSE_RELATIVE_SPEED_SCALE" }
  static MouseRelativeModeWarp { "SDL_MOUSE_RELATIVE_MODE_WARP" }
  static MouseFocusClickthrough { "SDL_MOUSE_FOCUS_CLICKTHROUGH" }
  static TouchMouseEvents { "SDL_TOUCH_MOUSE_EVENTS" }
  static MouseTouchEvents { "SDL_MOUSE_TOUCH_EVENTS" }
  static VideoMinimizeOnFocusLoss { "SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS" }
  static IdleTimerDisabled { "SDL_IOS_IDLE_TIMER_DISABLED" }
  static Orientations { "SDL_IOS_ORIENTATIONS" }
  static AppleTvControllerUiEvents { "SDL_APPLE_TV_CONTROLLER_UI_EVENTS" }
  static AppleTvRemoteAllowRotation { "SDL_APPLE_TV_REMOTE_ALLOW_ROTATION" }
  static IosHideHomeIndicator { "SDL_IOS_HIDE_HOME_INDICATOR" }
  static AccelerometerAsJoystick { "SDL_ACCELEROMETER_AS_JOYSTICK" }
  static TvRemoteAsJoystick { "SDL_TV_REMOTE_AS_JOYSTICK" }
  static XinputEnabled { "SDL_XINPUT_ENABLED" }
  static XinputUseOldJoystickMapping { "SDL_XINPUT_USE_OLD_JOYSTICK_MAPPING" }
  static Gamecontrollerconfig { "SDL_GAMECONTROLLERCONFIG" }
  static GamecontrollerconfigFile { "SDL_GAMECONTROLLERCONFIG_FILE" }
  static GamecontrollerIgnoreDevices { "SDL_GAMECONTROLLER_IGNORE_DEVICES" }
  static GamecontrollerIgnoreDevicesExcept { "SDL_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT" }
  static JoystickAllowBackgroundEvents { "SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS" }
  static JoystickHidapi { "SDL_JOYSTICK_HIDAPI" }
  static JoystickHidapiPs4 { "SDL_JOYSTICK_HIDAPI_PS4" }
  static JoystickHidapiPs4Rumble { "SDL_JOYSTICK_HIDAPI_PS4_RUMBLE" }
  static JoystickHidapiSteam { "SDL_JOYSTICK_HIDAPI_STEAM" }
  static JoystickHidapiSwitch { "SDL_JOYSTICK_HIDAPI_SWITCH" }
  static JoystickHidapiXbox { "SDL_JOYSTICK_HIDAPI_XBOX" }
  static EnableSteamControllers { "SDL_ENABLE_STEAM_CONTROLLERS" }
  static AllowTopmost { "SDL_ALLOW_TOPMOST" }
  static TimerResolution { "SDL_TIMER_RESOLUTION" }
  static QtwaylandContentOrientation { "SDL_QTWAYLAND_CONTENT_ORIENTATION" }
  static QtwaylandWindowFlags { "SDL_QTWAYLAND_WINDOW_FLAGS" }
  static ThreadStackSize { "SDL_THREAD_STACK_SIZE" }
  static VideoHighdpiDisabled { "SDL_VIDEO_HIGHDPI_DISABLED" }
  static MacCtrlClickEmulateRightClick { "SDL_MAcCtrl_CLICK_EMULATE_RIGHT_CLICK" }
  static VideoWinD3dcompiler { "SDL_VIDEO_WIN_D3DCOMPILER" }
  static VideoWindowSharePixelFormat { "SDL_VIDEO_WINDOW_SHARE_PIXEL_FORMAT" }
  static WinrtPrivacyPolicyUrl { "SDL_WINRT_PRIVACY_POLICY_URL" }
  static VideoMacFullscreenSpaces { "SDL_VIDEO_MAcFullscreen_SPACES" }
  static MacBackgroundApp { "SDL_MAcBackground_APP" }
  static AndroidApkExpansionMainFileVersion { "SDL_ANDROID_APK_EXPANSION_MAIN_FILE_VERSION" }
  static AndroidApkExpansionPatchFileVersion { "SDL_ANDROID_APK_EXPANSION_PATCH_FILE_VERSION" }
  static ImeInternalEditing { "SDL_IME_INTERNAL_EDITING" }
  static AndroidTrapBackButton { "SDL_ANDROID_TRAP_BACK_BUTTON" }
  static AndroidBlockOnPause { "SDL_ANDROID_BLOCK_ON_PAUSE" }
  static ReturnKeyHidesIme { "SDL_RETURN_KEY_HIDES_IME" }
  static EmscriptenKeyboardElement { "SDL_EMSCRIPTEN_KEYBOARD_ELEMENT" }
  static NoSignalHandlers { "SDL_NO_SIGNAL_HANDLERS" }
  static WindowsNoCloseOnAltF4 { "SDL_WINDOWS_NO_CLOSE_ON_ALT_F4" }
  static BmpSaveLegacyFormat { "SDL_BMP_SAVE_LEGACY_FORMAT" }
  static WindowsDisableThreadNaming { "SDL_WINDOWS_DISABLE_THREAD_NAMING" }
  static RpiVideoLayer { "SDL_RPI_VIDEO_LAYER" }
  static VideoDoubleBuffer { "SDL_VIDEO_DOUBLE_BUFFER" }
  static OpenglEsDriver { "SDL_OPENGL_ES_DRIVER" }
  static AudioResamplingMode { "SDL_AUDIO_RESAMPLING_MODE" }
  static AudioCategory { "SDL_AUDIO_CATEGORY" }
  static RenderBatching { "SDL_RENDER_BATCHING" }
  static EventLogging { "SDL_EVENT_LOGGING" }
  static WaveRiffChunkSize { "SDL_WAVE_RIFF_CHUNK_SIZE" }
  static WaveTruncation { "SDL_WAVE_TRUNCATION" }
  static WaveFactChunk { "SDL_WAVE_FACT_CHUNK" }
}

class SdlEventType {
  static getName(n){
    if(n == SdlEventType.Quit) return "Quit"
    if(n == SdlEventType.Terminating) return "Terminating"
    if(n == SdlEventType.Lowmemory) return "Lowmemory"
    if(n == SdlEventType.Willenterbackground) return "Willenterbackground"
    if(n == SdlEventType.Didenterbackground) return "Didenterbackground"
    if(n == SdlEventType.Willenterforeground) return "Willenterforeground"
    if(n == SdlEventType.Didenterforeground) return "Didenterforeground"
    if(n == SdlEventType.Displayevent) return "Displayevent"
    if(n == SdlEventType.Windowevent) return "Windowevent"
    if(n == SdlEventType.Syswmevent) return "Syswmevent"
    if(n == SdlEventType.Keydown) return "Keydown"
    if(n == SdlEventType.Keyup) return "Keyup"
    if(n == SdlEventType.Textediting) return "Textediting"
    if(n == SdlEventType.Textinput) return "Textinput"
    if(n == SdlEventType.Keymapchanged) return "Keymapchanged"
    if(n == SdlEventType.Mousemotion) return "Mousemotion"
    if(n == SdlEventType.Mousebuttondown) return "Mousebuttondown"
    if(n == SdlEventType.Mousebuttonup) return "Mousebuttonup"
    if(n == SdlEventType.Mousewheel) return "Mousewheel"
    if(n == SdlEventType.Joyaxismotion) return "Joyaxismotion"
    if(n == SdlEventType.Joyballmotion) return "Joyballmotion"
    if(n == SdlEventType.Joyhatmotion) return "Joyhatmotion"
    if(n == SdlEventType.Joybuttondown) return "Joybuttondown"
    if(n == SdlEventType.Joybuttonup) return "Joybuttonup"
    if(n == SdlEventType.Joydeviceadded) return "Joydeviceadded"
    if(n == SdlEventType.Joydeviceremoved) return "Joydeviceremoved"
    if(n == SdlEventType.Controlleraxismotion) return "Controlleraxismotion"
    if(n == SdlEventType.Controllerbuttondown) return "Controllerbuttondown"
    if(n == SdlEventType.Controllerbuttonup) return "Controllerbuttonup"
    if(n == SdlEventType.Controllerdeviceadded) return "Controllerdeviceadded"
    if(n == SdlEventType.Controllerdeviceremoved) return "Controllerdeviceremoved"
    if(n == SdlEventType.Controllerdeviceremapped) return "Controllerdeviceremapped"
    if(n == SdlEventType.Fingerdown) return "Fingerdown"
    if(n == SdlEventType.Fingerup) return "Fingerup"
    if(n == SdlEventType.Fingermotion) return "Fingermotion"
    if(n == SdlEventType.Dollargesture) return "Dollargesture"
    if(n == SdlEventType.Dollarrecord) return "Dollarrecord"
    if(n == SdlEventType.Multigesture) return "Multigesture"
    if(n == SdlEventType.Clipboardupdate) return "Clipboardupdate"
    if(n == SdlEventType.Dropfile) return "Dropfile"
    if(n == SdlEventType.Droptext) return "Droptext"
    if(n == SdlEventType.Dropbegin) return "Dropbegin"
    if(n == SdlEventType.Dropcomplete) return "Dropcomplete"
    if(n == SdlEventType.Audiodeviceadded) return "Audiodeviceadded"
    if(n == SdlEventType.Audiodeviceremoved) return "Audiodeviceremoved"
    if(n == SdlEventType.Sensorupdate) return "Sensorupdate"
    if(n == SdlEventType.Rendertargetsreset) return "Rendertargetsreset"
    if(n == SdlEventType.Renderdevicereset) return "Renderdevicereset"
    if(n == SdlEventType.Init) return "Init"
    if(n == SdlEventType.Load) return "Load"
    if(n == SdlEventType.Update) return "Update"

  }

  static Quit { 0x100 } 
  static Terminating { 0x101 }        
  static Lowmemory { 0x102 }          
  static Willenterbackground { 0x103 } 
  static Didenterbackground { 0x104 } 
  static Willenterforeground { 0x105 } 
  static Didenterforeground { 0x106 } 
  /* Display Events */
  static Displayevent { 0x150 }  
  /* Window Events */
  static Windowevent { 0x200 } 
  static Syswmevent { 0x201 }             
  /* Keyboard Events */
  static Keydown { 0x300 } 
  static Keyup { 0x301 }                  
  static Textediting { 0x302 }            
  static Textinput { 0x303 }              
  static Keymapchanged { 0x304 }          
  /* Mouse Events */
  static Mousemotion { 0x400 } 
  static Mousebuttondown { 0x401 }        
  static Mousebuttonup { 0x402 }          
  static Mousewheel { 0x403 }             
  /* Joystick Events */
  static Joyaxismotion { 0x600 } 
  static Joyballmotion { 0x601 }          
  static Joyhatmotion { 0x602 }           
  static Joybuttondown { 0x603 }          
  static Joybuttonup { 0x604 }            
  static Joydeviceadded { 0x605 }         
  static Joydeviceremoved { 0x606 }       
  /* Game Controller Events */
  static Controlleraxismotion { 0x650 } 
  static Controllerbuttondown { 0x651 }          
  static Controllerbuttonup { 0x652 }            
  static Controllerdeviceadded { 0x653 }         
  static Controllerdeviceremoved { 0x654 }       
  static Controllerdeviceremapped { 0x655 }      
  /* Touch Events */
  static Fingerdown { 0x700 }
  static Fingerup { 0x701 }
  static Fingermotion { 0x702 }
  /* Gesture Events */
  static Dollargesture { 0x800 }
  static Dollarrecord { 0x801 }
  static Multigesture { 0x802 }
  /* Clipboard Events */
  static Clipboardupdate { 0x900 } 
  /* Drag And Drop Events */
  static Dropfile { 0x1000 } 
  static Droptext { 0x1001 }                 
  static Dropbegin { 0x1002 }                
  static Dropcomplete { 0x1003 }             
  /* Audio Hotplug Events */
  static Audiodeviceadded { 0x1100 } 
  static Audiodeviceremoved { 0x1101 }        
  /* Sensor Events */
  static Sensorupdate { 0x1200 }     
  /* Render Events */
  static Rendertargetsreset { 0x2000 } 
  static Renderdevicereset { 0x2001 } 
}

class SdlKeyCode {
  static Unknown { 0 }
  static Backspace { 8 }
  static Tab { 9 }
  static Return { 13 }
  static Escape { 27 }
  static Space { 32 }
  static Exclaim { 33 }
  static Quotedbl { 34 }
  static Hash { 35 }
  static Dollar { 36 }
  static Percent { 37 }
  static Ampersand { 38 }
  static Quote { 39 }
  static Leftparen { 40 }
  static Rightparen { 41 }
  static Asterisk { 42 }
  static Plus { 43 }
  static Comma { 44 }
  static Minus { 45 }
  static Period { 46 }
  static Slash { 47 }
  static Num0 { 48 }
  static Num1 { 49 }
  static Num2 { 50 }
  static Num3 { 51 }
  static Num4 { 52 }
  static Num5 { 53 }
  static Num6 { 54 }
  static Num7 { 55 }
  static Num8 { 56 }
  static Num9 { 57 }
  static Colon { 58 }
  static Semicolon { 59 }
  static Less { 60 }
  static Equals { 61 }
  static Greater { 62 }
  static Question { 63 }
  static At { 64 }
  static Leftbracket { 91 }
  static Backslash { 92 }
  static Rightbracket { 93 }
  static Caret { 94 }
  static Underscore { 95 }
  static Backquote { 96 }
  static A { 97 }
  static B { 98 }
  static C { 99 }
  static D { 100 }
  static E { 101 }
  static F { 102 }
  static G { 103 }
  static H { 104 }
  static I { 105 }
  static J { 106 }
  static K { 107 }
  static L { 108 }
  static M { 109 }
  static N { 110 }
  static O { 111 }
  static P { 112 }
  static Q { 113 }
  static R { 114 }
  static S { 115 }
  static T { 116 }
  static U { 117 }
  static V { 118 }
  static W { 119 }
  static X { 120 }
  static Y { 121 }
  static Z { 122 }
  static Delete { 127 }
  static Capslock { 1073741881 }
  static F1 { 1073741882 }
  static F2 { 1073741883 }
  static F3 { 1073741884 }
  static F4 { 1073741885 }
  static F5 { 1073741886 }
  static F6 { 1073741887 }
  static F7 { 1073741888 }
  static F8 { 1073741889 }
  static F9 { 1073741890 }
  static F10 { 1073741891 }
  static F11 { 1073741892 }
  static F12 { 1073741893 }
  static Printscreen { 1073741894 }
  static Scrolllock { 1073741895 }
  static Pause { 1073741896 }
  static Insert { 1073741897 }
  static Home { 1073741898 }
  static Pageup { 1073741899 }
  static End { 1073741901 }
  static Pagedown { 1073741902 }
  static Right { 1073741903 }
  static Left { 1073741904 }
  static Down { 1073741905 }
  static Up { 1073741906 }
  static Numlockclear { 1073741907 }
  static KpDivide { 1073741908 }
  static KpMultiply { 1073741909 }
  static KpMinus { 1073741910 }
  static KpPlus { 1073741911 }
  static KpEnter { 1073741912 }
  static Kp1 { 1073741913 }
  static Kp2 { 1073741914 }
  static Kp3 { 1073741915 }
  static Kp4 { 1073741916 }
  static Kp5 { 1073741917 }
  static Kp6 { 1073741918 }
  static Kp7 { 1073741919 }
  static Kp8 { 1073741920 }
  static Kp9 { 1073741921 }
  static Kp0 { 1073741922 }
  static KpPeriod { 1073741923 }
  static Application { 1073741925 }
  static Power { 1073741926 }
  static KpEquals { 1073741927 }
  static F13 { 1073741928 }
  static F14 { 1073741929 }
  static F15 { 1073741930 }
  static F16 { 1073741931 }
  static F17 { 1073741932 }
  static F18 { 1073741933 }
  static F19 { 1073741934 }
  static F20 { 1073741935 }
  static F21 { 1073741936 }
  static F22 { 1073741937 }
  static F23 { 1073741938 }
  static F24 { 1073741939 }
  static Execute { 1073741940 }
  static Help { 1073741941 }
  static Menu { 1073741942 }
  static Select { 1073741943 }
  static Stop { 1073741944 }
  static Again { 1073741945 }
  static Undo { 1073741946 }
  static Cut { 1073741947 }
  static Copy { 1073741948 }
  static Paste { 1073741949 }
  static Find { 1073741950 }
  static Mute { 1073741951 }
  static Volumeup { 1073741952 }
  static Volumedown { 1073741953 }
  static KpComma { 1073741957 }
  static KpEqualsas400 { 1073741958 }
  static Alterase { 1073741977 }
  static Sysreq { 1073741978 }
  static Cancel { 1073741979 }
  static Clear { 1073741980 }
  static Prior { 1073741981 }
  static Return2 { 1073741982 }
  static Separator { 1073741983 }
  static Out { 1073741984 }
  static Oper { 1073741985 }
  static Clearagain { 1073741986 }
  static Crsel { 1073741987 }
  static Exsel { 1073741988 }
  static Kp00 { 1073742000 }
  static Kp000 { 1073742001 }
  static Thousandsseparator { 1073742002 }
  static Decimalseparator { 1073742003 }
  static Currencyunit { 1073742004 }
  static Currencysubunit { 1073742005 }
  static KpLeftparen { 1073742006 }
  static KpRightparen { 1073742007 }
  static KpLeftbrace { 1073742008 }
  static KpRightbrace { 1073742009 }
  static KpTab { 1073742010 }
  static KpBackspace { 1073742011 }
  static KpA { 1073742012 }
  static KpB { 1073742013 }
  static KpC { 1073742014 }
  static KpD { 1073742015 }
  static KpE { 1073742016 }
  static KpF { 1073742017 }
  static KpXor { 1073742018 }
  static KpPower { 1073742019 }
  static KpPercent { 1073742020 }
  static KpLess { 1073742021 }
  static KpGreater { 1073742022 }
  static KpAmpersand { 1073742023 }
  static KpDblampersand { 1073742024 }
  static KpVerticalbar { 1073742025 }
  static KpDblverticalbar { 1073742026 }
  static KpColon { 1073742027 }
  static KpHash { 1073742028 }
  static KpSpace { 1073742029 }
  static KpAt { 1073742030 }
  static KpExclam { 1073742031 }
  static KpMemstore { 1073742032 }
  static KpMemrecall { 1073742033 }
  static KpMemclear { 1073742034 }
  static KpMemadd { 1073742035 }
  static KpMemsubtract { 1073742036 }
  static KpMemmultiply { 1073742037 }
  static KpMemdivide { 1073742038 }
  static KpPlusminus { 1073742039 }
  static KpClear { 1073742040 }
  static KpClearentry { 1073742041 }
  static KpBinary { 1073742042 }
  static KpOctal { 1073742043 }
  static KpDecimal { 1073742044 }
  static KpHexadecimal { 1073742045 }
  static Lctrl { 1073742048 }
  static Lshift { 1073742049 }
  static Lalt { 1073742050 }
  static Lgui { 1073742051 }
  static Rctrl { 1073742052 }
  static Rshift { 1073742053 }
  static Ralt { 1073742054 }
  static Rgui { 1073742055 }
  static Mode { 1073742081 }
  static Audionext { 1073742082 }
  static Audioprev { 1073742083 }
  static Audiostop { 1073742084 }
  static Audioplay { 1073742085 }
  static Audiomute { 1073742086 }
  static Mediaselect { 1073742087 }
  static Www { 1073742088 }
  static Mail { 1073742089 }
  static Calculator { 1073742090 }
  static Computer { 1073742091 }
  static AcSearch { 1073742092 }
  static AcHome { 1073742093 }
  static AcBack { 1073742094 }
  static AcForward { 1073742095 }
  static AcStop { 1073742096 }
  static AcRefresh { 1073742097 }
  static AcBookmarks { 1073742098 }
  static Brightnessdown { 1073742099 }
  static Brightnessup { 1073742100 }
  static Displayswitch { 1073742101 }
  static Kbdillumtoggle { 1073742102 }
  static Kbdillumdown { 1073742103 }
  static Kbdillumup { 1073742104 }
  static Eject { 1073742105 }
  static Sleep { 1073742106 }
}