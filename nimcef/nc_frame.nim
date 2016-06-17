import nc_util, nc_types, nc_string_visitor, nc_request, nc_dom, nc_v8

# Structure used to represent a frame in the browser window. When used in the
# browser process the functions of this structure may be called on any thread
# unless otherwise indicated in the comments. When used in the render process
# the functions of this structure may only be called on the main thread.

#wrapAPI(NCFrame, cef_frame)  #moved to nc_types.nim to avoid circular import

# True if this object is currently attached to a valid frame.
proc isValid*(self: NCFrame): bool =
  self.wrapCall(is_valid, result)

# Execute undo in this frame.
proc undo*(self: NCFrame) =
  self.wrapCall(undo)

# Execute redo in this frame.
proc redo*(self: NCFrame) =
  self.wrapCall(redo)

# Execute cut in this frame.
proc cut*(self: NCFrame) =
  self.wrapCall(cut)

# Execute copy in this frame.
proc copy*(self: NCFrame) =
  self.wrapCall(copy)

# Execute paste in this frame.
proc paste*(self: NCFrame) =
  self.wrapCall(paste)

# Execute delete in this frame.
proc del*(self: NCFrame) =
  self.wrapCall(del)

# Execute select all in this frame.
proc selectAll*(self: NCFrame) =
  self.wrapCall(select_all)

# Save this frame's HTML source to a temporary file and open it in the
# default text viewing application. This function can only be called from the
# browser process.
proc viewSource*(self: NCFrame) =
  self.wrapCall(view_source)

# Retrieve this frame's HTML source as a string sent to the specified
# visitor.
proc getSource*(self: NCFrame, visitor: NCStringVisitor) =
  self.wrapCall(get_source, visitor)

# Retrieve this frame's display text as a string sent to the specified
# visitor.
proc getText*(self: NCFrame, visitor: NCStringVisitor) =
  self.wrapCall(get_text, visitor)

# Load the request represented by the |request| object.
proc loadRequest*(self: NCFrame, request: NCRequest) =
  self.wrapCall(load_request, request)

# Load the specified |url|.
proc loadUrl*(self: NCFrame, url: string) =
  self.wrapCall(load_url, url)

# Load the contents of |string_val| with the specified dummy |url|. |url|
# should have a standard scheme (for example, http scheme) or behaviors like
# link clicks and web security restrictions may not behave as expected.
proc loadString*(self: NCFrame, string_val, url: string) =
  self.wrapCall(load_string, string_val, url)

# Execute a string of JavaScript code in this frame. The |script_url|
# parameter is the URL where the script in question can be found, if any. The
# renderer may request this URL to show the developer the source of the
# error.  The |start_line| parameter is the base line number to use for error
# reporting.
proc executeJavaScript*(self: NCFrame, code, script_url: string, start_line: int) =
  self.wrapCall(execute_java_script, code, script_url, start_line)

# Returns true (1) if this is the main (top-level) frame.
proc isMain*(self: NCFrame): bool =
  self.wrapCall(is_main, result)

# Returns true (1) if this is the focused frame.
proc isFocused*(self: NCFrame): bool =
  self.wrapCall(is_focused, result)

# Returns the name for this frame. If the frame has an assigned name (for
# example, set via the iframe "name" attribute) then that value will be
# returned. Otherwise a unique name will be constructed based on the frame
# parent hierarchy. The main (top-level) frame will always have an NULL name
# value.
proc getName*(self: NCFrame): string =
  self.wrapCall(get_name, result)

# Returns the globally unique identifier for this frame or < 0 if the
# underlying frame does not yet exist.
proc getIdentifier*(self: NCFrame): int64 =
  self.wrapCall(get_identifier, result)

# Returns the parent of this frame or NULL if this is the main (top-level)
# frame.
proc getParent*(self: NCFrame): NCFrame =
  self.wrapCall(get_parent, result)

# Returns the URL currently loaded in this frame.
proc getUrl*(self: NCFrame): string =
  self.wrapCall(get_url, result)

# Returns the browser that this frame belongs to.
proc getBrowser*(self: NCFrame): NCBrowser =
  self.wrapCall(get_browser, result)

# Get the V8 context associated with the frame. This function can only be
# called from the render process.
proc getV8context*(self: NCFrame): NCV8context =
  self.wrapCall(get_v8context, result)

# Visit the DOM document. This function can only be called from the render
# process.
proc visitDom*(self: NCFrame, visitor: NCDomvisitor) =
  self.wrapCall(visit_dom, visitor)