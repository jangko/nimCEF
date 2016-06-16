import cef_base_api, cef_request_api, cef_callback_api, cef_response_api
include cef_import

# Structure used to implement a custom request handler structure. The functions
# of this structure will always be called on the IO thread.

type
  cef_resource_handler* = object of cef_base
    # Begin processing the request. To handle the request return true (1) and
    # call cef_callback_t::cont() once the response header information is
    # available (cef_callback_t::cont() can also be called from inside this
    # function if header information is available immediately). To cancel the
    # request return false (0).
    process_request*: proc(self: ptr cef_resource_handler,
      request: ptr cef_request, callback: ptr cef_callback): cint {.cef_callback.}

    # Retrieve response header information. If the response length is not known
    # set |response_length| to -1 and read_response() will be called until it
    # returns false (0). If the response length is known set |response_length| to
    # a positive value and read_response() will be called until it returns false
    # (0) or the specified number of bytes have been read. Use the |response|
    # object to set the mime type, http status code and other optional header
    # values. To redirect the request to a new URL set |redirectUrl| to the new
    # URL. If an error occured while setting up the request you can call
    # set_error() on |response| to indicate the error condition.
    get_response_headers*: proc(self: ptr cef_resource_handler,
      response: ptr cef_response, response_length: var int64, redirectUrl: ptr cef_string) {.cef_callback.}

    # Read response data. If data is available immediately copy up to
    # |bytes_to_read| bytes into |data_out|, set |bytes_read| to the number of
    # bytes copied, and return true (1). To read the data at a later time set
    # |bytes_read| to 0, return true (1) and call cef_callback_t::cont() when the
    # data is available. To indicate response completion return false (0).
    read_response*: proc(self: ptr cef_resource_handler,
      data_out: cstring, bytes_to_read: cint, bytes_read: var cint,
      callback: ptr cef_callback): cint {.cef_callback.}

    # Return true (1) if the specified cookie can be sent with the request or
    # false (0) otherwise. If false (0) is returned for any cookie then no
    # cookies will be sent with the request.
    can_get_cookie*: proc(self: ptr cef_resource_handler,
      cookie: ptr cef_cookie): cint {.cef_callback.}

    # Return true (1) if the specified cookie returned with the response can be
    # set or false (0) otherwise.
    can_set_cookie*: proc(self: ptr cef_resource_handler,
      cookie: ptr cef_cookie): cint {.cef_callback.}

    # Request processing has been canceled.
    cancel*: proc(self: ptr cef_resource_handler) {.cef_callback.}
