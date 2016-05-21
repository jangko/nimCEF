import cef/cef_request_context_handler_api, cef/cef_string_list_api
import nc_request_context_handler, nc_callback, nc_settings
import nc_cookie_manager, nc_scheme, nc_value, nc_util, nc_types
import impl/nc_util_impl
include cef/cef_import

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
wrapAPI(NCRequestContext, cef_request_context)
    
# Callback structure for cef_request_tContext::ResolveHost.
wrapCallback(NCResolveCallback, cef_resolve_callback):
  # Called after the ResolveHost request has completed. |result| will be the
  # result code. |resolved_ips| will be the list of resolved IP addresses or
  # NULL if the resolution failed.
  proc OnResolveCompleted*(self: NCResolveCallback, result: cef_errorcode, resolved_ips: seq[string])

# Returns true (1) if this object is pointing to the same context as |that|
# object.
proc IsSame*(self, other: NCRequestContext): bool =
  self.wrapCall(is_same, result, other)

# Returns true (1) if this object is sharing the same storage as |that|
# object.
proc IsSharingWith*(self, other: NCRequestContext): bool =
  self.wrapCall(is_sharing_with, result, other)

# Returns true (1) if this object is the global context. The global context
# is used by default when creating a browser or URL request with a NULL
# context argument.
proc IsGlobal*(self: NCRequestContext): bool =
  self.wrapCall(is_global, result)

# Returns the handler for this context if any.
proc GetContextHandler*(self: NCRequestContext): NCRequestContextHandler =
  self.wrapCall(get_handler, result)

# Returns the cache path for this object. If NULL an "incognito mode" in-
# memory cache is being used.
# The resulting string must be freed by calling string_free().
proc GetCachePath*(self: NCRequestContext): string =
  self.wrapCall(get_cache_path, result)

# Returns the default cookie manager for this object. This will be the global
# cookie manager if this object is the global request context. Otherwise,
# this will be the default cookie manager used when this request context does
# not receive a value via cef_request_tContextHandler::get_cookie_manager().
# If |callback| is non-NULL it will be executed asnychronously on the IO
# thread after the manager's storage has been initialized.
proc GetDefaultCookieManager*(self: NCRequestContext, callback: NCCompletionCallback): NCCookieManager =
  self.wrapCall(get_default_cookie_manager, result, callback)

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
proc RegisterSchemeHandlerFactory*(self: NCRequestContext, scheme_name, domain_name: string,
  factory: NCSchemeHandlerFactory): bool =
  
  debugModeOn()
  self.wrapCall(register_scheme_handler_factory, result, scheme_name, domain_name,
    factory)
  debugModeOff()
  
# Clear all registered scheme handler factories. Returns false (0) on error.
# This function may be called on any thread in the browser process.
proc ClearSchemeHandlerFactories*(self: NCRequestContext): bool =
  self.wrapCall(clear_scheme_handler_factories, result)

# Tells all renderer processes associated with this context to throw away
# their plugin list cache. If |reload_pages| is true (1) they will also
# reload all pages with plugins.
# cef_request_tContextHandler::OnBeforePluginLoad may be called to rebuild
# the plugin list cache.
proc PurgePluginListCache*(self: NCRequestContext, reload_pages: bool) =
  self.wrapCall(purge_plugin_list_cache, reload_pages)

# Returns true (1) if a preference with the specified |name| exists. This
# function must be called on the browser process UI thread.
proc HasPreference*(self: NCRequestContext, name: string): bool =
  self.wrapCall(has_preference, result, name)

# Returns the value for the preference with the specified |name|. Returns
# NULL if the preference does not exist. The returned object contains a copy
# of the underlying preference value and modifications to the returned object
# will not modify the underlying preference value. This function must be
# called on the browser process UI thread.
proc GetPreference*(self: NCRequestContext, name: string): NCValue =
  self.wrapCall(get_preference, result, name)

# Returns all preferences as a dictionary. If |include_defaults| is true (1)
# then preferences currently at their default value will be included. The
# returned object contains a copy of the underlying preference values and
# modifications to the returned object will not modify the underlying
# preference values. This function must be called on the browser process UI
# thread.
proc GetAllPreferences*(self: NCRequestContext, include_defaults: bool): NCDictionaryValue =
  self.wrapCall(get_all_preferences, result, include_defaults)

# Returns true (1) if the preference with the specified |name| can be
# modified using SetPreference. As one example preferences set via the
# command-line usually cannot be modified. This function must be called on
# the browser process UI thread.
proc CanSetPreference*(self: NCRequestContext, name: string): bool =
  self.wrapCall(can_set_preference, result, name)

# Set the |value| associated with preference |name|. Returns true (1) if the
# value is set successfully and false (0) otherwise. If |value| is NULL the
# preference will be restored to its default value. If setting the preference
# fails then |error| will be populated with a detailed description of the
# problem. This function must be called on the browser process UI thread.
proc SetPreference*(self: NCRequestContext, name: string, value: NCValue, error: var string): bool =
  self.wrapCall(set_preference, result, name, value, error)
  
# Clears all certificate exceptions that were added as part of handling
# cef_request_tHandler::on_certificate_error(). If you call this it is
# recommended that you also call close_all_connections() or you risk not
# being prompted again for server certificates if you reconnect quickly. If
# |callback| is non-NULL it will be executed on the UI thread after
# completion.
proc ClearCertificateExceptions*(self: NCRequestContext, callback: NCCompletionCallback) =
  self.wrapCall(clear_certificate_exceptions, callback)

# Clears all active and idle connections that Chromium currently has. This is
# only recommended if you have released all other CEF objects but don't yet
# want to call cef_shutdown(). If |callback| is non-NULL it will be executed
# on the UI thread after completion.
proc CloseAllConnections*(self: NCRequestContext, callback: NCCompletionCallback) =
  self.wrapCall(close_all_connections, callback)

# Attempts to resolve |origin| to a list of associated IP addresses.
# |callback| will be executed on the UI thread after completion.
proc ResolveHost*(self: NCRequestContext, origin: string, callback: NCResolveCallback) =
  self.wrapCall(resolve_host, origin, callback)

# Attempts to resolve |origin| to a list of associated IP addresses using
# cached data. |resolved_ips| will be populated with the list of resolved IP
# addresses or NULL if no cached data is available. Returns ERR_NONE on
# success. This function must be called on the browser process IO thread.
proc ResolveHostCached*(self: NCRequestContext, origin: string,
  resolved_ips: seq[string]): cef_errorcode =
  self.wrapCall(resolve_host_cached, result, origin, resolved_ips)

# Returns the global context object.
proc NCRequestContextGetGlobalContext*(): NCRequestContext =
  wrapProc(cef_request_context_get_global_context, result)

# Creates a new context object with the specified |settings| and optional
# |handler|.
proc NCRequestContextCreateContext*(settings: NCRequestContextSettings, handler: NCRequestContextHandler): NCRequestContext =
  wrapProc(cef_request_context_create_context, result, settings, handler)

# Creates a new context object that shares storage with |other| and uses an
# optional |handler|.
proc CreateContextShared*(other: NCRequestContext, handler: NCRequestContextHandler): NCRequestContext =
  wrapProc(create_context_shared, result, other, handler)