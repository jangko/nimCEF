import nc_util, nc_stream

# Structure used to represent drag data. The functions of this structure may be
# called on any thread.
wrapAPI(NCDragData, cef_drag_data)

# Returns a copy of the current object.
proc clone*(self: NCDragData): NCDragData =
  self.wrapCall(clone, result)

# Returns true (1) if this object is read-only.
proc isReadOnly*(self: NCDragData): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if the drag data is a link.
proc isLink*(self: NCDragData): bool =
  self.wrapCall(is_link, result)

# Returns true (1) if the drag data is a text or html fragment.
proc isFragment*(self: NCDragData): bool =
  self.wrapCall(is_fragment, result)

# Returns true (1) if the drag data is a file.
proc isFile*(self: NCDragData): bool =
  self.wrapCall(is_file, result)

# Return the link URL that is being dragged.
proc getLinkUrl*(self: NCDragData): string =
  self.wrapCall(get_link_url, result)

# Return the title associated with the link being dragged.
proc getLinkTitle*(self: NCDragData): string =
  self.wrapCall(get_link_title, result)

# Return the metadata, if any, associated with the link being dragged.
proc getLinkMetadata*(self: NCDragData): string =
  self.wrapCall(get_link_metadata, result)

# Return the plain text fragment that is being dragged.
proc getFragmentText*(self: NCDragData): string =
  self.wrapCall(get_fragment_text, result)

# Return the text/html fragment that is being dragged.
proc getFragmentHtml*(self: NCDragData): string =
  self.wrapCall(get_fragment_html, result)

# Return the base URL that the fragment came from. This value is used for
# resolving relative URLs and may be NULL.
proc getFragmentBaseUrl*(self: NCDragData): string =
  self.wrapCall(get_fragment_base_url, result)

# Return the name of the file being dragged out of the browser window.
proc getFileName*(self: NCDragData): string =
  self.wrapCall(get_file_name, result)

# Write the contents of the file being dragged out of the web view into
# |writer|. Returns the number of bytes sent to |writer|. If |writer| is NULL
# this function will return the size of the file contents in bytes. Call
# get_file_name() to get a suggested name for the file.
proc getFileContents*(self: NCDragData, writer: NCStreamWriter): int =
  self.wrapCall(get_file_contents, result, writer)

# Retrieve the list of file names that are being dragged into the browser
# window.
proc getFileNames*(self: NCDragData): seq[string] =
  self.wrapCall(get_file_names, result)

# Set the link URL that is being dragged.
proc setLinkUrl*(self: NCDragData, url: string) =
  self.wrapCall(set_link_url, url)

# Set the title associated with the link being dragged.
proc setLinkTitle*(self: NCDragData, title: string) =
  self.wrapCall(set_link_title, title)

# Set the metadata associated with the link being dragged.
proc setLinkMetadata*(self: NCDragData, data: string) =
  self.wrapCall(set_link_metadata, data)

# Set the plain text fragment that is being dragged.
proc setFragmentText*(self: NCDragData, text: string) =
  self.wrapCall(set_fragment_text, text)

# Set the text/html fragment that is being dragged.
proc setFragmentHtml*(self: NCDragData, html: string) =
  self.wrapCall(set_fragment_html, html)

# Set the base URL that the fragment came from.
proc setFragmentBaseUrl*(self: NCDragData, base_url: string) =
  self.wrapCall(set_fragment_base_url, base_url)

# Reset the file contents. You should do this before calling
# NCBrowserHost::DragTargetDragEnter as the web view does not allow us
# to drag in this kind of data.
proc resetFileContents*(self: NCDragData) =
  self.wrapCall(reset_file_contents)

# Add a file that is being dragged into the webview.
proc addFile*(self: NCDragData, path, display_name: string) =
  self.wrapCall(add_file, path, display_name)
