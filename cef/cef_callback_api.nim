import cef_base_api
include cef_import

# Generic callback structure used for asynchronous continuation
type
  cef_callback* = object
    base*: cef_base

    # Continue processing.
    cont*: proc(self: ptr cef_callback) {.cef_callback.}

    # Cancel processing.
    cancel*: proc(self: ptr cef_callback) {.cef_callback.}

  # Generic callback structure used for asynchronous completion.
  cef_completion_callback* = object
    base*: cef_base

    # Method that will be called once the task is complete.
    on_complete*: proc(self: ptr cef_completion_callback) {.cef_callback.}
