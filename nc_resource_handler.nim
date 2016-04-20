import cef/cef_resource_handler_api, cef/cef_callback_api, cef/cef_types
import cef/cef_request_api, cef/cef_response_api
import nc_request, nc_response, nc_util, nc_types
include cef/cef_import

type
  NCResourceHandler* = ref object of RootObj
    handler: cef_resource_handler
    
# Begin processing the request. To handle the request return true (1) and
# call cef_callback_t::cont() once the response header information is
# available (cef_callback_t::cont() can also be called from inside this
# function if header information is available immediately). To cancel the
# request return false (0).
method ProcessRequest*(self: NCResourceHandler, request: NCRequest, callback: ptr cef_callback): bool {.base.} =
  result = false

# Retrieve response header information. If the response length is not known
# set |response_length| to -1 and read_response() will be called until it
# returns false (0). If the response length is known set |response_length| to
# a positive value and read_response() will be called until it returns false
# (0) or the specified number of bytes have been read. Use the |response|
# object to set the mime type, http status code and other optional header
# values. To redirect the request to a new URL set |redirectUrl| to the new
# URL.
method GetResponseHeaders*(self: NCResourceHandler, response: NCResponse, 
  response_length: var int64, redirectUrl: var string) {.base.} =
  discard

# Read response data. If data is available immediately copy up to
# |bytes_to_read| bytes into |data_out|, set |bytes_read| to the number of
# bytes copied, and return true (1). To read the data at a later time set
# |bytes_read| to 0, return true (1) and call cef_callback_t::cont() when the
# data is available. To indicate response completion return false (0).
method ReadResponse*(self: NCResourceHandler, data_out: cstring, bytes_to_read: int, bytes_read: var int,
  callback: ptr cef_callback): bool {.base.} =
  result = false

# Return true (1) if the specified cookie can be sent with the request or
# false (0) otherwise. If false (0) is returned for any cookie then no
# cookies will be sent with the request.
method CanGetCookie*(self: NCResourceHandler, cookie: ptr cef_cookie): bool {.base.} =
  result = false

# Return true (1) if the specified cookie returned with the response can be
# set or false (0) otherwise.
method CanSetCookie*(self: NCResourceHandler, cookie: ptr cef_cookie): bool {.base.} =
  result = false

# Request processing has been canceled.
method Cancel*(self: NCResourceHandler) {.base.} =
  discard
 
proc process_request(self: ptr cef_resource_handler,
  request: ptr cef_request, callback: ptr cef_callback): cint {.cef_callback.} =
  var handler = type_to_type(NCResourceHandler, self)
  result = handler.ProcessRequest(request, callback).cint

proc get_response_headers(self: ptr cef_resource_handler, 
  response: ptr cef_response, response_length: var int64, redirectUrl: ptr cef_string) {.cef_callback.} =
  var handler = type_to_type(NCResourceHandler, self)
  var len = response_length
  var url = $redirectUrl
  handler.GetResponseHeaders(response, len, url)
  response_length = len
  cef_string_clear(redirect_url)
  discard cef_string_from_utf8(url.cstring, url.len.cint, redirect_url)

proc read_response(self: ptr cef_resource_handler,
  data_out: cstring, bytes_to_read: cint, bytes_read: var cint,
  callback: ptr cef_callback): cint {.cef_callback.} =
  var handler = type_to_type(NCResourceHandler, self)
  var readed = bytes_read.int
  result = handler.ReadResponse(data_out, bytes_to_read.int, readed, callback).cint
  bytes_read = readed.cint

proc can_get_cookie(self: ptr cef_resource_handler,
  cookie: ptr cef_cookie): cint {.cef_callback.} =
  var handler = type_to_type(NCResourceHandler, self)
  result = handler.CanGetCookie(cookie).cint
  
proc can_set_cookie(self: ptr cef_resource_handler,
  cookie: ptr cef_cookie): cint {.cef_callback.} =
  var handler = type_to_type(NCResourceHandler, self)
  result = handler.CanSetCookie(cookie).cint
  
proc cancel(self: ptr cef_resource_handler) {.cef_callback.} =
  var handler = type_to_type(NCResourceHandler, self)
  handler.Cancel()

proc initialize_resource_handler(handler: ptr cef_resource_handler) =
  init_base(handler)
  handler.process_request = process_request
  handler.get_response_headers = get_response_headers
  handler.read_response = read_response
  handler.can_get_cookie = can_get_cookie
  handler.can_set_cookie = can_set_cookie
  handler.cancel = cancel

proc GetHandler*(self: NCResourceHandler): ptr cef_resource_handler =
  result = self.handler.addr