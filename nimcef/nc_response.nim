import nc_util, nc_types

# Structure used to represent a web response. The functions of this structure
# may be called on any thread.
wrapAPI(NCResponse, cef_response)

# Returns true (1) if this object is read-only.
proc isReadOnly*(self: NCResponse): bool =
  self.wrapCall(is_read_only, result)

# Get the response error code. Returns ERR_NONE if there was no error.
proc getError*(self: NCResponse): cef_error_code =
  self.wrapCall(get_error, result)
  
# Set the response error code. This can be used by custom scheme handlers to
# return errors during initial request processing.
proc setError*(self: NCResponse, error: cef_error_code) =
  self.wrapCall(set_error, error)
    
# Get the response status code.
proc getStatus*(self: NCResponse): int =
  self.wrapCall(get_status, result)

# Set the response status code.
proc setStatus*(self: NCResponse, status: int) =
  self.wrapCall(set_status, status)

# Get the response status text.
proc getStatusText*(self: NCResponse): string =
  self.wrapCall(get_status_text, result)

# Set the response status text.
proc setStatusText*(self: NCResponse, statusText: string) =
  self.wrapCall(set_status_text, statusText)

# Get the response mime type.
proc getMimeType*(self: NCResponse): string =
  self.wrapCall(get_mime_type, result)

# Set the response mime type.
proc setMimeType*(self: NCResponse, mimeType: string) =
  self.wrapCall(set_mime_type, mimeType)

# Get the value for the specified response header field.
proc getHeader*(self: NCResponse, name: string): string =
  self.wrapCall(get_header, result, name)

# Get all response header fields.
proc getHeaderMap*(self: NCResponse): NCStringMultiMap =
  self.wrapCall(get_header_map, result)

# Set all response header fields.
proc setHeaderMap*(self: NCResponse, headerMap: NCStringMultiMap) =
  self.wrapCall(set_header_map, headerMap)

# Create a new cef_response_t object.
proc ncResponseCreate*(): NCResponse =
  wrapProc(cef_response_create, result)

