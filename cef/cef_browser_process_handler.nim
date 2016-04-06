import cef_base, cef_command_line, cef_values, cef_print_handler
include cef_import

type
  # Structure used to implement browser process callbacks. The functions of this
  # structure will be called on the browser process main thread unless otherwise
  # indicated.
  cef_browser_process_handler* = object
    # Base structure.
    base*: cef_base

    # Called on the browser process UI thread immediately after the CEF context
    # has been initialized.
    on_context_initialized*: proc(self: ptr cef_browser_process_handler) {.cef_callback.}

    # Called before a child process is launched. Will be called on the browser
    # process UI thread when launching a render process and on the browser
    # process IO thread when launching a GPU or plugin process. Provides an
    # opportunity to modify the child process command line. Do not keep a
    # reference to |command_line| outside of this function.
    on_before_child_process_launch*: proc(self: ptr cef_browser_process_handler,
      command_line: ptr cef_command_line) {.cef_callback.}

    # Called on the browser process IO thread after the main thread has been
    # created for a new render process. Provides an opportunity to specify extra
    # information that will be passed to
    # cef_render_process_handler_t::on_render_thread_created() in the render
    # process. Do not keep a reference to |extra_info| outside of this function.
    on_render_process_thread_created*: proc(self: ptr cef_browser_process_handler,
      extra_info: ptr cef_list_value) {.cef_callback.}

    # Return the handler for printing on Linux. If a print handler is not
    # provided then printing will not be supported on the Linux platform.
    get_print_handler*: proc(self: ptr cef_browser_process_handler): ptr cef_print_handler {.cef_callback.}

