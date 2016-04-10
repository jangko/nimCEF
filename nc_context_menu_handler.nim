import cef/cef_base_api, cef/cef_browser_api, cef/cef_context_menu_handler_api
import nc_client, nc_menu_model

method OnBeforeContextMenu*(self: NCClient, browser: ptr cef_browser,
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: NCMenuModel) {.base.} =
  discard

method RunContextMenu*(self: NCClient, browser: ptr cef_browser, 
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: NCMenuModel,
  callback: ptr cef_run_context_menu_callback): int {.base.} =
  discard

method OnContextMenuCommand*(self: NCClient, browser: ptr cef_browser, 
  frame: ptr cef_frame, params: ptr cef_context_menu_params, command_id: cef_menu_id, 
  event_flags: cef_event_flags): int {.base.} =
  discard

method OnContextMenuDismissed*(self: NCCLient,  browser: ptr cef_browser, 
  frame: ptr cef_frame) {.base.} =
  discard
  
include nc_context_menu_internal