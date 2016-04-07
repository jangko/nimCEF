import cef_base_api
include cef_import

# Retrieve the path associated with the specified |key|. Returns true (1) on
# success. Can be called on any thread in the browser process.
proc cef_get_path*(key: cef_path_key, path: ptr cef_string): cint {.cef_import.}