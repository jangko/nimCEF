import cef/cef_request_context_handler_api

type
  NCRequestContextHandler* = ref object of RootObj
    handler: cef_request_context_handler
    
proc GetHandler*(self: NCRequestContextHandler): ptr cef_request_context_handler {.inline.} =
  result = self.handler.addr