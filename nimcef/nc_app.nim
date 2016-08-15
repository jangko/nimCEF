import nc_util, nc_util_impl, cef_app_api, nc_command_line
import nc_scheme, nc_types, nc_sandbox_info, nc_settings
import nc_render_process_handler, nc_resource_bundle_handler
import nc_browser_process_handler
include cef_import

# Implement this structure to provide handler implementations. Methods will be
# called by the process and/or thread indicated.
wrapCallback(NCApp, cef_app):
  # Provides an opportunity to view and/or modify command-line arguments before
  # processing by CEF and Chromium. The |process_type| value will be NULL for
  # the browser process. Do not keep a reference to the NCCommandLine
  # object passed to this function. The CefSettings.command_line_args_disabled
  # value can be used to start with an NULL command-line object. Any values
  # specified in CefSettings that equate to command-line arguments will be set
  # before this function is called. Be cautious when using this function to
  # modify command-line arguments for non-browser processes as this may result
  # in undefined behavior including crashes.
  proc onBeforeCommandLineProcessing*(self: T, process_type: string, command_line: NCCommandLine)

  #--NCApp
  # Provides an opportunity to register custom schemes. Do not keep a reference
  # to the |registrar| object. This function is called on the main thread for
  # each process and the registered schemes should be the same across all
  # processes.
  proc onRegisterCustomSchemes*(self: T, registrar: NCSchemeRegistrar)

  # Return the handler for resource bundle events. If
  # CefSettings.pack_loading_disabled is true (1) a handler must be returned.
  # If no handler is returned resources will be loaded from pack files. This
  # function is called by the browser and render processes on multiple threads.
  proc getResourceBundleHandler*(self: T): NCResourceBundleHandler

  # Return the handler for functionality specific to the browser process. This
  # function is called on multiple threads in the browser process.
  proc getBrowserProcessHandler*(self: T): NCBrowserProcessHandler

  # Return the handler for functionality specific to the render process. This
  # function is called on the render process main thread.
  proc getRenderProcessHandler*(self: T): NCRenderProcessHandler

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
proc ncExecuteProcess*(args: NCMainArgs, application: NCApp, windows_sandbox_info: NCSandboxInfo = nil): int =
  wrapProc(cef_execute_process, result, args, application, windows_sandbox_info)

# This function should be called on the main application thread to initialize
# the CEF browser process. The |application| parameter may be NULL. A return
# value of true (1) indicates that it succeeded and false (0) indicates that it
# failed. The |windows_sandbox_info| parameter is only used on Windows and may
# be NULL (see cef_sandbox_win.h for details).
proc ncInitialize*(args: NCMainArgs, settings: NCSettings,
  application: NCApp, windows_sandbox_info: NCSandboxInfo = nil): bool =
  wrapProc(cef_initialize, result, args, settings, application, windows_sandbox_info)

# This function should be called on the main application thread to shut down
# the CEF browser process before the application exits.
proc ncShutdown*() =
  wrapProc(cef_shutdown)

# Perform a single iteration of CEF message loop processing. This function is
# provided for cases where the CEF message loop must be integrated into an
# existing application message loop. Use of this function is not recommended
# for most users; use either the cef_run_message_loop() function or
# CefSettings.multi_threaded_message_loop if possible. When using this function
# care must be taken to balance performance against excessive CPU usage. It is
# recommended to enable the CefSettings.external_message_pump option when using
# this function so that
# cef_browser_process_handler_t::on_schedule_message_pump_work() callbacks can
# facilitate the scheduling process. This function should only be called on the
# main application thread and only if cef_initialize() is called with a
# CefSettings.multi_threaded_message_loop value of false (0). This function
# will not block.
proc ncDoMessageLoopWork*()=
  wrapProc(cef_do_message_loop_work)

# Run the CEF message loop. Use this function instead of an application-
# provided message loop to get the best balance between performance and CPU
# usage. This function should only be called on the main application thread and
# only if cef_initialize() is called with a
# CefSettings.multi_threaded_message_loop value of false (0). This function
# will block until a quit message is received by the system.
proc ncRunMessageLoop*() =
  wrapProc(cef_run_message_loop)

# Quit the CEF message loop that was started by calling cef_run_message_loop().
# This function should only be called on the main application thread and only
# if cef_run_message_loop() was used.
proc ncQuitMessageLoop*() =
  wrapProc(cef_quit_message_loop)

# Set to true (1) before calling Windows APIs like TrackPopupMenu that enter a
# modal message loop. Set to false (0) after exiting the modal message loop.
proc ncSetOSModalLoop*(osModalLoop: bool) =
  wrapProc(cef_set_osmodal_loop, osModalLoop)

# Call during process startup to enable High-DPI support on Windows 7 or newer.
# Older versions of Windows should be left DPI-unaware because they do not
# support DirectWrite and GDI fonts are kerned very badly.
proc ncEnableHighDPISupport*() =
  wrapProc(cef_enable_highdpi_support)
