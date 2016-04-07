import cef_base_api, cef_request_api, cef_life_span_handler_api, cef_drag_handler_api, cef_find_handler_api
import cef_geolocation_handler_api, cef_keyboard_handler_api, cef_process_message_api
import cef_jsdialog_handler_api, cef_context_menu_handler_api, cef_dialog_handler_api
import cef_display_handler_api, cef_download_handler_api, cef_load_handler_api, cef_render_handler_api
import cef_focus_handler_api, cef_request_handler_api

export cef_request_api, cef_life_span_handler_api, cef_drag_handler_api, cef_find_handler_api
export cef_geolocation_handler_api, cef_keyboard_handler_api, cef_process_message_api
export cef_jsdialog_handler_api, cef_context_menu_handler_api, cef_dialog_handler_api
export cef_display_handler_api, cef_download_handler_api, cef_load_handler_api, cef_render_handler_api
export cef_focus_handler_api, cef_request_handler_api

include cef_import

type
  # Implement this structure to provide handler implementations.
  cef_client* = object
    base*: cef_base
    
    # Return the handler for context menus. If no handler is provided the default
    # implementation will be used.
    get_context_menu_handler*: proc(self: ptr cef_client): ptr cef_context_menu_handler {.cef_callback.}

    # Return the handler for dialogs. If no handler is provided the default
    # implementation will be used.
    get_dialog_handler*: proc(self: ptr cef_client): ptr cef_dialog_handler {.cef_callback.}
  
    # Return the handler for browser display state events.
    get_display_handler*: proc(self: ptr cef_client): ptr cef_display_handler {.cef_callback.}

    # Return the handler for download events. If no handler is returned downloads
    # will not be allowed.
    get_download_handler*: proc(self: ptr cef_client): ptr cef_download_handler {.cef_callback.}
  
    # Return the handler for drag events.
    get_drag_handler*: proc(self: ptr cef_client): ptr cef_drag_handler {.cef_callback.}
  
    # Return the handler for find result events.
    get_find_handler*: proc(self: ptr cef_client): ptr cef_find_handler {.cef_callback.}

    # Return the handler for focus events.
    get_focus_handler*: proc(self: ptr cef_client): ptr cef_focus_handler {.cef_callback.}

    # Return the handler for geolocation permissions requests. If no handler is
    # provided geolocation access will be denied by default.
    get_geolocation_handler*: proc(self: ptr cef_client): ptr cef_geolocation_handler {.cef_callback.}
  
    # Return the handler for JavaScript dialogs. If no handler is provided the
    # default implementation will be used.
    get_jsdialog_handler*: proc(self: ptr cef_client): ptr cef_jsdialog_handler {.cef_callback.}
  
    # Return the handler for keyboard events.
    get_keyboard_handler*: proc(self: ptr cef_client): ptr cef_keyboard_handler {.cef_callback.}
  
    # Return the handler for browser life span events.
    get_life_span_handler*: proc(self: ptr cef_client): ptr cef_life_span_handler {.cef_callback.}

    # Return the handler for browser load status events.
    get_load_handler*: proc(self: ptr cef_client): ptr cef_load_handler {.cef_callback.}
  
    # Return the handler for off-screen rendering events.
    get_render_handler*: proc(self: ptr cef_client): ptr cef_render_handler {.cef_callback.}

    # Return the handler for browser request events.
    get_request_handler*: proc(self: ptr cef_client): ptr cef_request_handler {.cef_callback.}

    # Called when a new message is received from a different process. Return true
    # (1) if the message was handled or false (0) otherwise. Do not keep a
    # reference to or attempt to access the message outside of this callback.
    on_process_message_received*: proc(self: ptr cef_client,
      browser: ptr_cef_browser, source_process: cef_process_id,
      message: ptr cef_process_message): cint {.cef_callback.}

