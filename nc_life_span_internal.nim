import cef/cef_life_span_handler_api, nc_util, nc_types
include cef/cef_import

proc on_before_popup(self: ptr cef_life_span_handler,
    browser: ptr_cef_browser, frame: ptr cef_frame,
    target_url, target_frame_name: ptr cef_string,
    target_disposition: cef_window_open_disposition, user_gesture: cint,
    popupFeatures: ptr cef_popup_features,
    windowInfo: ptr cef_window_info, client: var ptr_cef_client,
    settings: ptr cef_browser_settings, no_javascript_access: var cint): cint {.cef_callback.} =
    
  var cliente = get_client(browser)
  var brow = b_to_b(browser)
  var nja: cint = no_javascript_access
  result = cliente.OnBeforePopup(brow, frame, $target_url, $target_frame_name,
    target_disposition, user_gesture, popupFeatures, windowInfo, client, settings, nja).cint
  no_javascript_access = nja
  release(brow)
  release(frame)
  release(brow)
  
proc on_after_created(self: ptr cef_life_span_handler, browser: ptr_cef_browser) {.cef_callback.} =
  var client = get_client(browser)  
  var brow = b_to_b(browser)
  client.OnAfterCreated(brow)
  release(brow)

proc run_modal(self: ptr cef_life_span_handler, browser: ptr_cef_browser): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.RunModal(brow).cint
  release(brow)

proc do_close(self: ptr cef_life_span_handler, browser: ptr_cef_browser): cint {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  result = client.DoClose(brow).cint
  release(brow)

proc on_before_close(self: ptr cef_life_span_handler, browser: ptr_cef_browser) {.cef_callback.} =
  var client = get_client(browser)
  var brow = b_to_b(browser)
  client.OnBeforeClose(brow)
  release(brow)
 
proc initialize_life_span_handler*(span: ptr cef_life_span_handler) =
  init_base(span)
  span.on_before_popup = on_before_popup
  span.on_after_created = on_after_created
  span.run_modal = run_modal
  span.do_close = do_close
  span.on_before_close = on_before_close