import cef_base
include cef_import

type
  # Callback structure for asynchronous continuation of file dialog requests.
  cef_file_dialog_callback* = object
    # Base structure.
    base*: cef_base

    # Continue the file selection. |selected_accept_filter| should be the 0-based
    # index of the value selected from the accept filters array passed to
    # cef_dialog_handler_t::OnFileDialog. |file_paths| should be a single value
    # or a list of values depending on the dialog mode. An NULL |file_paths|
    # value is treated the same as calling cancel().
    cont*: proc(self: ptr cef_file_dialog_callback,
      selected_accept_filter: cint, file_paths: cef_string_list) {.cef_callback.}
  
    # Cancel the file selection.
    cancel*: proc(self: ptr cef_file_dialog_callback) {.cef_callback.}

  # Implement this structure to handle dialog events. The functions of this
  # structure will be called on the browser process UI thread.
  cef_dialog_handler* = object
    # Base structure.
    base*: cef_base

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
  
    on_file_dialog*: proc(self: ptr cef_dialog_handler,
      browser: ptr_cef_browser, mode: cef_file_dialog_mode,
      title, default_file_path: ptr cef_string,
      accept_filters: cef_string_list, selected_accept_filter: cint,
      callback: ptr cef_file_dialog_callback): cint {.cef_callback.}

