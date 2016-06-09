import cef_types, nc_util, nc_time

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
    creation*: NCTime

    # The cookie last access date. This is automatically populated by the system
    # on access.
    last_access*: NCTime

    # The cookie expiration date is only valid if |has_expires| is true.
    has_expires: bool
    expires*: NCTime

proc to_nim*(cc: ptr cef_cookie): NCCookie =
  result.name = $(cc.name.addr)
  result.value = $(cc.value.addr)
  result.domain = $(cc.domain.addr)
  result.path = $(cc.path.addr)
  result.secure = cc.secure == 1.cint
  result.httponly = cc.httponly == 1.cint
  result.creation = to_nim(cc.creation)
  result.last_access = to_nim(cc.last_access)
  result.has_expires = cc.has_expires == 1.cint
  result.expires = to_nim(cc.expires)

proc to_cef*(nc: NCCookie): cef_cookie =
  result.name <= nc.name
  result.value <= nc.value
  result.domain <= nc.domain
  result.path <= nc.path
  result.secure = nc.secure.cint
  result.httponly = nc.httponly.cint
  result.creation = to_cef(nc.creation)
  result.last_access = to_cef(nc.last_access)
  result.has_expires = nc.has_expires.cint
  result.expires = to_cef(nc.expires)

proc nc_free*(cc: var cef_cookie) =
  cef_string_clear(cc.name.addr)
  cef_string_clear(cc.value.addr)
  cef_string_clear(cc.domain.addr)
  cef_string_clear(cc.path.addr)