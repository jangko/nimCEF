import cef_base, cef_string_visitor, cef_request, cef_dom, cef_v8
include cef_import

# Structure used to represent a frame in the browser window. When used in the
# browser process the functions of this structure may be called on any thread
# unless otherwise indicated in the comments. When used in the render process
# the functions of this structure may only be called on the main thread.

type
  cef_frame* = object
    base*: cef_base

    # True if this object is currently attached to a valid frame.
    is_valid*: proc(self: ptr cef_frame): cint {.cef_callback.}

    # Execute undo in this frame.
    undo*: proc(self: ptr cef_frame) {.cef_callback.}

    # Execute redo in this frame.
    redo*: proc(self: ptr cef_frame) {.cef_callback.}

    # Execute cut in this frame.
    cut*: proc(self: ptr cef_frame) {.cef_callback.}

    # Execute copy in this frame.
    copy*: proc(self: ptr cef_frame) {.cef_callback.}
  
    # Execute paste in this frame.
    paste*: proc(self: ptr cef_frame) {.cef_callback.}

    # Execute delete in this frame.
    del*: proc(self: ptr cef_frame) {.cef_callback.}

    # Execute select all in this frame.
    select_all*: proc(self: ptr cef_frame) {.cef_callback.}

    # Save this frame's HTML source to a temporary file and open it in the
    # default text viewing application. This function can only be called from the
    # browser process.
    view_source*: proc(self: ptr cef_frame) {.cef_callback.}

    # Retrieve this frame's HTML source as a string sent to the specified
    # visitor.
    get_source*: proc(self: ptr cef_frame, visitor: ptr cef_string_visitor) {.cef_callback.}

    # Retrieve this frame's display text as a string sent to the specified
    # visitor.
    get_text*: proc(self: ptr cef_frame, visitor: ptr cef_string_visitor) {.cef_callback.}

    # Load the request represented by the |request| object.
    load_request*: proc(self: ptr cef_frame, request: ptr cef_request) {.cef_callback.}

    # Load the specified |url|.
    load_url*: proc(self: ptr cef_frame, url: ptr cef_string) {.cef_callback.}

    # Load the contents of |string_val| with the specified dummy |url|. |url|
    # should have a standard scheme (for example, http scheme) or behaviors like
    # link clicks and web security restrictions may not behave as expected.
    load_string*: proc(self: ptr cef_frame, string_val, url: ptr cef_string) {.cef_callback.}

    # Execute a string of JavaScript code in this frame. The |script_url|
    # parameter is the URL where the script in question can be found, if any. The
    # renderer may request this URL to show the developer the source of the
    # error.  The |start_line| parameter is the base line number to use for error
    # reporting.
    execute_java_script*: proc(self: ptr cef_frame,
      code, script_url: ptr cef_string, start_line: cint) {.cef_callback.}

    # Returns true (1) if this is the main (top-level) frame.
    is_main*: proc(self: ptr cef_frame): cint {.cef_callback.}
  
    # Returns true (1) if this is the focused frame.
    is_focused*: proc(self: ptr cef_frame): cint {.cef_callback.}

    # Returns the name for this frame. If the frame has an assigned name (for
    # example, set via the iframe "name" attribute) then that value will be
    # returned. Otherwise a unique name will be constructed based on the frame
    # parent hierarchy. The main (top-level) frame will always have an NULL name
    # value.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_name*: proc(self: ptr cef_frame): cef_string_userfree {.cef_callback.}

    # Returns the globally unique identifier for this frame or < 0 if the
    # underlying frame does not yet exist.
    get_identifier*: proc(self: ptr cef_frame): int64 {.cef_callback.}

    # Returns the parent of this frame or NULL if this is the main (top-level)
    # frame.
    get_parent*: proc(self: ptr cef_frame): ptr cef_frame {.cef_callback.}

    # Returns the URL currently loaded in this frame.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_url*: proc(self: ptr cef_frame): cef_string_userfree {.cef_callback.}

    # Returns the browser that this frame belongs to.
    get_browser*: proc(self: ptr cef_frame): ptr_cef_browser {.cef_callback.}
  
    # Get the V8 context associated with the frame. This function can only be
    # called from the render process.
    get_v8context*: proc(self: ptr cef_frame): ptr cef_v8context {.cef_callback.}

    # Visit the DOM document. This function can only be called from the render
    # process.
    visit_dom*: proc(self: ptr cef_frame, visitor: ptr cef_domvisitor) {.cef_callback.}