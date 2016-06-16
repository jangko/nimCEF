import cef_base_api, cef_browser_api, cef_client_api, cef_frame_api
import cef_string_api, cef_string_list_api, cef_types
import nc_util

export cef_types, cef_base_api

# Structure used to represent a frame in the browser window. When used in the
# browser process the functions of this structure may be called on any thread
# unless otherwise indicated in the comments. When used in the render process
# the functions of this structure may only be called on the main thread.
wrapAPI(NCFrame, cef_frame)

# Structure used to represent a browser window. When used in the browser
# process the functions of this structure may be called on any thread unless
# otherwise indicated in the comments. When used in the render process the
# functions of this structure may only be called on the main thread.
wrapAPI(NCBrowser, cef_browser, false)

# Structure used to represent the browser process aspects of a browser window.
# The functions of this structure can only be called in the browser process.
# They may be called on any thread in that process unless otherwise indicated
# in the comments.
wrapAPI(NCBrowserHost, cef_browser_host, false)

# Implement this structure to provide handler implementations.
wrapAPI(NCClient, cef_client, false)

template nc_wrap*(x: ptr_cef_client): expr = nc_wrap(cast[ptr cef_client](x))
template nc_wrap*(x: ptr_cef_browser): expr = nc_wrap(cast[ptr cef_browser](x))
template nc_wrap*(x: ptr_cef_frame): expr = nc_wrap(cast[ptr cef_frame](x))
template nc_release*(x: ptr_cef_browser): expr = nc_release(cast[ptr cef_browser](x))
template nc_release*(x: ptr_cef_client): expr = nc_release(cast[ptr cef_client](x))
template nc_release*(x: ptr_cef_frame): expr = nc_release(cast[ptr cef_frame](x))

template USER_MENU_ID*(n: int): expr = (MENU_ID_USER_FIRST.ord + n).cef_menu_id

type
  NCMainArgs* = object
    args: cef_main_args

proc to_cef*(nc: NCMainArgs): cef_main_args =
  result = nc.args

proc nc_free*(nc: cef_main_args) = discard

when defined(windows):
  import winapi

  proc makeNCMainArgs*(): NCMainArgs =
    result.args.instance = getModuleHandle(nil)

else:
  import os

  var nim_params: seq[string]
  var c_params: seq[cstring]

  proc makeNCMainArgs*(): NCMainArgs =
    let count = paramCount()
    result.args.argc = count
    nim_params = newSeq[string](count)
    c_params = newSeq[cstring](count+1)
    for i in 0.. <count:
      nim_params[i] = paramStr(i)
      c_params[i] = nim_params[i][0].addr
    c_params[count] = nil
    result.args.argv = cparams[0].addr

when defined(windows):
  type
    NCWindowInfo* = object
      #Standard parameters required by CreateWindowEx()
      ex_style*: DWORD
      window_name*: string
      style*: DWORD
      x*, y*, width*, height*: int
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
      windowless_rendering_enabled*: bool

      # Set to true (1) to enable transparent painting in combination with
      # windowless rendering. When this value is true a transparent background
      # color will be used (RGBA=0x00000000). When this value is false the
      # background will be white and opaque.
      transparent_painting_enabled*: bool

      # Handle for the new browser window. Only used with windowed rendering.
      window*: cef_window_handle

  proc to_cef*(nc: NCWindowInfo): cef_window_info =
    result.ex_style = nc.ex_style
    result.window_name <= nc.window_name
    result.style = nc.style
    result.x = nc.x.cint
    result.y = nc.y.cint
    result.width = nc.width.cint
    result.height = nc.height.cint
    result.parent_window = nc.parent_window
    result.menu = nc.menu
    result.windowless_rendering_enabled = nc.windowless_rendering_enabled.cint
    result.transparent_painting_enabled = nc.transparent_painting_enabled.cint
    result.window = nc.window

  proc to_nim*(nc: ptr cef_window_info): NCWindowInfo =
    result.ex_style = nc.ex_style
    result.window_name = $(nc.window_name.addr)
    result.style = nc.style
    result.x = nc.x.int
    result.y = nc.y.int
    result.width = nc.width.int
    result.height = nc.height.int
    result.parent_window = nc.parent_window
    result.menu = nc.menu
    result.windowless_rendering_enabled = nc.windowless_rendering_enabled == 1.cint
    result.transparent_painting_enabled = nc.transparent_painting_enabled == 1.cint
    result.window = nc.window

  proc nc_free*(nc: var cef_window_info) =
    cef_string_clear(nc.window_name.addr)

elif defined(UNIX):
  type
    NCWindowInfo* = object
      x*: uint
      y*: uint
      width*: uint
      height*: uint

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
      windowless_rendering_enabled*: bool

      # Set to true (1) to enable transparent painting in combination with
      # windowless rendering. When this value is true a transparent background
      # color will be used (RGBA=0x00000000). When this value is false the
      # background will be white and opaque.
      transparent_painting_enabled*: bool

      #Pointer for the new browser window. Only used with windowed rendering.
      window*: cef_window_handle

elif defined(MACOSX):
  type
    NCWindowInfo* = object
      window_name*: string
      x*, y*, width*, height*: int

      # Set to true (1) to create the view initially hidden.
      hidden*: bool

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
      windowless_rendering_enabled*: bool

      # Set to true (1) to enable transparent painting in combination with
      # windowless rendering. When this value is true a transparent background
      # color will be used (RGBA=0x00000000). When this value is false the
      # background will be white and opaque.
      transparent_painting_enabled*: bool

      # NSView pointer for the new browser view. Only used with windowed rendering.
      view*: cef_window_handle

type
  # Structure representing a point.
  NCPoint* = object
    x*, y*: int

  # Structure representing a rectangle.
  NCRect* = object
    x*, y*, width*, height*: int

  # Structure representing a size.
  NCSize* = object
    width*, height*: int

  # Structure representing a print job page range.
  NCRange* = object
    start*: int
    to*: int

  # Structure representing insets.
  NCInsets* = object
    top*: int
    left*: int
    bottom*: int
    right*: int
    
  # Structure representing a draggable region.
  NCDraggableRegion* = object
    # Bounds of the region.
    bounds*: NCRect

    # True (1) this this region is draggable and false (0) otherwise.
    draggable*: bool

   # Structure representing keyboard event information.
  NCKeyEvent* = object
    # The type of keyboard event.
    key_event_type*: cef_key_event_type

    # Bit flags describing any pressed modifier keys. See
    # cef_event_flags_t for values.
    modifiers*: uint32

    # The Windows key code for the key event. This value is used by the DOM
    # specification. Sometimes it comes directly from the event (i.e. on
    # Windows) and sometimes it's determined using a mapping function. See
    # WebCore/platform/chromium/KeyboardCodes.h for the list of values.
    windows_key_code*: int

    # The actual key code genenerated by the platform.
    native_key_code*: int

    # Indicates whether the event is considered a "system key" event (see
    # http:#msdn.microsoft.com/en-us/library/ms646286(VS.85).aspx for details).
    # This value will always be false on non-Windows platforms.
    is_system_key*: bool

    # The character generated by the keystroke.
    character*: uint16

    # Same as |character| but unmodified by any concurrently-held modifiers
    # (except shift). This is useful for working out shortcut keys.
    unmodified_character*: uint16

    # True if the focus is currently on an editable field on the page. This is
    # useful for determining if standard key events should be intercepted.
    focus_on_editable_field*: bool

  # Structure representing cursor information. |buffer| will be
  # |size.width|*|size.height|*4 bytes in size and represents a BGRA image with
  # an upper-left origin.
  NCCursorInfo* = object
    hotspot*: NCPoint
    image_scale_factor*: float32
    buffer*: string
    size*: NCSize

  # Screen information used when window rendering is disabled. This structure is
  # passed as a parameter to CefRenderHandler::GetScreenInfo and should be filled
  # in by the client.
  NCScreenInfo* = object
    # Device scale factor. Specifies the ratio between physical and logical
    # pixels.
    device_scale_factor*: float32

    # The screen depth in bits per pixel.
    depth*: int

    # The bits per color component. This assumes that the colors are balanced
    # equally.
    depth_per_component*: int

    # This can be true for black and white printers.
    is_monochrome*: bool

    # This is set from the rcMonitor member of MONITORINFOEX, to whit:
    #   "A RECT structure that specifies the display monitor rectangle,
    #   expressed in virtual-screen coordinates. Note that if the monitor
    #   is not the primary display monitor, some of the rectangle's
    #   coordinates may be negative values."
    #
    # The |rect| and |available_rect| properties are used to determine the
    # available surface for rendering popup views.
    rect*: NCRect

    # This is set from the rcWork member of MONITORINFOEX, to whit:
    #   "A RECT structure that specifies the work area rectangle of the
    #   display monitor that can be used by applications, expressed in
    #   virtual-screen coordinates. Windows uses this rectangle to
    #   maximize an application on the monitor. The rest of the area in
    #   rcMonitor contains system windows such as the task bar and side
    #   bars. Note that if the monitor is not the primary display monitor,
    #   some of the rectangle's coordinates may be negative values".
    #
    # The |rect| and |available_rect| properties are used to determine the
    # available surface for rendering popup views.
    available_rect*: NCRect

  # Popup window features.
  NCPopupFeatures* = object
    x*: int
    xSet*: int
    y*: int
    ySet*: int
    width*: int
    widthSet*: int
    height*: int
    heightSet*: int
    menuBarVisible*: bool
    statusBarVisible*: bool
    toolBarVisible*: bool
    locationBarVisible*: bool
    scrollbarsVisible*: bool
    resizable*: bool
    fullscreen*: bool
    dialog*: bool
    additionalFeatures*: seq[string]

  # Structure representing mouse event information.
  NCMouseEvent* = object
    # X coordinate relative to the left side of the view.
    x*: int

    # Y coordinate relative to the top side of the view.
    y*: int

    # Bit flags describing any pressed modifier keys. See
    # cef_event_flags_t for values.
    modifiers*: uint32

proc to_cef*(nc: NCPoint): cef_point =
  result.x = nc.x.cint
  result.y = nc.y.cint

template nc_free*(nc: cef_point) = discard

proc to_nim*(nc: cef_point): NCPoint =
  result.x = nc.x.int
  result.y = nc.y.int

proc to_cef*(nc: NCRect): cef_rect =
  result = cef_rect(x: nc.x.cint, y: nc.y.cint,
    width: nc.width.cint, height: nc.height.cint)

proc to_nim*(nc: cef_rect): NCRect =
  result.x = nc.x.int
  result.y = nc.y.int
  result.width = nc.width.int
  result.height = nc.height.int

proc to_nim*(nc: ptr cef_rect): NCRect =
  result.x = nc.x.int
  result.y = nc.y.int
  result.width = nc.width.int
  result.height = nc.height.int

template nc_free*(nc: cef_rect) = discard

proc to_cef*(nc: NCSize): cef_size =
  result.width  = nc.width.cint
  result.height = nc.height.cint

proc to_nim*(nc: cef_size): NCSize =
  result.width  = nc.width.int
  result.height = nc.height.int

template nc_free*(nc: cef_size) = discard

proc to_cef*(nc: NCRange): cef_range =
  result.start  = nc.start.cint
  result.to = nc.to.cint

proc to_nim*(nc: cef_range): NCRange =
  result.start = nc.start.int
  result.to = nc.to.int

template nc_free*(nc: cef_range) = discard

proc to_cef*(nc: NCInsets): cef_insets =
  result.top = nc.top.cint
  result.left = nc.left.cint
  result.bottom = nc.bottom.cint
  result.right = nc.right.cint

proc to_nim*(nc: cef_insets): NCInsets =
  result.top = nc.top.int
  result.left = nc.left.int
  result.bottom = nc.bottom.int
  result.right = nc.right.int

template nc_free*(nc: cef_insets) = discard

proc to_cef*(nc: NCDraggableRegion): cef_draggable_region =
  result.bounds = to_cef(nc.bounds)
  result.draggable = nc.draggable.cint

template nc_free*(nc: cef_point) = discard

proc to_nim*(nc: ptr cef_draggable_region): NCDraggableRegion =
  result.bounds = to_nim(nc.bounds)
  result.draggable = nc.draggable == 1.cint

proc to_cef*(nc: NCKeyEvent): cef_key_event =
  result.key_event_type = nc.key_event_type
  result.modifiers = nc.modifiers
  result.windows_key_code = nc.windows_key_code.cint
  result.native_key_code = nc.native_key_code.cint
  result.is_system_key = nc.is_system_key.cint
  result.character = nc.character
  result.unmodified_character = nc.unmodified_character
  result.focus_on_editable_field = nc.focus_on_editable_field.cint

proc to_nim*(nc: ptr cef_key_event): NCKeyEvent =
  result.key_event_type = nc.key_event_type
  result.modifiers = nc.modifiers
  result.windows_key_code = nc.windows_key_code.int
  result.native_key_code = nc.native_key_code.int
  result.is_system_key = nc.is_system_key == 1.cint
  result.character = nc.character
  result.unmodified_character = nc.unmodified_character
  result.focus_on_editable_field = nc.focus_on_editable_field == 1.cint

template nc_free*(nc: cef_key_event) = discard

proc to_nim*(nc: ptr cef_cursor_info): NCCursorInfo =
  result.hotspot = to_nim(nc.hotspot)
  result.image_scale_factor = nc.image_scale_factor.float32
  result.size = to_nim(nc.size)
  result.buffer = newString(result.size.height * result.size.width * 4)
  copyMem(result.buffer.cstring, nc.buffer, result.buffer.len)

proc to_nim*(nc: ptr cef_screen_info): NCScreenInfo =
  result.device_scale_factor = nc.device_scale_factor.float32
  result.depth = nc.depth.int
  result.depth_per_component = nc.depth_per_component.int
  result.is_monochrome = nc.is_monochrome == 1.cint
  result.rect = to_nim(nc.rect)
  result.available_rect = to_nim(nc.available_rect)

# Popup window features.
proc to_nim*(nc: ptr cef_popup_features): NCPopupFeatures =
  result.x = nc.x.int
  result.xSet = nc.xSet.int
  result.y = nc.y.int
  result.ySet = nc.ySet.int
  result.width = nc.width.int
  result.widthSet = nc.widthSet.int
  result.height = nc.height.int
  result.heightSet = nc.heightSet.int
  result.menuBarVisible = nc.menuBarVisible == 1.cint
  result.statusBarVisible = nc.statusBarVisible == 1.cint
  result.toolBarVisible = nc.toolBarVisible == 1.cint
  result.locationBarVisible = nc.locationBarVisible == 1.cint
  result.scrollbarsVisible = nc.scrollbarsVisible == 1.cint
  result.resizable = nc.resizable == 1.cint
  result.fullscreen = nc.fullscreen == 1.cint
  result.dialog = nc.dialog == 1.cint
  result.additionalFeatures = to_nim(nc.additionalFeatures)

proc to_cef*(nc: NCMouseEvent): cef_mouse_event =
  result.x = nc.x.cint
  result.y = nc.y.cint
  result.modifiers = nc.modifiers

template nc_free*(nc: cef_mouse_event) = discard