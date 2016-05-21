import cef/cef_base_api, cef/cef_browser_api, cef/cef_client_api, cef/cef_frame_api
import cef/cef_string_api, cef/cef_string_list_api, cef/cef_types
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

type
  #choose what kind of handler you want to exposed to your app
  NCClientCreateFlag* = enum
    NCCF_CONTEXT_MENU
    NCCF_LIFE_SPAN
    NCCF_DRAG
    NCCF_DISPLAY
    NCCF_FOCUS
    NCCF_KEYBOARD
    NCCF_LOAD
    NCCF_RENDER
    NCCF_DIALOG
    NCCF_DOWNLOAD
    NCCF_GEOLOCATION
    NCCF_JSDIALOG
    NCCF_REQUEST

  NCCFS* = set[NCClientCreateFlag]

template app_to_app*(app: expr): expr =
  cast[NCApp](cast[ByteAddress](app) - sizeof(pointer))

template type_to_type*(ctype: typedesc, obj: expr): expr =
  cast[ctype](cast[ByteAddress](obj) - sizeof(pointer))

template nc_wrap*(x: ptr_cef_browser): expr = nc_wrap(cast[ptr cef_browser](x))
template nc_wrap*(x: ptr_cef_frame): expr = nc_wrap(cast[ptr cef_frame](x))
template release*(x: ptr_cef_browser): expr = release(cast[ptr cef_browser](x))

type
  NCMainArgs* = ref object
    handler: cef_main_args

proc GetHandler*(arg: NCMainArgs): ptr cef_main_args {.inline.} =
  result = arg.handler.addr

when defined(windows):
  import winapi

  proc makeNCMainArgs*(): NCMainArgs =
    new(result)
    result.handler.instance = getModuleHandle(nil)

else:
  import os

  var nim_params: seq[string]
  var c_params: seq[cstring]

  proc makeNCMainArgs*(): NCMainArgs =
    new(result)
    let count = paramCount()
    result.handler.argc = count
    nim_params = newSeq[string](count)
    c_params = newSeq[cstring](count+1)
    for i in 0.. <count:
      nim_params[i] = paramStr(i)
      c_params[i] = nim_params[i][0].addr
    c_params[count] = nil
    result.handler.argv = cparams[0].addr

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
  NCPageRange* = object
    page_from*: int
    page_to*: int
    
proc to_cef*(nc: NCPoint): cef_point =
  result.x = nc.x.cint
  result.y = nc.x.cint

template nc_free*(nc: cef_point) = discard

proc to_cef*(nc: NCRect): cef_rect =
  result = cef_rect(x: nc.x.cint, y: nc.y.cint, 
    width: nc.width.cint, height: nc.height.cint)
  
template nc_free*(nc: cef_rect) = discard

proc to_cef*(nc: NCSize): cef_size =
  result.width  = nc.width.cint
  result.height = nc.height.cint

template nc_free*(nc: cef_size) = discard

proc to_cef*(nc: NCPageRange): cef_page_range =
  result.page_from  = nc.page_from.cint
  result.page_to = nc.page_to.cint

proc to_nim*(nc: cef_page_range): NCPageRange =
  result.page_from  = nc.page_from.int
  result.page_to = nc.page_to.int

template nc_free*(nc: cef_page_range) = discard
