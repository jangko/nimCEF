import nc_cookie, nc_types, nc_util, nc_callback, nc_util_impl
include cef_import

# Structure used for managing cookies. The functions of this structure may be
# called on any thread unless otherwise indicated.
wrapAPI(NCCookieManager, cef_cookie_manager)

# Structure to implement for visiting cookie values. The functions of this
# structure will always be called on the IO thread.
wrapCallback(NCCookieVisitor, cef_cookie_visitor):
  # Method that will be called once for each cookie. |count| is the 0-based
  # index for the current cookie. |total| is the total number of cookies. Set
  # |deleteCookie| to true (1) to delete the cookie currently being visited.
  # Return false (0) to stop visiting cookies. This function may never be
  # called if no cookies are found.
  proc cookieVisit*(self: T, cookie: NCCookie, count, total: int, deleteCookie: var bool): bool

# Structure to implement to be notified of asynchronous completion via
# NCCookieManager::set_cookie().
wrapCallback(NCSetCookieCallback, cef_set_cookie_callback):
  # Method that will be called upon completion. |success| will be true (1) if
  # the cookie was set successfully.
  proc onSetCookieComplete*(self: T, success: bool)

# Structure to implement to be notified of asynchronous completion via
# NCCookieManager::delete_cookies().
wrapCallback(NCDeleteCookiesCallback, cef_delete_cookies_callback):
  # Method that will be called upon completion. |num_deleted| will be the
  # number of cookies that were deleted or -1 if unknown.
  proc onDeleteCookiesComplete*(self: T, num_deleted: int)

# Set the schemes supported by this manager. The default schemes ("http",
# "https", "ws" and "wss") will always be supported. If |callback| is non-
# NULL it will be executed asnychronously on the IO thread after the change
# has been applied. Must be called before any cookies are accessed.
proc setSupportedSchemes*(self: NCCookieManager, schemes: seq[string], callback: NCCompletionCallback) =
  self.wrapCall(set_supported_schemes, schemes, callback)

# Visit all cookies on the IO thread. The returned cookies are ordered by
# longest path, then by earliest creation date. Returns false (0) if cookies
# cannot be accessed.
proc visitAllCookies*(self: NCCookieManager, visitor: NCCookieVisitor): bool =
  self.wrapCall(visit_all_cookies, result, visitor)

# Visit a subset of cookies on the IO thread. The results are filtered by the
# given url scheme, host, domain and path. If |includeHttpOnly| is true (1)
# HTTP-only cookies will also be included in the results. The returned
# cookies are ordered by longest path, then by earliest creation date.
# Returns false (0) if cookies cannot be accessed.
proc visitUrlCookies*(self: NCCookieManager, url: string, includeHttpOnly: bool, visitor: NCCookieVisitor): bool =
  self.wrapCall(visit_url_cookies, result, url, includeHttpOnly, visitor)

# Sets a cookie given a valid URL and explicit user-provided cookie
# attributes. This function expects each attribute to be well-formed. It will
# check for disallowed characters (e.g. the ';' character is disallowed
# within the cookie value attribute) and fail without setting the cookie if
# such characters are found. If |callback| is non-NULL it will be executed
# asnychronously on the IO thread after the cookie has been set. Returns
# false (0) if an invalid URL is specified or if cookies cannot be accessed.
proc setCookie*(self: NCCookieManager, url: string, cookie: NCCookie, callback: NCSetCookieCallback): bool =
  self.wrapCall(set_cookie, result, url, cookie, callback)

# Delete all cookies that match the specified parameters. If both |url| and
# |cookie_name| values are specified all host and domain cookies matching
# both will be deleted. If only |url| is specified all host cookies (but not
# domain cookies) irrespective of path will be deleted. If |url| is NULL all
# cookies for all hosts and domains will be deleted. If |callback| is non-
# NULL it will be executed asnychronously on the IO thread after the cookies
# have been deleted. Returns false (0) if a non-NULL invalid URL is specified
# or if cookies cannot be accessed. Cookies can alternately be deleted using
# the Visit*Cookies() functions.
proc deleteCookies*(self: NCCookieManager, url, cookie_name: string, callback: NCDeleteCookiesCallback): bool =
  self.wrapCall(delete_cookies, result, url, cookie_name, callback)

# Sets the directory path that will be used for storing cookie data. If
# |path| is NULL data will be stored in memory only. Otherwise, data will be
# stored at the specified |path|. To persist session cookies (cookies without
# an expiry date or validity interval) set |persist_session_cookies| to true
# (1). Session cookies are generally intended to be transient and most Web
# browsers do not persist them. If |callback| is non-NULL it will be executed
# asnychronously on the IO thread after the manager's storage has been
# initialized. Returns false (0) if cookies cannot be accessed.
proc setStoragePath*(self: NCCookieManager, path: string, persist_session_cookies: bool,
  callback: NCCompletionCallback): bool =
  self.wrapCall(set_storage_path, result, path, persist_session_cookies, callback)

# Flush the backing store (if any) to disk. If |callback| is non-NULL it will
# be executed asnychronously on the IO thread after the flush is complete.
# Returns false (0) if cookies cannot be accessed.
proc flushStore*(self: NCCookieManager, callback: NCCompletionCallback): bool =
  self.wrapCall(flush_store, result, callback)


# Returns the global cookie manager. By default data will be stored at
# CefSettings.cache_path if specified or in memory otherwise. If |callback| is
# non-NULL it will be executed asnychronously on the IO thread after the
# manager's storage has been initialized. Using this function is equivalent to
# calling NCRequestContext::NCRequestContextGetGlobalContext()->
# GetGefaultCookieManager().
proc ncCookieManagerGetGlobalManager*(callback: NCCompletionCallback): NCCookieManager =
  wrapProc(cef_cookie_manager_get_global_manager, result, callback)

# Creates a new cookie manager. If |path| is NULL data will be stored in memory
# only. Otherwise, data will be stored at the specified |path|. To persist
# session cookies (cookies without an expiry date or validity interval) set
# |persist_session_cookies| to true (1). Session cookies are generally intended
# to be transient and most Web browsers do not persist them. If |callback| is
# non-NULL it will be executed asnychronously on the IO thread after the
# manager's storage has been initialized.
proc ncCookieManagerCreateManager*(path: string, persist_session_cookies: bool,
  callback: NCCompletionCallback): NCCookieManager =
  wrapProc(cef_cookie_manager_create_manager, result, path,
    persist_session_cookies, callback)
