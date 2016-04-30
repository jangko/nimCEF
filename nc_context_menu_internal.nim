import nc_types, cef/cef_menu_model_api, cef/cef_callback_api, nc_util
include cef/cef_import

proc on_before_context_menu(self: ptr cef_context_menu_handler, browser: ptr_cef_browser,
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: ptr cef_menu_model) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnBeforeContextMenu(nc_wrap(brow), frame, params, model)
  release(brow)
  release(frame)
  release(params)
  release(model)

proc run_context_menu(self: ptr cef_context_menu_handler, browser: ptr_cef_browser,
  frame: ptr cef_frame, params: ptr cef_context_menu_params, model: ptr cef_menu_model,
  callback: ptr cef_run_context_menu_callback): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.RunContextMenu(nc_wrap(brow), frame, params, model, callback).cint
  release(brow)
  release(frame)
  release(params)
  release(model)
  release(callback)

proc on_context_menu_command(self: ptr cef_context_menu_handler, browser: ptr_cef_browser,
  frame: ptr cef_frame, params: ptr cef_context_menu_params, command_id: cint,
  event_flags: cef_event_flags): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.OnContextMenuCommand(nc_wrap(brow), frame, params, command_id.cef_menu_id, event_flags).cint
  release(brow)
  release(frame)
  release(params)

proc on_context_menu_dismissed(self: ptr cef_context_menu_handler,
  browser: ptr_cef_browser, frame: ptr cef_frame) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnContextMenuDismissed(nc_wrap(brow), frame)
  release(brow)
  release(frame)

proc initialize_context_menu_handler*(menu: ptr cef_context_menu_handler) =
  init_base(menu)
  menu.on_before_context_menu = on_before_context_menu
  menu.run_context_menu = run_context_menu
  menu.on_context_menu_command = on_context_menu_command
  menu.on_context_menu_dismissed = on_context_menu_dismissed