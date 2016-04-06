import cef_base, cef_callback
include cef_import

type
  # Structure used for managing cookies. The functions of this structure may be
  # called on any thread unless otherwise indicated.
  cef_cookie_manager* = object
    base*: cef_base

    # Set the schemes supported by this manager. The default schemes ("http",
    # "https", "ws" and "wss") will always be supported. If |callback| is non-
    # NULL it will be executed asnychronously on the IO thread after the change
    # has been applied. Must be called before any cookies are accessed.
    set_supported_schemes*: proc(self: ptr cef_cookie_manager,
      schemes: cef_string_list, callback: ptr cef_completion_callback) {.cef_callback.}
  
    # Visit all cookies on the IO thread. The returned cookies are ordered by
    # longest path, then by earliest creation date. Returns false (0) if cookies
    # cannot be accessed.
    visit_all_cookies*: proc(self: ptr cef_cookie_manager,
      visitor: ptr cef_cookie_visitor): int {.cef_callback.}
  
    # Visit a subset of cookies on the IO thread. The results are filtered by the
    # given url scheme, host, domain and path. If |includeHttpOnly| is true (1)
    # HTTP-only cookies will also be included in the results. The returned
    # cookies are ordered by longest path, then by earliest creation date.
    # Returns false (0) if cookies cannot be accessed.
    visit_url_cookies*: proc(self: ptr cef_cookie_manager,
      url: ptr cef_string, includeHttpOnly: int,
      visitor: ptr cef_cookie_visitor): int {.cef_callback.}
  
    # Sets a cookie given a valid URL and explicit user-provided cookie
    # attributes. This function expects each attribute to be well-formed. It will
    # check for disallowed characters (e.g. the ';' character is disallowed
    # within the cookie value attribute) and fail without setting the cookie if
    # such characters are found. If |callback| is non-NULL it will be executed
    # asnychronously on the IO thread after the cookie has been set. Returns
    # false (0) if an invalid URL is specified or if cookies cannot be accessed.
    set_cookie*: proc(self: ptr cef_cookie_manager,
        url: ptr cef_string, cookie: ptr cef_cookie,
        callback: ptr cef_set_cookie_callback): int {.cef_callback.}
  
    # Delete all cookies that match the specified parameters. If both |url| and
    # |cookie_name| values are specified all host and domain cookies matching
    # both will be deleted. If only |url| is specified all host cookies (but not
    # domain cookies) irrespective of path will be deleted. If |url| is NULL all
    # cookies for all hosts and domains will be deleted. If |callback| is non-
    # NULL it will be executed asnychronously on the IO thread after the cookies
    # have been deleted. Returns false (0) if a non-NULL invalid URL is specified
    # or if cookies cannot be accessed. Cookies can alternately be deleted using
    # the Visit*Cookies() functions.
    delete_cookies*: proc(self: ptr cef_cookie_manager,
        url, cookie_name: ptr cef_string,
        callback: ptr cef_delete_cookies_callback): int {.cef_callback.}
  
    # Sets the directory path that will be used for storing cookie data. If
    # |path| is NULL data will be stored in memory only. Otherwise, data will be
    # stored at the specified |path|. To persist session cookies (cookies without
    # an expiry date or validity interval) set |persist_session_cookies| to true
    # (1). Session cookies are generally intended to be transient and most Web
    # browsers do not persist them. If |callback| is non-NULL it will be executed
    # asnychronously on the IO thread after the manager's storage has been
    # initialized. Returns false (0) if cookies cannot be accessed.
    set_storage_path*: proc(self: ptr cef_cookie_manager,
      path: ptr cef_string, persist_session_cookies: int,
      callback: ptr cef_completion_callback): int {.cef_callback.}
  
    # Flush the backing store (if any) to disk. If |callback| is non-NULL it will
    # be executed asnychronously on the IO thread after the flush is complete.
    # Returns false (0) if cookies cannot be accessed.
    flush_store*: proc(self: ptr cef_cookie_manager,
      callback: ptr cef_completion_callback): int {.cef_callback.}


  # Structure to implement for visiting cookie values. The functions of this
  # structure will always be called on the IO thread.
  cef_cookie_visitor* = object
    base*: cef_base

    # Method that will be called once for each cookie. |count| is the 0-based
    # index for the current cookie. |total| is the total number of cookies. Set
    # |deleteCookie| to true (1) to delete the cookie currently being visited.
    # Return false (0) to stop visiting cookies. This function may never be
    # called if no cookies are found.
    visit*: proc(self: ptr cef_cookie_visitor,
        cookie: ptr cef_cookie, count, total: int,
        deleteCookie: var int): int {.cef_callback.}

  # Structure to implement to be notified of asynchronous completion via
  # cef_cookie_manager_t::set_cookie().
  cef_set_cookie_callback* = object
    base*: cef_base
  
    # Method that will be called upon completion. |success| will be true (1) if
    # the cookie was set successfully.
    on_complete*: proc(self: ptr cef_set_cookie_callback,
      success: int) {.cef_callback.}

  # Structure to implement to be notified of asynchronous completion via
  # cef_cookie_manager_t::delete_cookies().
  cef_delete_cookies_callback* = object
    base*: cef_base
  
    # Method that will be called upon completion. |num_deleted| will be the
    # number of cookies that were deleted or -1 if unknown.
    
    on_complete*: proc(self: ptr cef_delete_cookies_callback,
      num_deleted: int) {.cef_callback.}
      
# Returns the global cookie manager. By default data will be stored at
# CefSettings.cache_path if specified or in memory otherwise. If |callback| is
# non-NULL it will be executed asnychronously on the IO thread after the
# manager's storage has been initialized. Using this function is equivalent to
# calling cef_request_tContext::cef_request_context_get_global_context()->get_d
# efault_cookie_manager().
proc cef_cookie_manager_get_global_manager*(callback: ptr cef_completion_callback): ptr cef_cookie_manager {.cef_import.}

# Creates a new cookie manager. If |path| is NULL data will be stored in memory
# only. Otherwise, data will be stored at the specified |path|. To persist
# session cookies (cookies without an expiry date or validity interval) set
# |persist_session_cookies| to true (1). Session cookies are generally intended
# to be transient and most Web browsers do not persist them. If |callback| is
# non-NULL it will be executed asnychronously on the IO thread after the
# manager's storage has been initialized.
proc cef_cookie_manager_create_manager*(path: ptr cef_string, persist_session_cookies: int,
  callback: ptr cef_completion_callback): ptr cef_cookie_manager {.cef_import.}