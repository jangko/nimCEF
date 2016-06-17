import cef_base_api
include cef_import

# Implement this structure to handle events related to find results. The
# functions of this structure will be called on the UI thread.
type
  cef_find_handler* = object of cef_base
    # Called to report find results returned by cef_browser_host_t::find().
    # |identifer| is the identifier passed to find(), |count| is the number of
    # matches currently identified, |selectionRect| is the location of where the
    # match was found (in window coordinates), |activeMatchOrdinal| is the
    # current position in the search results, and |finalUpdate| is true (1) if
    # this is the last find notification.
    on_find_result*: proc(self: ptr cef_find_handler,
      browser: ptr_cef_browser, identifier, count: cint,
      selectionRect: ptr cef_rect, activeMatchOrdinal: cint,
      finalUpdate: cint) {.cef_callback.}
