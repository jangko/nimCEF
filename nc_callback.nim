import nc_util, nc_types, impl/nc_util_impl
include cef/cef_import

# Generic callback structure used for asynchronous continuation
wrapAPI(NCCallback, cef_callback)

wrapCallback(NCCompletionCallback, cef_completion_callback):
  # Method that will be called once the task is complete.
  proc OnComplete*(self: T)

# Continue processing.
proc Continue*(self: NCCallback) =
  self.wrapCall(cont)

# Cancel processing.
proc Cancel*(self: NCCallback) =
  self.wrapCall(cancel)