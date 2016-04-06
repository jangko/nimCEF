import cef_base
include cef_import

# CEF string multimaps are a set of key/value string pairs.
# More than one value can be assigned to a single key.

type
  cef_string_multimap* = distinct pointer

# Allocate a new string multimap.
proc cef_string_multimap_alloc*(): cef_string_multimap {.cef_import.}

# Return the number of elements in the string multimap.
proc cef_string_multimap_size*(map: cef_string_multimap): int {.cef_import.}


# Return the number of values with the specified key.
proc cef_string_multimap_find_count*(map: cef_string_multimap, key: ptr cef_string): int {.cef_import.}


# Return the value_index-th value with the specified key.
proc cef_string_multimap_enumerate*(map: cef_string_multimap,
                                             key: ptr cef_string,
                                             value_index: int,
                                             value: ptr cef_string): int {.cef_import.}


# Return the key at the specified zero-based string multimap index.
proc cef_string_multimap_key*(map: cef_string_multimap, index: int,
                                       key: ptr cef_string): int {.cef_import.}


# Return the value at the specified zero-based string multimap index.
proc cef_string_multimap_value*(map: cef_string_multimap, index: int,
                                         value: ptr cef_string): int {.cef_import.}


# Append a new key/value pair at the end of the string multimap.
proc cef_string_multimap_append*(map: cef_string_multimap,
                                          key: ptr cef_string,
                                          value: ptr cef_string): int {.cef_import.}


# Clear the string multimap.
proc cef_string_multimap_clear*(map: cef_string_multimap) {.cef_import.}


# Free the string multimap.
proc cef_string_multimap_free*(map: cef_string_multimap) {.cef_import.}