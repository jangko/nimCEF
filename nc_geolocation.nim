import cef/cef_geolocation_api, cef/cef_types, nc_util, cef/cef_time_api

type
  # Implement this structure to receive geolocation updates. The functions of
  # this structure will be called on the browser process UI thread.
  NCGetGeolocationCallback* = ref object
    handler: ptr cef_get_geolocation_callback

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
    timestamp*: cef_time

    # Error code, see enum above.
    error_code*: cef_geoposition_error_code

    # Human-readable error message.
    error_message*: string

  nc_get_geolocation_callback_i*[T] = object
    # Called with the 'best available' location information or, if the location
    # update failed, with error information.
    OnLocationUpdate*: proc(self: T, position: NCGeoPosition)

import impl/nc_util_impl
include cef/cef_import

type
  nc_get_geolocation_callback = object of nc_base[cef_get_geolocation_callback, NCGetGeolocationCallback]
    impl: nc_get_geolocation_callback_i[NCGetGeolocationCallback]

proc to_nim(cc: ptr cef_geoposition): NCGeoPosition =
  result.latitude = cc.latitude.float64
  result.longitude = cc.longitude.float64
  result.altitude = cc.altitude.float64
  result.accuracy = cc.accuracy.float64
  result.altitude_accuracy = cc.altitude_accuracy.float64
  result.heading = cc.heading.float64
  result.speed = cc.speed.float64
  result.timestamp = cc.timestamp
  result.error_code = cc.error_code
  result.error_message = $(cc.error_message.addr)

proc GetHandler*(self: NCGetGeolocationCallback): ptr cef_get_geolocation_callback {.inline.} =
  result = self.handler

proc nc_wrap*(handler: ptr cef_get_geolocation_callback): NCGetGeolocationCallback =
  new(result, nc_finalizer[NCGetGeolocationCallback])
  result.handler = handler
  add_ref(handler)

proc on_location_update(self: ptr cef_get_geolocation_callback, position: ptr cef_geoposition) {.cef_callback.} =
  var handler = toType(nc_get_geolocation_callback, self)
  if handler.impl.OnLocationUpdate != nil:
    handler.impl.OnLocationUpdate(handler.container, to_nim(position))

proc makeNCGeolocationCallback*[T](impl: nc_get_geolocation_callback_i[T]): T =
  nc_init(nc_get_geolocation_callback, T, impl)
  result.handler.on_location_update = on_location_update

# Request a one-time geolocation update. This function bypasses any user
# permission checks so should only be used by code that is allowed to access
# location information.
proc NCGetGeolocation*(callback: NCGetGeolocationCallback): bool =
  result = cef_get_geolocation(callback.handler) == 1.cint