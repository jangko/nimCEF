import cef/cef_request_context_handler_api, cef/cef_types
import nc_util, nc_cookie_manager, nc_web_plugin

type
  NCRequestContextHandler* = ref object of RootObj
    handler: ptr cef_request_context_handler
    
  # Implement this structure to provide handler implementations. The handler
  # instance will not be released until all objects related to the context have
  # been destroyed.  
  nc_request_context_handler_i*[T] = object 
    # Called on the browser process IO thread to retrieve the cookie manager. If
    # this function returns NULL the default cookie manager retrievable via
    # cef_request_tContext::get_default_cookie_manager() will be used.
    GetCookieManager*: proc(self: T): NCCookieManager

    # Called on multiple browser process threads before a plugin instance is
    # loaded. |mime_type| is the mime type of the plugin that will be loaded.
    # |plugin_url| is the content URL that the plugin will load and may be NULL.
    # |top_origin_url| is the URL for the top-level frame that contains the
    # plugin when loading a specific plugin instance or NULL when building the
    # initial list of enabled plugins for 'navigator.plugins' JavaScript state.
    # |plugin_info| includes additional information about the plugin that will be
    # loaded. |plugin_policy| is the recommended policy. Modify |plugin_policy|
    # and return true (1) to change the policy. Return false (0) to use the
    # recommended policy. The default plugin policy can be set at runtime using
    # the `--plugin-policy=[allow|detect|block]` command-line flag. Decisions to
    # mark a plugin as disabled by setting |plugin_policy| to
    # PLUGIN_POLICY_DISABLED may be cached when |top_origin_url| is NULL. To
    # purge the plugin list cache and potentially trigger new calls to this
    # function call cef_request_tContext::PurgePluginListCache.  
    OnBeforePluginLoad*: proc(self: T, mime_type, plugin_url, top_origin_url: string,
      plugin_info: NCWebPluginInfo, plugin_policy: var cef_plugin_policy): bool
      
      
import impl/nc_util_impl
import cef/cef_cookie_manager_api, cef/cef_web_plugin_info_api
include cef/cef_import

type
  nc_request_context_handler = object of nc_base[cef_request_context_handler, NCRequestContextHandler]
    impl: nc_request_context_handler_i[NCRequestContextHandler]
  
proc GetHandler*(self: NCRequestContextHandler): ptr cef_request_context_handler {.inline.} =
  result = self.handler
  
proc nc_wrap*(handler: ptr cef_request_context_handler): NCRequestContextHandler =
  new(result, nc_finalizer[NCRequestContextHandler])
  result.handler = handler
  add_ref(handler)
  
proc get_cookie_manager(self: ptr cef_request_context_handler): ptr cef_cookie_manager {.cef_callback.} =
  var handler = toType(nc_request_context_handler, self)
  if handler.impl.GetCookieManager != nil:
    result = handler.impl.GetCookieManager(handler.container).GetHandler()

proc on_before_plugin_load(self: ptr cef_request_context_handler,
  mime_type, plugin_url, top_origin_url: ptr cef_string,
  plugin_info: ptr cef_web_plugin_info, plugin_policy: var cef_plugin_policy): cint {.cef_callback.} =
  var handler = toType(nc_request_context_handler, self)
  if handler.impl.OnBeforePluginLoad != nil:
    result = handler.impl.OnBeforePluginLoad(handler.container, $mime_type, $plugin_url, $top_origin_url,
      nc_wrap(plugin_info), plugin_policy).cint
  
proc makeNCRequestContextHandler*[T](impl: nc_request_context_handler_i[T]): T =
  nc_init(nc_request_context_handler, T, impl)
  result.handler.get_cookie_manager = get_cookie_manager
  result.handler.on_before_plugin_load = on_before_plugin_load
