import cef_base, cef_values, cef_browser, cef_request, cef_frame
import cef_dom, cef_process_message
include cef_import

type
  # Structure used to implement render process callbacks. The functions of this
  # structure will be called on the render process main thread (TID_RENDERER)
  # unless otherwise indicated.
  cef_render_process_handler* = object
    base*: cef_base

    # Called after the render process main thread has been created. |extra_info|
    # is a read-only value originating from
    # cef_browser_process_handler_t::on_render_process_thread_created(). Do not
    # keep a reference to |extra_info| outside of this function.
    on_render_thread_created*: proc(self: ptr cef_render_process_handler,
      extra_info: ptr cef_list_value) {.cef_callback.}
  
    # Called after WebKit has been initialized.
    on_web_kit_initialized*: proc(self: ptr cef_render_process_handler) {.cef_callback.}
  
    # Called after a browser has been created. When browsing cross-origin a new
    # browser will be created before the old browser with the same identifier is
    # destroyed.
    on_browser_created*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser) {.cef_callback.}
  
    # Called before a browser is destroyed.
    on_browser_destroyed*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser) {.cef_callback.}
  
    # Return the handler for browser load status events.
    get_load_handler*: proc(self: ptr cef_render_process_handler): ptr cef_load_handler {.cef_callback.}
  
    # Called before browser navigation. Return true (1) to cancel the navigation
    # or false (0) to allow the navigation to proceed. The |request| object
    # cannot be modified in this callback.
    on_before_navigation*: proc(self: ptr cef_render_process_handler,
        browser: ptr cef_browser, frame: ptr cef_frame,
        request: ptr cef_request, navigation_type: cef_navigation_type,
        is_redirect: int): int {.cef_callback.}
  
    # Called immediately after the V8 context for a frame has been created. To
    # retrieve the JavaScript 'window' object use the
    # cef_v8context_t::get_global() function. V8 handles can only be accessed
    # from the thread on which they are created. A task runner for posting tasks
    # on the associated thread can be retrieved via the
    # cef_v8context_t::get_task_runner() function.
    on_context_created*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser, frame: ptr cef_frame,
      context: ptr cef_v8context) {.cef_callback.}
  
    # Called immediately before the V8 context for a frame is released. No
    # references to the context should be kept after this function is called.
    on_context_released*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser, frame: ptr cef_frame,
      context: ptr cef_v8context) {.cef_callback.}
    
    # Called for global uncaught exceptions in a frame. Execution of this
    # callback is disabled by default. To enable set
    # CefSettings.uncaught_exception_stack_size > 0.
    on_uncaught_exception*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser, frame: ptr cef_frame,
      context: ptr cef_v8context, exception: ptr cef_v8exception,
      stackTrace: ptr cef_v8stack_trace) {.cef_callback.}
  
    # Called when a new node in the the browser gets focus. The |node| value may
    # be NULL if no specific node has gained focus. The node object passed to
    # this function represents a snapshot of the DOM at the time this function is
    # executed. DOM objects are only valid for the scope of this function. Do not
    # keep references to or attempt to access any DOM objects outside the scope
    # of this function.
    on_focused_node_changed*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser, frame: ptr cef_frame,
      node: ptr cef_domnode) {.cef_callback.}
  
    # Called when a new message is received from a different process. Return true
    # (1) if the message was handled or false (0) otherwise. Do not keep a
    # reference to or attempt to access the message outside of this callback.
    on_process_message_received*: proc(self: ptr cef_render_process_handler,
      browser: ptr cef_browser, source_process: cef_process_id,
      message: ptr cef_process_message): int {.cef_callback.}
