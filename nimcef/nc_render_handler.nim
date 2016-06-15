import nc_util, nc_util_impl, cef_render_handler_api, nc_types, nc_drag_data
include cef_import

# Implement this structure to handle events when window rendering is disabled.
# The functions of this structure will be called on the UI thread.
wrapCallback(NCRenderHandler, cef_render_handler):
  # Called to retrieve the root window rectangle in screen coordinates. Return
  # true (1) if the rectangle was provided.
  proc GetRootScreenRect*(self: T, browser: NCBrowser, rect: NCRect): bool

  # Called to retrieve the view rectangle which is relative to screen
  # coordinates. Return true (1) if the rectangle was provided.
  proc GetViewRect*(self: T, browser: NCBrowser, rect: NCRect): bool

  # Called to retrieve the translation from view coordinates to actual screen
  # coordinates. Return true (1) if the screen coordinates were provided.
  proc GetScreenPoint*(self: T, browser: NCBrowser,
    viewX, viewY: int, screenX, screenY: var int): bool

  # Called to allow the client to fill in the CefScreenInfo object with
  # appropriate values. Return true (1) if the |screen_info| structure has been
  # modified.
  #
  # If the screen info rectangle is left NULL the rectangle from GetViewRect
  # will be used. If the rectangle is still NULL or invalid popups may not be
  # drawn correctly.
  proc GetScreenInfo*(self: T, browser: NCBrowser, screen_info: NCScreenInfo): bool

  # Called when the browser wants to show or hide the popup widget. The popup
  # should be shown if |show| is true (1) and hidden if |show| is false (0).
  proc OnPopupShow*(self: T, browser: NCBrowser, show: bool)

  # Called when the browser wants to move or resize the popup widget. |rect|
  # contains the new location and size in view coordinates.
  proc OnPopupSize*(self: T, browser: NCBrowser, rect: NCRect)

  # Called when an element should be painted. Pixel values passed to this
  # function are scaled relative to view coordinates based on the value of
  # CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
  # indicates whether the element is the view or the popup widget. |buffer|
  # contains the pixel data for the whole image. |dirtyRects| contains the set
  # of rectangles in pixel coordinates that need to be repainted. |buffer| will
  # be |width|*|height|*4 bytes in size and represents a BGRA image with an
  # upper-left origin.
  proc OnPaint*(self: T, browser: NCBrowser, ptype: cef_paint_element_type,
    dirtyRectsCount: int, dirtyRects: NCRect, buffer: pointer, width, height: int)

  # Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
  # |custom_cursor_info| will be populated with the custom cursor information.
  proc OnCursorChange*(self: T, browser: NCBrowser, cursor: cef_cursor_handle,
    ptype: cef_cursor_type, custom_cursor_info: NCCursorInfo)

  # Called when the user starts dragging content in the web view. Contextual
  # information about the dragged content is supplied by |drag_data|. (|x|,
  # |y|) is the drag start location in screen coordinates. OS APIs that run a
  # system message loop may be used within the StartDragging call.
  #
  # Return false (0) to abort the drag operation. Don't call any of
  # NCBrowserHost::DragSource*Ended* functions after returning false (0).
  #
  # Return true (1) to handle the drag operation. Call
  # NCBrowserHost::DragSourceEndedAt and DragSourceSystemDragEnded either
  # synchronously or asynchronously to inform the web view that the drag
  # operation has ended.
  proc StartDragging*(self: T, browser: NCBrowser, drag_data: NCDragData,
    allowed_ops: cef_drag_operations_mask, x, y: int): bool

  # Called when the web view wants to update the mouse cursor during a drag &
  # drop operation. |operation| describes the allowed operation (none, move,
  # copy, link).
  proc UpdateDragCursor*(self: T, browser: NCBrowser, operation: cef_drag_operations_mask)

  # Called when the scroll offset has changed.
  proc OnScrollOffsetChanged*(self: T, browser: NCBrowser, x, y: float64)