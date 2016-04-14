import cef/cef_base_api, nc_util, nc_types, cef/cef_values_api, cef/cef_browser_api
import cef/cef_request_api, cef/cef_v8_api, cef/cef_dom_api, cef/cef_process_message_api
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
  let app = app_to_app(self)
  if app.render_process_handler != nil:
    result = app.render_process_handler.handler.addr
  else:
    result = nil

proc initialize_app_handler*(app: ptr cef_app) = 
  init_base(app)
  app.on_before_command_line_processing = on_before_command_line_processing
  app.on_register_custom_schemes = on_register_custom_schemes
  app.get_resource_bundle_handler = get_resource_bundle_handler
  app.get_browser_process_handler = get_browser_process_handler
  app.get_render_process_handler = get_render_process_handler
  
type
  NCDummyBase = object
    refcount: int
    container: pointer
    
proc toApp[T](handler: T): NCApp =
  var base = cast[ptr NCDummyBase](cast[int](handler) - sizeof(int) - sizeof(pointer))
  result = cast[NCApp](base.container)

proc on_render_thread_created*(self: ptr cef_render_process_handler,
  extra_info: ptr cef_list_value) {.cef_callback.} =
  toApp(self).OnRenderThreadCreated(extra_info)
  release(extra_info)
    
proc on_web_kit_initialized*(self: ptr cef_render_process_handler) {.cef_callback.} =
  toApp(self).OnWebKitInitialized()

proc on_browser_created*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser) {.cef_callback.} =
  toApp(self).OnBrowserCreated(browser)
  release(browser)

proc on_browser_destroyed*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser) {.cef_callback.} =
  toApp(self).OnBrowserDestroyed(browser)
  release(browser)

proc get_load_handler*(self: ptr cef_render_process_handler): ptr cef_load_handler {.cef_callback.} =
  result = toApp(self).GetLoadHandler()
  
proc on_before_navigation*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser, frame: ptr cef_frame,
  request: ptr cef_request, navigation_type: cef_navigation_type,
  is_redirect: cint): cint {.cef_callback.} =  
  result = toApp(self).OnBeforeNavigation(browser, frame, request, navigation_type, is_redirect == 1.cint).cint
  release(browser)
  release(frame)
  release(request)
  
proc on_context_created*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser, frame: ptr cef_frame,
  context: ptr cef_v8context) {.cef_callback.} =
  toApp(self).OnContextCreated(browser, frame, context)
  release(browser)
  release(frame)
  release(context)
  
proc on_context_released*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser, frame: ptr cef_frame,
  context: ptr cef_v8context) {.cef_callback.} =
  toApp(self).OnContextReleased(browser, frame, context)
  release(browser)
  release(frame)
  release(context)
  
proc on_uncaught_exception*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser, frame: ptr cef_frame,
  context: ptr cef_v8context, exception: ptr cef_v8exception,
  stackTrace: ptr cef_v8stack_trace) {.cef_callback.} =
  toApp(self).OnUncaughtException(browser, frame, context, exception, stackTrace)
  release(browser)
  release(frame)
  release(context)
  release(exception)
  release(stackTrace)
  
proc on_focused_node_changed*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser, frame: ptr cef_frame,
  node: ptr cef_domnode) {.cef_callback.} =
  toApp(self).OnFocusedNodeChanged(browser, frame, node)
  release(browser)
  release(frame)
  release(node)
  
proc on_process_message_received*(self: ptr cef_render_process_handler,
  browser: ptr cef_browser, source_process: cef_process_id,
  message: ptr cef_process_message): cint {.cef_callback.} =
  result = toApp(self).OnBrowserProcessMessageReceived(browser, source_process, message).cint
  release(browser)
  release(message)
  
proc initialize_render_process_handler*(render: ptr cef_render_process_handler) =
  init_base(render)
  render.on_render_thread_created = on_render_thread_created
  render.on_web_kit_initialized = on_web_kit_initialized
  render.on_browser_created = on_browser_created
  render.on_browser_destroyed = on_browser_destroyed
  render.get_load_handler = get_load_handler
  render.on_before_navigation = on_before_navigation
  render.on_context_created = on_context_created
  render.on_context_released = on_context_released
  render.on_uncaught_exception = on_uncaught_exception
  render.on_focused_node_changed = on_focused_node_changed
  render.on_process_message_received = on_process_message_received