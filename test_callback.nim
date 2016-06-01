import nc_context_menu_handler, nc_browser, nc_types
import nc_util, nc_context_menu_params, nc_menu_model

type
  myHandler = ref object of NCContextMenuHandler
 
handlerImpl(abc, myHandler):
  proc OnBeforeContextMenu(self: myHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
    discard
   
  proc OnContextMenuCommand(self: myHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =
    discard