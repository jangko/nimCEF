import nc_util, nc_util_impl, cef_jsdialog_handler_api, nc_types, nc_drag_data
include cef_import

# Callback structure used for asynchronous continuation of JavaScript dialog
# requests.
wrapAPI(NCJsDialogCallback, cef_jsdialog_callback, false)

# Continue the JS dialog request. Set |success| to true (1) if the OK button
# was pressed. The |user_input| value should be specified for prompt dialogs.
proc continueCallback*(self: NCJsDialogCallback, success: bool, user_input: string) =
  self.wrapCall(cont, success, user_input)

# Implement this structure to handle events related to JavaScript dialogs. The
# functions of this structure will be called on the UI thread.
wrapCallback(NCJsDialogHandler, cef_jsdialog_handler):
  # Called to run a JavaScript dialog. If |origin_url| is non-NULL it can be
  # passed to the CefFormatUrlForSecurityDisplay function to retrieve a secure
  # and user-friendly display string. The |default_prompt_text| value will be
  # specified for prompt dialogs only. Set |suppress_message| to true (1) and
  # return false (0) to suppress the message (suppressing messages is
  # preferable to immediately executing the callback as this is used to detect
  # presumably malicious behavior like spamming alert messages in
  # onbeforeunload). Set |suppress_message| to false (0) and return false (0)
  # to use the default implementation (the default implementation will show one
  # modal dialog at a time and suppress any additional dialog requests until
  # the displayed dialog is dismissed). Return true (1) if the application will
  # use a custom dialog or if the callback has been executed immediately.
  # Custom dialogs may be either modal or modeless. If a custom dialog is used
  # the application must execute |callback| once the custom dialog is
  # dismissed.
  proc onJsdialog*(self: T, browser: NCBrowser, origin_url: string,
      dialog_type: cef_jsdialog_type, message_text, default_prompt_text: string,
      callback: NCJsDialogCallback, suppress_message: var bool): bool

  # Called to run a dialog asking the user if they want to leave a page. Return
  # false (0) to use the default dialog implementation. Return true (1) if the
  # application will use a custom dialog or if the callback has been executed
  # immediately. Custom dialogs may be either modal or modeless. If a custom
  # dialog is used the application must execute |callback| once the custom
  # dialog is dismissed.
  proc onBeforeUnloadDialog*(self: T, browser: NCBrowser, message_text: string,
    is_reload: bool, callback: NCJsDialogCallback): bool

  # Called to cancel any pending dialogs and reset any saved dialog state. Will
  # be called due to events like page navigation irregardless of whether any
  # dialogs are currently pending.
  proc onResetDialogState*(self: T, browser: NCBrowser)

  # Called when the default implementation dialog is closed.
  proc onDialogClosed*(self: T, browser: NCBrowser)