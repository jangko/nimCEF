import cef_base_api, cef_request_context_handler_api, cef_callback_api
import cef_cookie_manager_api, cef_scheme_api, cef_value_api
include cef_import

type
  # Callback structure for cef_request_tContext::ResolveHost.
  cef_resolve_callback* = object of cef_base
    # Called after the ResolveHost request has completed. |result| will be the
    # result code. |resolved_ips| will be the list of resolved IP addresses or
    # NULL if the resolution failed.
    on_resolve_completed*: proc(self: ptr cef_resolve_callback, result: cef_errorcode,
      resolved_ips: cef_string_list) {.cef_callback.}

  # A request context provides request handling for a set of related browser or
  # URL request objects. A request context can be specified when creating a new
  # browser via the cef_browser_host_t static factory functions or when creating
  # a new URL request via the cef_urlrequest_t static factory functions. Browser
  # objects with different request contexts will never be hosted in the same
  # render process. Browser objects with the same request context may or may not
  # be hosted in the same render process depending on the process model. Browser
  # objects created indirectly via the JavaScript window.open function or
  # targeted links will share the same render process and the same request
  # context as the source browser. When running in single-process mode there is
  # only a single render process (the main process) and so all browsers created
  # in single-process mode will share the same request context. This will be the
  # first request context passed into a cef_browser_host_t static factory
  # function and all other request context objects will be ignored.
  cef_request_context* = object of cef_base
    # Returns true (1) if this object is pointing to the same context as |that|
    # object.
    is_same*: proc(self, other: ptr cef_request_context): cint {.cef_callback.}

    # Returns true (1) if this object is sharing the same storage as |that|
    # object.
    is_sharing_with*: proc(self, other: ptr cef_request_context): cint {.cef_callback.}

    # Returns true (1) if this object is the global context. The global context
    # is used by default when creating a browser or URL request with a NULL
    # context argument.
    is_global*: proc(self: ptr cef_request_context): cint {.cef_callback.}

    # Returns the handler for this context if any.
    get_handler*: proc(self: ptr cef_request_context): ptr cef_request_context_handler {.cef_callback.}

    # Returns the cache path for this object. If NULL an "incognito mode" in-
    # memory cache is being used.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_cache_path*: proc(self: ptr cef_request_context): cef_string_userfree {.cef_callback.}

    # Returns the default cookie manager for this object. This will be the global
    # cookie manager if this object is the global request context. Otherwise,
    # this will be the default cookie manager used when this request context does
    # not receive a value via cef_request_tContextHandler::get_cookie_manager().
    # If |callback| is non-NULL it will be executed asnychronously on the IO
    # thread after the manager's storage has been initialized.
    get_default_cookie_manager*: proc(self: ptr cef_request_context,
      callback: ptr cef_completion_callback): ptr cef_cookie_manager {.cef_callback.}

    # Register a scheme handler factory for the specified |scheme_name| and
    # optional |domain_name|. An NULL |domain_name| value for a standard scheme
    # will cause the factory to match all domain names. The |domain_name| value
    # will be ignored for non-standard schemes. If |scheme_name| is a built-in
    # scheme and no handler is returned by |factory| then the built-in scheme
    # handler factory will be called. If |scheme_name| is a custom scheme then
    # you must also implement the cef_app_t::on_register_custom_schemes()
    # function in all processes. This function may be called multiple times to
    # change or remove the factory that matches the specified |scheme_name| and
    # optional |domain_name|. Returns false (0) if an error occurs. This function
    # may be called on any thread in the browser process.
    register_scheme_handler_factory*: proc(self: ptr cef_request_context,
        scheme_name, domain_name: ptr cef_string,
        factory: ptr_cef_scheme_handler_factory): cint {.cef_callback.}

    # Clear all registered scheme handler factories. Returns false (0) on error.
    # This function may be called on any thread in the browser process.
    clear_scheme_handler_factories*: proc(self: ptr cef_request_context): cint {.cef_callback.}

    # Tells all renderer processes associated with this context to throw away
    # their plugin list cache. If |reload_pages| is true (1) they will also
    # reload all pages with plugins.
    # cef_request_tContextHandler::OnBeforePluginLoad may be called to rebuild
    # the plugin list cache.
    purge_plugin_list_cache*: proc(self: ptr cef_request_context, reload_pages: cint) {.cef_callback.}

    # Returns true (1) if a preference with the specified |name| exists. This
    # function must be called on the browser process UI thread.
    has_preference*: proc(self: ptr cef_request_context,
       name: ptr cef_string): cint {.cef_callback.}

    # Returns the value for the preference with the specified |name|. Returns
    # NULL if the preference does not exist. The returned object contains a copy
    # of the underlying preference value and modifications to the returned object
    # will not modify the underlying preference value. This function must be
    # called on the browser process UI thread.
    get_preference*: proc(self: ptr cef_request_context, name: ptr cef_string): ptr cef_value {.cef_callback.}

    # Returns all preferences as a dictionary. If |include_defaults| is true (1)
    # then preferences currently at their default value will be included. The
    # returned object contains a copy of the underlying preference values and
    # modifications to the returned object will not modify the underlying
    # preference values. This function must be called on the browser process UI
    # thread.
    get_all_preferences*: proc(self: ptr cef_request_context, include_defaults: cint): ptr cef_dictionary_value {.cef_callback.}

    # Returns true (1) if the preference with the specified |name| can be
    # modified using SetPreference. As one example preferences set via the
    # command-line usually cannot be modified. This function must be called on
    # the browser process UI thread.
    can_set_preference*: proc(self: ptr cef_request_context, name: ptr cef_string): cint {.cef_callback.}

    # Set the |value| associated with preference |name|. Returns true (1) if the
    # value is set successfully and false (0) otherwise. If |value| is NULL the
    # preference will be restored to its default value. If setting the preference
    # fails then |error| will be populated with a detailed description of the
    # problem. This function must be called on the browser process UI thread.
    set_preference*: proc(self: ptr cef_request_context,
        name: ptr cef_string, value: ptr cef_value,
        error: ptr cef_string): cint {.cef_callback.}

    # Clears all certificate exceptions that were added as part of handling
    # cef_request_tHandler::on_certificate_error(). If you call this it is
    # recommended that you also call close_all_connections() or you risk not
    # being prompted again for server certificates if you reconnect quickly. If
    # |callback| is non-NULL it will be executed on the UI thread after
    # completion.
    clear_certificate_exceptions*: proc(self: ptr cef_request_context,
      callback: ptr cef_completion_callback) {.cef_callback.}

    # Clears all active and idle connections that Chromium currently has. This is
    # only recommended if you have released all other CEF objects but don't yet
    # want to call cef_shutdown(). If |callback| is non-NULL it will be executed
    # on the UI thread after completion.
    close_all_connections*: proc(self: ptr cef_request_context,
      callback: ptr cef_completion_callback) {.cef_callback.}

    # Attempts to resolve |origin| to a list of associated IP addresses.
    # |callback| will be executed on the UI thread after completion.
    resolve_host*: proc(self: ptr cef_request_context,
      origin: ptr cef_string, callback: ptr cef_resolve_callback) {.cef_callback.}

    # Attempts to resolve |origin| to a list of associated IP addresses using
    # cached data. |resolved_ips| will be populated with the list of resolved IP
    # addresses or NULL if no cached data is available. Returns ERR_NONE on
    # success. This function must be called on the browser process IO thread.
    resolve_host_cached*: proc(self: ptr cef_request_context, origin: ptr cef_string,
      resolved_ips: cef_string_list): cef_errorcode {.cef_callback.}

# Returns the global context object.
proc cef_request_context_get_global_context*(): ptr cef_request_context {.cef_import.}

# Creates a new context object with the specified |settings| and optional
# |handler|.
proc cef_request_context_create_context*(settings: ptr cef_request_context_settings,
  handler: ptr cef_request_context_handler): ptr cef_request_context {.cef_import.}

# Creates a new context object that shares storage with |other| and uses an
# optional |handler|.
proc cef_create_context_shared*(other: ptr cef_request_context,
  handler: ptr cef_request_context_handler): ptr cef_request_context {.cef_import.}