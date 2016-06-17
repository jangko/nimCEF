import cef_resource_handler_api, cef_callback_api, cef_types
import cef_request_api, cef_response_api, nc_util_impl
import nc_request, nc_response, nc_util, nc_types, nc_cookie, nc_callback
include cef_import

wrapCallback(NCResourceHandler, cef_resource_handler):
  # Begin processing the request. To handle the request return true (1) and
  # call NCCallback::Continue() once the response header information is
  # available (NCCallback::Continue() can also be called from inside this
  # function if header information is available immediately). To cancel the
  # request return false (0).
  proc ProcessRequest*(self: T, request: NCRequest, callback: NCCallback): bool

  # Retrieve response header information. If the response length is not known
  # set |response_length| to -1 and read_response() will be called until it
  # returns false (0). If the response length is known set |response_length| to
  # a positive value and read_response() will be called until it returns false
  # (0) or the specified number of bytes have been read. Use the |response|
  # object to set the mime type, http status code and other optional header
  # values. To redirect the request to a new URL set |redirectUrl| to the new
  # URL. If an error occured while setting up the request you can call
  # set_error() on |response| to indicate the error condition.
  proc getResponseHeaders*(self: T, response: NCResponse,
    response_length: var int64, redirectUrl: var string)

  # Read response data. If data is available immediately copy up to
  # |bytes_to_read| bytes into |data_out|, set |bytes_read| to the number of
  # bytes copied, and return true (1). To read the data at a later time set
  # |bytes_read| to 0, return true (1) and call NCCallback::Continue() when the
  # data is available. To indicate response completion return false (0).
  proc readResponse*(self: T, data_out: cstring, bytes_to_read: int, bytes_read: var int,
    callback: NCCallback): bool

  # Return true (1) if the specified cookie can be sent with the request or
  # false (0) otherwise. If false (0) is returned for any cookie then no
  # cookies will be sent with the request.
  proc CanGetCookie*(self: T, cookie: NCCookie): bool

  # Return true (1) if the specified cookie returned with the response can be
  # set or false (0) otherwise.
  proc CanSetCookie*(self: T, cookie: NCCookie): bool

  # Request processing has been canceled.
  proc Cancel*(self: T)