import nc_util

include cef/cef_import

template client_to_client(client: expr): expr =
  cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))

proc get_context_menu_handler(self: ptr cef_client): ptr cef_context_menu_handler {.cef_callback.} =
  result = client_to_client(self).context_menu_handler

proc get_dialog_handler(self: ptr cef_client): ptr cef_dialog_handler {.cef_callback.} =
  result = nil

proc get_display_handler(self: ptr cef_client): ptr cef_display_handler {.cef_callback.} =
  result = client_to_client(self).display_handler

proc get_download_handler(self: ptr cef_client): ptr cef_download_handler {.cef_callback.} =
  result = nil

proc get_drag_handler(self: ptr cef_client): ptr cef_drag_handler {.cef_callback.} =
  result = client_to_client(self).drag_handler

proc get_focus_handler(self: ptr cef_client): ptr cef_focus_handler {.cef_callback.} =
  result = client_to_client(self).focus_handler

proc get_geolocation_handler(self: ptr cef_client): ptr cef_geolocation_handler {.cef_callback.} =
  result = nil

proc get_jsdialog_handler(self: ptr cef_client): ptr cef_jsdialog_handler {.cef_callback.} =
  result = nil

proc get_keyboard_handler(self: ptr cef_client): ptr cef_keyboard_handler {.cef_callback.} =
  result = client_to_client(self).keyboard_handler

proc get_life_span_handler(self: ptr cef_client): ptr cef_life_span_handler {.cef_callback.} =
  result = client_to_client(self).life_span_handler

proc get_load_handler(self: ptr cef_client): ptr cef_load_handler {.cef_callback.} =
  result = client_to_client(self).load_handler

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
 

proc on_drag_enter(self: ptr cef_drag_handler, browser: ptr_cef_browser, dragData: ptr cef_drag_data,
  mask: cef_drag_operations_mask): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.OnDragEnter(brow, dragData, mask).cint
  release(brow)

proc on_draggable_regions_changed(self: ptr cef_drag_handler, browser: ptr_cef_browser,
  regionsCount: csize, regions: ptr cef_draggable_region) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnDraggableRegionsChanged(brow, regionsCount.int, regions)
  release(brow)
    
proc initialize_drag_handler*(drag: ptr cef_drag_handler) =
  drag.on_drag_enter = on_drag_enter
  drag.on_draggable_regions_changed = on_draggable_regions_changed
  
  
proc on_address_change(self: ptr cef_display_handler, browser: ptr_cef_browser, frame: ptr cef_frame, url: ptr cef_string) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnAddressChange(brow, frame, $url)
  release(brow)
  release(frame)

proc on_title_change(self: ptr cef_display_handler, browser: ptr_cef_browser, title: ptr cef_string) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnTitleChange(brow, $title)
  release(brow)

proc on_favicon_urlchange(self: ptr cef_display_handler, browser: ptr_cef_browser, icon_urls: cef_string_list) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnFaviconUrlChange(brow, $(icon_urls))
  release(brow)
  
proc on_fullscreen_mode_change(self: ptr cef_display_handler, browser: ptr_cef_browser, fullscreen: cint) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnFullscreenModeChange(brow, fullscreen == 1.cint)
  release(brow)

proc on_tooltip(self: ptr cef_display_handler, browser: ptr_cef_browser, text: ptr cef_string): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  var tip = $text
  result = client.OnTooltip(brow, tip).cint
  cef_string_clear(text)
  let ctext = to_cef_string(tip)
  discard cef_string_copy(ctext.str, ctext.length, text)
  cef_string_userfree_free(ctext)
  release(brow)

proc on_status_message(self: ptr cef_display_handler, browser: ptr_cef_browser, value: ptr cef_string) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnStatusMessage(brow, $value)
  release(brow)
  
proc on_console_message(self: ptr cef_display_handler, browser: ptr_cef_browser, message, source: ptr cef_string, line: cint): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.OnConsoleMessage(brow, $message, $source, line.int).cint
  release(brow)
  
proc initialize_display_handler*(disp: ptr cef_display_handler) =
  disp.on_address_change = on_address_change
  disp.on_title_change = on_title_change
  disp.on_favicon_urlchange = on_favicon_urlchange
  disp.on_fullscreen_mode_change = on_fullscreen_mode_change
  disp.on_tooltip = on_tooltip
  disp.on_status_message = on_status_message
  disp.on_console_message = on_console_message

proc on_take_focus(self: ptr cef_focus_handler, browser: ptr_cef_browser, next: cint) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnTakeFocus(brow, next == 1.cint)
  release(brow)
  
proc on_set_focus(self: ptr cef_focus_handler, browser: ptr_cef_browser, source: cef_focus_source): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.OnSetFocus(brow, source).cint
  release(brow)
  
proc on_got_focus(self: ptr cef_focus_handler, browser: ptr_cef_browser) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnGotFocus(brow)
  release(brow)
  
proc initialize_focus_handler*(focus: ptr cef_focus_handler) =
  focus.on_take_focus = on_take_focus
  focus.on_set_focus = on_set_focus
  focus.on_got_focus = on_got_focus
    
proc on_pre_key_event(self: ptr cef_keyboard_handler,
  browser: ptr_cef_browser, event: ptr cef_key_event,
  os_event: cef_event_handle, is_keyboard_shortcut: var cint): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  var iks = is_keyboard_shortcut.int
  result = client.OnPreKeyEvent(brow, event, os_event, iks).cint
  is_keyboard_shortcut = iks.cint
  release(brow)
  
proc on_key_event(self: ptr cef_keyboard_handler,
  browser: ptr_cef_browser, event: ptr cef_key_event,
  os_event: cef_event_handle): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.OnKeyEvent(brow, event, os_event).cint
  release(brow)
  
proc initialize_keyboard_handler*(keyboard: ptr cef_keyboard_handler) =
  keyboard.on_pre_key_event = on_pre_key_event
  keyboard.on_key_event = on_key_event
  
proc on_loading_state_change(self: ptr cef_load_handler,
  browser: ptr_cef_browser, isLoading, canGoBack, canGoForward: cint) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnLoadingStateChange(brow, isLoading == 1.cint, canGoBack == 1.cint, canGoForward == 1.cint)
  release(brow)
  
proc on_load_start(self: ptr cef_load_handler,
  browser: ptr_cef_browser, frame: ptr cef_frame) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnLoadStart(brow, frame)
  release(brow)
  release(frame)
  
proc on_load_end(self: ptr cef_load_handler,
  browser: ptr_cef_browser, frame: ptr cef_frame,
  httpStatusCode: cint) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnLoadEnd(brow, frame, httpStatusCode.int)
  release(brow)
  release(frame)
  
proc on_load_error(self: ptr cef_load_handler,
  browser: ptr_cef_browser, frame: ptr cef_frame,
  errorCode: cef_errorcode, errorText, failedUrl: ptr cef_string) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnLoadError(brow, frame, errorCode, $errorText, $failedUrl)
  release(brow)  
  release(frame)
  
proc initialize_load_handler*(load: ptr cef_load_handler) =
  load.on_loading_state_change = on_loading_state_change
  load.on_load_start = on_load_start
  load.on_load_end = on_load_end
  load.on_load_error = on_load_error