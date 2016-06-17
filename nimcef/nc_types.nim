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

template ncWrap*(x: ptr_cef_client): expr = ncWrap(cast[ptr cef_client](x))
template ncWrap*(x: ptr_cef_browser): expr = ncWrap(cast[ptr cef_browser](x))
template ncWrap*(x: ptr_cef_frame): expr = ncWrap(cast[ptr cef_frame](x))
template ncRelease*(x: ptr_cef_browser): expr = ncRelease(cast[ptr cef_browser](x))
template ncRelease*(x: ptr_cef_client): expr = ncRelease(cast[ptr cef_client](x))
template ncRelease*(x: ptr_cef_frame): expr = ncRelease(cast[ptr cef_frame](x))

template USER_MENU_ID*(n: int): expr = (MENU_ID_USER_FIRST.ord + n).cef_menu_id

type
  NCMainArgs* = object
    args: cef_main_args

proc toCef*(nc: NCMainArgs): cef_main_args =
  result = nc.args

proc ncFree*(nc: cef_main_args) = discard

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
      exStyle*: DWORD
      windowName*: string
      style*: DWORD
      x*, y*, width*, height*: int
      parentWindow*: cef_window_handle
      menu*: HMENU

      # Set to true (1) to create the browser using windowless (off-screen)
      # rendering. No window will be created for the browser and all rendering will
      # occur via the CefRenderHandler interface. The |parent_window| value will be
      # used to identify monitor info and to act as the parent window for dialogs,
      # context menus, etc. If |parent_window| is not provided then the main screen
      # monitor will be used and some functionality that requires a parent window
      # may not function correctly. In order to create windowless browsers the
      # CefSettings.windowless_rendering_enabled value must be set to true.
      windowlessRenderingEnabled*: bool

      # Set to true (1) to enable transparent painting in combination with
      # windowless rendering. When this value is true a transparent background
      # color will be used (RGBA=0x00000000). When this value is false the
      # background will be white and opaque.
      transparentPaintingEnabled*: bool

      # Handle for the new browser window. Only used with windowed rendering.
      window*: cef_window_handle

  proc toCef*(nc: NCWindowInfo): cef_window_info =
    result.ex_style = nc.exStyle
    result.window_name <= nc.windowName
    result.style = nc.style
    result.x = nc.x.cint
    result.y = nc.y.cint
    result.width = nc.width.cint
    result.height = nc.height.cint
    result.parent_window = nc.parentWindow
    result.menu = nc.menu
    result.windowless_rendering_enabled = nc.windowlessRenderingEnabled.cint
    result.transparent_painting_enabled = nc.transparentPaintingEnabled.cint
    result.window = nc.window

  proc toNim*(nc: ptr cef_window_info): NCWindowInfo =
    result.exStyle = nc.ex_style
    result.windowName = $(nc.window_name.addr)
    result.style = nc.style
    result.x = nc.x.int
    result.y = nc.y.int
    result.width = nc.width.int
    result.height = nc.height.int
    result.parentWindow = nc.parent_window
    result.menu = nc.menu
    result.windowlessRenderingEnabled = nc.windowless_rendering_enabled == 1.cint
    result.transparentPaintingEnabled = nc.transparent_painting_enabled == 1.cint
    result.window = nc.window

  proc ncFree*(nc: var cef_window_info) =
    cef_string_clear(nc.window_name.addr)

elif defined(UNIX):
  type
    NCWindowInfo* = object
      x*: uint
      y*: uint
      width*: uint
      height*: uint

      # Pointer for the parent window.
      parentWindow*: cef_window_handle

      # Set to true (1) to create the browser using windowless (off-screen)
      # rendering. No window will be created for the browser and all rendering will
      # occur via the CefRenderHandler interface. The |parent_window| value will be
      # used to identify monitor info and to act as the parent window for dialogs,
      # context menus, etc. If |parent_window| is not provided then the main screen
      # monitor will be used and some functionality that requires a parent window
      # may not function correctly. In order to create windowless browsers the
      # CefSettings.windowless_rendering_enabled value must be set to true.
      windowlessRenderingEnabled*: bool

      # Set to true (1) to enable transparent painting in combination with
      # windowless rendering. When this value is true a transparent background
      # color will be used (RGBA=0x00000000). When this value is false the
      # background will be white and opaque.
      transparentPaintingEnabled*: bool

      #Pointer for the new browser window. Only used with windowed rendering.
      window*: cef_window_handle

elif defined(MACOSX):
  type
    NCWindowInfo* = object
      windowName*: string
      x*, y*, width*, height*: int

      # Set to true (1) to create the view initially hidden.
      hidden*: bool

      # NSView pointer for the parent view.
      parentView*: cef_window_handle

      # Set to true (1) to create the browser using windowless (off-screen)
      # rendering. No view will be created for the browser and all rendering will
      # occur via the CefRenderHandler interface. The |parent_view| value will be
      # used to identify monitor info and to act as the parent view for dialogs,
      # context menus, etc. If |parent_view| is not provided then the main screen
      # monitor will be used and some functionality that requires a parent view
      # may not function correctly. In order to create windowless browsers the
      # CefSettings.windowless_rendering_enabled value must be set to true.
      windowlessRenderingEnabled*: bool

      # Set to true (1) to enable transparent painting in combination with
      # windowless rendering. When this value is true a transparent background
      # color will be used (RGBA=0x00000000). When this value is false the
      # background will be white and opaque.
      transparentPaintingEnabled*: bool

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
    keyEventType*: cef_key_event_type

    # Bit flags describing any pressed modifier keys. See
    # cef_event_flags_t for values.
    modifiers*: uint32

    # The Windows key code for the key event. This value is used by the DOM
    # specification. Sometimes it comes directly from the event (i.e. on
    # Windows) and sometimes it's determined using a mapping function. See
    # WebCore/platform/chromium/KeyboardCodes.h for the list of values.
    windowsKeyCode*: int

    # The actual key code genenerated by the platform.
    nativeKeyCode*: int

    # Indicates whether the event is considered a "system key" event (see
    # http:#msdn.microsoft.com/en-us/library/ms646286(VS.85).aspx for details).
    # This value will always be false on non-Windows platforms.
    isSystemKey*: bool

    # The character generated by the keystroke.
    character*: uint16

    # Same as |character| but unmodified by any concurrently-held modifiers
    # (except shift). This is useful for working out shortcut keys.
    unmodifiedCharacter*: uint16

    # True if the focus is currently on an editable field on the page. This is
    # useful for determining if standard key events should be intercepted.
    focusOnEditableField*: bool

  # Structure representing cursor information. |buffer| will be
  # |size.width|*|size.height|*4 bytes in size and represents a BGRA image with
  # an upper-left origin.
  NCCursorInfo* = object
    hotspot*: NCPoint
    imageScaleFactor*: float32
    buffer*: string
    size*: NCSize

  # Screen information used when window rendering is disabled. This structure is
  # passed as a parameter to CefRenderHandler::GetScreenInfo and should be filled
  # in by the client.
  NCScreenInfo* = object
    # Device scale factor. Specifies the ratio between physical and logical
    # pixels.
    deviceScaleFactor*: float32

    # The screen depth in bits per pixel.
    depth*: int

    # The bits per color component. This assumes that the colors are balanced
    # equally.
    depthPerComponent*: int

    # This can be true for black and white printers.
    isMonochrome*: bool

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
    availableRect*: NCRect

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

proc toCef*(nc: NCPoint): cef_point =
  result.x = nc.x.cint
  result.y = nc.y.cint

template ncFree*(nc: cef_point) = discard

proc toNim*(nc: cef_point): NCPoint =
  result.x = nc.x.int
  result.y = nc.y.int

proc toCef*(nc: NCRect): cef_rect =
  result = cef_rect(x: nc.x.cint, y: nc.y.cint,
    width: nc.width.cint, height: nc.height.cint)

proc toNim*(nc: cef_rect): NCRect =
  result.x = nc.x.int
  result.y = nc.y.int
  result.width = nc.width.int
  result.height = nc.height.int

proc toNim*(nc: ptr cef_rect): NCRect =
  result.x = nc.x.int
  result.y = nc.y.int
  result.width = nc.width.int
  result.height = nc.height.int

template ncFree*(nc: cef_rect) = discard

proc toCef*(nc: NCSize): cef_size =
  result.width  = nc.width.cint
  result.height = nc.height.cint

proc toNim*(nc: cef_size): NCSize =
  result.width  = nc.width.int
  result.height = nc.height.int

template ncFree*(nc: cef_size) = discard

proc toCef*(nc: NCRange): cef_range =
  result.start  = nc.start.cint
  result.to = nc.to.cint

proc toNim*(nc: cef_range): NCRange =
  result.start = nc.start.int
  result.to = nc.to.int

template ncFree*(nc: cef_range) = discard

proc toCef*(nc: NCInsets): cef_insets =
  result.top = nc.top.cint
  result.left = nc.left.cint
  result.bottom = nc.bottom.cint
  result.right = nc.right.cint

proc toNim*(nc: cef_insets): NCInsets =
  result.top = nc.top.int
  result.left = nc.left.int
  result.bottom = nc.bottom.int
  result.right = nc.right.int

template ncFree*(nc: cef_insets) = discard

proc toCef*(nc: NCDraggableRegion): cef_draggable_region =
  result.bounds = toCef(nc.bounds)
  result.draggable = nc.draggable.cint

template ncFree*(nc: cef_point) = discard

proc toNim*(nc: ptr cef_draggable_region): NCDraggableRegion =
  result.bounds = toNim(nc.bounds)
  result.draggable = nc.draggable == 1.cint

proc toCef*(nc: NCKeyEvent): cef_key_event =
  result.key_event_type = nc.keyEventType
  result.modifiers = nc.modifiers
  result.windows_key_code = nc.windowsKeyCode.cint
  result.native_key_code = nc.nativeKeyCode.cint
  result.is_system_key = nc.isSystemKey.cint
  result.character = nc.character
  result.unmodified_character = nc.unmodifiedCharacter
  result.focus_on_editable_field = nc.focusOnEditableField.cint

proc toNim*(nc: ptr cef_key_event): NCKeyEvent =
  result.keyEventType = nc.key_event_type
  result.modifiers = nc.modifiers
  result.windowsKeyCode = nc.windows_key_code.int
  result.nativeKeyCode = nc.native_key_code.int
  result.isSystemKey = nc.is_system_key == 1.cint
  result.character = nc.character
  result.unmodifiedCharacter = nc.unmodified_character
  result.focusOnEditableField = nc.focus_on_editable_field == 1.cint

template ncFree*(nc: cef_key_event) = discard

proc toNim*(nc: ptr cef_cursor_info): NCCursorInfo =
  result.hotspot = toNim(nc.hotspot)
  result.imageScaleFactor = nc.image_scale_factor.float32
  result.size = toNim(nc.size)
  result.buffer = newString(result.size.height * result.size.width * 4)
  copyMem(result.buffer.cstring, nc.buffer, result.buffer.len)

proc toNim*(nc: ptr cef_screen_info): NCScreenInfo =
  result.deviceScaleFactor = nc.device_scale_factor.float32
  result.depth = nc.depth.int
  result.depthPerComponent = nc.depth_per_component.int
  result.isMonochrome = nc.is_monochrome == 1.cint
  result.rect = toNim(nc.rect)
  result.availableRect = toNim(nc.available_rect)

# Popup window features.
proc toNim*(nc: ptr cef_popup_features): NCPopupFeatures =
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
  result.additionalFeatures = toNim(nc.additionalFeatures)

proc toCef*(nc: NCMouseEvent): cef_mouse_event =
  result.x = nc.x.cint
  result.y = nc.y.cint
  result.modifiers = nc.modifiers

template ncFree*(nc: cef_mouse_event) = discard