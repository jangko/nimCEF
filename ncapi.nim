import cef/cef_base_api, cef/cef_app_api, cef/cef_client_api, cef/cef_browser_api
import cef/cef_menu_model_api

export cef_base_api, cef_app_api, cef_client_api, cef_browser_api
export cef_menu_model_api

include cef/cef_import

import nc_menu_model, nc_util, nc_process_message, nc_app, nc_client, nc_context_menu_handler
import nc_life_span_handler, nc_types

#menu model
#context menu handler
#base
#client
#app
#life span handler

proc client_finalizer[T](client: T) =
  if client.context_menu_handler != nil: freeShared(client.context_menu_handler)
  if client.life_span_handler != nil: freeShared(client.life_span_handler)
  if client.drag_handler != nil: freeShared(client.drag_handler)
  if client.display_handler != nil: freeShared(client.display_handler)
  if client.focus_handler != nil: freeShared(client.focus_handler)
  if client.keyboard_handler != nil: freeShared(client.keyboard_handler)
  if client.load_handler != nil: freeShared(client.load_handler)
  if client.render_handler != nil: freeShared(client.render_handler)
  if client.dialog_handler != nil: freeShared(client.dialog_handler)
  if client.download_handler != nil: freeShared(client.download_handler)
  if client.geolocation_handler != nil: freeShared(client.geolocation_handler)
  if client.jsdialog_handler != nil: freeShared(client.jsdialog_handler)
  if client.request_handler != nil: freeShared(client.request_handler)
  
proc makeNCClient*(T: typedesc, flags: NCCFS): auto =
  var client: T
  new(client, client_finalizer)
  
  initialize_client_handler(client.client_handler.addr)
  
  if NCCF_CONTEXT_MENU in flags:
    client.context_menu_handler = createShared(cef_context_menu_handler)
    initialize_context_menu_handler(client.context_menu_handler)
    
  if NCCF_LIFE_SPAN in flags:
    client.life_span_handler = createShared(cef_life_span_handler)
    initialize_life_span_handler(client.life_span_handler)
    
  if NCCF_DRAG in flags:
    client.drag_handler = createShared(cef_drag_handler)
    initialize_drag_handler(client.drag_handler)
    
  if NCCF_DISPLAY in flags:
    client.display_handler = createShared(cef_display_handler)
    initialize_display_handler(client.display_handler)
    
  if NCCF_FOCUS in flags:
    client.focus_handler = createShared(cef_focus_handler)
    initialize_focus_handler(client.focus_handler)
    
  if NCCF_KEYBOARD in flags:
    client.keyboard_handler = createShared(cef_keyboard_handler)
    initialize_keyboard_handler(client.keyboard_handler)
    
  if NCCF_LOAD in flags:
    client.load_handler = createShared(cef_load_handler)
    initialize_load_handler(client.load_handler)
    
  if NCCF_RENDER in flags:
    client.render_handler = createShared(cef_render_handler)
    initialize_render_handler(client.render_handler)
    
  if NCCF_DIALOG in flags:
    client.dialog_handler = createShared(cef_dialog_handler)
    initialize_dialog_handler(client.dialog_handler)
    
  if NCCF_DOWNLOAD in flags:
    client.download_handler = createShared(cef_download_handler)
    initialize_download_handler(client.download_handler)
    
  if NCCF_GEOLOCATION in flags:
    client.geolocation_handler = createShared(cef_geolocation_handler)
    initialize_geolocation_handler(client.geolocation_handler)
    
  if NCCF_JSDIALOG in flags:
    client.jsdialog_handler = createShared(cef_jsdialog_handler)
    initialize_jsdialog_handler(client.jsdialog_handler)
    
  if NCCF_REQUEST in flags:
    client.request_handler = createShared(cef_request_handler)
    initialize_request_handler(client.request_handler)
  return client