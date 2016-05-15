import nc_util, cef/cef_types, cef/cef_string_multimap_api

# Structure used to represent a web request. The functions of this structure
# may be called on any thread.
wrapAPI(NCRequest, cef_request)

# Structure used to represent post data for a web request. The functions of
# this structure may be called on any thread.
wrapAPI(NCPostData, cef_post_data, false)

# Structure used to represent a single element in the request post data. The
# functions of this structure may be called on any thread.
wrapAPI(NCPostDataElement, cef_post_data_element, false)

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCRequest): bool =
  self.wrapCall(is_read_only, result)

# Get the fully qualified URL.
proc GetUrl*(self: NCRequest): string =
  self.wrapCall(get_url, result)

# Set the fully qualified URL.
proc SetUrl*(self: NCRequest, url: string) =
  self.wrapCall(set_url, url)

# Get the request function type. The value will default to POST if post data
# is provided and GET otherwise.
proc GetMethod*(self: NCRequest): string =
  self.wrapCall(get_method, result)

# Set the request function type.
proc SetMethod*(self: NCRequest, the_method: string) =
  self.wrapCall(set_method, the_method)

# Set the referrer URL and policy. If non-NULL the referrer URL must be fully
# qualified with an HTTP or HTTPS scheme component. Any username, password or
# ref component will be removed.
proc SetReferrer*(self: NCRequest, referrer_url: string, policy: cef_referrer_policy) =
  self.wrapCall(set_referrer, referrer_url, policy)

# Get the referrer URL.
proc GetReferrer_url*(self: NCRequest): string =
  self.wrapCall(get_referrer_url, result)

# Get the referrer policy.
proc Getreferrer_policy*(self: NCRequest): cef_referrer_policy =
  self.wrapCall(get_referrer_policy, result)

# Get the post data.
proc GetPostData*(self: NCRequest): NCPostData =
  self.wrapCall(get_post_data, result)

# Set the post data.
proc SetPostData*(self: NCRequest, postData: NCPostData) =
  self.wrapCall(set_post_data, postData)

# Get the header values. Will not include the Referer value if any.
proc GetHeaderMap*(self: NCRequest): NCStringMultiMap =
  self.wrapCall(get_header_map, result)

# Set the header values. If a Referer value exists in the header map it will
# be removed and ignored.
proc SetHeaderMap*(self: NCRequest, headerMap: NCStringMultiMap) =
  self.wrapCall(set_header_map, headerMap)

# Set all values at one time.
proc SetValues*(self: NCRequest, url: string, the_method: string, postData: NCPostData, headerMap: NCStringMultiMap) =
  self.wrapCall(set_values, url, the_method, postData, headerMap)

# Get the flags used in combination with cef_urlrequest_t. See
# cef_urlrequest_flags_t for supported values.
proc GetFlags*(self: NCRequest): int =
  self.wrapCall(get_flags, result)

# Set the flags used in combination with cef_urlrequest_t.  See
# cef_urlrequest_flags_t for supported values.
proc SetFlags*(self: NCRequest, flags: int) =
  self.wrapCall(set_flags, flags)

# Set the URL to the first party for cookies used in combination with
# cef_urlrequest_t.
proc GetFirstPartyForCookies*(self: NCRequest): string =
  self.wrapCall(get_first_party_for_cookies, result)

# Get the URL to the first party for cookies used in combination with
# cef_urlrequest_t.
proc SetFirstPartyForCookies*(self: NCRequest, url: string) =
  self.wrapCall(set_first_party_for_cookies, url)

# Get the resource type for this request. Only available in the browser
# process.
proc GetResourceType*(self: NCRequest): cef_resource_type =
  self.wrapCall(get_resource_type, result)

# Get the transition type for this request. Only available in the browser
# process and only applies to requests that represent a main frame or sub-
# frame navigation.
proc GetTransitionType*(self: NCRequest): cef_transition_type =
  self.wrapCall(get_transition_type, result)

# Returns the globally unique identifier for this request or 0 if not
# specified. Can be used by cef_request_tHandler implementations in the
# browser process to track a single request across multiple callbacks.
proc GetIdentifier*(self: NCRequest): int64 =
  self.wrapCall(get_identifier, result)

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCPostData): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if the underlying POST data includes elements that are not
# represented by this cef_post_data_t object (for example, multi-part file
# upload data). Modifying cef_post_data_t objects with excluded elements may
# result in the request failing.
proc HasExcludedElements*(self: NCPostData): bool =
  self.wrapCall(has_excluded_elements, result)

# Returns the number of existing post data elements.
proc GetElementCount*(self: NCPostData): int =
  self.wrapCall(get_element_count, result)

# Retrieve the post data elements.
proc GetElements*(self: NCPostData): seq[NCPostDataElement] =
  var size = self.GetElementCount()
  self.wrapCall(get_elements, result, size)

# Remove the specified post data element.  Returns true (1) if the removal
# succeeds.
proc RemoveElement*(self: NCPostData, element: NCPostDataElement): bool =
  self.wrapCall(remove_element, result, element)

# Add the specified post data element.  Returns true (1) if the add succeeds.
proc AddElement*(self: NCPostData, element: NCPostDataElement): bool =
  self.wrapCall(add_element, result, element)

# Remove all existing post data elements.
proc RemoveElements*(self: NCPostData) =
  self.wrapCall(remove_elements)

# Returns true (1) if this object is read-only.
proc IsReadOnly*(self: NCPostDataElement): bool =
  self.wrapCall(is_read_only, result)

# Remove all contents from the post data element.
proc SetToEmpty*(self: NCPostDataElement) =
  self.wrapCall(set_to_empty)

# The post data element will represent a file.
proc SetToFile*(self: NCPostDataElement, fileName: string) =
  self.wrapCall(set_to_file, fileName)

# The post data element will represent bytes.  The bytes passed in will be
# copied.
proc SetToBytes*(self: NCPostDataElement, size: int, bytes: pointer) =
  self.wrapCall(set_to_bytes, size, bytes)

# Return the type of this post data element.
proc GetType*(self: NCPostDataElement): cef_postdataelement_type =
  self.wrapCall(get_type, result)

# Return the file name.
proc GetFile*(self: NCPostDataElement): string =
  self.wrapCall(get_file, result)

# Return the number of bytes.
proc GetBytesCount*(self: NCPostDataElement): int =
  self.wrapCall(get_bytes_count, result)

# Read up to |size| bytes into |bytes| and return the number of bytes
# actually read.
proc GetBytes*(self: NCPostDataElement, size: int, bytes: pointer): int =
  self.wrapCall(get_bytes, result, size, bytes)

proc GetBytes*(self: NCPostDataElement): string =
  let len = self.GetBytesCount()
  result = newString(len)
  let read = self.GetBytes(len, result.cstring)
  result.setLen(read)

# Create a new cef_post_data_element_t object.
proc NCPostDataElementCreate*(): NCPostDataElement =
  wrapProc(cef_post_data_element_create, result)

# Create a new cef_request_t object.
proc NCRequestCreate*(): NCRequest =
  wrapProc(cef_request_create, result)

# Create a new cef_post_data_t object.
proc NCPostDataCreate*(): NCPostData =
  wrapProc(cef_post_data_create, result)
