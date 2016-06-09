import nc_util, nc_util_impl, cef_find_handler_api
import nc_types, nc_drag_data, nc_settings
include cef_import

# Implement this structure to handle events related to find results. The
# functions of this structure will be called on the UI thread.
wrapCallback(NCFindHandler, cef_find_handler):
  # Called to report find results returned by NCBrowserHost::find().
  # |identifer| is the identifier passed to find(), |count| is the number of
  # matches currently identified, |selectionRect| is the location of where the
  # match was found (in window coordinates), |activeMatchOrdinal| is the
  # current position in the search results, and |finalUpdate| is true (1) if
  # this is the last find notification.
  proc OnFindResult*(self: T, browser: NCBrowser, identifier, count: int,
    selectionRect: NCRect, activeMatchOrdinal: int, finalUpdate: bool)