import cef/cef_base_api, cef/cef_browser_api, cef/cef_frame_api
import nc_client

method OnBeforePopup*(self: NCClient, browser: ptr cef_browser, frame: ptr cef_frame,
    target_url, target_frame_name: string,
    target_disposition: cef_window_open_disposition, user_gesture: cint,
    popupFeatures: ptr cef_popup_features,
    windowInfo: ptr cef_window_info, client: var ptr_cef_client,
    settings: ptr cef_browser_settings, no_javascript_access: var cint): int {.base.} =
  result = 0
  
method OnAfterCreated*(self: NCClient, browser: ptr cef_browser) {.base.} =
  discard

method RunModal*(self: NCClient, browser: ptr cef_browser): int {.base.} =
  discard

method DoClose*(self: NCClient, browser: ptr cef_browser): int {.base.} =
  discard

method OnBeforeClose*(self: NCClient, browser: ptr cef_browser) {.base.} =
  discard