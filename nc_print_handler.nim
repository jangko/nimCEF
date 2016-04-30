import cef/cef_print_handler_api
import nc_print_settings, nc_types, nc_util

type
  # Callback structure for asynchronous continuation of print dialog requests.
  NCPrintDialogCallback* = ref object
    handler: ptr cef_print_dialog_callback
  
  # Callback structure for asynchronous continuation of print job requests.
  NCPrintJobCallback* = ref object
    handler: ptr cef_print_job_callback
    
  # Implement this structure to handle printing on Linux. The functions of this
  # structure will be called on the browser process UI thread.
  nc_print_handler_i*[T] = object
    # Called when printing has started for the specified |browser|. This function
    # will be called before the other OnPrint*() functions and irrespective of
    # how printing was initiated (e.g. cef_browser_host_t::print(), JavaScript
    # window.print() or PDF extension print button).
    OnPrintStart*: proc(self: T, browser: NCBrowser)
  
    # Synchronize |settings| with client state. If |get_defaults| is true (1)
    # then populate |settings| with the default print settings. Do not keep a
    # reference to |settings| outside of this callback.
    OnPrintSettings*: proc(self: T, settings: NCPrintSettings, getDefaults: bool)
  
    # Show the print dialog. Execute |callback| once the dialog is dismissed.
    # Return true (1) if the dialog will be displayed or false (0) to cancel the
    # printing immediately.
    OnPrintDialog*: proc(self: T,  hasSelection: bool, callback: NCPrintDialogCallback): bool
  
    # Send the print job to the printer. Execute |callback| once the job is
    # completed. Return true (1) if the job will proceed or false (0) to cancel
    # the job immediately.
    OnPrintJob*: proc(self: T, documentName, pdfFilePath: string, callback: NCPrintJobCallback): bool
  
    # Reset client state related to printing.
    OnPrintReset*: proc(self: T)
  
    # Return the PDF paper size in device units. Used in combination with
    # cef_browser_host_t::print_to_pdf().
    GetPdfPaperSize*: proc(self: T,  device_units_per_inch: int): cef_size
    
  NCPrintHandler* = ref object of RootObj
    handler: ptr cef_print_handler
      
import impl/nc_util_impl, cef/cef_browser_api, cef/cef_print_settings_api
include cef/cef_import

proc GetHandler*(self: NCPrintDialogCallback): ptr cef_print_dialog_callback {.inline.} =
  result = self.handler
  
proc nc_wrap*(handler: ptr cef_print_dialog_callback): NCPrintDialogCallback =
  new(result, nc_finalizer[NCPrintDialogCallback])
  result.handler = handler
  add_ref(handler)
  
# Continue printing with the specified |settings|.
proc Continue*(self: NCPrintDialogCallback, settings: NCPrintSettings) =
  self.handler.cont(self.handler, settings.GetHandler())

# Cancel the printing.
proc Cancel*(self: NCPrintDialogCallback) =
  self.handler.cancel(self.handler)


proc GetHandler*(self: NCPrintJobCallback): ptr cef_print_job_callback {.inline.} =
  result = self.handler
  
proc nc_wrap*(handler: ptr cef_print_job_callback): NCPrintJobCallback =
  new(result, nc_finalizer[NCPrintJobCallback])
  result.handler = handler
  add_ref(handler)
  
# Indicate completion of the print job.
proc Continue*(self: NCPrintJobCallback) =
  self.handler.cont(self.handler)

type
  nc_print_handler = object of nc_base[cef_print_handler, NCPrintHandler]
    impl: nc_print_handler_i[NCPrintHandler]
  
proc GetHandler*(self: NCPrintHandler): ptr cef_print_handler {.inline.} =
  result = self.handler
  
proc nc_wrap*(handler: ptr cef_print_handler): NCPrintHandler =
  new(result, nc_finalizer[NCPrintHandler])
  result.handler = handler
  add_ref(handler)
  
proc on_print_start*(self: ptr cef_print_handler, browser: ptr_cef_browser) {.cef_callback.} =
  var handler = toType(nc_print_handler, self)
  var brow = b_to_b(browser)
  if handler.impl.OnPrintStart != nil:
    handler.impl.OnPrintStart(handler.container, nc_wrap(brow))
  release(brow)

proc on_print_settings*(self: ptr cef_print_handler, 
  settings: ptr cef_print_settings, get_defaults: cint) {.cef_callback.} =
  var handler = toType(nc_print_handler, self)
  if handler.impl.OnPrintSettings != nil:
    handler.impl.OnPrintSettings(handler.container, nc_wrap(settings), get_defaults == 1.cint)
  release(settings)
  
proc on_print_dialog*(self: ptr cef_print_handler, 
  has_selection: cint, callback: ptr cef_print_dialog_callback): cint {.cef_callback.} =
  var handler = toType(nc_print_handler, self)
  if handler.impl.OnPrintDialog != nil:
    result = handler.impl.OnPrintDialog(handler.container, has_selection == 1.cint, nc_wrap(callback)).cint
  release(callback)
  
proc on_print_job*(self: ptr cef_print_handler,
  document_name, pdf_file_path: ptr cef_string,
  callback: ptr cef_print_job_callback): cint {.cef_callback.} =
  var handler = toType(nc_print_handler, self)
  if handler.impl.OnPrintJob != nil:
    result = handler.impl.OnPrintJob(handler.container, $document_name, $pdf_file_path, nc_wrap(callback)).cint
  release(callback)

proc on_print_reset*(self: ptr cef_print_handler) {.cef_callback.} =
  var handler = toType(nc_print_handler, self)
  if handler.impl.OnPrintReset != nil:
    handler.impl.OnPrintReset(handler.container)

proc get_pdf_paper_size*(self: ptr cef_print_handler, 
  device_units_per_inch: cint): cef_size {.cef_callback.} =
  var handler = toType(nc_print_handler, self)
  if handler.impl.GetPdfPaperSize != nil:
    result = handler.impl.GetPdfPaperSize(handler.container, device_units_per_inch.int)

proc makeNCPrintHandler*[T](impl: nc_print_handler_i[T]): T =
  nc_init(nc_print_handler, T, impl)
  result.handler.on_print_start = on_print_start
  result.handler.on_print_settings = on_print_settings
  result.handler.on_print_dialog = on_print_dialog
  result.handler.on_print_job = on_print_job
  result.handler.on_print_reset = on_print_reset
  result.handler.get_pdf_paper_size = get_pdf_paper_size