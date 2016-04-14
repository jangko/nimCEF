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
      
#--Render Handler      
# Called to retrieve the root window rectangle in screen coordinates. Return
# true (1) if the rectangle was provided.
method GetRootScreenRect*(self: NCClient, browser: NCBrowser, rect: ptr cef_rect): bool {.base.} =
  result = false

# Called to retrieve the view rectangle which is relative to screen
# coordinates. Return true (1) if the rectangle was provided.
method GetViewRect*(self: NCClient, browser: NCBrowser, rect: ptr cef_rect): bool {.base.} =
  result = false

# Called to retrieve the translation from view coordinates to actual screen
# coordinates. Return true (1) if the screen coordinates were provided.
method GetScreenPoint*(self: NCClient,
  browser: NCBrowser, viewX, viewY: int, screenX, screenY: var int): bool {.base.} =
  result = false

# Called to allow the client to fill in the CefScreenInfo object with
# appropriate values. Return true (1) if the |screen_info| structure has been
# modified.
#
# If the screen info rectangle is left NULL the rectangle from GetViewRect
# will be used. If the rectangle is still NULL or invalid popups may not be
# drawn correctly.
method GetScreenInfo*(self: NCClient,
  browser: NCBrowser, screen_info: ptr cef_screen_info): bool {.base.} =
  result = false

# Called when the browser wants to show or hide the popup widget. The popup
# should be shown if |show| is true (1) and hidden if |show| is false (0).
method OnPopupShow*(self: NCClient, browser: NCBrowser, show: bool) {.base.} =
  discard

# Called when the browser wants to move or resize the popup widget. |rect|
# contains the new location and size in view coordinates.
method OnPopupSize*(self: NCClient, browser: NCBrowser, rect: ptr cef_rect) {.base.} =
  discard

# Called when an element should be painted. Pixel values passed to this
# function are scaled relative to view coordinates based on the value of
# CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
# indicates whether the element is the view or the popup widget. |buffer|
# contains the pixel data for the whole image. |dirtyRects| contains the set
# of rectangles in pixel coordinates that need to be repainted. |buffer| will
# be |width|*|height|*4 bytes in size and represents a BGRA image with an
# upper-left origin.
method OnPaint*(self: NCClient, browser: NCBrowser, ptype: cef_paint_element_type,
  dirtyRectsCount: int, dirtyRects: ptr cef_rect, buffer: pointer, width, height: int) {.base.} =
  discard

# Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
# |custom_cursor_info| will be populated with the custom cursor information.
method OnCursorChange*(self: NCClient, browser: NCBrowser, cursor: cef_cursor_handle,
  ptype: cef_cursor_type, custom_cursor_info: ptr cef_cursor_info) {.base.} =
  discard

# Called when the user starts dragging content in the web view. Contextual
# information about the dragged content is supplied by |drag_data|. (|x|,
# |y|) is the drag start location in screen coordinates. OS APIs that run a
# system message loop may be used within the StartDragging call.
#
# Return false (0) to abort the drag operation. Don't call any of
# cef_browser_host_t::DragSource*Ended* functions after returning false (0).
#
# Return true (1) to handle the drag operation. Call
# cef_browser_host_t::DragSourceEndedAt and DragSourceSystemDragEnded either
# synchronously or asynchronously to inform the web view that the drag
# operation has ended.
method StartDragging*(self: NCClient, browser: NCBrowser, drag_data: ptr cef_drag_data,
  allowed_ops: cef_drag_operations_mask, x, y: int): bool {.base.} =
  result = false

# Called when the web view wants to update the mouse cursor during a drag &
# drop operation. |operation| describes the allowed operation (none, move,
# copy, link).
method UpdateDragCursor*(self: NCClient, browser: NCBrowser, operation: cef_drag_operations_mask) {.base.} =
  discard

# Called when the scroll offset has changed.
method OnScrollOffsetChanged*(self: NCClient, browser: NCBrowser, x, y: float64) {.base.} =
  discard
  
include nc_client_internal

proc GetHandler*(client: NCClient): ptr cef_client = client.client_handler.addr
