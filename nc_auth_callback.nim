import cef/cef_auth_callback_api, nc_types, nc_util

# Callback structure used for asynchronous continuation of authentication
# requests.
type
  NCAuthCallback* = ptr cef_auth_callback    

# Continue the authentication request.
proc Continue*(self: NCAuthCallback, username, password: string) =
  let cuser = to_cef(username)
  let cpass = to_cef(password)
  self.cont(self, cuser, cpass)
  cef_string_userfree_free(cuser)
  cef_string_userfree_free(cpass)

# Cancel the authentication request.
proc Cancel*(self: NCAuthCallback) =
  self.cancel(self)