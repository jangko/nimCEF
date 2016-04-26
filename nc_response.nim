import cef/cef_response_api, cef/cef_string_multimap_api, nc_util

type
  # Structure used to represent a web response. The functions of this structure
  # may be called on any thread.
  NCResponse* = ptr cef_response
  
# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCResponse): bool =
  result = self.is_read_only(self) == 1.cint

# Get the response status code.
proc GetStatus*(self: NCResponse): int =
  result = self.get_status(self).int

# Set the response status code.
proc SetStatus*(self: NCResponse, status: int) =
  self.set_status(self, status.cint)

# Get the response status text.
# The resulting string must be freed by calling string_free().
proc GetStatusText*(self: NCResponse): string =
  result = to_nim(self.get_status_text(self))

# Set the response status text.
proc SetStatusText*(self: NCResponse, statusText: string) =
  let cstatus = to_cef(statusText)
  self.set_status_text(self, cstatus)
  nc_free(cstatus)

# Get the response mime type.
# The resulting string must be freed by calling string_free().
proc GetMimeType*(self: NCResponse): string =
  result = to_nim(self.get_mime_type(self))

# Set the response mime type.
proc SetMimeType*(self: NCResponse, mimeType: string) =
  let cmime = to_cef(mimeType)
  self.set_mime_type(self, cmime)
  nc_free(cmime)

# Get the value for the specified response header field.
# The resulting string must be freed by calling string_free().
proc GetHeader*(self: NCResponse, name: string): string =
  let cname = to_cef(name)
  result = to_nim(self.get_header(self, cname))
  nc_free(cname)

# Get all response header fields.
proc GetHeaderMap*(self: NCResponse): NCStringMultiMap =
  var map = cef_string_multimap_alloc()
  self.get_header_map(self, map)
  result = to_nim(map)
  
# Set all response header fields.
proc SetHeaderMap*(self: NCResponse, headerMap: NCStringMultiMap) =
  let cmap = to_cef(headerMap)
  self.set_header_map(self, cmap)
  cef_string_multimap_free(cmap)

# Create a new cef_response_t object.
proc NCResponseCreate*(): NCResponse =
  result = cef_response_create()

