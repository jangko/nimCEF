import cef/cef_app_api

type
  # Implement this structure to provide handler implementations. Methods will be
  # called by the process and/or thread indicated.
  NCApp* = ref object of RootObj
    app_handler*: cef_app
  
# Provides an opportunity to view and/or modify command-line arguments before
# processing by CEF and Chromium. The |process_type| value will be NULL for
# the browser process. Do not keep a reference to the cef_command_line_t
# object passed to this function. The CefSettings.command_line_args_disabled
# value can be used to start with an NULL command-line object. Any values
# specified in CefSettings that equate to command-line arguments will be set
# before this function is called. Be cautious when using this function to
# modify command-line arguments for non-browser processes as this may result
# in undefined behavior including crashes.  
method OnBeforeCommandLineProcessing*(self: NCApp, process_type: string, command_line: ptr cef_command_line) {.base.} =
  discard

# Provides an opportunity to register custom schemes. Do not keep a reference
# to the |registrar| object. This function is called on the main thread for
# each process and the registered schemes should be the same across all
# processes.
method OnRegisterCustomSchemes*(self: NCApp, registrar: ptr cef_scheme_registrar) {.base.} =
  discard

# Return the handler for resource bundle events. If
# CefSettings.pack_loading_disabled is true (1) a handler must be returned.
# If no handler is returned resources will be loaded from pack files. This
# function is called by the browser and render processes on multiple threads.
method GetResourceBundleHandler*(self: NCApp): ptr cef_resource_bundle_handler {.base.} =
  result = nil

# Return the handler for functionality specific to the browser process. This
# function is called on multiple threads in the browser process.
method GetBrowserProcessHandler*(self: NCApp): ptr cef_browser_process_handler {.base.} =
  result = nil

# Return the handler for functionality specific to the render process. This
# function is called on the render process main thread.
method GetRenderProcessHandler*(self: NCApp): ptr cef_render_process_handler {.base.} =
  result = nil
  
proc GetHandler*(app: NCApp): ptr cef_app = app.app_handler.addr