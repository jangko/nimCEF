import cef_base_api
include cef_import

type
  # Callback structure used for asynchronous continuation of geolocation
  # permission requests.
  cef_geolocation_callback* = object
    base*: cef_base
    
    # Call to allow or deny geolocation access.
    cont*: proc(self: ptr cef_geolocation_callback, allow: cint): cint {.cef_callback.}

  # Implement this structure to handle events related to geolocation permission
  # requests. The functions of this structure will be called on the browser
  # process UI thread.
  cef_geolocation_handler* = object
    base*: cef_base
  
    # Called when a page requests permission to access geolocation information.
    # |requesting_url| is the URL requesting permission and |request_id| is the
    # unique ID for the permission request. Return true (1) and call
    # cef_geolocation_callback_t::cont() either in this function or at a later
    # time to continue or cancel the request. Return false (0) to cancel the
    # request immediately.
    on_request_geolocation_permission*: proc(self: ptr cef_geolocation_handler, 
      browser: ptr_cef_browser, requesting_url: ptr cef_string, request_id: cint,
      callback: ptr cef_geolocation_callback): cint {.cef_callback.}

    # Called when a geolocation access request is canceled. |request_id| is the
    # unique ID for the permission request.
  
    on_cancel_geolocation_permission*: proc(self: ptr cef_geolocation_handler, 
      browser: ptr_cef_browser, request_id: cint) {.cef_callback.}
      