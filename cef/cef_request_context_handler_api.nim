import cef_base_api, cef_cookie_manager_api, cef_web_plugin_info_api
include cef_import

type
  # Implement this structure to provide handler implementations. The handler
  # instance will not be released until all objects related to the context have
  # been destroyed.
  cef_request_context_handler* = object
    # Base structure.
    base*: cef_base

    # Called on the browser process IO thread to retrieve the cookie manager. If
    # this function returns NULL the default cookie manager retrievable via
    # cef_request_tContext::get_default_cookie_manager() will be used.
  
    get_cookie_manager*: proc(self: ptr cef_request_context_handler): ptr cef_cookie_manager {.cef_callback.}

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
  
    on_before_plugin_load*: proc(self: ptr cef_request_context_handler,
      mime_type, plugin_url, top_origin_url: ptr cef_string,
      plugin_info: ptr cef_web_plugin_info,
      plugin_policy: var cef_plugin_policy): cint {.cef_callback.}

