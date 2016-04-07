import cef_string_api
include cef_import

# CEF string maps are a set of key/value string pairs.
type
  cef_string_map* = distinct pointer

# Allocate a new string map.
proc cef_string_map_alloc*(): cef_string_map {.cef_import.}

# Return the number of elements in the string map.
proc cef_string_map_size*(map: cef_string_map): cint {.cef_import.}

# Return the value assigned to the specified key.
proc cef_string_map_find*(map: cef_string_map, key, value: ptr cef_string): cint {.cef_import.}

# Return the key at the specified zero-based string map index.
proc cef_string_map_key*(map: cef_string_map, index: cint, key: ptr cef_string): cint {.cef_import.}

# Return the value at the specified zero-based string map index.
proc cef_string_map_value*(map: cef_string_map, index: cint, value: ptr cef_string): cint {.cef_import.}

# Append a new key/value pair at the end of the string map.
proc cef_string_map_append*(map: cef_string_map, key, value: ptr cef_string): cint {.cef_import.}

# Clear the string map.
proc cef_string_map_clear*(map: cef_string_map) {.cef_import.}

# Free the string map.
proc cef_string_map_free*(map: cef_string_map) {.cef_import.}
