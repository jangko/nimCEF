import cef/cef_base_api, nc_util, nc_internal
include cef/cef_import

proc on_before_command_line_processing(self: ptr cef_app,
  process_type: ptr cef_string, command_line: ptr cef_command_line) {.cef_callback.} =
  app_to_app(self).OnBeforeCommandLineProcessing($process_type, command_line)
  release(command_line)
  
proc on_register_custom_schemes(self: ptr cef_app, registrar: ptr cef_scheme_registrar) {.cef_callback.} =
  app_to_app(self).OnRegisterCustomSchemes(registrar)
  release(registrar)
  
proc get_resource_bundle_handler(self: ptr cef_app): ptr cef_resource_bundle_handler {.cef_callback.} =
  result = app_to_app(self).GetResourceBundleHandler()

proc get_browser_process_handler(self: ptr cef_app): ptr cef_browser_process_handler {.cef_callback.} =
  result = app_to_app(self).GetBrowserProcessHandler()
  
proc get_render_process_handler(self: ptr cef_app): ptr cef_render_process_handler {.cef_callback.} =
  result = app_to_app(self).GetRenderProcessHandler()

proc initialize_app_handler*(app: ptr cef_app) = 
  init_base(app)
  app.on_before_command_line_processing = on_before_command_line_processing
  app.on_register_custom_schemes = on_register_custom_schemes
  app.get_resource_bundle_handler = get_resource_bundle_handler
  app.get_browser_process_handler = get_browser_process_handler
  app.get_render_process_handler = get_render_process_handler