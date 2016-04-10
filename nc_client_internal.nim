import nc_util

include cef/cef_import

template client_to_client(client: expr): expr =
  cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))

proc get_context_menu_handler(self: ptr cef_client): ptr cef_context_menu_handler {.cef_callback.} =
  result = client_to_client(self).context_menu_handler

proc get_dialog_handler(self: ptr cef_client): ptr cef_dialog_handler {.cef_callback.} =
  result = nil

proc get_display_handler(self: ptr cef_client): ptr cef_display_handler {.cef_callback.} =
  result = nil

proc get_download_handler(self: ptr cef_client): ptr cef_download_handler {.cef_callback.} =
  result = nil

proc get_drag_handler(self: ptr cef_client): ptr cef_drag_handler {.cef_callback.} =
  result = nil

proc get_focus_handler(self: ptr cef_client): ptr cef_focus_handler {.cef_callback.} =
  result = nil

proc get_geolocation_handler(self: ptr cef_client): ptr cef_geolocation_handler {.cef_callback.} =
  result = nil

proc get_jsdialog_handler(self: ptr cef_client): ptr cef_jsdialog_handler {.cef_callback.} =
  result = nil

proc get_keyboard_handler(self: ptr cef_client): ptr cef_keyboard_handler {.cef_callback.} =
  result = nil

proc get_life_span_handler(self: ptr cef_client): ptr cef_life_span_handler {.cef_callback.} =
  result = client_to_client(self).life_span_handler

proc get_load_handler(self: ptr cef_client): ptr cef_load_handler {.cef_callback.} =
  result = nil

proc get_render_handler(self: ptr cef_client): ptr cef_render_handler {.cef_callback.} =
  result = nil

proc get_request_handler(self: ptr cef_client): ptr cef_request_handler {.cef_callback.} =
  result = nil

proc on_process_message_received(self: ptr cef_client,
  browser: ptr_cef_browser, source_process: cef_process_id,
  message: ptr cef_process_message): cint {.cef_callback.} =
  var brow = b_to_b(browser)
  result = client_to_client(self).OnProcessMessageReceived(brow, source_process, message).cint
  release(brow)
  release(message)
    
proc initialize_client_handler*(client: ptr cef_client) =
  init_base(client) 
  client.get_context_menu_handler = get_context_menu_handler
  client.get_dialog_handler = get_dialog_handler
  client.get_display_handler = get_display_handler
  client.get_download_handler = get_download_handler
  client.get_drag_handler = get_drag_handler
  client.get_focus_handler = get_focus_handler
  client.get_geolocation_handler = get_geolocation_handler
  client.get_jsdialog_handler = get_jsdialog_handler
  client.get_keyboard_handler = get_keyboard_handler
  client.get_life_span_handler = get_life_span_handler
  client.get_load_handler = get_load_handler
  client.get_render_handler = get_render_handler
  client.get_request_handler = get_request_handler
  client.on_process_message_received = on_process_message_received