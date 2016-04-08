import cef/cef_base_api, cef/cef_client_api, cef/cef_browser_api
import nc_process_message

type
  NCClient* = ref object of RootObj
    client_handler*: cef_client
    life_span_handler*: ptr cef_life_span_handler
    context_menu_handler*: ptr cef_context_menu_handler
    
method OnProcessMessageReceived*(self: NCClient, browser: ptr cef_browser, 
  source_process: cef_process_id, message: NCProcessMessage): bool {.base.} =
  result = false