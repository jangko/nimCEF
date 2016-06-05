import nc_time, nc_util, cef/cef_types

# Structure used to represent an entry in navigation history.
wrapAPI(NCNavigationEntry, cef_navigation_entry)

# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCNavigationEntry): bool =
  self.wrapCall(is_valid, result)

# Returns the actual URL of the page. For some pages this may be data: URL or
# similar. Use get_display_url() to return a display-friendly version.
proc GetUrl*(self: NCNavigationEntry): string =
  self.wrapCall(get_url, result)

# Returns a display-friendly version of the URL.
proc GetDisplayUrl*(self: NCNavigationEntry): string =
  self.wrapCall(get_display_url, result)

# Returns the original URL that was entered by the user before any redirects.
proc GetOriginalUrl*(self: NCNavigationEntry): string =
  self.wrapCall(get_original_url, result)

# Returns the title set by the page. This value may be NULL.
proc GetTitle*(self: NCNavigationEntry): string =
  self.wrapCall(get_title, result)

# Returns the transition type which indicates what the user did to move to
# this page from the previous page.
proc GetTransitionType*(self: NCNavigationEntry): cef_transition_type =
  self.wrapCall(get_transition_type, result)

# Returns true (1) if this navigation includes post data.
proc HasPostData*(self: NCNavigationEntry): bool =
  self.wrapCall(has_post_data, result)

# Returns the time for the last known successful navigation completion. A
# navigation may be completed more than once if the page is reloaded. May be
# 0 if the navigation has not yet completed.
proc GetCompletionTime*(self: NCNavigationEntry): NCTime =
  self.wrapCall(get_completion_time, result)

# Returns the HTTP status code for the last known successful navigation
# response. May be 0 if the response has not yet been received or if the
# navigation has not yet completed.
proc GetHttpStatusCode*(self: NCNavigationEntry): bool =
  self.wrapCall(get_http_status_code, result)
