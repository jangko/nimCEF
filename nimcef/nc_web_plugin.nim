import nc_types, nc_util, nc_util_impl
include cef_import

# Information about a specific web plugin.
wrapAPI(NCWebPluginInfo, cef_web_plugin_info)

# Returns the plugin name (i.e. Flash).
proc GetName*(self: NCWebPluginInfo): string =
  self.wrapCall(get_name, result)

# Returns the plugin file path (DLL/bundle/library).
proc GetPath*(self: NCWebPluginInfo): string =
  self.wrapCall(get_path, result)

# Returns the version of the plugin (may be OS-specific).
proc GetVersion*(self: NCWebPluginInfo): string =
  self.wrapCall(get_version, result)

# Returns a description of the plugin from the version information.
proc GetDescription*(self: NCWebPluginInfo): string =
  self.wrapCall(get_description, result)

wrapCallback(NCWebPluginInfoVisitor, cef_web_plugin_info_visitor):
  # Method that will be called once for each plugin. |count| is the 0-based
  # index for the current plugin. |total| is the total number of plugins.
  # Return false (0) to stop visiting plugins. This function may never be
  # called if no plugins are found.
  proc Visit*(self: T, info: NCWebPluginInfo, count, total: int): bool

# Structure to implement for receiving unstable plugin information. The
# functions of this structure will be called on the browser process IO thread.
wrapCallback(NCWebPluginUnstableCallback, cef_web_plugin_unstable_callback):
  # Method that will be called for the requested plugin. |unstable| will be
  # true (1) if the plugin has reached the crash count threshold of 3 times in
  # 120 seconds.
  proc IsUnstable*(self: T, path: string, unstable: bool)

# Visit web plugin information. Can be called on any thread in the browser
# process.
proc NCVisitWebPluginInfo*(visitor: NCWebPluginInfoVisitor) =
  wrapProc(cef_visit_web_plugin_info, visitor)

# Cause the plugin list to refresh the next time it is accessed regardless of
# whether it has already been loaded. Can be called on any thread in the
# browser process.
proc NCRefreshWebPlugins*() =
  wrapProc(cef_refresh_web_plugins)

# Add a plugin path (directory + file). This change may not take affect until
# after cef_refresh_web_plugins() is called. Can be called on any thread in the
# browser process.
proc NCAddWebPluginPath*(path: string) =
  wrapProc(cef_add_web_plugin_path, path)

# Add a plugin directory. This change may not take affect until after
# cef_refresh_web_plugins() is called. Can be called on any thread in the
# browser process.
proc NCAddWebPluginDirectory*(dir: string) =
  wrapProc(cef_add_web_plugin_directory, dir)

# Remove a plugin path (directory + file). This change may not take affect
# until after cef_refresh_web_plugins() is called. Can be called on any thread
# in the browser process.
proc NCRemoveWebPluginPath*(path: string) =
  wrapProc(cef_remove_web_plugin_path, path)

# Unregister an internal plugin. This may be undone the next time
# cef_refresh_web_plugins() is called. Can be called on any thread in the
# browser process.
proc NCUnregisterInternalWebPlugin*(path: string) =
  wrapProc(cef_unregister_internal_web_plugin, path)

# Force a plugin to shutdown. Can be called on any thread in the browser
# process but will be executed on the IO thread.
proc NCForceWebPluginShutdown*(path: string) =
  wrapProc(cef_force_web_plugin_shutdown, path)

# Register a plugin crash. Can be called on any thread in the browser process
# but will be executed on the IO thread.
proc NCRegisterWebPluginCrash*(path: string) =
  wrapProc(cef_register_web_plugin_crash, path)

# Query if a plugin is unstable. Can be called on any thread in the browser
# process.
proc NCIsWebPluginUnstable*(path: string, callback: NCWebPluginUnstableCallback) =
  wrapProc(cef_is_web_plugin_unstable, path, callback)
