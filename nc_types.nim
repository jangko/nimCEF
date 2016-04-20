import cef/cef_base_api, cef/cef_browser_api, cef/cef_client_api, cef/cef_frame_api
import cef/cef_string_api, cef/cef_string_list_api

export cef_base_api, cef_string_api, cef_string_list_api

type
  # Implement this structure to provide handler implementations.
  NCClient* = ref object of RootObj
    client_handler*: cef_client
    life_span_handler*: ptr cef_life_span_handler
    context_menu_handler*: ptr cef_context_menu_handler
    drag_handler*: ptr cef_drag_handler
    display_handler*: ptr cef_display_handler
    focus_handler*: ptr cef_focus_handler
    keyboard_handler*: ptr cef_keyboard_handler
    load_handler*: ptr cef_load_handler
    render_handler*: ptr cef_render_handler
    dialog_handler*: ptr cef_dialog_handler
    download_handler*: ptr cef_download_handler
    geolocation_handler*: ptr cef_geolocation_handler
    jsdialog_handler*: ptr cef_jsdialog_handler
    request_handler*: ptr cef_request_handler

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

  # Structure used to represent a frame in the browser window. When used in the
  # browser process the functions of this structure may be called on any thread
  # unless otherwise indicated in the comments. When used in the render process
  # the functions of this structure may only be called on the main thread.
  NCFrame* = ptr cef_frame

  # Structure used to represent a browser window. When used in the browser
  # process the functions of this structure may be called on any thread unless
  # otherwise indicated in the comments. When used in the render process the
  # functions of this structure may only be called on the main thread.
  NCBrowser* = ptr cef_browser

  # Structure used to represent the browser process aspects of a browser window.
  # The functions of this structure can only be called in the browser process.
  # They may be called on any thread in that process unless otherwise indicated
  # in the comments.
  NCBrowserHost* = ptr cef_browser_host


#these procs below are for internal uses
proc get_client*(browser: ptr_cef_browser): NCClient =
  var brow = cast[ptr cef_browser](browser)
  var host = brow.get_host(brow)
  var client = host.get_client(host)
  result = cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))

template app_to_app*(app: expr): expr =
  cast[NCApp](cast[ByteAddress](app) - sizeof(pointer))

template client_to_client*(client: expr): expr =
  cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))

template to_cclient*(client: expr): expr =
  client.client_handler.addr
  
template type_to_type*(ctype: typedesc, obj: expr): expr =
  cast[ctype](cast[ByteAddress](obj) - sizeof(pointer))