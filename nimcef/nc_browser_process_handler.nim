import nc_util, nc_util_impl, cef_browser_process_handler_api
import nc_command_line, nc_value, nc_print_handler
import cef_print_handler_api
include cef_import

# Structure used to implement browser process callbacks. The functions of this
# structure will be called on the browser process main thread unless otherwise
# indicated.
wrapCallback(NCBrowserProcessHandler, cef_browser_process_handler):
  # Called on the browser process UI thread immediately after the CEF context
  # has been initialized.
  proc onContextInitialized*(self: T)

  # Called before a child process is launched. Will be called on the browser
  # process UI thread when launching a render process and on the browser
  # process IO thread when launching a GPU or plugin process. Provides an
  # opportunity to modify the child process command line. Do not keep a
  # reference to |command_line| outside of this function.
  proc onBeforeChildProcessLaunch*(self: T, command_line: NCCommandLine)

  # Called on the browser process IO thread after the main thread has been
  # created for a new render process. Provides an opportunity to specify extra
  # information that will be passed to
  # NCRenderProcessHandler::OnRenderThreadCreated() in the render
  # process. Do not keep a reference to |extra_info| outside of this function.
  proc onRenderProcessThreadCreated*(self: T, extra_info: NCListValue)

  # Return the handler for printing on Linux. If a print handler is not
  # provided then printing will not be supported on the Linux platform.
  proc getPrintHandler*(self: T): NCPrintHandler

  # Called from any thread when work has been scheduled for the browser process
  # main (UI) thread. This callback is used in combination with CefSettings.
  # external_message_pump and cef_do_message_loop_work() in cases where the CEF
  # message loop must be integrated into an existing application message loop
  # (see additional comments and warnings on CefDoMessageLoopWork). This
  # callback should schedule a cef_do_message_loop_work() call to happen on the
  # main (UI) thread. |delay_ms| is the requested delay in milliseconds. If
  # |delay_ms| is <= 0 then the call should happen reasonably soon. If
  # |delay_ms| is > 0 then the call should be scheduled to happen after the
  # specified delay and any currently pending scheduled call should be cancelled.
  proc onScheduleMessagePumpWork*(self: T, delay_ms: int64)