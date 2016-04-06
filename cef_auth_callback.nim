import cef_base
include cef_import

# Callback structure used for asynchronous continuation of authentication
# requests.
type
  cef_auth_callback = object
    base*: cef_base

    # Continue the authentication request.
    cont*: proc(self: ptr cef_auth_callback,
      username, password: ptr cef_string) {.cef_callback.}

    # Cancel the authentication request.
    cancel*: proc(self: ptr cef_auth_callback) {.cef_callback.}
