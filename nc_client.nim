import cef/cef_base_api, cef/cef_client_api, cef/cef_browser_api
import nc_process_message, nc_types

#moved to nc_types.nim to avoid circular import
#type
#  NCClient* = ref object of RootObj

#--Client Handler
# Called when a new message is received from a different process. Return true
# (1) if the message was handled or false (0) otherwise. Do not keep a
# reference to or attempt to access the message outside of this callback.
method OnProcessMessageReceived*(self: NCClient, browser: NCBrowser, 
  source_process: cef_process_id, message: NCProcessMessage): bool {.base.} =
  result = false
  
  
#--Drag Handler
# Called when an external drag event enters the browser window. |dragData|
# contains the drag event data and |mask| represents the type of drag
# operation. Return false (0) for default drag handling behavior or true (1)
# to cancel the drag event.
method OnDragEnter*(self: NCClient, browser: NCBrowser, dragData: ptr cef_drag_data,
  mask: cef_drag_operations_mask): bool {.base.} =
  result = false

# Called whenever draggable regions for the browser window change. These can
# be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
# draggable regions are never defined in a document this function will also
# never be called. If the last draggable region is removed from a document
# this function will be called with an NULL vector.
method OnDraggableRegionsChanged*(self: NCClient, browser: NCBrowser,
  regionsCount: int, regions: ptr cef_draggable_region) {.base.} =
  discard

#--Display Handler  
# Called when a frame's address has changed.
method OnAddressChange*(self: NCClient, browser: NCBrowser, frame: NCFrame, url: string) {.base.} =
  discard
  
# Called when the page title changes.
method OnTitleChange*(self: NCClient, browser: NCBrowser, title: string) {.base.} =
  discard

# Called when the page icon changes.
method OnFaviconUrlchange*(self: NCClient, browser: NCBrowser, icon_urls: seq[string]) {.base.} =
  discard
  
# Called when web content in the page has toggled fullscreen mode. If
# |fullscreen| is true (1) the content will automatically be sized to fill
# the browser content area. If |fullscreen| is false (0) the content will
# automatically return to its original size and position. The client is
# responsible for resizing the browser if desired.
method OnFullscreenModeChange*(self: NCClient, browser: NCBrowser, fullscreen: bool) {.base.} =
  discard

# Called when the browser is about to display a tooltip. |text| contains the
# text that will be displayed in the tooltip. To handle the display of the
# tooltip yourself return true (1). Otherwise, you can optionally modify
# |text| and then return false (0) to allow the browser to display the
# tooltip. When window rendering is disabled the application is responsible
# for drawing tooltips and the return value is ignored.
method OnTooltip*(self: NCClient, browser: NCBrowser, text: var string): bool {.base.} =
  result = false

# Called when the browser receives a status message. |value| contains the
# text that will be displayed in the status message.
method OnStatusMessage*(self: NCClient, browser: NCBrowser, value: string) {.base.} =
  discard

# Called to display a console message. Return true (1) to stop the message
# from being output to the console.
method OnConsoleMessage*(self: NCClient, browser: NCBrowser, message, source: string, line: int): bool {.base.} =
  result = false
      
#--Focus Handler
# Called when the browser component is about to loose focus. For instance, if
# focus was on the last HTML element and the user pressed the TAB key. |next|
# will be true (1) if the browser is giving focus to the next component and
# false (0) if the browser is giving focus to the previous component.
method OnTakeFocus*(self: NCClient, browser: NCBrowser, next: bool) {.base.} =
  discard

# Called when the browser component is requesting focus. |source| indicates
# where the focus request is originating from. Return false (0) to allow the
# focus to be set or true (1) to cancel setting the focus.
method OnSetFocus*(self: NCClient, browser: NCBrowser, source: cef_focus_source): bool {.base.} =
  result = true
  
# Called when the browser component has received focus.
method OnGotFocus*(self: NCClient, browser: NCBrowser) {.base.} =
  discard
      
#--Keyboard Handler
# Called before a keyboard event is sent to the renderer. |event| contains
# information about the keyboard event. |os_event| is the operating system
# event message, if any. Return true (1) if the event was handled or false
# (0) otherwise. If the event will be handled in on_key_event() as a keyboard
# shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
method OnPreKeyEvent*(self: NCClient, browser: NCBrowser, event: ptr cef_key_event,
  os_event: cef_event_handle, is_keyboard_shortcut: var int): bool {.base.} =
  result = false

# Called after the renderer and JavaScript in the page has had a chance to
# handle the event. |event| contains information about the keyboard event.
# |os_event| is the operating system event message, if any. Return true (1)
# if the keyboard event was handled or false (0) otherwise.
method OnKeyEvent*(self: NCClient, browser: NCBrowser, event: ptr cef_key_event,
  os_event: cef_event_handle): bool {.base.} =
  result = false
      
#--Load Handler
# Called when the loading state has changed. This callback will be executed
# twice -- once when loading is initiated either programmatically or by user
# action, and once when loading is terminated due to completion, cancellation
# of failure. It will be called before any calls to OnLoadStart and after all
# calls to OnLoadError and/or OnLoadEnd.
method OnLoadingStateChange*(self: NCClient,
  browser: NCBrowser, isLoading, canGoBack, canGoForward: bool) {.base.} =
  discard

# Called when the browser begins loading a frame. The |frame| value will
# never be NULL -- call the is_main() function to check if this frame is the
# main frame. Multiple frames may be loading at the same time. Sub-frames may
# start or continue loading after the main frame load has ended. This
# function will always be called for all frames irrespective of whether the
# request completes successfully. For notification of overall browser load
# status use OnLoadingStateChange instead.
method OnLoadStart*(self: NCClient, browser: NCBrowser, frame: NCFrame) {.base.} =
  discard
  
# Called when the browser is done loading a frame. The |frame| value will
# never be NULL -- call the is_main() function to check if this frame is the
# main frame. Multiple frames may be loading at the same time. Sub-frames may
# start or continue loading after the main frame load has ended. This
# function will always be called for all frames irrespective of whether the
# request completes successfully. For notification of overall browser load
# status use OnLoadingStateChange instead.
method OnLoadEnd*(self: NCClient, browser: NCBrowser, frame: NCFrame, httpStatusCode: int) {.base.} =
  discard
  
# Called when the resource load for a navigation fails or is canceled.
# |errorCode| is the error code number, |errorText| is the error text and
# |failedUrl| is the URL that failed to load. See net\base\net_error_list.h
# for complete descriptions of the error codes.
method OnLoadError*(self: NCClient, browser: NCBrowser, frame: NCFrame,
  errorCode: cef_errorcode, errorText, failedUrl: string) {.base.} =
  discard
      
include nc_client_internal

proc GetHandler*(client: NCClient): ptr cef_client = client.client_handler.addr
