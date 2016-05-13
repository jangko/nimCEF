import cef/cef_string_visitor_api, nc_util, nc_types
include cef/cef_import

# Implement this structure to receive string values asynchronously.
type
  NCStringVisitor* = ref object of RootObj
    handler: cef_string_visitor

# Method that will be executed.
method StringVisit*(self: NCStringVisitor, str: string) {.base.} =
  discard

proc GetHandler*(self: NCStringVisitor): ptr cef_string_visitor {.inline.} =
  result = self.handler.addr

proc visit_string(self: ptr cef_string_visitor, str: ptr cef_string) {.cef_callback.} =
  var handler = type_to_type(NCStringVisitor, self)
  handler.StringVisit($str)

proc init_string_visitor(handler: ptr cef_string_visitor) =
  init_base(handler)
  handler.visit = visit_string

proc makeStringVisitor*(T: typedesc): auto =
  result = new(T)
  init_string_visitor(result.GetHandler())