import cef/cef_base_api, cef/cef_browser_api, cef/cef_context_menu_handler_api
import nc_client, nc_menu_model, nc_context_menu_params

# Called before a context menu is displayed. |params| provides information
# about the context menu state. |model| initially contains the default
# context menu. The |model| can be cleared to show no context menu or
# modified to show a custom menu. Do not keep references to |params| or
# |model| outside of this callback.
method OnBeforeContextMenu*(self: NCClient, browser: ptr cef_browser,
  frame: ptr cef_frame, params: NCContextMenuParams, model: NCMenuModel) {.base.} =
  discard
  
# Called to allow custom display of the context menu. |params| provides
# information about the context menu state. |model| contains the context menu
# model resulting from OnBeforeContextMenu. For custom display return true
# (1) and execute |callback| either synchronously or asynchronously with the
# selected command ID. For default display return false (0). Do not keep
# references to |params| or |model| outside of this callback.
method RunContextMenu*(self: NCClient, browser: ptr cef_browser, 
  frame: ptr cef_frame, params: NCContextMenuParams, model: NCMenuModel,
  callback: ptr cef_run_context_menu_callback): int {.base.} =
  discard
  
# Called to execute a command selected from the context menu. Return true (1)
# if the command was handled or false (0) for the default implementation. See
# cef_menu_id_t for the command ids that have default implementations. All
# user-defined command ids should be between MENU_ID_USER_FIRST and
# MENU_ID_USER_LAST. |params| will have the same values as what was passed to
# on_before_context_menu(). Do not keep a reference to |params| outside of
# this callback.
method OnContextMenuCommand*(self: NCClient, browser: ptr cef_browser, 
  frame: ptr cef_frame, params: NCContextMenuParams, command_id: cef_menu_id, 
  event_flags: cef_event_flags): int {.base.} =
  discard
  
# Called when the context menu is dismissed irregardless of whether the menu
# was NULL or a command was selected.
method OnContextMenuDismissed*(self: NCCLient,  browser: ptr cef_browser, 
  frame: ptr cef_frame) {.base.} =
  discard
  
include nc_context_menu_internal