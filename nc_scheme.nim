import cef/cef_scheme_api, cef/cef_resource_handler_api
import nc_util, nc_resource_handler, nc_types, nc_request
import impl/nc_util_impl
include cef/cef_import

# Structure that manages custom scheme registrations.
wrapAPI(NCSchemeRegistrar, cef_scheme_registrar, false)

# Structure that creates cef_resource_handler_t instances for handling scheme
# requests. The functions of this structure will always be called on the IO
# thread.
wrapCallback(NCSchemeHandlerFactory, cef_scheme_handler_factory):
  # Return a new resource handler instance to handle the request or an NULL
  # reference to allow default handling of the request. |browser| and |frame|
  # will be the browser window and frame respectively that originated the
  # request or NULL if the request did not originate from a browser window (for
  # example, if the request came from cef_urlrequest_t). The |request| object
  # passed to this function will not contain cookie data.
  proc Create*(self: T, browser: NCBrowser,
    frame: NCFrame, schemeName: string, request: NCRequest): NCResourceHandler

# Register a custom scheme. This function should not be called for the built-
# in HTTP, HTTPS, FILE, FTP, ABOUT and DATA schemes.
#
# If |is_standard| is true (1) the scheme will be treated as a standard
# scheme. Standard schemes are subject to URL canonicalization and parsing
# rules as defined in the Common Internet Scheme Syntax RFC 1738 Section 3.1
# available at http://www.ietf.org/rfc/rfc1738.txt
#
# In particular, the syntax for standard scheme URLs must be of the form:
# <pre>
#  [scheme]://[username]:[password]@[host]:[port]/[url-path]
# </pre> Standard scheme URLs must have a host component that is a fully
# qualified domain name as defined in Section 3.5 of RFC 1034 [13] and
# Section 2.1 of RFC 1123. These URLs will be canonicalized to
# "scheme://host/path" in the simplest case and
# "scheme://username:password@host:port/path" in the most explicit case. For
# example, "scheme:host/path" and "scheme:host/path" will both be
# canonicalized to "scheme://host/path". The origin of a standard scheme URL
# is the combination of scheme, host and port (i.e., "scheme://host:port" in
# the most explicit case).
#
# For non-standard scheme URLs only the "scheme:" component is parsed and
# canonicalized. The remainder of the URL will be passed to the handler as-
# is. For example, "scheme:some%20text" will remain the same. Non-standard
# scheme URLs cannot be used as a target for form submission.
#
# If |is_local| is true (1) the scheme will be treated as local (i.e., with
# the same security rules as those applied to "file" URLs). Normal pages
# cannot link to or access local URLs. Also, by default, local URLs can only
# perform XMLHttpRequest calls to the same URL (origin + path) that
# originated the request. To allow XMLHttpRequest calls from a local URL to
# other URLs with the same origin set the
# CefSettings.file_access_from_file_urls_allowed value to true (1). To allow
# XMLHttpRequest calls from a local URL to all origins set the
# CefSettings.universal_access_from_file_urls_allowed value to true (1).
#
# If |is_display_isolated| is true (1) the scheme will be treated as display-
# isolated. This means that pages cannot display these URLs unless they are
# from the same scheme. For example, pages in another origin cannot create
# iframes or hyperlinks to URLs with this scheme.
#
# This function may be called on any thread. It should only be called once
# per unique |scheme_name| value. If |scheme_name| is already registered or
# if an error occurs this function will return false (0).
proc AddCustomScheme*(self: NCSchemeRegistrar, schemeName: string, isStandard, isLocal, isDisplayIsolated: bool): bool =
  self.wrapCall(add_custom_scheme, result, schemeName, isStandard, isLocal, isDisplayIsolated)

# Register a scheme handler factory with the global request context. An NULL
# |domain_name| value for a standard scheme will cause the factory to match all
# domain names. The |domain_name| value will be ignored for non-standard
# schemes. If |scheme_name| is a built-in scheme and no handler is returned by
# |factory| then the built-in scheme handler factory will be called. If
# |scheme_name| is a custom scheme then you must also implement the
# NCApp::OnRegisterCustomSchemes() function in all processes. This
# function may be called multiple times to change or remove the factory that
# matches the specified |scheme_name| and optional |domain_name|. Returns false
# (0) if an error occurs. This function may be called on any thread in the
# browser process. Using this function is equivalent to calling 
# NCRequestContext::NCRequestContextGetGlobalContext()->
# RegisterSchemeHandlerFactory().
proc NCRegisterSchemeHandlerFactory*(schemeName, domainName: string, factory: NCSchemeHandlerFactory) =
  wrapProc(cef_register_scheme_handler_factory, schemeName, domainName, factory)

# Clear all scheme handler factories registered with the global request
# context. Returns false (0) on error. This function may be called on any
# thread in the browser process. Using this function is equivalent to calling c
# ef_request_tContext::cef_request_context_get_global_context()->clear_scheme_h
# andler_factories().
proc NCClearSchemeHandlerFactories*(): bool =
  wrapProc(cef_clear_scheme_handler_factories, result)