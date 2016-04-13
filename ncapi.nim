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
  if client.context_menu_handler != nil: freeShared(client.context_menu_handler.addr)
  if client.life_span_handler != nil: freeShared(client.life_span_handler.addr)
  
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
    
  return client