import cef_base, cef_drag_data
include cef_import

type
  # Implement this structure to handle events when window rendering is disabled.
  # The functions of this structure will be called on the UI thread.
  cef_render_handler* = object
    base*: cef_base

    # Called to retrieve the root window rectangle in screen coordinates. Return
    # true (1) if the rectangle was provided.
    get_root_screen_rect*: proc(self: ptr cef_render_handler,
      browser: ptr_cef_browser, rect: ptr cef_rect): cint {.cef_callback.}

    # Called to retrieve the view rectangle which is relative to screen
    # coordinates. Return true (1) if the rectangle was provided.
    get_view_rect*: proc(self: ptr cef_render_handler,
      browser: ptr_cef_browser, rect: ptr cef_rect): cint {.cef_callback.}
  
    # Called to retrieve the translation from view coordinates to actual screen
    # coordinates. Return true (1) if the screen coordinates were provided.
    get_screen_point*: proc(self: ptr cef_render_handler,
      browser: ptr_cef_browser, viewX, viewY: cint, screenX, screenY: var cint): cint {.cef_callback.}

    # Called to allow the client to fill in the CefScreenInfo object with
    # appropriate values. Return true (1) if the |screen_info| structure has been
    # modified.
    #
    # If the screen info rectangle is left NULL the rectangle from GetViewRect
    # will be used. If the rectangle is still NULL or invalid popups may not be
    # drawn correctly.
    get_screen_info*: proc(self: ptr cef_render_handler,
        browser: ptr_cef_browser, screen_info: ptr cef_screen_info): cint {.cef_callback.}
  
    # Called when the browser wants to show or hide the popup widget. The popup
    # should be shown if |show| is true (1) and hidden if |show| is false (0).
    on_popup_show*: proc(self: ptr cef_render_handler,
        browser: ptr_cef_browser, show: cint) {.cef_callback.}
  
    # Called when the browser wants to move or resize the popup widget. |rect|
    # contains the new location and size in view coordinates.
    on_popup_size*: proc(self: ptr cef_render_handler,
        browser: ptr_cef_browser, rect: ptr cef_rect) {.cef_callback.}
  
    # Called when an element should be painted. Pixel values passed to this
    # function are scaled relative to view coordinates based on the value of
    # CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
    # indicates whether the element is the view or the popup widget. |buffer|
    # contains the pixel data for the whole image. |dirtyRects| contains the set
    # of rectangles in pixel coordinates that need to be repainted. |buffer| will
    # be |width|*|height|*4 bytes in size and represents a BGRA image with an
    # upper-left origin.
    on_paint*: proc(self: ptr cef_render_handler,
        browser: ptr_cef_browser, ptype: cef_paint_element_type,
        dirtyRectsCount: csize, dirtyRects: ptr cef_rect, buffer: pointer,
        width, height: cint) {.cef_callback.}
  
    # Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
    # |custom_cursor_info| will be populated with the custom cursor information.
    on_cursor_change*: proc(self: ptr cef_render_handler,
        browser: ptr_cef_browser, cursor: cef_cursor_handle,
        ptype: cef_cursor_type,
        custom_cursor_info: ptr cef_cursor_info) {.cef_callback.}
  
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
    start_dragging*: proc(self: ptr cef_render_handler,
      browser: ptr_cef_browser, drag_data: ptr cef_drag_data,
      allowed_ops: cef_drag_operations_mask, x, y: cint): cint {.cef_callback.}
  
    # Called when the web view wants to update the mouse cursor during a drag &
    # drop operation. |operation| describes the allowed operation (none, move,
    # copy, link).
    update_drag_cursor*: proc(self: ptr cef_render_handler,
      browser: ptr_cef_browser, operation: cef_drag_operations_mask) {.cef_callback.}
  
    # Called when the scroll offset has changed.
    on_scroll_offset_changed*: proc(self: ptr cef_render_handler, 
      browser: ptr_cef_browser, x, y: float64) {.cef_callback.}