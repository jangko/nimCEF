import nc_util, impl/nc_util_impl, cef/cef_render_process_handler_api
import nc_types, nc_value, nc_load_handler, nc_request, nc_v8, nc_dom
import nc_process_message, cef/cef_browser_api, cef/cef_load_handler_api
include cef/cef_import

# Structure used to implement render process callbacks. The functions of this
# structure will be called on the render process main thread (TID_RENDERER)
# unless otherwise indicated.
wrapCallback(NCRenderProcessHandler, cef_render_process_handler):
  # Called after the render process main thread has been created. |extra_info|
  # is a read-only value originating from
  # NCBrowserProcessHandler::OnRenderProcessThreadCreated(). Do not
  # keep a reference to |extra_info| outside of this function.
  proc OnRenderThreadCreated*(self: T, extra_info: NCListValue)

  # Called after WebKit has been initialized.
  proc OnWebKitInitialized*(self: T)

  # Called after a browser has been created. When browsing cross-origin a new
  # browser will be created before the old browser with the same identifier is
  # destroyed.
  proc OnBrowserCreated*(self: T, browser: NCBrowser)

  # Called before a browser is destroyed.
  proc OnBrowserDestroyed*(self: T, browser: NCBrowser)

  # Return the handler for browser load status events.
  proc GetLoadHandler*(self: T): NCLoadHandler

  # Called before browser navigation. Return true (1) to cancel the navigation
  # or false (0) to allow the navigation to proceed. The |request| object
  # cannot be modified in this callback.
  proc OnBeforeNavigation*(self: T, browser: NCBrowser, frame: NCFrame,
    request: NCRequest, navigation_type: cef_navigation_type, is_redirect: bool): bool

  # Called immediately after the V8 context for a frame has been created. To
  # retrieve the JavaScript 'window' object use the
  # NCV8Context::GetGlobal() function. V8 handles can only be accessed
  # from the thread on which they are created. A task runner for posting tasks
  # on the associated thread can be retrieved via the
  # NCV8Context::GetTaskRunner() function.
  proc OnContextCreated*(self: T, browser: NCBrowser, frame: NCFrame,
    context: NCV8Context)

  # Called immediately before the V8 context for a frame is released. No
  # references to the context should be kept after this function is called.
  proc OnContextReleased*(self: T, browser: NCBrowser, frame: NCFrame,
    context: NCV8Context)

  # Called for global uncaught exceptions in a frame. Execution of this
  # callback is disabled by default. To enable set
  # CefSettings.uncaught_exception_stack_size > 0.
  proc OnUncaughtException*(self: T, browser: NCBrowser, frame: NCFrame,
    context: NCV8Context, exception: NCV8Exception,
    stackTrace: NCV8StackTrace)

  # Called when a new node in the the browser gets focus. The |node| value may
  # be NULL if no specific node has gained focus. The node object passed to
  # this function represents a snapshot of the DOM at the time this function is
  # executed. DOM objects are only valid for the scope of this function. Do not
  # keep references to or attempt to access any DOM objects outside the scope
  # of this function.
  proc OnFocusedNodeChanged*(self: T, browser: NCBrowser, frame: NCFrame, node: NCDomNode)

  # Called when a new message is received from a different process. Return true
  # (1) if the message was handled or false (0) otherwise. Do not keep a
  # reference to or attempt to access the message outside of this callback.
  proc OnBrowserProcessMessageReceived*(self: T, browser: NCBrowser, source_process: cef_process_id,
    message: NCProcessMessage): bool