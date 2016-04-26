import cef/cef_request_api, nc_util, cef/cef_types, cef/cef_string_multimap_api

type
  # Structure used to represent a web request. The functions of this structure
  # may be called on any thread.
  NCRequest* = ptr cef_request

  # Structure used to represent post data for a web request. The functions of
  # this structure may be called on any thread.
  NCPostData* = ptr cef_post_data

  # Structure used to represent a single element in the request post data. The
  # functions of this structure may be called on any thread.
  NCPostDataElement* = ptr cef_post_data_element

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCRequest): bool =
  result = self.is_read_only(self) == 1.cint

# Get the fully qualified URL.
# The resulting string must be freed by calling string_free().
proc GetUrl*(self: NCRequest): string =
  result = to_nim(self.get_url(self))

# Set the fully qualified URL.
proc SetUrl*(self: NCRequest, url: string) =
  let curl = to_cef(url)
  self.set_url(self, curl)
  nc_free(curl)

# Get the request function type. The value will default to POST if post data
# is provided and GET otherwise.
# The resulting string must be freed by calling string_free().
proc GetMethod*(self: NCRequest): string =
  result = to_nim(self.get_method(self))

# Set the request function type.
proc SetMethod*(self: NCRequest, pmethod: string) =
  let cmethod = to_cef(pmethod)
  self.set_method(self, cmethod)
  nc_free(cmethod)

# Set the referrer URL and policy. If non-NULL the referrer URL must be fully
# qualified with an HTTP or HTTPS scheme component. Any username, password or
# ref component will be removed.
proc SetReferrer*(self: NCRequest, referrer_url: string, policy: cef_referrer_policy) =
  let curl = to_cef(referrer_url)
  self.set_referrer(self, curl, policy)
  nc_free(curl)

# Get the referrer URL.
# The resulting string must be freed by calling string_free().
proc GetReferrer_url*(self: NCRequest): string =
  result = to_nim(self.get_referrer_url(self))

# Get the referrer policy.
proc Getreferrer_policy*(self: NCRequest): cef_referrer_policy =
  result = self.get_referrer_policy(self)

# Get the post data.
proc GetPostData*(self: NCRequest): NCPostData =
  result = self.get_post_data(self)

# Set the post data.
proc SetPostData*(self: NCRequest, postData: NCPostData) =
  add_ref(postData)
  self.set_post_data(self, postData)

# Get the header values. Will not include the Referer value if any.
proc GetHeaderMap*(self: NCRequest): NCStringMultiMap =
  var map = cef_string_multimap_alloc()
  self.get_header_map(self, map)
  result = to_nim(map)

# Set the header values. If a Referer value exists in the header map it will
# be removed and ignored.
proc SetHeaderMap*(self: NCRequest, headerMap: NCStringMultiMap) =
  let cmap = to_cef(headerMap)
  self.set_header_map(self, cmap)
  cef_string_multimap_free(cmap)

# Set all values at one time.
proc SetValues*(self: NCRequest, url: string, pmethod: string, postData: NCPostData, headerMap: NCStringMultiMap) =
  add_ref(postData)
  let curl = to_cef(url)
  let cmethod = to_cef(pmethod)
  let cmap = to_cef(headerMap)
  self.set_values(self, curl, cmethod, postData, cmap)
  nc_free(curl)
  nc_free(cmethod)
  cef_string_multimap_free(cmap)

# Get the flags used in combination with cef_urlrequest_t. See
# cef_urlrequest_flags_t for supported values.
proc GetFlags*(self: NCRequest): int =
  result = self.get_flags(self).int

# Set the flags used in combination with cef_urlrequest_t.  See
# cef_urlrequest_flags_t for supported values.
proc SetFlags*(self: NCRequest, flags: int) =
  self.set_flags(self, flags.cint)

# Set the URL to the first party for cookies used in combination with
# cef_urlrequest_t.
# The resulting string must be freed by calling string_free().
proc GetFirstPartyForCookies*(self: NCRequest): string =
  result = to_nim(self.get_first_party_for_cookies(self))

# Get the URL to the first party for cookies used in combination with
# cef_urlrequest_t.
proc SetFirstPartyForCookies*(self: NCRequest, url: string) =
  let curl = to_cef(url)
  self.set_first_party_for_cookies(self, curl)
  nc_free(curl)

# Get the resource type for this request. Only available in the browser
# process.
proc GetResourceType*(self: NCRequest): cef_resource_type =
  result = self.get_resource_type(self)

# Get the transition type for this request. Only available in the browser
# process and only applies to requests that represent a main frame or sub-
# frame navigation.
proc GetTransitionType*(self: NCRequest): cef_transition_type =
  result = self.get_transition_type(self)

# Returns the globally unique identifier for this request or 0 if not
# specified. Can be used by cef_request_tHandler implementations in the
# browser process to track a single request across multiple callbacks.
proc GetIdentifier*(self: NCRequest): int64 =
  result = self.get_identifier(self)

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCPostData): bool =
  result = self.is_read_only(self) == 1.cint

# Returns true (1) if the underlying POST data includes elements that are not
# represented by this cef_post_data_t object (for example, multi-part file
# upload data). Modifying cef_post_data_t objects with excluded elements may
# result in the request failing.
proc HasExcludedElements*(self: NCPostData): bool =
  result = self.has_excluded_elements(self) == 1.cint

# Returns the number of existing post data elements.
proc GetElementCount*(self: NCPostData): int =
  result = self.get_element_count(self).int

# Retrieve the post data elements.
proc GetElements*(self: NCPostData): seq[NCPostDataElement] =
  result = newSeq[NCPostDataElement](self.GetElementCount())
  var buf = cast[ptr NCPostDataElement](result[0].addr)
  var size = result.len.csize
  self.get_elements(self, size, buf)

# Remove the specified post data element.  Returns true (1) if the removal
# succeeds.
proc RemoveElement*(self: NCPostData, element: NCPostDataElement): bool =
  add_ref(element)
  result = self.remove_element(self, element) == 1.cint

# Add the specified post data element.  Returns true (1) if the add succeeds.
proc AddElement*(self: NCPostData, element: NCPostDataElement): bool =
  add_ref(element)
  result = self.add_element(self, element) == 1.cint

# Remove all existing post data elements.
proc RemoveElements*(self: NCPostData) =
  self.remove_elements(self)

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCPostDataElement): bool =
  result = self.is_read_only(self) == 1.cint

# Remove all contents from the post data element.
proc SetToEmpty*(self: NCPostDataElement) =
  self.set_to_empty(self)

# The post data element will represent a file.
proc SetToFile*(self: NCPostDataElement, fileName: string) =
  let cname = to_cef(fileName)
  self.set_to_file(self, cname)
  nc_free(cname)

# The post data element will represent bytes.  The bytes passed in will be
# copied.
proc SetToBytes*(self: NCPostDataElement, size: int, bytes: pointer) =
  self.set_to_bytes(self, size.csize, bytes)

# Return the type of this post data element.
proc GetType*(self: NCPostDataElement): cef_postdataelement_type =
  result = self.get_type(self)

# Return the file name.
# The resulting string must be freed by calling string_free().
proc GetFile*(self: NCPostDataElement): string =
  result = to_nim(self.get_file(self))

# Return the number of bytes.
proc GetBytesCount*(self: NCPostDataElement): int =
  result = self.get_bytes_count(self).int

# Read up to |size| bytes into |bytes| and return the number of bytes
# actually read.
proc GetBytes*(self: NCPostDataElement, size: int, bytes: pointer): int =
  result = self.get_bytes(self, size.csize, bytes).int

proc GetBytes*(self: NCPostDataElement): string =
  let len = self.get_bytes_count(self)
  result = newString(len.int)
  discard self.get_bytes(self, len, result.cstring)

# Create a new cef_post_data_element_t object.
proc NCPostDataElementCreate*(): NCPostDataElement = cef_post_data_element_create()

# Create a new cef_request_t object.
proc NCRequestCreate*(): NCRequest = cef_request_create()

# Create a new cef_post_data_t object.
proc NCPostDataCreate*(): NCPostData = cef_post_data_create()
