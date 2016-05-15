import cef/cef_drag_data_api, nc_util, nc_stream

type
  # Structure used to represent drag data. The functions of this structure may be
  # called on any thread.
  NCDragData* = ptr cef_drag_data

# Returns a copy of the current object.
proc Clone*(self: NCDragData): NCDragData =
  result = self.clone(self)

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCDragData): bool =
  result = self.is_read_only(self) == 1.cint

# Returns true (1) if the drag data is a link.
proc IsLink*(self: NCDragData): bool =
  result = self.is_link(self) == 1.cint

# Returns true (1) if the drag data is a text or html fragment.
proc IsFragment*(self: NCDragData): bool =
  result = self.is_fragment(self) == 1.cint

# Returns true (1) if the drag data is a file.
proc IsFile*(self: NCDragData): bool =
  result = self.is_file(self) == 1.cint

# Return the link URL that is being dragged.
# The resulting string must be freed by calling string_free().
proc GetLinkUrl*(self: NCDragData): string =
  result = to_nim(self.get_link_url(self))

# Return the title associated with the link being dragged.
# The resulting string must be freed by calling string_free().
proc GetLinkTitle*(self: NCDragData): string =
  result = to_nim(self.get_link_title(self))

# Return the metadata, if any, associated with the link being dragged.
# The resulting string must be freed by calling string_free().
proc GetLinkMetadata*(self: NCDragData): string =
  result = to_nim(self.get_link_metadata(self))

# Return the plain text fragment that is being dragged.
# The resulting string must be freed by calling string_free().
proc GetFragmentText*(self: NCDragData): string =
  result = to_nim(self.get_fragment_text(self))

# Return the text/html fragment that is being dragged.
# The resulting string must be freed by calling string_free().
proc GetFragmentHtml*(self: NCDragData): string =
  result = to_nim(self.get_fragment_html(self))

# Return the base URL that the fragment came from. This value is used for
# resolving relative URLs and may be NULL.
# The resulting string must be freed by calling string_free().
proc GetFragmentBaseUrl*(self: NCDragData): string =
  result = to_nim(self.get_fragment_base_url(self))

# Return the name of the file being dragged out of the browser window.
# The resulting string must be freed by calling string_free().
proc GetFileName*(self: NCDragData): string =
  result = to_nim(self.get_file_name(self))

# Write the contents of the file being dragged out of the web view into
# |writer|. Returns the number of bytes sent to |writer|. If |writer| is NULL
# this function will return the size of the file contents in bytes. Call
# get_file_name() to get a suggested name for the file.
proc GetFileContents*(self: NCDragData, writer: NCStreamWriter): int =
  add_ref(writer)
  result = self.get_file_contents(self, writer).int

# Retrieve the list of file names that are being dragged into the browser
# window.
proc GetFileNames*(self: NCDragData): seq[string] =
  var list = cef_string_list_alloc()
  if self.get_file_names(self, list) == 1.cint:
    result = to_nim(list)
  else:
    nc_free(list)
    result = @[]

# Set the link URL that is being dragged.
proc SetLinkUrl*(self: NCDragData, url: string) =
  let curl = to_cef(url)
  self.set_link_url(self, curl)
  nc_free(curl)

# Set the title associated with the link being dragged.
proc SetLinkTitle*(self: NCDragData, title: string) =
  let ctitle = to_cef(title)
  self.set_link_title(self, ctitle)
  nc_free(ctitle)

# Set the metadata associated with the link being dragged.
proc SetLinkMetadata*(self: NCDragData, data: string) =
  let cdata = to_cef(data)
  self.set_link_metadata(self, cdata)
  nc_free(cdata)

# Set the plain text fragment that is being dragged.
proc SetFragmentText*(self: NCDragData, text: string) =
  let ctext = to_cef(text)
  self.set_fragment_text(self, ctext)
  nc_free(ctext)

# Set the text/html fragment that is being dragged.
proc SetFragmentHtml*(self: NCDragData, html: string) =
  let chtml = to_cef(html)
  self.set_fragment_html(self, chtml)
  nc_free(chtml)

# Set the base URL that the fragment came from.
proc SetFragmentBaseUrl*(self: NCDragData, base_url: string) =
  let curl = to_cef(base_url)
  self.set_fragment_base_url(self, curl)
  nc_free(curl)

# Reset the file contents. You should do this before calling
# cef_browser_host_t::DragTargetDragEnter as the web view does not allow us
# to drag in this kind of data.
proc ResetFileContents*(self: NCDragData) =
  self.reset_file_contents(self)

# Add a file that is being dragged into the webview.
proc AddFile*(self: NCDragData, path, display_name: string) =
  let cpath = to_cef(path)
  let cname = to_cef(display_name)
  self.add_file(self, cpath, cname)
  nc_free(cpath)
  nc_free(cname)