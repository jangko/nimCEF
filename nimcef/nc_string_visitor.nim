import cef_string_visitor_api, nc_util, nc_util_impl
include cef_import

# Implement this structure to receive string values asynchronously.
wrapCallback(NCStringVisitor, cef_string_visitor):
  # Method that will be executed.
  proc visit*(self: T, str: string)
