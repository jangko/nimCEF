import cef_base
include cef_import

# Implement this structure to receive geolocation updates. The functions of
# this structure will be called on the browser process UI thread.
type
  cef_get_geolocation_callback = object
    base*: cef_base

    # Called with the 'best available' location information or, if the location
    # update failed, with error information.
    on_location_update*: proc(self: ptr cef_get_geolocation_callback,
      position: ptr cef_geoposition) {.cef_callback.}

# Request a one-time geolocation update. This function bypasses any user
# permission checks so should only be used by code that is allowed to access
# location information.
proc cef_get_geolocation(callback: ptr cef_get_geolocation_callback): int {.cef_import.}