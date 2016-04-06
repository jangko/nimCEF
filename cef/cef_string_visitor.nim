import cef_base
include cef_import

# Implement this structure to receive string values asynchronously.
type
  cef_string_visitor* = object
    base*: cef_base

    # Method that will be executed.
    visit: proc(self: ptr cef_string_visitor, str: ptr cef_string) {.cef_callback.}