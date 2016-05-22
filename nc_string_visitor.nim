import cef/cef_string_visitor_api, nc_util, impl/nc_util_impl
include cef/cef_import

# Implement this structure to receive string values asynchronously.
wrapCallback(NCStringVisitor, cef_string_visitor):
  # Method that will be executed.
  proc Visit*(self: T, str: string)
