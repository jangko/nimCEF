import cef_base, cef_command_line, cef_scheme, cef_request
include cef_import

type
  cef_app* {.pure.} = object
    base*: cef_base
    
    # Provides an opportunity to view and/or modify command-line arguments before
    # processing by CEF and Chromium. The |process_type| value will be NULL for
    # the browser process. Do not keep a reference to the cef_command_line_t
    # object passed to this function. The CefSettings.command_line_args_disabled
    # value can be used to start with an NULL command-line object. Any values
    # specified in CefSettings that equate to command-line arguments will be set
    # before this function is called. Be cautious when using this function to
    # modify command-line arguments for non-browser processes as this may result
    # in undefined behavior including crashes.
    on_before_command_line_processing*: proc(self: ptr cef_app,
      process_type: ptr cef_string, command_line: ptr cef_command_line) {.cef_callback.}

    # Provides an opportunity to register custom schemes. Do not keep a reference
    # to the |registrar| object. This function is called on the main thread for
    # each process and the registered schemes should be the same across all
    # processes.
    on_register_custom_schemes*: proc(self: ptr cef_app, registrar: ptr cef_scheme_registrar) {.cef_callback.}

    # Return the handler for resource bundle events. If
    # CefSettings.pack_loading_disabled is true (1) a handler must be returned.
    # If no handler is returned resources will be loaded from pack files. This
    # function is called by the browser and render processes on multiple threads.
    get_resource_bundle_handler*: proc(self: ptr cef_app): ptr cef_resource_bundle_handler {.cef_callback.}

    # Return the handler for functionality specific to the browser process. This
    # function is called on multiple threads in the browser process.
    get_browser_process_handler*: proc(self: ptr cef_app): ptr cef_browser_process_handler {.cef_callback.}

    # Return the handler for functionality specific to the render process. This
    # function is called on the render process main thread.
    get_render_process_handler*: proc(self: ptr cef_app): ptr cef_render_process_handler {.cef_callback.}
    
# This function should be called from the application entry point function to
# execute a secondary process. It can be used to run secondary processes from
# the browser client executable (default behavior) or from a separate
# executable specified by the CefSettings.browser_subprocess_path value. If
# called for the browser process (identified by no "type" command-line value)
# it will return immediately with a value of -1. If called for a recognized
# secondary process it will block until the process should exit and then return
# the process exit code. The |application| parameter may be NULL. The
# |windows_sandbox_info| parameter is only used on Windows and may be NULL (see
# cef_sandbox_win.h for details).

proc cef_execute_process*(args: ptr cef_main_args,
    application: ptr cef_app, windows_sandbox_info: pointer): int {.cef_import.}

# This function should be called on the main application thread to initialize
# the CEF browser process. The |application| parameter may be NULL. A return
# value of true (1) indicates that it succeeded and false (0) indicates that it
# failed. The |windows_sandbox_info| parameter is only used on Windows and may
# be NULL (see cef_sandbox_win.h for details).

proc cef_initialize*(args: ptr cef_main_args,
    settings: ptr cef_settings, application: ptr cef_app,
    windows_sandbox_info: pointer): int {.cef_import.}

# This function should be called on the main application thread to shut down
# the CEF browser process before the application exits.

proc cef_shutdown*() {.cef_import.}

# Perform a single iteration of CEF message loop processing. This function is
# used to integrate the CEF message loop into an existing application message
# loop. Care must be taken to balance performance against excessive CPU usage.
# This function should only be called on the main application thread and only
# if cef_initialize() is called with a CefSettings.multi_threaded_message_loop
# value of false (0). This function will not block.

proc cef_do_message_loop_work*() {.cef_import.}

# Run the CEF message loop. Use this function instead of an application-
# provided message loop to get the best balance between performance and CPU
# usage. This function should only be called on the main application thread and
# only if cef_initialize() is called with a
# CefSettings.multi_threaded_message_loop value of false (0). This function
# will block until a quit message is received by the system.

proc cef_run_message_loop*() {.cef_import.}

# Quit the CEF message loop that was started by calling cef_run_message_loop().
# This function should only be called on the main application thread and only
# if cef_run_message_loop() was used.

proc cef_quit_message_loop*() {.cef_import.}

# Set to true (1) before calling Windows APIs like TrackPopupMenu that enter a
# modal message loop. Set to false (0) after exiting the modal message loop.

proc cef_set_osmodal_loop*(osModalLoop: int) {.cef_import.}

# Call during process startup to enable High-DPI support on Windows 7 or newer.
# Older versions of Windows should be left DPI-unaware because they do not
# support DirectWrite and GDI fonts are kerned very badly.

proc cef_enable_highdpi_support*() {.cef_import.}
