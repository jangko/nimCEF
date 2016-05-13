const
  kNullCursorHandle* = nil
  kNullEventHandle*  = nil
  kNullWindowHandle* = nil

type
  cef_window_handle* = distinct pointer #NSView*
  cef_text_input_context* = distinct pointer #NSTextInputContext*
  cef_event_handle* = distinct pointer #NSEvent*
  cef_cursor_handle* = distinct pointer #NSCursor*

  # Structure representing CefExecuteProcess arguments.
  cef_main_args* = object
    argc*: cint
    argv*: ptr cstring

  # Class representing window information.
  cef_window_info* = object
    window_name*: cef_string
    x*, y*, width*, height*: cint

    # Set to true (1) to create the view initially hidden.
    hidden*: cint

    # NSView pointer for the parent view.
    parent_view*: cef_window_handle

    # Set to true (1) to create the browser using windowless (off-screen)
    # rendering. No view will be created for the browser and all rendering will
    # occur via the CefRenderHandler interface. The |parent_view| value will be
    # used to identify monitor info and to act as the parent view for dialogs,
    # context menus, etc. If |parent_view| is not provided then the main screen
    # monitor will be used and some functionality that requires a parent view
    # may not function correctly. In order to create windowless browsers the
    # CefSettings.windowless_rendering_enabled value must be set to true.
    windowless_rendering_enabled*: cint

    # Set to true (1) to enable transparent painting in combination with
    # windowless rendering. When this value is true a transparent background
    # color will be used (RGBA=0x00000000). When this value is false the
    # background will be white and opaque.
    transparent_painting_enabled*: cint

    # NSView pointer for the new browser view. Only used with windowed rendering.
    view*: cef_window_handle
