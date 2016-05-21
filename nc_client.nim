import cef/cef_request_handler_api, cef/cef_string_list_api, cef/cef_dialog_handler_api
import cef/cef_download_handler_api, cef/cef_geolocation_handler_api, cef/cef_jsdialog_handler_api
import cef/cef_resource_handler_api, cef/cef_context_menu_handler_api, cef/cef_client_api
import nc_process_message, nc_types, nc_download_item, nc_request, nc_response, nc_drag_data
import nc_auth_callback, nc_ssl_info, nc_util, nc_response_filter, nc_resource_handler
import nc_context_menu_params, nc_menu_model
import impl/nc_util_impl

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

type
  nc_client_i*[T] = object
    #--Client Handler
    # Called when a new message is received from a different process. Return true
    # (1) if the message was handled or false (0) otherwise. Do not keep a
    # reference to or attempt to access the message outside of this callback.
    OnRenderProcessMessageReceived*: proc(self: T, browser: NCBrowser,
      source_process: cef_process_id, message: NCProcessMessage): bool
    
    #--Drag Handler
    # Called when an external drag event enters the browser window. |dragData|
    # contains the drag event data and |mask| represents the type of drag
    # operation. Return false (0) for default drag handling behavior or true (1)
    # to cancel the drag event.
    OnDragEnter*: proc(self: T, browser: NCBrowser, dragData: NCDragData,
      mask: cef_drag_operations_mask): bool
    
    #--Drag Handler
    # Called whenever draggable regions for the browser window change. These can
    # be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
    # draggable regions are never defined in a document this function will also
    # never be called. If the last draggable region is removed from a document
    # this function will be called with an NULL vector.
    OnDraggableRegionsChanged*: proc(self: T, browser: NCBrowser,
      regionsCount: int, regions: ptr cef_draggable_region)
    
    #--Display Handler
    # Called when a frame's address has changed.
    OnAddressChange*: proc(self: T, browser: NCBrowser, frame: NCFrame, url: string)
    
    #--Display Handler
    # Called when the page title changes.
    OnTitleChange*: proc(self: T, browser: NCBrowser, title: string)
    
    #--Display Handler
    # Called when the page icon changes.
    OnFaviconUrlchange*: proc(self: T, browser: NCBrowser, icon_urls: seq[string])
    
    #--Display Handler
    # Called when web content in the page has toggled fullscreen mode. If
    # |fullscreen| is true (1) the content will automatically be sized to fill
    # the browser content area. If |fullscreen| is false (0) the content will
    # automatically return to its original size and position. The client is
    # responsible for resizing the browser if desired.
    OnFullscreenModeChange*: proc(self: T, browser: NCBrowser, fullscreen: bool)
    
    #--Display Handler
    # Called when the browser is about to display a tooltip. |text| contains the
    # text that will be displayed in the tooltip. To handle the display of the
    # tooltip yourself return true (1). Otherwise, you can optionally modify
    # |text| and then return false (0) to allow the browser to display the
    # tooltip. When window rendering is disabled the application is responsible
    # for drawing tooltips and the return value is ignored.
    OnTooltip*: proc(self: T, browser: NCBrowser, text: var string): bool
    
    #--Display Handler
    # Called when the browser receives a status message. |value| contains the
    # text that will be displayed in the status message.
    OnStatusMessage*: proc(self: T, browser: NCBrowser, value: string)
    
    #--Display Handler
    # Called to display a console message. Return true (1) to stop the message
    # from being output to the console.
    OnConsoleMessage*: proc(self: T, browser: NCBrowser, message, source: string, line: int): bool
    
    #--Focus Handler
    # Called when the browser component is about to loose focus. For instance, if
    # focus was on the last HTML element and the user pressed the TAB key. |next|
    # will be true (1) if the browser is giving focus to the next component and
    # false (0) if the browser is giving focus to the previous component.
    OnTakeFocus*: proc(self: T, browser: NCBrowser, next: bool)
    
    #--Focus Handler
    # Called when the browser component is requesting focus. |source| indicates
    # where the focus request is originating from. Return false (0) to allow the
    # focus to be set or true (1) to cancel setting the focus.
    OnSetFocus*: proc(self: T, browser: NCBrowser, source: cef_focus_source): bool
    
    #--Focus Handler
    # Called when the browser component has received focus.
    OnGotFocus*: proc(self: T, browser: NCBrowser)
    
    #--Keyboard Handler
    # Called before a keyboard event is sent to the renderer. |event| contains
    # information about the keyboard event. |os_event| is the operating system
    # event message, if any. Return true (1) if the event was handled or false
    # (0) otherwise. If the event will be handled in on_key_event() as a keyboard
    # shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
    OnPreKeyEvent*: proc(self: T, browser: NCBrowser, event: ptr cef_key_event,
      os_event: cef_event_handle, is_keyboard_shortcut: var int): bool
    
    #--Keyboard Handler
    # Called after the renderer and JavaScript in the page has had a chance to
    # handle the event. |event| contains information about the keyboard event.
    # |os_event| is the operating system event message, if any. Return true (1)
    # if the keyboard event was handled or false (0) otherwise.
    OnKeyEvent*: proc(self: T, browser: NCBrowser, event: ptr cef_key_event,
      os_event: cef_event_handle): bool
    
    #--Load Handler
    # Called when the loading state has changed. This callback will be executed
    # twice -- once when loading is initiated either programmatically or by user
    # action, and once when loading is terminated due to completion, cancellation
    # of failure. It will be called before any calls to OnLoadStart and after all
    # calls to OnLoadError and/or OnLoadEnd.
    OnLoadingStateChange*: proc(self: T, browser: NCBrowser, 
      isLoading, canGoBack, canGoForward: bool)
    
    #--Load Handler
    # Called when the browser begins loading a frame. The |frame| value will
    # never be NULL -- call the is_main() function to check if this frame is the
    # main frame. Multiple frames may be loading at the same time. Sub-frames may
    # start or continue loading after the main frame load has ended. This
    # function will always be called for all frames irrespective of whether the
    # request completes successfully. For notification of overall browser load
    # status use OnLoadingStateChange instead.
    OnLoadStart*: proc(self: T, browser: NCBrowser, frame: NCFrame)
    
    #--Load Handler
    # Called when the browser is done loading a frame. The |frame| value will
    # never be NULL -- call the is_main() function to check if this frame is the
    # main frame. Multiple frames may be loading at the same time. Sub-frames may
    # start or continue loading after the main frame load has ended. This
    # function will always be called for all frames irrespective of whether the
    # request completes successfully. For notification of overall browser load
    # status use OnLoadingStateChange instead.
    OnLoadEnd*: proc(self: T, browser: NCBrowser, frame: NCFrame, httpStatusCode: int)
    
    #--Load Handler
    # Called when the resource load for a navigation fails or is canceled.
    # |errorCode| is the error code number, |errorText| is the error text and
    # |failedUrl| is the URL that failed to load. See net\base\net_error_list.h
    # for complete descriptions of the error codes.
    OnLoadError*: proc(self: T, browser: NCBrowser, frame: NCFrame,
      errorCode: cef_errorcode, errorText, failedUrl: string)
    
    #--Render Handler
    # Called to retrieve the root window rectangle in screen coordinates. Return
    # true (1) if the rectangle was provided.
    GetRootScreenRect*: proc(self: T, browser: NCBrowser, rect: ptr cef_rect): bool
    
    #--Render Handler
    # Called to retrieve the view rectangle which is relative to screen
    # coordinates. Return true (1) if the rectangle was provided.
    GetViewRect*: proc(self: T, browser: NCBrowser, rect: ptr cef_rect): bool
    
    #--Render Handler
    # Called to retrieve the translation from view coordinates to actual screen
    # coordinates. Return true (1) if the screen coordinates were provided.
    GetScreenPoint*: proc(self: T,
      browser: NCBrowser, viewX, viewY: int, screenX, screenY: var int): bool
    
    #--Render Handler
    # Called to allow the client to fill in the CefScreenInfo object with
    # appropriate values. Return true (1) if the |screen_info| structure has been
    # modified.
    #
    # If the screen info rectangle is left NULL the rectangle from GetViewRect
    # will be used. If the rectangle is still NULL or invalid popups may not be
    # drawn correctly.
    GetScreenInfo*: proc(self: T,
      browser: NCBrowser, screen_info: ptr cef_screen_info): bool
    
    #--Render Handler
    # Called when the browser wants to show or hide the popup widget. The popup
    # should be shown if |show| is true (1) and hidden if |show| is false (0).
    OnPopupShow*: proc(self: T, browser: NCBrowser, show: bool)
    
    #--Render Handler
    # Called when the browser wants to move or resize the popup widget. |rect|
    # contains the new location and size in view coordinates.
    OnPopupSize*: proc(self: T, browser: NCBrowser, rect: ptr cef_rect)
    
    #--Render Handler
    # Called when an element should be painted. Pixel values passed to this
    # function are scaled relative to view coordinates based on the value of
    # CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
    # indicates whether the element is the view or the popup widget. |buffer|
    # contains the pixel data for the whole image. |dirtyRects| contains the set
    # of rectangles in pixel coordinates that need to be repainted. |buffer| will
    # be |width|*|height|*4 bytes in size and represents a BGRA image with an
    # upper-left origin.
    OnPaint*: proc(self: T, browser: NCBrowser, ptype: cef_paint_element_type,
      dirtyRectsCount: int, dirtyRects: ptr cef_rect, buffer: pointer, width, height: int)
    
    #--Render Handler
    # Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
    # |custom_cursor_info| will be populated with the custom cursor information.
    OnCursorChange*: proc(self: T, browser: NCBrowser, cursor: cef_cursor_handle,
      ptype: cef_cursor_type, custom_cursor_info: ptr cef_cursor_info)
    
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
    StartDragging*: proc(self: T, browser: NCBrowser, drag_data: NCDragData,
      allowed_ops: cef_drag_operations_mask, x, y: int): bool
    
    #--Render Handler
    # Called when the web view wants to update the mouse cursor during a drag &
    # drop operation. |operation| describes the allowed operation (none, move,
    # copy, link).
    UpdateDragCursor*: proc(self: T, browser: NCBrowser, operation: cef_drag_operations_mask)
    
    #--Render Handler
    # Called when the scroll offset has changed.
    OnScrollOffsetChanged*: proc(self: T, browser: NCBrowser, x, y: float64)    
    
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
    OnFileDialog*: proc(self: T,
      browser: NCBrowser, mode: cef_file_dialog_mode,
      title, default_file_path: string,
      accept_filters: seq[string], selected_accept_filter: int,
      callback: NCFileDialogCallback): bool
    
    #--Download Handler
    # Called before a download begins. |suggested_name| is the suggested name for
    # the download file. By default the download will be canceled. Execute
    # |callback| either asynchronously or in this function to continue the
    # download if desired. Do not keep a reference to |download_item| outside of
    # this function.
    OnBeforeDownload*: proc(self: T, browser: NCBrowser,
      download_item: NCDownloadItem, suggested_name: string,
      callback: NCBeforeDownloadCallback)
    
    #--Download Handler
    # Called when a download's status or progress information has been updated.
    # This may be called multiple times before and after on_before_download().
    # Execute |callback| either asynchronously or in this function to cancel the
    # download if desired. Do not keep a reference to |download_item| outside of
    # this function.
    OnDownloadUpdated*: proc(self: T, browser: NCBrowser,
      download_item: NCDownloadItem, callback: NCDownloadItemCallback)
    
    #--Geolocation Handler
    # Called when a page requests permission to access geolocation information.
    # |requesting_url| is the URL requesting permission and |request_id| is the
    # unique ID for the permission request. Return true (1) and call
    # cef_geolocation_callback_t::cont() either in this function or at a later
    # time to continue or cancel the request. Return false (0) to cancel the
    # request immediately.
    OnRequestGeolocationPermission*: proc(self: T,
      browser: NCBrowser, requesting_url: string, request_id: int,
      callback: NCGeolocationCallback): bool
    
    #--Geolocation Handler
    # Called when a geolocation access request is canceled. |request_id| is the
    # unique ID for the permission request.
    OnCancelGeolocationPermission*: proc(self: T,
      browser: NCBrowser, request_id: int)
    
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
    OnJsdialog*: proc(self: T,
        browser: NCBrowser, origin_url, accept_lang: string,
        dialog_type: cef_jsdialog_type,
        message_text, default_prompt_text: string,
        callback: NCJsDialogCallback, suppress_message: var bool): bool
    
    #--JSDialog Handler
    # Called to run a dialog asking the user if they want to leave a page. Return
    # false (0) to use the default dialog implementation. Return true (1) if the
    # application will use a custom dialog or if the callback has been executed
    # immediately. Custom dialogs may be either modal or modeless. If a custom
    # dialog is used the application must execute |callback| once the custom
    # dialog is dismissed.
    OnBeforeUnloadDialog*: proc(self: T,
      browser: NCBrowser, message_text: string, is_reload: bool,
      callback: NCJsDialogCallback): bool
    
    #--JSDialog Handler
    # Called to cancel any pending dialogs and reset any saved dialog state. Will
    # be called due to events like page navigation irregardless of whether any
    # dialogs are currently pending.
    OnResetDialogState*: proc(self: T, browser: NCBrowser)
    
    #--JSDialog Handler
    # Called when the default implementation dialog is closed.
    OnDialogClosed*: proc(self: T, browser: NCBrowser)
    
    #--Request Handler
    # Called on the UI thread before browser navigation. Return true (1) to
    # cancel the navigation or false (0) to allow the navigation to proceed. The
    # |request| object cannot be modified in this callback.
    # cef_load_handler_t::OnLoadingStateChange will be called twice in all cases.
    # If the navigation is allowed cef_load_handler_t::OnLoadStart and
    # cef_load_handler_t::OnLoadEnd will be called. If the navigation is canceled
    # cef_load_handler_t::OnLoadError will be called with an |errorCode| value of
    # ERR_ABORTED.
    OnBeforeBrowse*: proc(self: T, browser: NCBrowser, frame: NCFrame,
      request: NCRequest, is_redirect: bool): bool
    
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
    OnOpenUrlFromTab*: proc(self: T, browser: NCBrowser, frame: NCFrame, target_url: string,
      target_disposition: cef_window_open_disposition, user_gesture: bool): bool
    
    #--Request Handler
    # Called on the IO thread before a resource request is loaded. The |request|
    # object may be modified. Return RV_CONTINUE to continue the request
    # immediately. Return RV_CONTINUE_ASYNC and call cef_request_tCallback::
    # cont() at a later time to continue or cancel the request asynchronously.
    # Return RV_CANCEL to cancel the request immediately.
    OnBeforeResourceLoad*: proc(self: T,
      browser: NCBrowser, frame: NCFrame, request: NCRequest,
      callback: NCRequestCallback): cef_return_value
    
    #--Request Handler
    # Called on the IO thread before a resource is loaded. To allow the resource
    # to load normally return NULL. To specify a handler for the resource return
    # a cef_resource_handler_t object. The |request| object should not be
    # modified in this callback.
    GetResourceHandler*: proc(self: T, browser: NCBrowser,
      frame: NCFrame, request: NCRequest): NCResourceHandler
    
    #--Request Handler
    # Called on the IO thread when a resource load is redirected. The |request|
    # parameter will contain the old URL and other request-related information.
    # The |new_url| parameter will contain the new URL and can be changed if
    # desired. The |request| object cannot be modified in this callback.
    OnResourceRedirect*: proc(self: T, browser: NCBrowser, frame: NCFrame,
      request: NCRequest, new_url: string)
    
    #--Request Handler
    # Called on the IO thread when a resource response is received. To allow the
    # resource to load normally return false (0). To redirect or retry the
    # resource modify |request| (url, headers or post body) and return true (1).
    # The |response| object cannot be modified in this callback.
    OnResourceResponse*: proc(self: T,
      browser: NCBrowser, frame: NCFrame,
      request: NCRequest, response: NCResponse): bool
    
    #--Request Handler
    # Called on the IO thread to optionally filter resource response content.
    # |request| and |response| represent the request and response respectively
    # and cannot be modified in this callback.
    GetResourceResponseFilter*: proc(self: T, browser: NCBrowser,
      frame: NCFrame, request: NCRequest,
      response: NCResponse): NCResponseFilter
    
    #--Request Handler
    # Called on the IO thread when a resource load has completed. |request| and
    # |response| represent the request and response respectively and cannot be
    # modified in this callback. |status| indicates the load completion status.
    # |received_content_length| is the number of response bytes actually read.
    OnResourceLoadComplete*: proc(self: T, browser: NCBrowser,
      frame: NCFrame, request: NCRequest,
      response: NCResponse, status: cef_urlrequest_status,
      received_content_length: int64)
    
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
    GetAuthCredentials*: proc(self: T, browser: NCBrowser, frame: NCFrame, isProxy: bool,
      host: string, port: int, realm: string,
      scheme: string, callback: NCAuthCallback): bool
    
    #--Request Handler
    # Called on the IO thread when JavaScript requests a specific storage quota
    # size via the webkitStorageInfo.requestQuota function. |origin_url| is the
    # origin of the page making the request. |new_size| is the requested quota
    # size in bytes. Return true (1) to continue the request and call
    # cef_request_tCallback::cont() either in this function or at a later time to
    # grant or deny the request. Return false (0) to cancel the request
    # immediately.
    OnQuotaRequest*: proc(self: T, browser: NCBrowser, origin_url: string,
      new_size: int64, callback: NCRequestCallback): bool
    
    #--Request Handler
    # Called on the UI thread to handle requests for URLs with an unknown
    # protocol component. Set |allow_os_execution| to true (1) to attempt
    # execution via the registered OS protocol handler, if any. SECURITY WARNING:
    # YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR
    # OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
    OnProtocolExecution*: proc(self: T, browser: NCBrowser,
      url: string, allow_os_execution: var bool)
    
    #--Request Handler
    # Called on the UI thread to handle requests for URLs with an invalid SSL
    # certificate. Return true (1) and call cef_request_tCallback::cont() either
    # in this function or at a later time to continue or cancel the request.
    # Return false (0) to cancel the request immediately. If
    # CefSettings.ignore_certificate_errors is set all invalid certificates will
    # be accepted without calling this function.
    OnCertificateError*: proc(self: T,
        browser: NCBrowser, cert_error: cef_errorcode,
        request_url: string, ssl_info: NCSslInfo,
        callback: NCRequestCallback): bool
    
    #--Request Handler
    # Called on the browser process UI thread when a plugin has crashed.
    # |plugin_path| is the path of the plugin that crashed.
    OnPluginCrashed*: proc(self: T, browser: NCBrowser, plugin_path: string)
    
    #--Request Handler
    # Called on the browser process UI thread when the render view associated
    # with |browser| is ready to receive/handle IPC messages in the render
    # process.
    OnRenderViewReady*: proc(self: T, browser: NCBrowser)
    
    #--Request Handler
    # Called on the browser process UI thread when the render process terminates
    # unexpectedly. |status| indicates how the process terminated.
    OnRenderProcessTerminated*: proc(self: T, browser: NCBrowser,
      status: cef_termination_status)
      
    #--Context Menu Handler
    # Called before a context menu is displayed. |params| provides information
    # about the context menu state. |model| initially contains the default
    # context menu. The |model| can be cleared to show no context menu or
    # modified to show a custom menu. Do not keep references to |params| or
    # |model| outside of this callback.
    OnBeforeContextMenu*: proc(self: T, browser: NCBrowser,
      frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel)
      
    #--Context Menu Handler
    # Called to allow custom display of the context menu. |params| provides
    # information about the context menu state. |model| contains the context menu
    # model resulting from OnBeforeContextMenu. For custom display return true
    # (1) and execute |callback| either synchronously or asynchronously with the
    # selected command ID. For default display return false (0). Do not keep
    # references to |params| or |model| outside of this callback.
    RunContextMenu*: proc(self: T, browser: NCBrowser,
      frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel,
      callback: ptr cef_run_context_menu_callback): int
      
    #--Context Menu Handler
    # Called to execute a command selected from the context menu. Return true (1)
    # if the command was handled or false (0) for the default implementation. See
    # cef_menu_id_t for the command ids that have default implementations. All
    # user-defined command ids should be between MENU_ID_USER_FIRST and
    # MENU_ID_USER_LAST. |params| will have the same values as what was passed to
    # on_before_context_menu(). Do not keep a reference to |params| outside of
    # this callback.
    OnContextMenuCommand*: proc(self: T, browser: NCBrowser,
      frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
      event_flags: cef_event_flags): int
      
    #--Context Menu Handler
    # Called when the context menu is dismissed irregardless of whether the menu
    # was NULL or a command was selected.
    OnContextMenuDismissed*: proc(self: T,  browser: NCBrowser, frame: NCFrame)
    
    #--Life Span Handler
    # Called on the IO thread before a new popup browser is created. The
    # |browser| and |frame| values represent the source of the popup request. The
    # |target_url| and |target_frame_name| values indicate where the popup
    # browser should navigate and may be NULL if not specified with the request.
    # The |target_disposition| value indicates where the user intended to open
    # the popup (e.g. current tab, new tab, etc). The |user_gesture| value will
    # be true (1) if the popup was opened via explicit user gesture (e.g.
    # clicking a link) or false (0) if the popup opened automatically (e.g. via
    # the DomContentLoaded event). The |popupFeatures| structure contains
    # additional information about the requested popup window. To allow creation
    # of the popup browser optionally modify |windowInfo|, |client|, |settings|
    # and |no_javascript_access| and return false (0). To cancel creation of the
    # popup browser return true (1). The |client| and |settings| values will
    # default to the source browser's values. If the |no_javascript_access| value
    # is set to false (0) the new browser will not be scriptable and may not be
    # hosted in the same renderer process as the source browser.
    OnBeforePopup*: proc(self: T, browser: NCBrowser, frame: NCFrame,
        target_url, target_frame_name: string,
        target_disposition: cef_window_open_disposition, user_gesture: cint,
        popupFeatures: ptr cef_popup_features,
        windowInfo: ptr cef_window_info, client: var ptr_cef_client,
        settings: ptr cef_browser_settings, no_javascript_access: var cint): int
      
    #--Life Span Handler
    # Called after a new browser is created.
    OnAfterCreated*: proc(self: T, browser: NCBrowser)
    
    #--Life Span Handler
    # Called when a modal window is about to display and the modal loop should
    # begin running. Return false (0) to use the default modal loop
    # implementation or true (1) to use a custom implementation.
    RunModal*: proc(self: T, browser: NCBrowser): int
    
    #--Life Span Handler
    # Called when a browser has recieved a request to close. This may result
    # directly from a call to cef_browser_host_t::close_browser() or indirectly
    # if the browser is a top-level OS window created by CEF and the user
    # attempts to close the window. This function will be called after the
    # JavaScript 'onunload' event has been fired. It will not be called for
    # browsers after the associated OS window has been destroyed (for those
    # browsers it is no longer possible to cancel the close).
    #
    # If CEF created an OS window for the browser returning false (0) will send
    # an OS close notification to the browser window's top-level owner (e.g.
    # WM_CLOSE on Windows, performClose: on OS-X and "delete_event" on Linux). If
    # no OS window exists (window rendering disabled) returning false (0) will
    # cause the browser object to be destroyed immediately. Return true (1) if
    # the browser is parented to another window and that other window needs to
    # receive close notification via some non-standard technique.
    #
    # If an application provides its own top-level window it should handle OS
    # close notifications by calling cef_browser_host_t::CloseBrowser(false (0))
    # instead of immediately closing (see the example below). This gives CEF an
    # opportunity to process the 'onbeforeunload' event and optionally cancel the
    # close before do_close() is called.
    #
    # The cef_life_span_handler_t::on_before_close() function will be called
    # immediately before the browser object is destroyed. The application should
    # only exit after on_before_close() has been called for all existing
    # browsers.
    #
    # If the browser represents a modal window and a custom modal loop
    # implementation was provided in cef_life_span_handler_t::run_modal() this
    # callback should be used to restore the opener window to a usable state.
    #
    # By way of example consider what should happen during window close when the
    # browser is parented to an application-provided top-level OS window. 1.
    # User clicks the window close button which sends an OS close
    #     notification (e.g. WM_CLOSE on Windows, performClose: on OS-X and
    #     "delete_event" on Linux).
    # 2.  Application's top-level window receives the close notification and:
    #     A. Calls CefBrowserHost::CloseBrowser(false).
    #     B. Cancels the window close.
    # 3.  JavaScript 'onbeforeunload' handler executes and shows the close
    #     confirmation dialog (which can be overridden via
    #     CefJSDialogHandler::OnBeforeUnloadDialog()).
    # 4.  User approves the close. 5.  JavaScript 'onunload' handler executes. 6.
    # Application's do_close() handler is called. Application will:
    #     A. Set a flag to indicate that the next close attempt will be allowed.
    #     B. Return false.
    # 7.  CEF sends an OS close notification. 8.  Application's top-level window
    # receives the OS close notification and
    #     allows the window to close based on the flag from #6B.
    # 9.  Browser OS window is destroyed. 10. Application's
    # cef_life_span_handler_t::on_before_close() handler is called and
    #     the browser object is destroyed.
    # 11. Application exits by calling cef_quit_message_loop() if no other
    # browsers
    #     exist.
    DoClose*: proc(self: T, browser: NCBrowser): int
      
    #--Life Span Handler
    # Called just before a browser is destroyed. Release all references to the
    # browser object and do not attempt to execute any functions on the browser
    # object after this callback returns. If this is a modal window and a custom
    # modal loop implementation was provided in run_modal() this callback should
    # be used to exit the custom modal loop. See do_close() documentation for
    # additional usage information.
    OnBeforeClose*: proc(self: T, browser: NCBrowser)

  # Implement this structure to provide handler implementations.
  nc_handler = object of nc_base[cef_client, NCClient]
    impl: nc_client_i[NCClient]
    life_span_handler*: ptr cef_life_span_handler
    context_menu_handler*: ptr cef_context_menu_handler
    drag_handler*: ptr cef_drag_handler
    display_handler*: ptr cef_display_handler
    focus_handler*: ptr cef_focus_handler
    keyboard_handler*: ptr cef_keyboard_handler
    load_handler*: ptr cef_load_handler
    render_handler*: ptr cef_render_handler
    dialog_handler*: ptr cef_dialog_handler
    download_handler*: ptr cef_download_handler
    geolocation_handler*: ptr cef_geolocation_handler
    jsdialog_handler*: ptr cef_jsdialog_handler
    request_handler*: ptr cef_request_handler

include nc_client_internal

proc client_finalizer[A, B](client: A) =
  let handler = cast[ptr B](client.handler)
  if handler.context_menu_handler != nil: freeShared(handler.context_menu_handler)
  if handler.life_span_handler != nil: freeShared(handler.life_span_handler)
  if handler.drag_handler != nil: freeShared(handler.drag_handler)
  if handler.display_handler != nil: freeShared(handler.display_handler)
  if handler.focus_handler != nil: freeShared(handler.focus_handler)
  if handler.keyboard_handler != nil: freeShared(handler.keyboard_handler)
  if handler.load_handler != nil: freeShared(handler.load_handler)
  if handler.render_handler != nil: freeShared(handler.render_handler)
  if handler.dialog_handler != nil: freeShared(handler.dialog_handler)
  if handler.download_handler != nil: freeShared(handler.download_handler)
  if handler.geolocation_handler != nil: freeShared(handler.geolocation_handler)
  if handler.jsdialog_handler != nil: freeShared(handler.jsdialog_handler)
  if handler.request_handler != nil: freeShared(handler.request_handler)
  release(client.handler)
  
template client_init*(T, X: typedesc) =
  var handler = createShared(T)
  nc_init_base[T](handler)
  new(result, client_finalizer[X, T])
  result.handler = handler.handler.addr
  add_ref(handler.handler.addr)
  handler.container = result
  
proc makeNCClient*[T](impl: nc_client_i[T], flags: NCCFS = {}): T =
  client_init(nc_handler, T)
  initialize_client_handler(result.handler)
  
  let handler = cast[ptr nc_handler](result.handler)
  copyMem(handler.impl.addr, impl.unsafeAddr, sizeof(impl))
  
  if NCCF_CONTEXT_MENU in flags:
    handler.context_menu_handler = createShared(cef_context_menu_handler)
    initialize_context_menu_handler(handler.context_menu_handler)

  if NCCF_LIFE_SPAN in flags:
    handler.life_span_handler = createShared(cef_life_span_handler)
    initialize_life_span_handler(handler.life_span_handler)

  if NCCF_DRAG in flags:
    handler.drag_handler = createShared(cef_drag_handler)
    initialize_drag_handler(handler.drag_handler)

  if NCCF_DISPLAY in flags:
    handler.display_handler = createShared(cef_display_handler)
    initialize_display_handler(handler.display_handler)

  if NCCF_FOCUS in flags:
    handler.focus_handler = createShared(cef_focus_handler)
    initialize_focus_handler(handler.focus_handler)

  if NCCF_KEYBOARD in flags:
    handler.keyboard_handler = createShared(cef_keyboard_handler)
    initialize_keyboard_handler(handler.keyboard_handler)

  if NCCF_LOAD in flags:
    handler.load_handler = createShared(cef_load_handler)
    initialize_load_handler(handler.load_handler)

  if NCCF_RENDER in flags:
    handler.render_handler = createShared(cef_render_handler)
    initialize_render_handler(handler.render_handler)

  if NCCF_DIALOG in flags:
    handler.dialog_handler = createShared(cef_dialog_handler)
    initialize_dialog_handler(handler.dialog_handler)

  if NCCF_DOWNLOAD in flags:
    handler.download_handler = createShared(cef_download_handler)
    initialize_download_handler(handler.download_handler)

  if NCCF_GEOLOCATION in flags:
    handler.geolocation_handler = createShared(cef_geolocation_handler)
    initialize_geolocation_handler(handler.geolocation_handler)

  if NCCF_JSDIALOG in flags:
    handler.jsdialog_handler = createShared(cef_jsdialog_handler)
    initialize_jsdialog_handler(handler.jsdialog_handler)

  if NCCF_REQUEST in flags:
    handler.request_handler = createShared(cef_request_handler)
    initialize_request_handler(handler.request_handler)