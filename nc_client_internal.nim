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
  result = client_to_client(self).render_handler

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
  init_base(drag)
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
  init_base(disp)
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
  init_base(focus)
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
  init_base(keyboard)
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
  init_base(load)
  load.on_loading_state_change = on_loading_state_change
  load.on_load_start = on_load_start
  load.on_load_end = on_load_end
  load.on_load_error = on_load_error
  
proc get_root_screen_rect(self: ptr cef_render_handler, browser: ptr_cef_browser, rect: ptr cef_rect): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.GetRootScreenRect(brow, rect).cint
  release(brow)
  
proc get_view_rect(self: ptr cef_render_handler, browser: ptr_cef_browser, rect: ptr cef_rect): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.GetViewRect(brow, rect).cint
  release(brow)

proc get_screen_point(self: ptr cef_render_handler,
  browser: ptr_cef_browser, viewX, viewY: cint, screenX, screenY: var cint): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  var scX = screenX.int
  var scY = screenY.int
  result = client.GetScreenPoint(brow, viewX.int, viewY.int, scX, scY).cint
  screenX = scX.cint
  screenY = scY.cint
  release(brow)
  
proc get_screen_info(self: ptr cef_render_handler, browser: ptr_cef_browser, screen_info: ptr cef_screen_info): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.GetScreenInfo(brow, screen_info).cint
  release(brow)
  
proc on_popup_show(self: ptr cef_render_handler, browser: ptr_cef_browser, show: cint) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnPopupShow(brow, show == 1.cint)
  release(brow)

proc on_popup_size(self: ptr cef_render_handler, browser: ptr_cef_browser, rect: ptr cef_rect) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnPopupSize(brow, rect)
  release(brow)
  
proc on_paint(self: ptr cef_render_handler, browser: ptr_cef_browser, ptype: cef_paint_element_type,
  dirtyRectsCount: csize, dirtyRects: ptr cef_rect, buffer: pointer, width, height: cint) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnPaint(brow, ptype, dirtyRectsCount.int, dirtyRects, buffer, width.int, height.int)
  release(brow)
  
proc on_cursor_change(self: ptr cef_render_handler,
  browser: ptr_cef_browser, cursor: cef_cursor_handle,
  ptype: cef_cursor_type, custom_cursor_info: ptr cef_cursor_info) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnCursorChange(brow, cursor, ptype, custom_cursor_info)
  release(brow)
  
proc start_dragging(self: ptr cef_render_handler,
  browser: ptr_cef_browser, drag_data: ptr cef_drag_data,
  allowed_ops: cef_drag_operations_mask, x, y: cint): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.StartDragging(brow, drag_data, allowed_ops, x.int, y.int).cint
  release(brow)
  
proc update_drag_cursor(self: ptr cef_render_handler,
  browser: ptr_cef_browser, operation: cef_drag_operations_mask) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.UpdateDragCursor(brow, operation)
  release(brow)
  
proc on_scroll_offset_changed(self: ptr cef_render_handler, 
  browser: ptr_cef_browser, x, y: cdouble) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnScrollOffsetChanged(brow, x.float64, y.float64)
  release(brow)
  
proc initialize_render_handler*(render: ptr cef_render_handler) =
  init_base(render)
  render.get_root_screen_rect = get_root_screen_rect
  render.get_view_rect = get_view_rect
  render.get_screen_point = get_screen_point
  render.get_screen_info = get_screen_info
  render.on_popup_show = on_popup_show
  render.on_popup_size = on_popup_size
  render.on_paint = on_paint
  render.on_cursor_change = on_cursor_change
  render.start_dragging = start_dragging
  render.update_drag_cursor = update_drag_cursor
  render.on_scroll_offset_changed = on_scroll_offset_changed