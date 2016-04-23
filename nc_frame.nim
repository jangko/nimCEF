import nc_browser, nc_util, nc_types
import nc_string_visitor, nc_request, nc_dom, nc_v8


# Structure used to represent a frame in the browser window. When used in the
# browser process the functions of this structure may be called on any thread
# unless otherwise indicated in the comments. When used in the render process
# the functions of this structure may only be called on the main thread.

#type
#  NCFrame* = ptr cef_frame  #moved to nc_types.nim to avoid circular import

# True if this object is currently attached to a valid frame.
proc IsValid*(self: NCFrame): bool =
  result = self.is_valid(self) == 1.cint

# Execute undo in this frame.
proc Undo*(self: NCFrame) =
  self.undo(self)

# Execute redo in this frame.
proc Redo*(self: NCFrame) =
  self.redo(self)

# Execute cut in this frame.
proc Cut*(self: NCFrame) =
  self.cut(self)

# Execute copy in this frame.
proc Copy*(self: NCFrame) =
  self.copy(self)

# Execute paste in this frame.
proc Paste*(self: NCFrame) =
  self.paste(self)

# Execute delete in this frame.
proc Del*(self: NCFrame) =
  self.del(self)

# Execute select all in this frame.
proc SelectAll*(self: NCFrame) =
  self.select_all(self)

# Save this frame's HTML source to a temporary file and open it in the
# default text viewing application. This function can only be called from the
# browser process.
proc ViewSource*(self: NCFrame) =
  self.view_source(self)

# Retrieve this frame's HTML source as a string sent to the specified
# visitor.
proc GetSource*(self: NCFrame, visitor: NCStringVisitor) =
  add_ref(visitor.GetHandler())
  self.get_source(self, visitor.GetHandler())

# Retrieve this frame's display text as a string sent to the specified
# visitor.
proc GetText*(self: NCFrame, visitor: NCStringVisitor) =
  add_ref(visitor.GetHandler())
  self.get_text(self, visitor.GetHandler())

# Load the request represented by the |request| object.
proc LoadRequest*(self: NCFrame, request: NCRequest) =
  add_ref(request)
  self.load_request(self, request)

# Load the specified |url|.
proc LoadUrl*(self: NCFrame, url: string) =
  var curl = to_cef(url)
  self.load_url(self, curl)
  cef_string_userfree_free(curl)

# Load the contents of |string_val| with the specified dummy |url|. |url|
# should have a standard scheme (for example, http scheme) or behaviors like
# link clicks and web security restrictions may not behave as expected.
proc LoadString*(self: NCFrame, string_val, url: string) =
  var cval = to_cef(string_val)
  var curl = to_cef(url)
  self.load_string(self, cval, curl)
  cef_string_userfree_free(curl)
  cef_string_userfree_free(cval)

# Execute a string of JavaScript code in this frame. The |script_url|
# parameter is the URL where the script in question can be found, if any. The
# renderer may request this URL to show the developer the source of the
# error.  The |start_line| parameter is the base line number to use for error
# reporting.
proc ExecuteJavaScript*(self: NCFrame, code, script_url: string, start_line: int) =
  var ccode = to_cef(code)
  var curl = to_cef(script_url)
  self.execute_java_script(self, ccode, curl, start_line.cint)
  cef_string_userfree_free(ccode)
  cef_string_userfree_free(curl)

# Returns true (1) if this is the main (top-level) frame.
proc IsMain*(self: NCFrame): bool =
  result = self.is_main(self) == 1.cint

# Returns true (1) if this is the focused frame.
proc IsFocused*(self: NCFrame): bool =
  result = self.is_focused(self) == 1.cint

# Returns the name for this frame. If the frame has an assigned name (for
# example, set via the iframe "name" attribute) then that value will be
# returned. Otherwise a unique name will be constructed based on the frame
# parent hierarchy. The main (top-level) frame will always have an NULL name
# value.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetName*(self: NCFrame): string =
  result = to_nim(self.get_name(self))

# Returns the globally unique identifier for this frame or < 0 if the
# underlying frame does not yet exist.
proc GetIdentifier*(self: NCFrame): int64 =
  result = self.get_identifier(self)

# Returns the parent of this frame or NULL if this is the main (top-level)
# frame.
proc GetParent*(self: NCFrame): NCFrame =
  result = self.get_parent(self)

# Returns the URL currently loaded in this frame.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetUrl*(self: NCFrame): string =
  result = to_nim(self.get_url(self))

# Returns the browser that this frame belongs to.
proc GetBrowser*(self: NCFrame): NCBrowser =
  result = cast[NCBrowser](self.get_browser(self))

# Get the V8 context associated with the frame. This function can only be
# called from the render process.
proc GetV8context*(self: NCFrame): NCV8context =
  result = self.get_v8context(self)

# Visit the DOM document. This function can only be called from the render
# process.
proc VisitDom*(self: NCFrame, visitor: NCDomvisitor) =
  add_ref(visitor.GetHandler())
  self.visit_dom(self, visitor.GetHandler())