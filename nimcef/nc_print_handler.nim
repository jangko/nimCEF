import nc_print_settings, nc_types, nc_util, cef_print_handler_api
import nc_util_impl, cef_browser_api, cef_print_settings_api
include cef_import

# Callback structure for asynchronous continuation of print dialog requests.
wrapAPI(NCPrintDialogCallback, cef_print_dialog_callback, false)

# Callback structure for asynchronous continuation of print job requests.
wrapAPI(NCPrintJobCallback, cef_print_job_callback, false)

# Implement this structure to handle printing on Linux. The functions of this
# structure will be called on the browser process UI thread.
wrapCallback(NCPrintHandler, cef_print_handler):
  # Called when printing has started for the specified |browser|. This function
  # will be called before the other OnPrint*() functions and irrespective of
  # how printing was initiated (e.g. NCBrowserHost::Print(), JavaScript
  # window.print() or PDF extension print button).
  proc OnPrintStart*(self: T, browser: NCBrowser)

  # Synchronize |settings| with client state. If |get_defaults| is true (1)
  # then populate |settings| with the default print settings. Do not keep a
  # reference to |settings| outside of this callback.
  proc OnPrintSettings*(self: T, settings: NCPrintSettings, getDefaults: bool)

  # Show the print dialog. Execute |callback| once the dialog is dismissed.
  # Return true (1) if the dialog will be displayed or false (0) to cancel the
  # printing immediately.
  proc OnPrintDialog*(self: T,  hasSelection: bool, callback: NCPrintDialogCallback): bool

  # Send the print job to the printer. Execute |callback| once the job is
  # completed. Return true (1) if the job will proceed or false (0) to cancel
  # the job immediately.
  proc OnPrintJob*(self: T, documentName, pdfFilePath: string, callback: NCPrintJobCallback): bool

  # Reset client state related to printing.
  proc OnPrintReset*(self: T)

  # Return the PDF paper size in device units. Used in combination with
  # NCBrowserHost::PrintToPdf().
  proc GetPdfPaperSize*(self: T,  device_units_per_inch: int): NCSize


# Continue printing with the specified |settings|.
proc Continue*(self: NCPrintDialogCallback, settings: NCPrintSettings) =
  self.wrapCall(cont, settings)

# Cancel the printing.
proc Cancel*(self: NCPrintDialogCallback) =
  self.wrapCall(cancel)

# Indicate completion of the print job.
proc Continue*(self: NCPrintJobCallback) =
  self.wrapCall(cont)