import cef/cef_types, nc_util, cef/cef_time_api

type
  # Cookie information.
  NCCookie* = object
    # The cookie name.
    name*: string

    # The cookie value.
    value*: string

    # If |domain| is empty a host cookie will be created instead of a domain
    # cookie. Domain cookies are stored with a leading "." and are visible to
    # sub-domains whereas host cookies are not.
    domain*: string

    # If |path| is non-empty only URLs at or below the path will get the cookie
    # value.
    path*: string

    # If |secure| is true the cookie will only be sent for HTTPS requests.
    secure*: bool

    # If |httponly| is true the cookie will only be sent for HTTP requests.
    httponly*: bool

    # The cookie creation date. This is automatically populated by the system on
    # cookie creation.
    creation*: cef_time

    # The cookie last access date. This is automatically populated by the system
    # on access.
    last_access*: cef_time

    # The cookie expiration date is only valid if |has_expires| is true.
    has_expires: bool
    expires*: cef_time

proc to_nim*(cc: ptr cef_cookie): NCCookie =
  result.name = $(cc.name.addr)
  result.value = $(cc.value.addr)
  result.domain = $(cc.domain.addr)
  result.path = $(cc.path.addr)
  result.secure = cc.secure == 1.cint
  result.httponly = cc.httponly == 1.cint
  result.creation = cc.creation
  result.last_access = cc.last_access
  result.has_expires = cc.has_expires == 1.cint
  result.expires = cc.expires

proc to_cef*(nc: NCCookie, cc: var cef_cookie) =
  cc.name <= nc.name
  cc.value <= nc.value
  cc.domain <= nc.domain
  cc.path <= nc.path
  cc.secure = nc.secure.cint
  cc.httponly = nc.httponly.cint
  cc.creation = nc.creation
  cc.last_access = nc.last_access
  cc.has_expires = nc.has_expires.cint
  cc.expires = nc.expires

proc clear*(cc: var cef_cookie) =
  cef_string_clear(cc.name.addr)
  cef_string_clear(cc.value.addr)
  cef_string_clear(cc.domain.addr)
  cef_string_clear(cc.path.addr)