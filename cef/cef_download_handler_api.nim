import cef_base_api, cef_download_item_api
include cef_import

type
  # Callback structure used to asynchronously continue a download.
  cef_before_download_callback* = object
    # Base structure.
    base*: cef_base

    # Call to continue the download. Set |download_path| to the full file path
    # for the download including the file name or leave blank to use the
    # suggested name and the default temp directory. Set |show_dialog| to true
    # (1) if you do wish to show the default "Save As" dialog.
    cont*: proc(self: ptr cef_before_download_callback,
      download_path: ptr cef_string, show_dialog: cint) {.cef_callback.}

  # Callback structure used to asynchronously cancel a download.
  cef_download_item_callback* = object
    # Base structure.
    base*: cef_base

    # Call to cancel the download.
    cancel*: proc(self: ptr cef_download_item_callback) {.cef_callback.}

    # Call to pause the download.
    pause*: proc(self: ptr cef_download_item_callback) {.cef_callback.}

    # Call to resume the download.
    resume*: proc(self: ptr cef_download_item_callback) {.cef_callback.}


  # Structure used to handle file downloads. The functions of this structure will
  # called on the browser process UI thread.
  cef_download_handler* = object
    # Base structure.
    base*: cef_base

    # Called before a download begins. |suggested_name| is the suggested name for
    # the download file. By default the download will be canceled. Execute
    # |callback| either asynchronously or in this function to continue the
    # download if desired. Do not keep a reference to |download_item| outside of
    # this function.
    on_before_download*: proc(self: ptr cef_download_handler,
      browser: ptr_cef_browser,
      download_item: ptr cef_download_item,
      suggested_name: ptr cef_string,
      callback: ptr cef_before_download_callback) {.cef_callback.}

    # Called when a download's status or progress information has been updated.
    # This may be called multiple times before and after on_before_download().
    # Execute |callback| either asynchronously or in this function to cancel the
    # download if desired. Do not keep a reference to |download_item| outside of
    # this function.
    on_download_updated*: proc(self: ptr cef_download_handler,
      browser: ptr_cef_browser,
      download_item: ptr cef_download_item,
      callback: ptr cef_download_item_callback) {.cef_callback.}

