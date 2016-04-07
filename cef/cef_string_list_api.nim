import cef_string_api
include cef_import

# CEF string maps are a set of key/value string pairs.
type
  cef_string_list* = distinct pointer

# Allocate a new string map.
proc cef_string_list_alloc*(): cef_string_list {.cef_import.}

# Return the number of elements in the string list.
proc cef_string_list_size*(list: cef_string_list): cint {.cef_import.}

# Retrieve the value at the specified zero-based string list index. Returns
# true (1) if the value was successfully retrieved.
proc cef_string_list_value*(list: cef_string_list, index: cint, value: ptr cef_string): cint {.cef_import.}

# Append a new value at the end of the string list.
proc cef_string_list_append*(list: cef_string_list, value: ptr cef_string) {.cef_import.}

# Clear the string list.
proc cef_string_list_clear*(list: cef_string_list) {.cef_import.}

# Free the string list.
proc cef_string_list_free*(list: cef_string_list) {.cef_import.}

# Creates a copy of an existing string list.
proc cef_string_list_copy*(list: cef_string_list): cef_string_list {.cef_import.}
