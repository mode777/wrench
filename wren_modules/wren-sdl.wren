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
  static MacCtrlClickEmulateRightClick { "SDL_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK" }
  static VideoWinD3dcompiler { "SDL_VIDEO_WIN_D3DCOMPILER" }
  static VideoWindowSharePixelFormat { "SDL_VIDEO_WINDOW_SHARE_PIXEL_FORMAT" }
  static WinrtPrivacyPolicyUrl { "SDL_WINRT_PRIVACY_POLICY_URL" }
  static VideoMacFullscreenSpaces { "SDL_VIDEO_MAC_FULLSCREEN_SPACES" }
  static MacBackgroundApp { "SDL_MAC_BACKGROUND_APP" }
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