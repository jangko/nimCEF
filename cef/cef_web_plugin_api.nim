import cef_base_api
include cef_import

type
  # Information about a specific web plugin.
  cef_web_plugin_info* = object
    base*: cef_base

    # Returns the plugin name (i.e. Flash).
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_name*: proc(self: ptr cef_web_plugin_info): cef_string_userfree {.cef_callback.}

    # Returns the plugin file path (DLL/bundle/library).
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_path*: proc(self: ptr cef_web_plugin_info): cef_string_userfree {.cef_callback.}

    # Returns the version of the plugin (may be OS-specific).
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_version*: proc(self: ptr cef_web_plugin_info): cef_string_userfree {.cef_callback.}

    # Returns a description of the plugin from the version information.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_description*: proc(self: ptr cef_web_plugin_info): cef_string_userfree {.cef_callback.}

  # Structure to implement for visiting web plugin information. The functions of
  # this structure will be called on the browser process UI thread.
  cef_web_plugin_info_visitor* = object
    base*: cef_base

    # Method that will be called once for each plugin. |count| is the 0-based
    # index for the current plugin. |total| is the total number of plugins.
    # Return false (0) to stop visiting plugins. This function may never be
    # called if no plugins are found.
    visit*: proc(self: ptr cef_web_plugin_info_visitor,
      info: ptr cef_web_plugin_info, count, total: cint): cint {.cef_callback.}

  # Structure to implement for receiving unstable plugin information. The
  # functions of this structure will be called on the browser process IO thread.
  cef_web_plugin_unstable_callback* = object
    base*: cef_base
  
    # Method that will be called for the requested plugin. |unstable| will be
    # true (1) if the plugin has reached the crash count threshold of 3 times in
    # 120 seconds.
    is_unstable*: proc(self: ptr cef_web_plugin_unstable_callback,
      path: ptr cef_string, unstable: cint) {.cef_callback.}

# Visit web plugin information. Can be called on any thread in the browser
# process.
proc cef_visit_web_plugin_info*(visitor: ptr cef_web_plugin_info_visitor) {.cef_import.}

# Cause the plugin list to refresh the next time it is accessed regardless of
# whether it has already been loaded. Can be called on any thread in the
# browser process.
proc cef_refresh_web_plugins*() {.cef_import.}

# Add a plugin path (directory + file). This change may not take affect until
# after cef_refresh_web_plugins() is called. Can be called on any thread in the
# browser process.
proc cef_add_web_plugin_path*(path: ptr cef_string) {.cef_import.}

# Add a plugin directory. This change may not take affect until after
# cef_refresh_web_plugins() is called. Can be called on any thread in the
# browser process.
proc cef_add_web_plugin_directory*(dir: ptr cef_string) {.cef_import.}

# Remove a plugin path (directory + file). This change may not take affect
# until after cef_refresh_web_plugins() is called. Can be called on any thread
# in the browser process.
proc cef_remove_web_plugin_path*(path: ptr cef_string) {.cef_import.}

# Unregister an internal plugin. This may be undone the next time
# cef_refresh_web_plugins() is called. Can be called on any thread in the
# browser process.
proc cef_unregister_internal_web_plugin*(path: ptr cef_string) {.cef_import.}

# Force a plugin to shutdown. Can be called on any thread in the browser
# process but will be executed on the IO thread.
proc cef_force_web_plugin_shutdown*(path: ptr cef_string) {.cef_import.}

# Register a plugin crash. Can be called on any thread in the browser process
# but will be executed on the IO thread.
proc cef_register_web_plugin_crash*(path: ptr cef_string) {.cef_import.}

# Query if a plugin is unstable. Can be called on any thread in the browser
# process.
proc cef_is_web_plugin_unstable*(path: ptr cef_string,
  callback: ptr cef_web_plugin_unstable_callback) {.cef_import.}