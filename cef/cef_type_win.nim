import winapi

const
  kNullCursorHandle* = nil
  kNullEventHandle*  = nil
  kNullWindowHandle* = nil

type
  cef_window_handle* = HWND
  cef_text_input_context* = distinct pointer
  cef_event_handle* = ptr MSG
  cef_cursor_handle* = HCURSOR

  # Structure representing CefExecuteProcess arguments.
  cef_main_args* = object
    instance*: HINST

  # Structure representing window information.
  cef_window_info* = object
    #Standard parameters required by CreateWindowEx()
    ex_style*: DWORD
    window_name*: cef_string
    style*: DWORD
    x*, y*, width*, height*: cint
    parent_window*: cef_window_handle
    menu*: HMENU

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

    # Handle for the new browser window. Only used with windowed rendering.
    window*: cef_window_handle
