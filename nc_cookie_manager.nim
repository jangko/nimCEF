import cef/cef_cookie_manager_api, cef/cef_string_list_api
import nc_cookie, nc_types, nc_util, nc_callback
include cef/cef_import

type
  # Structure used for managing cookies. The functions of this structure may be
  # called on any thread unless otherwise indicated.
  NCCookieManager* = ptr cef_cookie_manager
    
  # Structure to implement for visiting cookie values. The functions of this
  # structure will always be called on the IO thread.
  NCCookieVisitor* = ref object of RootObj
    handler: cef_cookie_visitor
  
  # Structure to implement to be notified of asynchronous completion via
  # cef_cookie_manager_t::set_cookie().
  NCSetCookieCallback* = ref object of RootObj
    handler: cef_set_cookie_callback
  
  # Structure to implement to be notified of asynchronous completion via
  # cef_cookie_manager_t::delete_cookies().
  NCDeleteCookiesCallback* = ref object of RootObj
    handler: cef_delete_cookies_callback
  
proc GetHandler*(self: NCCookieVisitor): ptr cef_cookie_visitor {.inline.} =
  result = self.handler.addr

proc GetHandler*(self: NCSetCookieCallback): ptr cef_set_cookie_callback {.inline.} =
  result = self.handler.addr

proc GetHandler*(self: NCDeleteCookiesCallback): ptr cef_delete_cookies_callback {.inline.} =
  result = self.handler.addr
  
# Set the schemes supported by this manager. The default schemes ("http",
# "https", "ws" and "wss") will always be supported. If |callback| is non-
# NULL it will be executed asnychronously on the IO thread after the change
# has been applied. Must be called before any cookies are accessed.
proc SetSupportedSchemes*(self: NCCookieManager, schemes: seq[string], callback: NCCompletionCallback) =
  add_ref(callback.GetHandler())
  var cscheme = nim_to_string_list(schemes)
  self.set_supported_schemes(self, cscheme, callback.GetHandler())
  cef_string_list_free(cscheme)
  
# Visit all cookies on the IO thread. The returned cookies are ordered by
# longest path, then by earliest creation date. Returns false (0) if cookies
# cannot be accessed.
proc VisitAllCookies*(self: NCCookieManager, visitor: NCCookieVisitor): bool =
  add_ref(visitor.GetHandler())
  result = self.visit_all_cookies(self, visitor.GetHandler()) == 1.cint

# Visit a subset of cookies on the IO thread. The results are filtered by the
# given url scheme, host, domain and path. If |includeHttpOnly| is true (1)
# HTTP-only cookies will also be included in the results. The returned
# cookies are ordered by longest path, then by earliest creation date.
# Returns false (0) if cookies cannot be accessed.
proc VisitUrlCookies*(self: NCCookieManager, url: string, includeHttpOnly: bool, visitor: NCCookieVisitor): bool =
  add_ref(visitor.GetHandler())
  let curl = to_cef_string(url)
  result = self.visit_url_cookies(self, curl, includeHttpOnly.cint, visitor.GetHandler()) == 1.cint
  cef_string_userfree_free(curl)
  
# Sets a cookie given a valid URL and explicit user-provided cookie
# attributes. This function expects each attribute to be well-formed. It will
# check for disallowed characters (e.g. the ';' character is disallowed
# within the cookie value attribute) and fail without setting the cookie if
# such characters are found. If |callback| is non-NULL it will be executed
# asnychronously on the IO thread after the cookie has been set. Returns
# false (0) if an invalid URL is specified or if cookies cannot be accessed.
proc SetCookie*(self: NCCookieManager, url: string, cookie: NCCookie, callback: NCSetCookieCallback): bool =
  add_ref(callback.GetHandler())
  let curl = to_cef_string(url)
  var ccookie: cef_cookie
  to_cef(cookie, ccookie)
  result = self.set_cookie(self, curl, ccookie.addr, callback.GetHandler()) == 1.cint
  cef_string_userfree_free(curl)
  ccookie.clear()
  
# Delete all cookies that match the specified parameters. If both |url| and
# |cookie_name| values are specified all host and domain cookies matching
# both will be deleted. If only |url| is specified all host cookies (but not
# domain cookies) irrespective of path will be deleted. If |url| is NULL all
# cookies for all hosts and domains will be deleted. If |callback| is non-
# NULL it will be executed asnychronously on the IO thread after the cookies
# have been deleted. Returns false (0) if a non-NULL invalid URL is specified
# or if cookies cannot be accessed. Cookies can alternately be deleted using
# the Visit*Cookies() functions.
proc DeleteCookies*(self: NCCookieManager, url, cookie_name: string,  callback: NCDeleteCookiesCallback): bool =
  add_ref(callback.GetHandler())
  let curl = to_cef_string(url)
  let cname = to_cef_string(cookie_name)
  result = self.delete_cookies(self, curl, cname, callback.GetHandler()) == 1.cint
  cef_string_userfree_free(curl)
  cef_string_userfree_free(cname)
  
# Sets the directory path that will be used for storing cookie data. If
# |path| is NULL data will be stored in memory only. Otherwise, data will be
# stored at the specified |path|. To persist session cookies (cookies without
# an expiry date or validity interval) set |persist_session_cookies| to true
# (1). Session cookies are generally intended to be transient and most Web
# browsers do not persist them. If |callback| is non-NULL it will be executed
# asnychronously on the IO thread after the manager's storage has been
# initialized. Returns false (0) if cookies cannot be accessed.
proc SetStoragePath*(self: NCCookieManager, path: string, persist_session_cookies: bool,
  callback: NCCompletionCallback): bool =
  add_ref(callback.GetHandler())
  let cpath = to_cef_string(path)
  result = self.set_storage_path(self, cpath, persist_session_cookies.cint, callback.GetHandler()) == 1.cint
  cef_string_userfree_free(cpath)
  
# Flush the backing store (if any) to disk. If |callback| is non-NULL it will
# be executed asnychronously on the IO thread after the flush is complete.
# Returns false (0) if cookies cannot be accessed.
proc FlushStore*(self: NCCookieManager, callback: NCCompletionCallback): bool =
  add_ref(callback.GetHandler())
  result = self.flush_store(self, callback.GetHandler()) == 1.cint


# Method that will be called once for each cookie. |count| is the 0-based
# index for the current cookie. |total| is the total number of cookies. Set
# |deleteCookie| to true (1) to delete the cookie currently being visited.
# Return false (0) to stop visiting cookies. This function may never be
# called if no cookies are found.
method CookieVisit*(self: NCCookieVisitor, cookie: NCCookie, count, total: int, deleteCookie: var bool): bool {.base.} =
  result = false
    
proc cookie_visit(self: ptr cef_cookie_visitor, cookie: ptr cef_cookie, count, total: cint, deleteCookie: var cint): cint {.cef_callback.} =
  var handler = type_to_type(NCCookieVisitor, self)
  var delCookie = deleteCookie == 1.cint
  result = handler.CookieVisit(to_nim(cookie), count.int, total.int, delCookie).cint
  deleteCookie = delCookie.cint

proc initialize_cookie_visitor(handler: ptr cef_cookie_visitor) =
  init_base(handler)
  handler.visit = cookie_visit
  
proc makeNCCookieVisitor*(T: typedesc): auto =
  result = new(T)
  initialize_cookie_visitor(result.GetHandler())
  
# Method that will be called upon completion. |success| will be true (1) if
# the cookie was set successfully.
method OnSetCookieComplete*(self: NCSetCookieCallback, success: bool) {.base.} =
  discard

proc on_set_cookie_complete(self: ptr cef_set_cookie_callback, success: cint) {.cef_callback.} =
  var handler = type_to_type(NCSetCookieCallback, self)
  handler.OnSetCookieComplete(success == 1.cint)

proc initialize_set_cookie_callback(handler: ptr cef_set_cookie_callback) =
  init_base(handler)
  handler.on_complete = on_set_cookie_complete
  
proc makeNCSetCookieCallback*(T: typedesc): auto =
  result = new(T)
  initialize_set_cookie_callback(result.GetHandler())

# Method that will be called upon completion. |num_deleted| will be the
# number of cookies that were deleted or -1 if unknown.
method OnDeleteCookiesComplete*(self: NCDeleteCookiesCallback, num_deleted: int) {.base.} =
  discard

proc on_delete_cookies_complete(self: ptr cef_delete_cookies_callback, num_deleted: cint) {.cef_callback.} =
  var handler = type_to_type(NCDeleteCookiesCallback, self)
  handler.OnDeleteCookiesComplete(num_deleted.int)

proc initialize_delete_cookies_callback(handler: ptr cef_delete_cookies_callback) =
  init_base(handler)
  handler.on_complete = on_delete_cookies_complete
  
proc makeNCDeleteCookiesCallback*(T: typedesc): auto =
  result = new(T)
  initialize_delete_cookies_callback(result.GetHandler())

# Returns the global cookie manager. By default data will be stored at
# CefSettings.cache_path if specified or in memory otherwise. If |callback| is
# non-NULL it will be executed asnychronously on the IO thread after the
# manager's storage has been initialized. Using this function is equivalent to
# calling cef_request_tContext::cef_request_context_get_global_context()->get_d
# efault_cookie_manager().
proc NCCookieManagerGetGlobalManager*(callback: NCCompletionCallback): NCCookieManager =
  add_ref(callback.GetHandler())
  result = cef_cookie_manager_get_global_manager(callback.GetHandler())

# Creates a new cookie manager. If |path| is NULL data will be stored in memory
# only. Otherwise, data will be stored at the specified |path|. To persist
# session cookies (cookies without an expiry date or validity interval) set
# |persist_session_cookies| to true (1). Session cookies are generally intended
# to be transient and most Web browsers do not persist them. If |callback| is
# non-NULL it will be executed asnychronously on the IO thread after the
# manager's storage has been initialized.
proc NCCookieManagerCreateManager*(path: string, persist_session_cookies: bool,
  callback: NCCompletionCallback): NCCookieManager =
  add_ref(callback.GetHandler())
  let cpath = to_cef_string(path)
  result = cef_cookie_manager_create_manager(cpath, persist_session_cookies.cint, callback.GetHandler())
  cef_string_userfree_free(cpath)