import nc_context_menu_handler, nc_dialog_handler, nc_display_handler
import nc_download_handler, nc_drag_handler, nc_find_handler
import nc_focus_handler, nc_geolocation_handler, nc_jsdialog_handler
import nc_keyboard_handler, nc_life_span_handler, nc_load_handler
import nc_render_handler, nc_request_handler, nc_types, nc_process_message
import nc_util, nc_util_impl, cef_client_api
include cef_import

#moved to nc_types.nim to avoid circular import
#wrapAPI(NCClient, cef_client)
wrapHandler(NCClient, cef_client, RootObj):
  # Return the handler for context menus. If no handler is provided the default
  # implementation will be used.
  proc getContextMenuHandler*(self: T): NCContextMenuHandler

  # Return the handler for dialogs. If no handler is provided the default
  # implementation will be used.
  proc getDialogHandler*(self: T): NCDialogHandler

  # Return the handler for browser display state events.
  proc getDisplayHandler*(self: T): NCDisplayHandler

  # Return the handler for download events. If no handler is returned downloads
  # will not be allowed.
  proc getDownloadHandler*(self: T): NCDownloadHandler

  # Return the handler for drag events.
  proc getDragHandler*(self: T): NCDragHandler

  # Return the handler for find result events.
  proc getFindHandler*(self: T): NCFindHandler

  # Return the handler for focus events.
  proc getFocusHandler*(self: T): NCFocusHandler

  # Return the handler for geolocation permissions requests. If no handler is
  # provided geolocation access will be denied by default.
  proc getGeolocationHandler*(self: T): NCGeolocationHandler

  # Return the handler for JavaScript dialogs. If no handler is provided the
  # default implementation will be used.
  proc getJsDialogHandler*(self: T): NCJsDialogHandler

  # Return the handler for keyboard events.
  proc getKeyboardHandler*(self: T): NCKeyboardHandler

  # Return the handler for browser life span events.
  proc getLifeSpanHandler*(self: T): NCLifeSpanHandler

  # Return the handler for browser load status events.
  proc getLoadHandler*(self: T): NCLoadHandler

  # Return the handler for off-screen rendering events.
  proc getRenderHandler*(self: T): NCRenderHandler

  # Return the handler for browser request events.
  proc getRequestHandler*(self: T): NCRequestHandler

  # Called when a new message is received from a different process. Return true
  # (1) if the message was handled or false (0) otherwise. Do not keep a
  # reference to or attempt to access the message outside of this callback.
  proc onRenderProcessMessageReceived*(self: T, browser: NCBrowser,
    source_process: cef_process_id, message: NCProcessMessage): bool

proc getClient*[T](browser: NCBrowser): T =
  let client = browser.GetHost().GetClient()
  let handler = toType(nc_client, client.handler)
  result = T(handler.container)