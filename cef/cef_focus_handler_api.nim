import cef_base_api
include cef_import

# Implement this structure to handle events related to focus. The functions of
# this structure will be called on the UI thread.
type
  cef_focus_handler* = object
    # Base structure.
    base*: cef_base

    # Called when the browser component is about to loose focus. For instance, if
    # focus was on the last HTML element and the user pressed the TAB key. |next|
    # will be true (1) if the browser is giving focus to the next component and
    # false (0) if the browser is giving focus to the previous component.
    on_take_focus*: proc(self: ptr cef_focus_handler,
      browser: ptr_cef_browser, next: cint) {.cef_callback.}

    # Called when the browser component is requesting focus. |source| indicates
    # where the focus request is originating from. Return false (0) to allow the
    # focus to be set or true (1) to cancel setting the focus.
    on_set_focus*: proc(self: ptr cef_focus_handler,
      browser: ptr_cef_browser, source: cef_focus_source): cint {.cef_callback.}

    # Called when the browser component has received focus.
    on_got_focus*: proc(self: ptr cef_focus_handler,
      browser: ptr_cef_browser) {.cef_callback.}