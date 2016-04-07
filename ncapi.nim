import cef/cef_base_api, cef/cef_app_api, cef/cef_client_api, cef/cef_browser_api
import cef/cef_menu_model_api

export cef_base_api, cef_app_api, cef_client_api, cef_browser_api
export cef_menu_model_api

include cef/cef_import

import nc_menu_model

type
  NCClient* = ref object of RootObj
    client_handler: cef_client
    life_span_handler: ptr cef_life_span_handler
    context_menu_handler: ptr cef_context_menu_handler
    
proc nc_add_ref(self: ptr cef_base) {.cef_callback.} = discard
proc nc_release(self: ptr cef_base): cint {.cef_callback.} = 1
proc nc_has_one_ref(self: ptr cef_base): cint {.cef_callback.} = 1

proc initialize_cef_base(base: ptr cef_base) =
  let size = base.size
  if size <= 0:
    echo "FATAL: initialize_cef_base failed, size member not set"
    quit(1)
    
  base.add_ref = nc_add_ref
  base.release = nc_release
  base.has_one_ref = nc_has_one_ref

proc init_base[T](elem: T) =
  elem.base.size = sizeof(elem[])
  initialize_cef_base(cast[ptr cef_base](elem))

proc get_client(browser: ptr_cef_browser): NCClient =
  var brow = cast[ptr cef_browser](browser)
  var host = brow.get_host(brow)
  var client = host.get_client(host)
  result = cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))

template client_to_client(client: expr): expr =
  cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))
  
method OnBeforeContextMenu(self: NCClient, browser: ptr cef_browser,
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: NCMenuModel) {.base.} =
  discard

method RunContextMenu(self: NCClient, browser: ptr cef_browser, 
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: NCMenuModel,
  callback: ptr cef_run_context_menu_callback): int {.base.} =
  discard

method OnContextMenuCommand(self: NCClient, browser: ptr cef_browser, 
  frame: ptr cef_frame, params: ptr cef_context_menu_params, command_id: int, 
  event_flags: cef_event_flags): int {.base.} =
  discard

method OnContextMenuDismissed(self: NCCLient,  browser: ptr cef_browser, 
  frame: ptr cef_frame) {.base.} =
  discard
  
proc on_before_context_menu(self: ptr cef_context_menu_handler, browser: ptr_cef_browser,
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: ptr cef_menu_model) {.cef_callback.} =
  var client = get_client(browser)
  client.OnBeforeContextMenu(cast[ptr cef_browser](browser), frame, params, model)

proc run_context_menu(self: ptr cef_context_menu_handler, browser: ptr_cef_browser, 
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: ptr cef_menu_model,
  callback: ptr cef_run_context_menu_callback): cint {.cef_callback.} =
  var client = get_client(browser)
  result = client.RunContextMenu(cast[ptr cef_browser](browser), frame, params, model, callback).cint

proc on_context_menu_command(self: ptr cef_context_menu_handler, browser: ptr_cef_browser, 
  frame: ptr cef_frame, params: ptr cef_context_menu_params, command_id: cint, 
  event_flags: cef_event_flags): cint {.cef_callback.} =
  var client = get_client(browser)
  result = client.OnContextMenuCommand(cast[ptr cef_browser](browser), frame, params, command_id, event_flags).cint
  
proc on_context_menu_dismissed(self: ptr cef_context_menu_handler, 
  browser: ptr_cef_browser, frame: ptr cef_frame) {.cef_callback.} =
  var client = get_client(browser)
  client.OnContextMenuDismissed(cast[ptr cef_browser](browser), frame)
  
proc initialize_context_menu_handler(menu: ptr cef_context_menu_handler) =
  init_base(menu)
  menu.on_before_context_menu = on_before_context_menu
  menu.run_context_menu = run_context_menu
  menu.on_context_menu_command = on_context_menu_command
  menu.on_context_menu_dismissed = on_context_menu_dismissed
  
method OnBeforePopup(self: NCClient, browser: ptr cef_browser, frame: ptr cef_frame,
    target_url, target_frame_name: ptr cef_string,
    target_disposition: cef_window_open_disposition, user_gesture: cint,
    popupFeatures: ptr cef_popup_features,
    windowInfo: ptr cef_window_info, client: ptr_ptr_cef_client,
    settings: ptr cef_browser_settings, no_javascript_access: var cint): int {.base.} =
  result = 0
  
method OnAfterCreated(self: NCClient, browser: ptr cef_browser) {.base.} =
  discard

method RunModal(self: NCClient, browser: ptr cef_browser): int {.base.} =
  discard

method DoClose(self: NCClient, browser: ptr cef_browser): int {.base.} =
  discard

method OnBeforeClose(self: NCClient, browser: ptr cef_browser) {.base.} =
  discard
  
proc on_before_popup(self: ptr cef_life_span_handler,
    browser: ptr_cef_browser, frame: ptr cef_frame,
    target_url, target_frame_name: ptr cef_string,
    target_disposition: cef_window_open_disposition, user_gesture: cint,
    popupFeatures: ptr cef_popup_features,
    windowInfo: ptr cef_window_info, client: ptr_ptr_cef_client,
    settings: ptr cef_browser_settings, no_javascript_access: var cint): cint {.cef_callback.} =
    
  var cliente = get_client(browser)
  var nja: cint = no_javascript_access
  result = cliente.OnBeforePopup(cast[ptr cef_browser](browser), frame, target_url, target_frame_name,
    target_disposition, user_gesture, popupFeatures, windowInfo, client, settings, nja).cint
  no_javascript_access = nja
  
proc on_after_created(self: ptr cef_life_span_handler, browser: ptr_cef_browser) {.cef_callback.} =
  var client = get_client(browser)
  client.OnAfterCreated(cast[ptr cef_browser](browser))

proc run_modal(self: ptr cef_life_span_handler, browser: ptr_cef_browser): cint {.cef_callback.} =
  var client = get_client(browser)
  result = client.RunModal(cast[ptr cef_browser](browser)).cint

proc do_close(self: ptr cef_life_span_handler, browser: ptr_cef_browser): cint {.cef_callback.} =
  var client = get_client(browser)
  result = client.DoClose(cast[ptr cef_browser](browser)).cint

proc on_before_close(self: ptr cef_life_span_handler, browser: ptr_cef_browser) {.cef_callback.} =
  var client = get_client(browser)
  client.OnBeforeClose(cast[ptr cef_browser](browser))
 
proc initialize_life_span_handler(span: ptr cef_life_span_handler) =
  init_base(span)
  span.on_before_popup = on_before_popup
  span.on_after_created = on_after_created
  span.run_modal = run_modal
  span.do_close = do_close
  span.on_before_close = on_before_close
  
  
  
proc on_before_command_line_processing(self: ptr cef_app,
  process_type: ptr cef_string, command_line: ptr cef_command_line) {.cef_callback.} =
  discard

proc on_register_custom_schemes(self: ptr cef_app, registrar: ptr cef_scheme_registrar) {.cef_callback.} =
  discard

proc get_resource_bundle_handler(self: ptr cef_app): ptr cef_resource_bundle_handler {.cef_callback.} =
  result = nil

proc get_browser_process_handler(self: ptr cef_app): ptr cef_browser_process_handler {.cef_callback.} =
  result = nil
  
proc get_render_process_handler(self: ptr cef_app): ptr cef_render_process_handler {.cef_callback.} =
  result = nil

proc initialize_app_handler*(app: ptr cef_app) = 
  init_base(app)
  app.on_before_command_line_processing = on_before_command_line_processing
  app.on_register_custom_schemes = on_register_custom_schemes
  app.get_resource_bundle_handler = get_resource_bundle_handler
  app.get_browser_process_handler = get_browser_process_handler
  app.get_render_process_handler = get_render_process_handler
  

  
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
  result = 0
    
proc initialize_client_handler(client: ptr cef_client) =
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

type
  NCClientCreateFlag* = enum
    NCCF_CONTEXT_MENU
    NCCF_LIFE_SPAN
    
  NCCFS* = set[NCClientCreateFlag]
  
proc makeNCClient*(T: typedesc, flags: NCCFS): auto =
  var client = new(T)
  initialize_client_handler(client.client_handler.addr)
  
  if NCCF_CONTEXT_MENU in flags:
    client.context_menu_handler = createShared(cef_context_menu_handler)
    initialize_context_menu_handler(client.context_menu_handler)
    
  if NCCF_LIFE_SPAN in flags:
    client.life_span_handler = createShared(cef_life_span_handler)
    initialize_life_span_handler(client.life_span_handler)
    
  return client
  
proc GetHandler*(client: NCClient): ptr cef_client = client.client_handler.addr