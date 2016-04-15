import cef/cef_navigation_entry_api, cef/cef_time_api, nc_util, cef/cef_types

type
  # Structure used to represent an entry in navigation history.
  NCNavigationEntry* = ptr cef_navigation_entry


# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc is_valid*(self: NCNavigationEntry): bool =
  result = self.is_valid(self) == 1.cint

# Returns the actual URL of the page. For some pages this may be data: URL or
# similar. Use get_display_url() to return a display-friendly version.
# The resulting string must be freed by calling string_free().
proc get_url*(self: NCNavigationEntry): string =
  result = to_nim_string(self.get_url(self))

# Returns a display-friendly version of the URL.
# The resulting string must be freed by calling string_free().
proc get_display_url*(self: NCNavigationEntry): string =
  result = to_nim_string(self.get_display_url(self))

# Returns the original URL that was entered by the user before any redirects.
# The resulting string must be freed by calling string_free().
proc get_original_url*(self: NCNavigationEntry): string =
  result = to_nim_string(self.get_original_url(self))

# Returns the title set by the page. This value may be NULL.
# The resulting string must be freed by calling string_free().
proc get_title*(self: NCNavigationEntry): string =
  result = to_nim_string(self.get_title(self))

# Returns the transition type which indicates what the user did to move to
# this page from the previous page.
proc get_transition_type*(self: NCNavigationEntry): cef_transition_type =
  result = self.get_transition_type(self)

# Returns true (1) if this navigation includes post data.
proc has_post_data*(self: NCNavigationEntry): bool =
  result = self.has_post_data(self) == 1.cint

# Returns the time for the last known successful navigation completion. A
# navigation may be completed more than once if the page is reloaded. May be
# 0 if the navigation has not yet completed.
proc get_completion_time*(self: NCNavigationEntry): cef_time =
  result = self.get_completion_time(self)

# Returns the HTTP status code for the last known successful navigation
# response. May be 0 if the response has not yet been received or if the
# navigation has not yet completed.
proc get_http_status_code*(self: NCNavigationEntry): bool =
  result = self.get_http_status_code(self) == 1.cint
