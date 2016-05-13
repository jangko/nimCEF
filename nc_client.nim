import cef/cef_request_handler_api, cef/cef_string_list_api, cef/cef_dialog_handler_api
import cef/cef_download_handler_api, cef/cef_geolocation_handler_api, cef/cef_jsdialog_handler_api
import cef/cef_resource_handler_api
import nc_process_message, nc_types, nc_download_item, nc_request, nc_response, nc_drag_data
import nc_auth_callback, nc_ssl_info, nc_util, nc_response_filter, nc_context_menu_handler
import nc_life_span_handler, nc_resource_handler
#moved to nc_types.nim to avoid circular import
#type
#  NCClient* = ref object of RootObj

type
  # Callback structure used for asynchronous continuation of url requests.
  NCRequestCallback* = ptr cef_request_callback

  # Callback structure for asynchronous continuation of file dialog requests.
  NCFileDialogCallback* = ptr cef_file_dialog_callback

  # Callback structure used to asynchronously continue a download.
  NCBeforeDownloadCallback* = ptr cef_before_download_callback

  # Callback structure used to asynchronously cancel a download.
  NCDownloadItemCallback* = ptr cef_download_item_callback

  # Callback structure used for asynchronous continuation of geolocation
  # permission requests.
  NCGeolocationCallback* = ptr cef_geolocation_callback

  # Callback structure used for asynchronous continuation of JavaScript dialog
  # requests.
  NCJsDialogCallback* = ptr cef_jsdialog_callback

# Continue the url request. If |allow| is true (1) the request will be
# continued. Otherwise, the request will be canceled.
proc Continue*(self: NCRequestCallback, allow: bool) =
  self.cont(self, allow.cint)

# Cancel the url request.
proc Cancel*(self: NCRequestCallback) =
  self.cancel(self)

# Continue the file selection. |selected_accept_filter| should be the 0-based
# index of the value selected from the accept filters array passed to
# cef_dialog_handler_t::OnFileDialog. |file_paths| should be a single value
# or a list of values depending on the dialog mode. An NULL |file_paths|
# value is treated the same as calling cancel().
proc Continue*(self: NCFileDialogCallback, selected_accept_filter: int, file_paths: seq[string]) =
  let clist = to_cef(file_paths)
  self.cont(self, selected_accept_filter.cint, clist)
  nc_free(clist)

# Cancel the file selection.
proc Cancel*(self: NCFileDialogCallback) =
  self.cancel(self)

# Call to continue the download. Set |download_path| to the full file path
# for the download including the file name or leave blank to use the
# suggested name and the default temp directory. Set |show_dialog| to true
# (1) if you do wish to show the default "Save As" dialog.
proc Continue*(self: NCBeforeDownloadCallback, download_path: string, show_dialog: bool) =
  let cpath = to_cef(download_path)
  self.cont(self, cpath, show_dialog.cint)
  nc_free(cpath)

# Call to cancel the download.
proc Cancel*(self: NCDownloadItemCallback) =
  self.cancel(self)

# Call to pause the download.
proc Pause*(self: NCDownloadItemCallback) =
  self.pause(self)

# Call to resume the download.
proc Resume*(self: NCDownloadItemCallback) =
  self.resume(self)

# Call to allow or deny geolocation access.
proc Continue*(self: NCGeolocationCallback, allow: bool): bool =
  result = self.cont(self, allow.cint) == 1.cint

# Continue the JS dialog request. Set |success| to true (1) if the OK button
# was pressed. The |user_input| value should be specified for prompt dialogs.
proc Continue*(self: NCJsDialogCallback, success: bool, user_input: string) =
  let cinput = to_cef(user_input)
  self.cont(self, success.cint, cinput)
  nc_free(cinput)

#--Client Handler
# Called when a new message is received from a different process. Return true
# (1) if the message was handled or false (0) otherwise. Do not keep a
# reference to or attempt to access the message outside of this callback.
method OnRenderProcessMessageReceived*(self: NCClient, browser: NCBrowser,
  source_process: cef_process_id, message: NCProcessMessage): bool {.base.} =
  result = false

#--Drag Handler
# Called when an external drag event enters the browser window. |dragData|
# contains the drag event data and |mask| represents the type of drag
# operation. Return false (0) for default drag handling behavior or true (1)
# to cancel the drag event.
method OnDragEnter*(self: NCClient, browser: NCBrowser, dragData: NCDragData,
  mask: cef_drag_operations_mask): bool {.base.} =
  result = false

#--Drag Handler
# Called whenever draggable regions for the browser window change. These can
# be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
# draggable regions are never defined in a document this function will also
# never be called. If the last draggable region is removed from a document
# this function will be called with an NULL vector.
method OnDraggableRegionsChanged*(self: NCClient, browser: NCBrowser,
  regionsCount: int, regions: ptr cef_draggable_region) {.base.} =
  discard

#--Display Handler
# Called when a frame's address has changed.
method OnAddressChange*(self: NCClient, browser: NCBrowser, frame: NCFrame, url: string) {.base.} =
  discard

#--Display Handler
# Called when the page title changes.
method OnTitleChange*(self: NCClient, browser: NCBrowser, title: string) {.base.} =
  discard

#--Display Handler
# Called when the page icon changes.
method OnFaviconUrlchange*(self: NCClient, browser: NCBrowser, icon_urls: seq[string]) {.base.} =
  discard

#--Display Handler
# Called when web content in the page has toggled fullscreen mode. If
# |fullscreen| is true (1) the content will automatically be sized to fill
# the browser content area. If |fullscreen| is false (0) the content will
# automatically return to its original size and position. The client is
# responsible for resizing the browser if desired.
method OnFullscreenModeChange*(self: NCClient, browser: NCBrowser, fullscreen: bool) {.base.} =
  discard

#--Display Handler
# Called when the browser is about to display a tooltip. |text| contains the
# text that will be displayed in the tooltip. To handle the display of the
# tooltip yourself return true (1). Otherwise, you can optionally modify
# |text| and then return false (0) to allow the browser to display the
# tooltip. When window rendering is disabled the application is responsible
# for drawing tooltips and the return value is ignored.
method OnTooltip*(self: NCClient, browser: NCBrowser, text: var string): bool {.base.} =
  result = false

#--Display Handler
# Called when the browser receives a status message. |value| contains the
# text that will be displayed in the status message.
method OnStatusMessage*(self: NCClient, browser: NCBrowser, value: string) {.base.} =
  discard

#--Display Handler
# Called to display a console message. Return true (1) to stop the message
# from being output to the console.
method OnConsoleMessage*(self: NCClient, browser: NCBrowser, message, source: string, line: int): bool {.base.} =
  result = false

#--Focus Handler
# Called when the browser component is about to loose focus. For instance, if
# focus was on the last HTML element and the user pressed the TAB key. |next|
# will be true (1) if the browser is giving focus to the next component and
# false (0) if the browser is giving focus to the previous component.
method OnTakeFocus*(self: NCClient, browser: NCBrowser, next: bool) {.base.} =
  discard

#--Focus Handler
# Called when the browser component is requesting focus. |source| indicates
# where the focus request is originating from. Return false (0) to allow the
# focus to be set or true (1) to cancel setting the focus.
method OnSetFocus*(self: NCClient, browser: NCBrowser, source: cef_focus_source): bool {.base.} =
  result = true

#--Focus Handler
# Called when the browser component has received focus.
method OnGotFocus*(self: NCClient, browser: NCBrowser) {.base.} =
  discard

#--Keyboard Handler
# Called before a keyboard event is sent to the renderer. |event| contains
# information about the keyboard event. |os_event| is the operating system
# event message, if any. Return true (1) if the event was handled or false
# (0) otherwise. If the event will be handled in on_key_event() as a keyboard
# shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
method OnPreKeyEvent*(self: NCClient, browser: NCBrowser, event: ptr cef_key_event,
  os_event: cef_event_handle, is_keyboard_shortcut: var int): bool {.base.} =
  result = false

#--Keyboard Handler
# Called after the renderer and JavaScript in the page has had a chance to
# handle the event. |event| contains information about the keyboard event.
# |os_event| is the operating system event message, if any. Return true (1)
# if the keyboard event was handled or false (0) otherwise.
method OnKeyEvent*(self: NCClient, browser: NCBrowser, event: ptr cef_key_event,
  os_event: cef_event_handle): bool {.base.} =
  result = false

#--Load Handler
# Called when the loading state has changed. This callback will be executed
# twice -- once when loading is initiated either programmatically or by user
# action, and once when loading is terminated due to completion, cancellation
# of failure. It will be called before any calls to OnLoadStart and after all
# calls to OnLoadError and/or OnLoadEnd.
method OnLoadingStateChange*(self: NCClient,
  browser: NCBrowser, isLoading, canGoBack, canGoForward: bool) {.base.} =
  discard

#--Load Handler
# Called when the browser begins loading a frame. The |frame| value will
# never be NULL -- call the is_main() function to check if this frame is the
# main frame. Multiple frames may be loading at the same time. Sub-frames may
# start or continue loading after the main frame load has ended. This
# function will always be called for all frames irrespective of whether the
# request completes successfully. For notification of overall browser load
# status use OnLoadingStateChange instead.
method OnLoadStart*(self: NCClient, browser: NCBrowser, frame: NCFrame) {.base.} =
  discard

#--Load Handler
# Called when the browser is done loading a frame. The |frame| value will
# never be NULL -- call the is_main() function to check if this frame is the
# main frame. Multiple frames may be loading at the same time. Sub-frames may
# start or continue loading after the main frame load has ended. This
# function will always be called for all frames irrespective of whether the
# request completes successfully. For notification of overall browser load
# status use OnLoadingStateChange instead.
method OnLoadEnd*(self: NCClient, browser: NCBrowser, frame: NCFrame, httpStatusCode: int) {.base.} =
  discard

#--Load Handler
# Called when the resource load for a navigation fails or is canceled.
# |errorCode| is the error code number, |errorText| is the error text and
# |failedUrl| is the URL that failed to load. See net\base\net_error_list.h
# for complete descriptions of the error codes.
method OnLoadError*(self: NCClient, browser: NCBrowser, frame: NCFrame,
  errorCode: cef_errorcode, errorText, failedUrl: string) {.base.} =
  discard

#--Render Handler
# Called to retrieve the root window rectangle in screen coordinates. Return
# true (1) if the rectangle was provided.
method GetRootScreenRect*(self: NCClient, browser: NCBrowser, rect: ptr cef_rect): bool {.base.} =
  result = false

#--Render Handler
# Called to retrieve the view rectangle which is relative to screen
# coordinates. Return true (1) if the rectangle was provided.
method GetViewRect*(self: NCClient, browser: NCBrowser, rect: ptr cef_rect): bool {.base.} =
  result = false

#--Render Handler
# Called to retrieve the translation from view coordinates to actual screen
# coordinates. Return true (1) if the screen coordinates were provided.
method GetScreenPoint*(self: NCClient,
  browser: NCBrowser, viewX, viewY: int, screenX, screenY: var int): bool {.base.} =
  result = false

#--Render Handler
# Called to allow the client to fill in the CefScreenInfo object with
# appropriate values. Return true (1) if the |screen_info| structure has been
# modified.
#
# If the screen info rectangle is left NULL the rectangle from GetViewRect
# will be used. If the rectangle is still NULL or invalid popups may not be
# drawn correctly.
method GetScreenInfo*(self: NCClient,
  browser: NCBrowser, screen_info: ptr cef_screen_info): bool {.base.} =
  result = false

#--Render Handler
# Called when the browser wants to show or hide the popup widget. The popup
# should be shown if |show| is true (1) and hidden if |show| is false (0).
method OnPopupShow*(self: NCClient, browser: NCBrowser, show: bool) {.base.} =
  discard

#--Render Handler
# Called when the browser wants to move or resize the popup widget. |rect|
# contains the new location and size in view coordinates.
method OnPopupSize*(self: NCClient, browser: NCBrowser, rect: ptr cef_rect) {.base.} =
  discard

#--Render Handler
# Called when an element should be painted. Pixel values passed to this
# function are scaled relative to view coordinates based on the value of
# CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
# indicates whether the element is the view or the popup widget. |buffer|
# contains the pixel data for the whole image. |dirtyRects| contains the set
# of rectangles in pixel coordinates that need to be repainted. |buffer| will
# be |width|*|height|*4 bytes in size and represents a BGRA image with an
# upper-left origin.
method OnPaint*(self: NCClient, browser: NCBrowser, ptype: cef_paint_element_type,
  dirtyRectsCount: int, dirtyRects: ptr cef_rect, buffer: pointer, width, height: int) {.base.} =
  discard

#--Render Handler
# Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
# |custom_cursor_info| will be populated with the custom cursor information.
method OnCursorChange*(self: NCClient, browser: NCBrowser, cursor: cef_cursor_handle,
  ptype: cef_cursor_type, custom_cursor_info: ptr cef_cursor_info) {.base.} =
  discard

#--Render Handler
# Called when the user starts dragging content in the web view. Contextual
# information about the dragged content is supplied by |drag_data|. (|x|,
# |y|) is the drag start location in screen coordinates. OS APIs that run a
# system message loop may be used within the StartDragging call.
#
# Return false (0) to abort the drag operation. Don't call any of
# cef_browser_host_t::DragSource*Ended* functions after returning false (0).
#
# Return true (1) to handle the drag operation. Call
# cef_browser_host_t::DragSourceEndedAt and DragSourceSystemDragEnded either
# synchronously or asynchronously to inform the web view that the drag
# operation has ended.
method StartDragging*(self: NCClient, browser: NCBrowser, drag_data: NCDragData,
  allowed_ops: cef_drag_operations_mask, x, y: int): bool {.base.} =
  result = false

#--Render Handler
# Called when the web view wants to update the mouse cursor during a drag &
# drop operation. |operation| describes the allowed operation (none, move,
# copy, link).
method UpdateDragCursor*(self: NCClient, browser: NCBrowser, operation: cef_drag_operations_mask) {.base.} =
  discard

#--Render Handler
# Called when the scroll offset has changed.
method OnScrollOffsetChanged*(self: NCClient, browser: NCBrowser, x, y: float64) {.base.} =
  discard


#--Dialog Handler
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
method OnFileDialog*(self: NCClient,
  browser: NCBrowser, mode: cef_file_dialog_mode,
  title, default_file_path: string,
  accept_filters: seq[string], selected_accept_filter: int,
  callback: NCFileDialogCallback): bool {.base.} =
  result = false

#--Download Handler
# Called before a download begins. |suggested_name| is the suggested name for
# the download file. By default the download will be canceled. Execute
# |callback| either asynchronously or in this function to continue the
# download if desired. Do not keep a reference to |download_item| outside of
# this function.
method OnBeforeDownload*(self: NCClient, browser: NCBrowser,
  download_item: NCDownloadItem, suggested_name: string,
  callback: NCBeforeDownloadCallback) {.base.} =
  discard

#--Download Handler
# Called when a download's status or progress information has been updated.
# This may be called multiple times before and after on_before_download().
# Execute |callback| either asynchronously or in this function to cancel the
# download if desired. Do not keep a reference to |download_item| outside of
# this function.
method OnDownloadUpdated*(self: NCClient, browser: NCBrowser,
  download_item: NCDownloadItem, callback: NCDownloadItemCallback) {.base.} =
  discard

#--Geolocation Handler
# Called when a page requests permission to access geolocation information.
# |requesting_url| is the URL requesting permission and |request_id| is the
# unique ID for the permission request. Return true (1) and call
# cef_geolocation_callback_t::cont() either in this function or at a later
# time to continue or cancel the request. Return false (0) to cancel the
# request immediately.
method OnRequestGeolocationPermission*(self: NCClient,
  browser: NCBrowser, requesting_url: string, request_id: int,
  callback: NCGeolocationCallback): bool {.base.} =
  result = false

#--Geolocation Handler
# Called when a geolocation access request is canceled. |request_id| is the
# unique ID for the permission request.
method OnCancelGeolocationPermission*(self: NCClient,
  browser: NCBrowser, request_id: int) {.base.} =
  discard

#--JSDialog Handler
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
method OnJsdialog*(self: NCClient,
    browser: NCBrowser, origin_url, accept_lang: string,
    dialog_type: cef_jsdialog_type,
    message_text, default_prompt_text: string,
    callback: NCJsDialogCallback, suppress_message: var bool): bool {.base.} =
    result = false

#--JSDialog Handler
# Called to run a dialog asking the user if they want to leave a page. Return
# false (0) to use the default dialog implementation. Return true (1) if the
# application will use a custom dialog or if the callback has been executed
# immediately. Custom dialogs may be either modal or modeless. If a custom
# dialog is used the application must execute |callback| once the custom
# dialog is dismissed.
method OnBeforeUnloadDialog*(self: NCClient,
  browser: NCBrowser, message_text: string, is_reload: bool,
  callback: NCJsDialogCallback): bool {.base.} =
  result = false

#--JSDialog Handler
# Called to cancel any pending dialogs and reset any saved dialog state. Will
# be called due to events like page navigation irregardless of whether any
# dialogs are currently pending.
method OnResetDialogState*(self: NCClient, browser: NCBrowser) {.base.} =
  discard

#--JSDialog Handler
# Called when the default implementation dialog is closed.
method OnDialogClosed*(self: NCClient, browser: NCBrowser) {.base.} =
  discard

#--Request Handler
# Called on the UI thread before browser navigation. Return true (1) to
# cancel the navigation or false (0) to allow the navigation to proceed. The
# |request| object cannot be modified in this callback.
# cef_load_handler_t::OnLoadingStateChange will be called twice in all cases.
# If the navigation is allowed cef_load_handler_t::OnLoadStart and
# cef_load_handler_t::OnLoadEnd will be called. If the navigation is canceled
# cef_load_handler_t::OnLoadError will be called with an |errorCode| value of
# ERR_ABORTED.
method OnBeforeBrowse*(self: NCClient, browser: NCBrowser, frame: NCFrame,
  request: NCRequest, is_redirect: bool): bool {.base.} =
  result = false

#--Request Handler
# Called on the UI thread before OnBeforeBrowse in certain limited cases
# where navigating a new or different browser might be desirable. This
# includes user-initiated navigation that might open in a special way (e.g.
# links clicked via middle-click or ctrl + left-click) and certain types of
# cross-origin navigation initiated from the renderer process (e.g.
# navigating the top-level frame to/from a file URL). The |browser| and
# |frame| values represent the source of the navigation. The
# |target_disposition| value indicates where the user intended to navigate
# the browser based on standard Chromium behaviors (e.g. current tab, new
# tab, etc). The |user_gesture| value will be true (1) if the browser
# navigated via explicit user gesture (e.g. clicking a link) or false (0) if
# it navigated automatically (e.g. via the DomContentLoaded event). Return
# true (1) to cancel the navigation or false (0) to allow the navigation to
# proceed in the source browser's top-level frame.
method OnOpenUrlFromTab*(self: NCClient, browser: NCBrowser, frame: NCFrame, target_url: string,
  target_disposition: cef_window_open_disposition, user_gesture: bool): bool {.base.} =
  result = false

#--Request Handler
# Called on the IO thread before a resource request is loaded. The |request|
# object may be modified. Return RV_CONTINUE to continue the request
# immediately. Return RV_CONTINUE_ASYNC and call cef_request_tCallback::
# cont() at a later time to continue or cancel the request asynchronously.
# Return RV_CANCEL to cancel the request immediately.
method OnBeforeResourceLoad*(self: NCClient,
  browser: NCBrowser, frame: NCFrame, request: NCRequest,
  callback: NCRequestCallback): cef_return_value {.base.} =
  discard

#--Request Handler
# Called on the IO thread before a resource is loaded. To allow the resource
# to load normally return NULL. To specify a handler for the resource return
# a cef_resource_handler_t object. The |request| object should not be
# modified in this callback.
method GetResourceHandler*(self: NCClient, browser: NCBrowser,
  frame: NCFrame, request: NCRequest): NCResourceHandler {.base.} =
  result = nil

#--Request Handler
# Called on the IO thread when a resource load is redirected. The |request|
# parameter will contain the old URL and other request-related information.
# The |new_url| parameter will contain the new URL and can be changed if
# desired. The |request| object cannot be modified in this callback.
method OnResourceRedirect*(self: NCClient, browser: NCBrowser, frame: NCFrame,
  request: NCRequest, new_url: string) {.base.} =
  discard

#--Request Handler
# Called on the IO thread when a resource response is received. To allow the
# resource to load normally return false (0). To redirect or retry the
# resource modify |request| (url, headers or post body) and return true (1).
# The |response| object cannot be modified in this callback.
method OnResourceResponse*(self: NCClient,
  browser: NCBrowser, frame: NCFrame,
  request: NCRequest, response: NCResponse): bool {.base.} =
  result = false

#--Request Handler
# Called on the IO thread to optionally filter resource response content.
# |request| and |response| represent the request and response respectively
# and cannot be modified in this callback.
method GetResourceResponseFilter*(self: NCClient, browser: NCBrowser,
  frame: NCFrame, request: NCRequest,
  response: NCResponse): NCResponseFilter {.base.} =
  result = nil

#--Request Handler
# Called on the IO thread when a resource load has completed. |request| and
# |response| represent the request and response respectively and cannot be
# modified in this callback. |status| indicates the load completion status.
# |received_content_length| is the number of response bytes actually read.
method OnResourceLoadComplete*(self: NCClient, browser: NCBrowser,
  frame: NCFrame, request: NCRequest,
  response: NCResponse, status: cef_urlrequest_status,
  received_content_length: int64) {.base.} =
  discard

#--Request Handler
# Called on the IO thread when the browser needs credentials from the user.
# |isProxy| indicates whether the host is a proxy server. |host| contains the
# hostname and |port| contains the port number. |realm| is the realm of the
# challenge and may be NULL. |scheme| is the authentication scheme used, such
# as "basic" or "digest", and will be NULL if the source of the request is an
# FTP server. Return true (1) to continue the request and call
# cef_auth_callback_t::cont() either in this function or at a later time when
# the authentication information is available. Return false (0) to cancel the
# request immediately.
method GetAuthCredentials*(self: NCClient, browser: NCBrowser, frame: NCFrame, isProxy: bool,
  host: string, port: int, realm: string,
  scheme: string, callback: NCAuthCallback): bool {.base.} =
  result = false

#--Request Handler
# Called on the IO thread when JavaScript requests a specific storage quota
# size via the webkitStorageInfo.requestQuota function. |origin_url| is the
# origin of the page making the request. |new_size| is the requested quota
# size in bytes. Return true (1) to continue the request and call
# cef_request_tCallback::cont() either in this function or at a later time to
# grant or deny the request. Return false (0) to cancel the request
# immediately.
method OnQuotaRequest*(self: NCClient,
  browser: NCBrowser, origin_url: string,
  new_size: int64, callback: NCRequestCallback): bool {.base.} =
  result = false

#--Request Handler
# Called on the UI thread to handle requests for URLs with an unknown
# protocol component. Set |allow_os_execution| to true (1) to attempt
# execution via the registered OS protocol handler, if any. SECURITY WARNING:
# YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR
# OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
method OnProtocolExecution*(self: NCClient, browser: NCBrowser,
  url: string, allow_os_execution: var bool) {.base.} =
  discard

#--Request Handler
# Called on the UI thread to handle requests for URLs with an invalid SSL
# certificate. Return true (1) and call cef_request_tCallback::cont() either
# in this function or at a later time to continue or cancel the request.
# Return false (0) to cancel the request immediately. If
# CefSettings.ignore_certificate_errors is set all invalid certificates will
# be accepted without calling this function.
method OnCertificateError*(self: NCClient,
    browser: NCBrowser, cert_error: cef_errorcode,
    request_url: string, ssl_info: NCSslInfo,
    callback: NCRequestCallback): bool {.base.} =
  result = false

#--Request Handler
# Called on the browser process UI thread when a plugin has crashed.
# |plugin_path| is the path of the plugin that crashed.
method OnPluginCrashed*(self: NCClient, browser: NCBrowser, plugin_path: string) {.base.} =
  discard

#--Request Handler
# Called on the browser process UI thread when the render view associated
# with |browser| is ready to receive/handle IPC messages in the render
# process.
method OnRenderViewReady*(self: NCClient, browser: NCBrowser) {.base.} =
  discard

#--Request Handler
# Called on the browser process UI thread when the render process terminates
# unexpectedly. |status| indicates how the process terminated.
method OnRenderProcessTerminated*(self: NCClient, browser: NCBrowser,
  status: cef_termination_status) {.base.} =
  discard

include nc_client_internal

proc GetHandler*(client: NCClient): ptr cef_client {.inline.} = client.client_handler.addr

proc client_finalizer[T](client: T) =
  if client.context_menu_handler != nil: freeShared(client.context_menu_handler)
  if client.life_span_handler != nil: freeShared(client.life_span_handler)
  if client.drag_handler != nil: freeShared(client.drag_handler)
  if client.display_handler != nil: freeShared(client.display_handler)
  if client.focus_handler != nil: freeShared(client.focus_handler)
  if client.keyboard_handler != nil: freeShared(client.keyboard_handler)
  if client.load_handler != nil: freeShared(client.load_handler)
  if client.render_handler != nil: freeShared(client.render_handler)
  if client.dialog_handler != nil: freeShared(client.dialog_handler)
  if client.download_handler != nil: freeShared(client.download_handler)
  if client.geolocation_handler != nil: freeShared(client.geolocation_handler)
  if client.jsdialog_handler != nil: freeShared(client.jsdialog_handler)
  if client.request_handler != nil: freeShared(client.request_handler)

proc makeNCClient*(T: typedesc, flags: NCCFS = {}): auto =
  var client: T
  new(client, client_finalizer)

  initialize_client_handler(client.client_handler.addr)

  if NCCF_CONTEXT_MENU in flags:
    client.context_menu_handler = createShared(cef_context_menu_handler)
    initialize_context_menu_handler(client.context_menu_handler)

  if NCCF_LIFE_SPAN in flags:
    client.life_span_handler = createShared(cef_life_span_handler)
    initialize_life_span_handler(client.life_span_handler)

  if NCCF_DRAG in flags:
    client.drag_handler = createShared(cef_drag_handler)
    initialize_drag_handler(client.drag_handler)

  if NCCF_DISPLAY in flags:
    client.display_handler = createShared(cef_display_handler)
    initialize_display_handler(client.display_handler)

  if NCCF_FOCUS in flags:
    client.focus_handler = createShared(cef_focus_handler)
    initialize_focus_handler(client.focus_handler)

  if NCCF_KEYBOARD in flags:
    client.keyboard_handler = createShared(cef_keyboard_handler)
    initialize_keyboard_handler(client.keyboard_handler)

  if NCCF_LOAD in flags:
    client.load_handler = createShared(cef_load_handler)
    initialize_load_handler(client.load_handler)

  if NCCF_RENDER in flags:
    client.render_handler = createShared(cef_render_handler)
    initialize_render_handler(client.render_handler)

  if NCCF_DIALOG in flags:
    client.dialog_handler = createShared(cef_dialog_handler)
    initialize_dialog_handler(client.dialog_handler)

  if NCCF_DOWNLOAD in flags:
    client.download_handler = createShared(cef_download_handler)
    initialize_download_handler(client.download_handler)

  if NCCF_GEOLOCATION in flags:
    client.geolocation_handler = createShared(cef_geolocation_handler)
    initialize_geolocation_handler(client.geolocation_handler)

  if NCCF_JSDIALOG in flags:
    client.jsdialog_handler = createShared(cef_jsdialog_handler)
    initialize_jsdialog_handler(client.jsdialog_handler)

  if NCCF_REQUEST in flags:
    client.request_handler = createShared(cef_request_handler)
    initialize_request_handler(client.request_handler)
  return client