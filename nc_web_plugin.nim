import nc_types, nc_util
include cef/cef_import

# Information about a specific web plugin.
wrapAPI(NCWebPluginInfo, cef_web_plugin_info)

type
  # Structure to implement for visiting web plugin information. The functions of
  # this structure will be called on the browser process UI thread.
  NCWebPluginInfoVisitor* = ref object of RootObj
    handler: cef_web_plugin_info_visitor

  # Structure to implement for receiving unstable plugin information. The
  # functions of this structure will be called on the browser process IO thread.
  NCWebPluginUnstableCallback* = ref object of RootObj
    handler: cef_web_plugin_unstable_callback


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

# Method that will be called once for each plugin. |count| is the 0-based
# index for the current plugin. |total| is the total number of plugins.
# Return false (0) to stop visiting plugins. This function may never be
# called if no plugins are found.
method WebPluginVisit*(self: NCWebPluginInfoVisitor, info: NCWebPluginInfo, count, total: int): bool {.base.} =
  result = false

proc GetHandler*(self: NCWebPluginInfoVisitor): ptr cef_web_plugin_info_visitor {.inline.} =
  result = self.handler.addr

proc visit(self: ptr cef_web_plugin_info_visitor,
  info: ptr cef_web_plugin_info, count, total: cint): cint {.cef_callback.} =
  var handler = type_to_type(NCWebPluginInfoVisitor, self)
  result = handler.WebPluginVisit(nc_wrap(info), count.int, total.int).cint
  release(info)

proc init_web_plugin_info_visitor(handler: ptr cef_web_plugin_info_visitor) =
  init_base(handler)
  handler.visit = visit

proc makeNCWebPluginInfoVisitor*(T: typedesc): auto =
  result = new(T)
  init_web_plugin_info_visitor(result.GetHandler())

# Method that will be called for the requested plugin. |unstable| will be
# true (1) if the plugin has reached the crash count threshold of 3 times in
# 120 seconds.
method IsUnstable*(self: NCWebPluginUnstableCallback, path: string, unstable: bool) {.base.} =
  discard

proc GetHandler*(self: NCWebPluginUnstableCallback): ptr cef_web_plugin_unstable_callback {.inline.} =
  result = self.handler.addr

proc is_unstable(self: ptr cef_web_plugin_unstable_callback, path: ptr cef_string, unstable: cint) {.cef_callback.} =
  var handler = type_to_type(NCWebPluginUnstableCallback, self)
  handler.IsUnstable($path, unstable == 1.cint)

proc init_web_plugin_unstable_callback(handler: ptr cef_web_plugin_unstable_callback) =
  init_base(handler)
  handler.is_unstable = is_unstable

proc makeNCWebPluginUnstableCallback*(T: typedesc): auto =
  result = new(T)
  init_web_plugin_unstable_callback(result.GetHandler())

# Visit web plugin information. Can be called on any thread in the browser
# process.
proc NCVisitWebPluginInfo*(visitor: NCWebPluginInfoVisitor) =
  debugModeOn()
  #add_ref(visitor.GetHandler())
  #cef_visit_web_plugin_info(visitor.GetHandler())
  #wrapProc(cef_visit_web_plugin_info, visitor)
  debugModeOff()

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
proc NCAddWwebPluginDirectory*(dir: string) =
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
  debugModeOn()
  wrapProc(cef_is_web_plugin_unstable, path, callback)
  debugModeOff()
  add_ref(callback.GetHandler())
  let cpath = to_cef(path)
  cef_is_web_plugin_unstable(cpath, callback.GetHandler())
  nc_free(cpath)