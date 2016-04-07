import cef_base_api, cef_string_multimap_api
include cef_import

type
  # Structure used to represent a web response. The functions of this structure
  # may be called on any thread.
  cef_response* = object
    # Base structure.
    base*: cef_base

    # Returns true (1) if this object is read-only.
    is_read_only*: proc(self: ptr cef_response): cint {.cef_callback.}

    # Get the response status code.
    get_status*: proc(self: ptr cef_response): cint {.cef_callback.}

    # Set the response status code.
    set_status*: proc(self: ptr cef_response, status: cint) {.cef_callback.}

    # Get the response status text.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_status_text*: proc(self: ptr cef_response): cef_string_userfree {.cef_callback.}

    # Set the response status text.
    set_status_text*: proc(self: ptr cef_response,
      statusText: ptr cef_string) {.cef_callback.}

    # Get the response mime type.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_mime_type*: proc(self: ptr cef_response): cef_string_userfree {.cef_callback.}

    # Set the response mime type.
    set_mime_type*: proc(self: ptr cef_response,
      mimeType: ptr cef_string) {.cef_callback.}

    # Get the value for the specified response header field.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_header*: proc(self: ptr cef_response,
      name: ptr cef_string): cef_string_userfree {.cef_callback.}

    # Get all response header fields.
    get_header_map*: proc(self: ptr cef_response,
      headerMap: cef_string_multimap) {.cef_callback.}

    # Set all response header fields.
    set_header_map*: proc(self: ptr cef_response,
      headerMap: cef_string_multimap) {.cef_callback.}

# Create a new cef_response_t object.
proc cef_response_create*(): ptr cef_response {.cef_import.}

