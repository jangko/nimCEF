import cef/cef_request_handler_api, cef/cef_string_list_api, cef/cef_dialog_handler_api
import cef/cef_download_handler_api, cef/cef_geolocation_handler_api, cef/cef_jsdialog_handler_api
import cef/cef_resource_handler_api, cef/cef_context_menu_handler_api, cef/cef_client_api
import nc_process_message, nc_types, nc_download_item, nc_request, nc_response, nc_drag_data
import nc_auth_callback, nc_ssl_info, nc_util, nc_response_filter, nc_resource_handler
import nc_context_menu_params, nc_menu_model
import impl/nc_util_impl

#moved to nc_types.nim to avoid circular import
#wrapAPI(NCClient, cef_client)


  
type
  nc_client_i*[T] = object
    #--Client Handler
    # Called when a new message is received from a different process. Return true
    # (1) if the message was handled or false (0) otherwise. Do not keep a
    # reference to or attempt to access the message outside of this callback.
    OnRenderProcessMessageReceived*: proc(self: T, browser: NCBrowser,
      source_process: cef_process_id, message: NCProcessMessage): bool


  # Implement this structure to provide handler implementations.
  nc_handler = object of nc_base[cef_client, NCClient]
    impl: nc_client_i[NCClient]
    life_span_handler*: ptr cef_life_span_handler
    context_menu_handler*: ptr cef_context_menu_handler
    drag_handler*: ptr cef_drag_handler
    display_handler*: ptr cef_display_handler
    focus_handler*: ptr cef_focus_handler
    keyboard_handler*: ptr cef_keyboard_handler
    load_handler*: ptr cef_load_handler
    render_handler*: ptr cef_render_handler
    dialog_handler*: ptr cef_dialog_handler
    download_handler*: ptr cef_download_handler
    geolocation_handler*: ptr cef_geolocation_handler
    jsdialog_handler*: ptr cef_jsdialog_handler
    request_handler*: ptr cef_request_handler

include nc_client_internal

proc client_finalizer[A, B](client: A) =
  let handler = cast[ptr B](client.handler)
  if handler.context_menu_handler != nil: freeShared(handler.context_menu_handler)
  if handler.life_span_handler != nil: freeShared(handler.life_span_handler)
  if handler.drag_handler != nil: freeShared(handler.drag_handler)
  if handler.display_handler != nil: freeShared(handler.display_handler)
  if handler.focus_handler != nil: freeShared(handler.focus_handler)
  if handler.keyboard_handler != nil: freeShared(handler.keyboard_handler)
  if handler.load_handler != nil: freeShared(handler.load_handler)
  if handler.render_handler != nil: freeShared(handler.render_handler)
  if handler.dialog_handler != nil: freeShared(handler.dialog_handler)
  if handler.download_handler != nil: freeShared(handler.download_handler)
  if handler.geolocation_handler != nil: freeShared(handler.geolocation_handler)
  if handler.jsdialog_handler != nil: freeShared(handler.jsdialog_handler)
  if handler.request_handler != nil: freeShared(handler.request_handler)
  release(client.handler)
  
template client_init*(T, X: typedesc) =
  var handler = createShared(T)
  nc_init_base[T](handler)
  new(result, client_finalizer[X, T])
  result.handler = handler.handler.addr
  add_ref(handler.handler.addr)
  handler.container = result
  
proc makeNCClient*[T](impl: nc_client_i[T], flags: NCCFS = {}): T =
  client_init(nc_handler, T)
  initialize_client_handler(result.handler)
  
  let handler = cast[ptr nc_handler](result.handler)
  copyMem(handler.impl.addr, impl.unsafeAddr, sizeof(impl))
  
  if NCCF_CONTEXT_MENU in flags:
    handler.context_menu_handler = createShared(cef_context_menu_handler)
    initialize_context_menu_handler(handler.context_menu_handler)

  if NCCF_LIFE_SPAN in flags:
    handler.life_span_handler = createShared(cef_life_span_handler)
    initialize_life_span_handler(handler.life_span_handler)

  if NCCF_DRAG in flags:
    handler.drag_handler = createShared(cef_drag_handler)
    initialize_drag_handler(handler.drag_handler)

  if NCCF_DISPLAY in flags:
    handler.display_handler = createShared(cef_display_handler)
    initialize_display_handler(handler.display_handler)

  if NCCF_FOCUS in flags:
    handler.focus_handler = createShared(cef_focus_handler)
    initialize_focus_handler(handler.focus_handler)

  if NCCF_KEYBOARD in flags:
    handler.keyboard_handler = createShared(cef_keyboard_handler)
    initialize_keyboard_handler(handler.keyboard_handler)

  if NCCF_LOAD in flags:
    handler.load_handler = createShared(cef_load_handler)
    initialize_load_handler(handler.load_handler)

  if NCCF_RENDER in flags:
    handler.render_handler = createShared(cef_render_handler)
    initialize_render_handler(handler.render_handler)

  if NCCF_DIALOG in flags:
    handler.dialog_handler = createShared(cef_dialog_handler)
    initialize_dialog_handler(handler.dialog_handler)

  if NCCF_DOWNLOAD in flags:
    handler.download_handler = createShared(cef_download_handler)
    initialize_download_handler(handler.download_handler)

  if NCCF_GEOLOCATION in flags:
    handler.geolocation_handler = createShared(cef_geolocation_handler)
    initialize_geolocation_handler(handler.geolocation_handler)

  if NCCF_JSDIALOG in flags:
    handler.jsdialog_handler = createShared(cef_jsdialog_handler)
    initialize_jsdialog_handler(handler.jsdialog_handler)

  if NCCF_REQUEST in flags:
    handler.request_handler = createShared(cef_request_handler)
    initialize_request_handler(handler.request_handler)