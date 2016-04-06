import cef_base
include cef_import

type
  # Callback structure used for asynchronous continuation of JavaScript dialog
  # requests.
  cef_jsdialog_callback* = object
    base*: cef_base

    # Continue the JS dialog request. Set |success| to true (1) if the OK button
    # was pressed. The |user_input| value should be specified for prompt dialogs.
    cont*: proc(self: ptr cef_jsdialog_callback, success: int,
      user_input: ptr cef_string) {.cef_callback.}


  # Implement this structure to handle events related to JavaScript dialogs. The
  # functions of this structure will be called on the UI thread.
  cef_jsdialog_handler* = object
    base*: cef_base

    # Called to run a JavaScript dialog. If |origin_url| and |accept_lang| are
    # non-NULL they can be passed to the CefFormatUrlForSecurityDisplay function
    # to retrieve a secure and user-friendly display string. The
    # |default_prompt_text| value will be specified for prompt dialogs only. Set
    # |suppress_message| to true (1) and return false (0) to suppress the message
    # (suppressing messages is preferable to immediately executing the callback
    # as this is used to detect presumably malicious behavior like spamming alert
    # messages in onbeforeunload). Set |suppress_message| to false (0) and return
    # false (0) to use the default implementation (the default implementation
    # will show one modal dialog at a time and suppress any additional dialog
    # requests until the displayed dialog is dismissed). Return true (1) if the
    # application will use a custom dialog or if the callback has been executed
    # immediately. Custom dialogs may be either modal or modeless. If a custom
    # dialog is used the application must execute |callback| once the custom
    # dialog is dismissed.
    on_jsdialog*: proc(self: ptr cef_jsdialog_handler,
        browser: ptr_cef_browser, origin_url, accept_lang: ptr cef_string, 
        dialog_type: cef_jsdialog_type,
        message_text, default_prompt_text: ptr cef_string,
        callback: ptr cef_jsdialog_callback, suppress_message: var int): int {.cef_callback.}

    # Called to run a dialog asking the user if they want to leave a page. Return
    # false (0) to use the default dialog implementation. Return true (1) if the
    # application will use a custom dialog or if the callback has been executed
    # immediately. Custom dialogs may be either modal or modeless. If a custom
    # dialog is used the application must execute |callback| once the custom
    # dialog is dismissed.
    on_before_unload_dialog*: proc(self: ptr cef_jsdialog_handler, 
      browser: ptr_cef_browser, message_text: ptr cef_string, is_reload: int,
      callback: ptr cef_jsdialog_callback): int {.cef_callback.}

    # Called to cancel any pending dialogs and reset any saved dialog state. Will
    # be called due to events like page navigation irregardless of whether any
    # dialogs are currently pending.
    on_reset_dialog_state*: proc(self: ptr cef_jsdialog_handler, 
      browser: ptr_cef_browser) {.cef_callback.}

    # Called when the default implementation dialog is closed.
    on_dialog_closed*: proc(self: ptr cef_jsdialog_handler,
      browser: ptr_cef_browser) {.cef_callback.}