import nc_util, nc_util_impl, cef_dialog_handler_api, nc_types, nc_drag_data
include cef_import

# Callback structure for asynchronous continuation of file dialog requests.
wrapAPI(NCFileDialogCallback, cef_file_dialog_callback, false)

# Continue the file selection. |selected_accept_filter| should be the 0-based
# index of the value selected from the accept filters array passed to
# NCDialogHandler::OnFileDialog. |file_paths| should be a single value
# or a list of values depending on the dialog mode. An NULL |file_paths|
# value is treated the same as calling cancel().
proc continueCallback*(self: NCFileDialogCallback, selected_accept_filter: int, file_paths: seq[string]) =
  self.wrapCall(cont, selected_accept_filter, file_paths)

# Cancel the file selection.
proc cancel*(self: NCFileDialogCallback) =
  self.wrapCall(cancel)

# Implement this structure to handle dialog events. The functions of this
# structure will be called on the browser process UI thread.
wrapCallback(NCDialogHandler, cef_dialog_handler):
  # Called to run a file chooser dialog. |mode| represents the type of dialog
  # to display. |title| to the title to be used for the dialog and may be NULL
  # to show the default title ("Open" or "Save" depending on the mode).
  # |default_file_path| is the path with optional directory and/or file name
  # component that should be initially selected in the dialog. |accept_filters|
  # are used to restrict the selectable file types and may any combination of
  # (a) valid lower-cased MIME types (e.g. "text/*" or "image/*"), (b)
  # individual file extensions (e.g. ".txt" or ".png"), or (c) combined
  # description and file extension delimited using "|" and ";" (e.g. "Image
  # Types|.png;.gif;.jpg"). |selected_accept_filter| is the 0-based index of
  # the filter that should be selected by default. To display a custom dialog
  # return true (1) and execute |callback| either inline or at a later time. To
  # display the default dialog return false (0).
  proc onFileDialog*(self: T, browser: NCBrowser, mode: cef_file_dialog_mode,
    title, default_file_path: string, accept_filters: seq[string],
    selected_accept_filter: int, callback: NCFileDialogCallback): bool