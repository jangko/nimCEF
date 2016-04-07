import cef_base_api, cef_print_settings_api
include cef_import

type
  # Callback structure for asynchronous continuation of print dialog requests.
  cef_print_dialog_callback* = object
    base*: cef_base
  
    # Continue printing with the specified |settings|.
    cont*: proc(self: ptr cef_print_dialog_callback,
      settings: ptr cef_print_settings) {.cef_callback.}

    # Cancel the printing.
    cancel*: proc(self: ptr cef_print_dialog_callback) {.cef_callback.}

  # Callback structure for asynchronous continuation of print job requests.
  cef_print_job_callback* = object
    base*: cef_base

    # Indicate completion of the print job.
    cont*: proc(self: ptr cef_print_job_callback) {.cef_callback.}

  # Implement this structure to handle printing on Linux. The functions of this
  # structure will be called on the browser process UI thread.
  cef_print_handler* = object
    base*: cef_base
  
    # Called when printing has started for the specified |browser|. This function
    # will be called before the other OnPrint*() functions and irrespective of
    # how printing was initiated (e.g. cef_browser_host_t::print(), JavaScript
    # window.print() or PDF extension print button).
    on_print_start*: proc(self: ptr cef_print_handler,
      browser: ptr_cef_browser) {.cef_callback.}
  
    # Synchronize |settings| with client state. If |get_defaults| is true (1)
    # then populate |settings| with the default print settings. Do not keep a
    # reference to |settings| outside of this callback.
    on_print_settings*: proc(self: ptr cef_print_handler,
      settings: ptr cef_print_settings, get_defaults: cint) {.cef_callback.}
  
    # Show the print dialog. Execute |callback| once the dialog is dismissed.
    # Return true (1) if the dialog will be displayed or false (0) to cancel the
    # printing immediately.
    on_print_dialog*: proc(self: ptr cef_print_handler,
      has_selection: cint, callback: ptr cef_print_dialog_callback): cint {.cef_callback.}
  
    # Send the print job to the printer. Execute |callback| once the job is
    # completed. Return true (1) if the job will proceed or false (0) to cancel
    # the job immediately.
    on_print_job*: proc(self: ptr cef_print_handler,
      document_name, pdf_file_path: ptr cef_string,
      callback: ptr cef_print_job_callback): cint {.cef_callback.}
  
    # Reset client state related to printing.
    on_print_reset*: proc(self: ptr cef_print_handler) {.cef_callback.}
  
    # Return the PDF paper size in device units. Used in combination with
    # cef_browser_host_t::print_to_pdf().
    get_pdf_paper_size*: proc(self: ptr cef_print_handler, 
      device_units_per_inch: cint): cef_size {.cef_callback.}