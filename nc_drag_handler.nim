import nc_util, impl/nc_util_impl, cef/cef_types
import nc_types, nc_drag_data, cef/cef_drag_handler_api
include cef/cef_import

wrapCallback(NCDragHandler, cef_drag_handler):
  # Called when an external drag event enters the browser window. |dragData|
  # contains the drag event data and |mask| represents the type of drag
  # operation. Return false (0) for default drag handling behavior or true (1)
  # to cancel the drag event.
  proc OnDragEnter*(self: T, browser: NCBrowser, dragData: NCDragData,
    mask: cef_drag_operations_mask): bool
    
  # Called whenever draggable regions for the browser window change. These can
  # be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
  # draggable regions are never defined in a document this function will also
  # never be called. If the last draggable region is removed from a document
  # this function will be called with an NULL vector.
  proc OnDraggableRegionsChanged*(self: T, browser: NCBrowser,
    regionsCount: int, regions: NCDraggableRegion)