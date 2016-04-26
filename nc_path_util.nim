import cef/cef_path_util_api, nc_util, nc_types, cef/cef_types

# Retrieve the path associated with the specified |key|. Returns true (1) on
# success. Can be called on any thread in the browser process.
proc NCGetPath*(key: cef_path_key, path: string): bool =
  let cpath = to_cef(path)
  result = cef_get_path(key, cpath) == 1.cint
  nc_free(cpath)