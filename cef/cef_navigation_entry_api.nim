import cef_base_api, cef_time_api
include cef_import

type
  # Structure used to represent an entry in navigation history.
  cef_navigation_entry* = object of cef_base
    # Returns true (1) if this object is valid. Do not call any other functions
    # if this function returns false (0).
    is_valid*: proc(self: ptr cef_navigation_entry): cint {.cef_callback.}

    # Returns the actual URL of the page. For some pages this may be data: URL or
    # similar. Use get_display_url() to return a display-friendly version.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_url*: proc(self: ptr cef_navigation_entry): cef_string_userfree {.cef_callback.}

    # Returns a display-friendly version of the URL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_display_url*: proc(self: ptr cef_navigation_entry): cef_string_userfree {.cef_callback.}

    # Returns the original URL that was entered by the user before any redirects.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_original_url*: proc(self: ptr cef_navigation_entry): cef_string_userfree {.cef_callback.}

    # Returns the title set by the page. This value may be NULL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_title*: proc(self: ptr cef_navigation_entry): cef_string_userfree {.cef_callback.}

    # Returns the transition type which indicates what the user did to move to
    # this page from the previous page.

    get_transition_type*: proc(self: ptr cef_navigation_entry): cef_transition_type {.cef_callback.}

    # Returns true (1) if this navigation includes post data.
    has_post_data*: proc(self: ptr cef_navigation_entry): cint {.cef_callback.}

    # Returns the time for the last known successful navigation completion. A
    # navigation may be completed more than once if the page is reloaded. May be
    # 0 if the navigation has not yet completed.
    get_completion_time*: proc(self: ptr cef_navigation_entry): cef_time {.cef_callback.}

    # Returns the HTTP status code for the last known successful navigation
    # response. May be 0 if the response has not yet been received or if the
    # navigation has not yet completed.
    get_http_status_code*: proc(self: ptr cef_navigation_entry): cint {.cef_callback.}

