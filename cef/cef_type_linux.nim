include cef_import

const 
  kNullCursorHandle* = 0
  kNullEventHandle*  = nil
  kNullWindowHandle* = 0
  
type  
  cef_cursor_handle* = culong
  cef_event_handle*  = distinct pointer # XEvent*
  cef_window_handle* = culong
  XDisplay = distinct pointer
  cef_text_input_context* = distinct pointer

  # Structure representing CefExecuteProcess arguments.
  cef_main_args* = object
    argc*: cint
    argv*: ptr cstring

  # Class representing window information.
  
  cef_window_info* = object
    x*: cuint
    y*: cuint
    width*: cuint
    height*: cuint

    # Pointer for the parent window.
    parent_window*: cef_window_handle

    # Set to true (1) to create the browser using windowless (off-screen)
    # rendering. No window will be created for the browser and all rendering will
    # occur via the CefRenderHandler interface. The |parent_window| value will be
    # used to identify monitor info and to act as the parent window for dialogs,
    # context menus, etc. If |parent_window| is not provided then the main screen
    # monitor will be used and some functionality that requires a parent window
    # may not function correctly. In order to create windowless browsers the
    # CefSettings.windowless_rendering_enabled value must be set to true.
    windowless_rendering_enabled*: cint

    # Set to true (1) to enable transparent painting in combination with
    # windowless rendering. When this value is true a transparent background
    # color will be used (RGBA=0x00000000). When this value is false the
    # background will be white and opaque.
    transparent_painting_enabled*: cint

    #Pointer for the new browser window. Only used with windowed rendering.
    window*: cef_window_handle
  
proc cef_get_xdisplay*(): XDisplay {.cef_import.}

