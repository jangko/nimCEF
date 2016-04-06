import cef_base, cef_drag_data
include cef_import

# Implement this structure to handle events related to dragging. The functions
# of this structure will be called on the UI thread.
type
  cef_drag_handler* = object
    base*: cef_base

    # Called when an external drag event enters the browser window. |dragData|
    # contains the drag event data and |mask| represents the type of drag
    # operation. Return false (0) for default drag handling behavior or true (1)
    # to cancel the drag event.
    on_drag_enter*: proc(self: ptr cef_drag_handler,
      browser: ptr_cef_browser, dragData: ptr cef_drag_data,
      mask: cef_drag_operations_mask): cint {.cef_callback.}

    # Called whenever draggable regions for the browser window change. These can
    # be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
    # draggable regions are never defined in a document this function will also
    # never be called. If the last draggable region is removed from a document
    # this function will be called with an NULL vector.
    on_draggable_regions_changed*: proc(self: ptr cef_drag_handler, browser: ptr_cef_browser,
      regionsCount: csize, regions: ptr cef_draggable_region) {.cef_callback.}
