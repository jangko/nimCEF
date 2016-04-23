import cef/cef_callback_api, nc_util, nc_types
include cef/cef_import

type
  # Generic callback structure used for asynchronous continuation
  NCCallback* = ptr cef_callback
  NCCompletionCallback* = ref object of RootObj  
    handler: cef_completion_callback

# Continue processing.
proc Continue*(self: NCCallback) =
  self.cont(self)

# Cancel processing.
proc Cancel*(self: NCCallback) =
  self.cancel(self)
  
  
# Method that will be called once the task is complete.
method OnComplete*(self: NCCompletionCallback) {.base.} =
  discard
  
proc on_complete(self: ptr cef_completion_callback) {.cef_callback.} =
  var handler = type_to_type(NCCompletionCallback, self)
  handler.OnComplete()

proc initialize_completion_callback(cb: ptr cef_completion_callback) =
  init_base(cb)
  cb.on_complete = on_complete

proc GetHandler*(self: NCCompletionCallback): ptr cef_completion_callback {.inline.} =
  result = self.handler.addr
  
proc makeNCCompletionCallback*(T: typedesc): auto =
  result = new(T)
  initialize_completion_callback(result.GetHandler())
