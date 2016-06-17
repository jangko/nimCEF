import nc_util, nc_types, nc_util_impl
include cef_import

# Generic callback structure used for asynchronous continuation
wrapAPI(NCCallback, cef_callback)

wrapCallback(NCCompletionCallback, cef_completion_callback):
  # Method that will be called once the task is complete.
  proc onComplete*(self: T)

# Continue processing.
proc continueCallback*(self: NCCallback) =
  self.wrapCall(cont)

# Cancel processing.
proc cancel*(self: NCCallback) =
  self.wrapCall(cancel)