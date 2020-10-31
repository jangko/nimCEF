import cef_base_api, cef_stream_api
include cef_import

# Structure used to represent drag data. The functions of this structure may be
# called on any thread.
type
  cef_drag_data* = object of cef_base
    # Returns a copy of the current object.
    clone*: proc(self: ptr cef_drag_data): ptr cef_drag_data {.cef_callback.}

    # Returns true (1) if this object is read-only.
    is_read_only*: proc(self: ptr cef_drag_data): cint {.cef_callback.}

    # Returns true (1) if the drag data is a link.
    is_link*: proc(self: ptr cef_drag_data): cint {.cef_callback.}

    # Returns true (1) if the drag data is a text or html fragment.
    is_fragment*: proc(self: ptr cef_drag_data): cint {.cef_callback.}

    # Returns true (1) if the drag data is a file.
    is_file*: proc(self: ptr cef_drag_data): cint {.cef_callback.}

    # Return the link URL that is being dragged.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_link_url*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Return the title associated with the link being dragged.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_link_title*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Return the metadata, if any, associated with the link being dragged.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_link_metadata*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Return the plain text fragment that is being dragged.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_fragment_text*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Return the text/html fragment that is being dragged.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_fragment_html*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Return the base URL that the fragment came from. This value is used for
    # resolving relative URLs and may be NULL.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_fragment_base_url*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Return the name of the file being dragged out of the browser window.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_file_name*: proc(self: ptr cef_drag_data): cef_string_userfree {.cef_callback.}

    # Write the contents of the file being dragged out of the web view into
    # |writer|. Returns the number of bytes sent to |writer|. If |writer| is NULL
    # this function will return the size of the file contents in bytes. Call
    # get_file_name() to get a suggested name for the file.
    get_file_contents*: proc(self: ptr cef_drag_data,
      writer: ptr cef_stream_writer): csize_t {.cef_callback.}

    # Retrieve the list of file names that are being dragged into the browser
    # window.
    get_file_names*: proc(self: ptr cef_drag_data,
      names: cef_string_list): cint {.cef_callback.}

    # Set the link URL that is being dragged.
    set_link_url*: proc(self: ptr cef_drag_data,
      url: ptr cef_string) {.cef_callback.}

    # Set the title associated with the link being dragged.
    set_link_title*: proc(self: ptr cef_drag_data,
      title: ptr cef_string) {.cef_callback.}

    # Set the metadata associated with the link being dragged.
    set_link_metadata*: proc(self: ptr cef_drag_data,
      data: ptr cef_string) {.cef_callback.}

    # Set the plain text fragment that is being dragged.
    set_fragment_text*: proc(self: ptr cef_drag_data,
      text: ptr cef_string) {.cef_callback.}

    # Set the text/html fragment that is being dragged.
    set_fragment_html*: proc(self: ptr cef_drag_data,
      html: ptr cef_string) {.cef_callback.}

    # Set the base URL that the fragment came from.
    set_fragment_base_url*: proc(self: ptr cef_drag_data,
      base_url: ptr cef_string) {.cef_callback.}

    # Reset the file contents. You should do this before calling
    # cef_browser_host_t::DragTargetDragEnter as the web view does not allow us
    # to drag in this kind of data.
    reset_file_contents*: proc(self: ptr cef_drag_data) {.cef_callback.}

    # Add a file that is being dragged into the webview.
    add_file*: proc(self: ptr cef_drag_data,
      path, display_name: ptr cef_string) {.cef_callback.}