import nc_util, impl/nc_util_impl, cef/cef_browser_process_handler_api
import nc_command_line, nc_value, nc_print_handler
import cef/cef_print_handler_api
include cef/cef_import

# Structure used to implement browser process callbacks. The functions of this
# structure will be called on the browser process main thread unless otherwise
# indicated.
wrapCallback(NCBrowserProcessHandler, cef_browser_process_handler):
  # Called on the browser process UI thread immediately after the CEF context
  # has been initialized.
  proc OnContextInitialized*(self: T)

  # Called before a child process is launched. Will be called on the browser
  # process UI thread when launching a render process and on the browser
  # process IO thread when launching a GPU or plugin process. Provides an
  # opportunity to modify the child process command line. Do not keep a
  # reference to |command_line| outside of this function.
  proc OnBeforeChildProcessLaunch*(self: T, command_line: NCCommandLine)

  # Called on the browser process IO thread after the main thread has been
  # created for a new render process. Provides an opportunity to specify extra
  # information that will be passed to
  # NCRenderProcessHandler::OnRenderThreadCreated() in the render
  # process. Do not keep a reference to |extra_info| outside of this function.
  proc OnRenderProcessThreadCreated*(self: T, extra_info: NCListValue)

  # Return the handler for printing on Linux. If a print handler is not
  # provided then printing will not be supported on the Linux platform.
  proc GetPrintHandler*(self: T): NCPrintHandler