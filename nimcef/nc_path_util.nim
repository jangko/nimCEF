import cef_path_util_api, nc_util, nc_types, cef_types

# Retrieve the path associated with the specified |key|. Returns true (1) on
# success. Can be called on any thread in the browser process.
proc ncGetPath*(key: cef_path_key, path: var string): bool =
  wrapProc(cef_get_path, result, key, path)
