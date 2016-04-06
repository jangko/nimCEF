import cef_base, cef_string_multimap
include cef_import

type
  cef_request* = object
    base*: cef_base
 
    # Returns true (1) if this object is read-only.
    is_read_only*: proc(self: ptr cef_request): cint {.cef_callback.}

    # Get the fully qualified URL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_url*: proc(self: ptr cef_request): cef_string_userfree {.cef_callback.}

    # Set the fully qualified URL.
    set_url*: proc(self: ptr cef_request, url: ptr cef_string) {.cef_callback.}

    # Get the request function type. The value will default to POST if post data
    # is provided and GET otherwise.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_method*: proc(self: ptr cef_request): ptr cef_string_userfree {.cef_callback.}
  
    # Set the request function type.
    set_method*: proc(self: ptr cef_request, pmethod: ptr cef_string) {.cef_callback.}

    # Set the referrer URL and policy. If non-NULL the referrer URL must be fully
    # qualified with an HTTP or HTTPS scheme component. Any username, password or
    # ref component will be removed.
    set_referrer*: proc(self: ptr cef_request,
      referrer_url: ptr cef_string, policy: cef_referrer_policy) {.cef_callback.}

    # Get the referrer URL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_referrer_url*: proc(self: ptr cef_request): cef_string_userfree {.cef_callback.}

    # Get the referrer policy.
    get_referrer_policy*: proc(self: ptr cef_request): cef_referrer_policy {.cef_callback.}

    # Get the post data.
    get_post_data*: proc(self: ptr cef_request): ptr cef_post_data {.cef_callback.}

    # Set the post data.
    set_post_data*: proc(self: ptr cef_request,
      postData: ptr cef_post_data) {.cef_callback.}

    # Get the header values. Will not include the Referer value if any.
    get_header_map*: proc(self: ptr cef_request, headerMap: cef_string_multimap) {.cef_callback.}

    # Set the header values. If a Referer value exists in the header map it will
    # be removed and ignored.
    set_header_map*: proc(self: ptr cef_request,
      headerMap: cef_string_multimap) {.cef_callback.}

    # Set all values at one time.
    set_values*: proc(self: ptr cef_request, url: ptr cef_string,
      pmethod: ptr cef_string, postData: ptr cef_post_data,
      headerMap: cef_string_multimap) {.cef_callback.}

    # Get the flags used in combination with cef_urlrequest_t. See
    # cef_urlrequest_flags_t for supported values.
    get_flags*: proc(self: ptr cef_request): cint {.cef_callback.}

    # Set the flags used in combination with cef_urlrequest_t.  See
    # cef_urlrequest_flags_t for supported values.
    set_flags*: proc(self: ptr cef_request, flags: cint) {.cef_callback.}

    # Set the URL to the first party for cookies used in combination with
    # cef_urlrequest_t.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_first_party_for_cookies*: proc(self: ptr cef_request): cef_string_userfree {.cef_callback.}

    # Get the URL to the first party for cookies used in combination with
    # cef_urlrequest_t.
    set_first_party_for_cookies*: proc(self: ptr cef_request,
      url: ptr cef_string) {.cef_callback.}

    # Get the resource type for this request. Only available in the browser
    # process.
    get_resource_type*: proc(self: ptr cef_request): cef_resource_type {.cef_callback.}
  
    # Get the transition type for this request. Only available in the browser
    # process and only applies to requests that represent a main frame or sub-
    # frame navigation.
    get_transition_type*: proc(self: ptr cef_request): cef_transition_type {.cef_callback.}

    # Returns the globally unique identifier for this request or 0 if not
    # specified. Can be used by cef_request_tHandler implementations in the
    # browser process to track a single request across multiple callbacks.
    get_identifier*: proc(self: ptr cef_request): int64 {.cef_callback.}

  # Structure used to represent post data for a web request. The functions of
  # this structure may be called on any thread.
  cef_post_data* = object
    # Base structure.
    base*: cef_base

    # Returns true (1) if this object is read-only.
    is_read_only*: proc(self: ptr cef_post_data): cint {.cef_callback.}
  
    # Returns true (1) if the underlying POST data includes elements that are not
    # represented by this cef_post_data_t object (for example, multi-part file
    # upload data). Modifying cef_post_data_t objects with excluded elements may
    # result in the request failing.
    has_excluded_elements*: proc(self: ptr cef_post_data): cint {.cef_callback.}

    # Returns the number of existing post data elements.
    get_element_count*: proc(self: ptr cef_post_data): csize {.cef_callback.}
  
    # Retrieve the post data elements.
    get_elements*: proc(self: ptr cef_post_data,
      elementsCount: var csize, elements: ptr ptr cef_post_data_element) {.cef_callback.}

    # Remove the specified post data element.  Returns true (1) if the removal
    # succeeds.
    remove_element*: proc(self: ptr cef_post_data,
      element: ptr cef_post_data_element): cint {.cef_callback.}

    # Add the specified post data element.  Returns true (1) if the add succeeds.
    add_element*: proc(self: ptr cef_post_data,
      element: ptr cef_post_data_element): cint {.cef_callback.}

    # Remove all existing post data elements.
    remove_elements*: proc(self: ptr cef_post_data) {.cef_callback.}

  # Structure used to represent a single element in the request post data. The
  # functions of this structure may be called on any thread.
  cef_post_data_element* = object
    # Base structure.
    base*: cef_base
  
    # Returns true (1) if this object is read-only.
    is_read_only*: proc(self: ptr cef_post_data_element): cint {.cef_callback.}

    # Remove all contents from the post data element.
    set_to_empty*: proc(self: ptr cef_post_data_element) {.cef_callback.}

    # The post data element will represent a file.
    set_to_file*: proc(self: ptr cef_post_data_element,
      fileName: ptr cef_string) {.cef_callback.}

    # The post data element will represent bytes.  The bytes passed in will be
    # copied.
    set_to_bytes*: proc(self: ptr cef_post_data_element,
      size: csize, bytes: pointer) {.cef_callback.}

    # Return the type of this post data element.
    get_type*: proc(self: ptr cef_post_data_element): cef_postdataelement_type {.cef_callback.}

    # Return the file name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_file*: proc(self: ptr cef_post_data_element): cef_string_userfree {.cef_callback.}
  
    # Return the number of bytes.
    get_bytes_count*: proc(self: ptr cef_post_data_element): csize {.cef_callback.}

    # Read up to |size| bytes into |bytes| and return the number of bytes
    # actually read.
    get_bytes*: proc(self: ptr cef_post_data_element,
      size: csize, bytes: pointer): csize {.cef_callback.}


# Create a new cef_post_data_element_t object.
proc cef_post_data_element_create*(): ptr cef_post_data_element {.cef_import.}

# Create a new cef_request_t object.
proc cef_request_create*(): ptr cef_request {.cef_import.}

# Create a new cef_post_data_t object.
proc cef_post_data_create*(): ptr cef_post_data {.cef_import.}
