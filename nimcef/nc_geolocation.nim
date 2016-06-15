import cef_geolocation_api, cef_types, nc_util, nc_time
import nc_util_impl
include cef_import

type
  # Structure representing geoposition information. The properties of this
  # structure correspond to those of the JavaScript Position object although
  # their types may differ.
  NCGeoPosition* = object
    # Latitude in decimal degrees north (WGS84 coordinate frame).
    latitude*: float64

    # Longitude in decimal degrees west (WGS84 coordinate frame).
    longitude*: float64

    # Altitude in meters (above WGS84 datum).
    altitude*: float64

    # Accuracy of horizontal position in meters.
    accuracy*: float64

    # Accuracy of altitude in meters.
    altitude_accuracy*: float64

    # Heading in decimal degrees clockwise from true north.
    heading*: float64

    # Horizontal component of device velocity in meters per second.
    speed*: float64

    # Time of position measurement in milliseconds since Epoch in UTC time. This
    # is taken from the host computer's system clock.
    timestamp*: NCTime

    # Error code, see enum above.
    error_code*: cef_geoposition_error_code

    # Human-readable error message.
    error_message*: string

proc to_nim(cc: ptr cef_geoposition): NCGeoPosition =
  result.latitude = cc.latitude.float64
  result.longitude = cc.longitude.float64
  result.altitude = cc.altitude.float64
  result.accuracy = cc.accuracy.float64
  result.altitude_accuracy = cc.altitude_accuracy.float64
  result.heading = cc.heading.float64
  result.speed = cc.speed.float64
  result.timestamp = to_nim(cc.timestamp)
  result.error_code = cc.error_code
  result.error_message = $(cc.error_message.addr)

# Implement this structure to receive geolocation updates. The functions of
# this structure will be called on the browser process UI thread.
wrapCallback(NCGetGeolocationCallback, cef_get_geolocation_callback):
  # Called with the 'best available' location information or, if the location
  # update failed, with error information.
  proc OnLocationUpdate*(self: T, position: NCGeoPosition)

# Request a one-time geolocation update. This function bypasses any user
# permission checks so should only be used by code that is allowed to access
# location information.
proc NCGetGeolocation*(callback: NCGetGeolocationCallback): bool =
  wrapProc(cef_get_geolocation, result, callback)