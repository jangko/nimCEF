import cef/cef_request_context_handler_api, nc_util

type
  NCRequestContextHandler* = ref object of RootObj
    handler: ptr cef_request_context_handler
    
import impl/nc_util_impl

proc GetHandler*(self: NCRequestContextHandler): ptr cef_request_context_handler {.inline.} =
  result = self.handler
  
proc nc_wrap*(handler: ptr cef_request_context_handler): NCRequestContextHandler =
  new(result, nc_finalizer[NCRequestContextHandler])
  result.handler = handler
  add_ref(handler)