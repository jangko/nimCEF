import nc_util, nc_util_impl, cef_focus_handler_api, nc_types
include cef_import

# Implement this structure to handle events related to focus. The functions of
# this structure will be called on the UI thread.
wrapCallback(NCFocusHandler, cef_focus_handler):
  # Called when the browser component is about to loose focus. For instance, if
  # focus was on the last HTML element and the user pressed the TAB key. |next|
  # will be true (1) if the browser is giving focus to the next component and
  # false (0) if the browser is giving focus to the previous component.
  proc OnTakeFocus*(self: T, browser: NCBrowser, next: bool)

  # Called when the browser component is requesting focus. |source| indicates
  # where the focus request is originating from. Return false (0) to allow the
  # focus to be set or true (1) to cancel setting the focus.
  proc OnSetFocus*(self: T, browser: NCBrowser, source: cef_focus_source): bool

  # Called when the browser component has received focus.
  proc OnGotFocus*(self: T, browser: NCBrowser)