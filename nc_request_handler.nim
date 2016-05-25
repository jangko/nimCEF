import nc_util, impl/nc_util_impl, cef/cef_request_handler_api
import nc_types, nc_drag_data, nc_request, nc_resource_handler
import nc_response, nc_response_filter, nc_auth_callback
import nc_ssl_info, cef/cef_resource_handler_api, cef/cef_response_filter_api
include cef/cef_import

# Callback structure used for asynchronous continuation of url requests.
wrapAPI(NCRequestCallback, cef_request_callback, false)

# Continue the url request. If |allow| is true (1) the request will be
# continued. Otherwise, the request will be canceled.
proc Continue*(self: NCRequestCallback, allow: bool) =
  self.wrapCall(cont, allow)

# Cancel the url request.
proc Cancel*(self: NCRequestCallback) =
  self.wrapCall(cancel)

# Implement this structure to handle events related to browser requests. The
# functions of this structure will be called on the thread indicated.
wrapCallback(NCRequestHandler, cef_request_handler):
  # Called on the UI thread before browser navigation. Return true (1) to
  # cancel the navigation or false (0) to allow the navigation to proceed. The
  # |request| object cannot be modified in this callback.
  # cef_load_handler_t::OnLoadingStateChange will be called twice in all cases.
  # If the navigation is allowed cef_load_handler_t::OnLoadStart and
  # cef_load_handler_t::OnLoadEnd will be called. If the navigation is canceled
  # cef_load_handler_t::OnLoadError will be called with an |errorCode| value of
  # ERR_ABORTED.
  proc OnBeforeBrowse*(self: T, browser: NCBrowser, frame: NCFrame,
    request: NCRequest, is_redirect: bool): bool

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
  proc OnOpenUrlFromTab*(self: T, browser: NCBrowser, frame: NCFrame, target_url: string,
    target_disposition: cef_window_open_disposition, user_gesture: bool): bool

  # Called on the IO thread before a resource request is loaded. The |request|
  # object may be modified. Return RV_CONTINUE to continue the request
  # immediately. Return RV_CONTINUE_ASYNC and call cef_request_tCallback::
  # cont() at a later time to continue or cancel the request asynchronously.
  # Return RV_CANCEL to cancel the request immediately.
  proc OnBeforeResourceLoad*(self: T,
    browser: NCBrowser, frame: NCFrame, request: NCRequest,
    callback: NCRequestCallback): cef_return_value

  # Called on the IO thread before a resource is loaded. To allow the resource
  # to load normally return NULL. To specify a handler for the resource return
  # a cef_resource_handler_t object. The |request| object should not be
  # modified in this callback.
  proc GetResourceHandler*(self: T, browser: NCBrowser,
    frame: NCFrame, request: NCRequest): NCResourceHandler

  # Called on the IO thread when a resource load is redirected. The |request|
  # parameter will contain the old URL and other request-related information.
  # The |new_url| parameter will contain the new URL and can be changed if
  # desired. The |request| object cannot be modified in this callback.
  proc OnResourceRedirect*(self: T, browser: NCBrowser, frame: NCFrame,
    request: NCRequest, new_url: string)

  # Called on the IO thread when a resource response is received. To allow the
  # resource to load normally return false (0). To redirect or retry the
  # resource modify |request| (url, headers or post body) and return true (1).
  # The |response| object cannot be modified in this callback.
  proc OnResourceResponse*(self: T,
    browser: NCBrowser, frame: NCFrame,
    request: NCRequest, response: NCResponse): bool

  # Called on the IO thread to optionally filter resource response content.
  # |request| and |response| represent the request and response respectively
  # and cannot be modified in this callback.
  proc GetResourceResponseFilter*(self: T, browser: NCBrowser,
    frame: NCFrame, request: NCRequest,
    response: NCResponse): NCResponseFilter

  # Called on the IO thread when a resource load has completed. |request| and
  # |response| represent the request and response respectively and cannot be
  # modified in this callback. |status| indicates the load completion status.
  # |received_content_length| is the number of response bytes actually read.
  proc OnResourceLoadComplete*(self: T, browser: NCBrowser,
    frame: NCFrame, request: NCRequest,
    response: NCResponse, status: cef_urlrequest_status,
    received_content_length: int64)

  # Called on the IO thread when the browser needs credentials from the user.
  # |isProxy| indicates whether the host is a proxy server. |host| contains the
  # hostname and |port| contains the port number. |realm| is the realm of the
  # challenge and may be NULL. |scheme| is the authentication scheme used, such
  # as "basic" or "digest", and will be NULL if the source of the request is an
  # FTP server. Return true (1) to continue the request and call
  # cef_auth_callback_t::cont() either in this function or at a later time when
  # the authentication information is available. Return false (0) to cancel the
  # request immediately.
  proc GetAuthCredentials*(self: T, browser: NCBrowser, frame: NCFrame, isProxy: bool,
    host: string, port: int, realm: string,
    scheme: string, callback: NCAuthCallback): bool

  # Called on the IO thread when JavaScript requests a specific storage quota
  # size via the webkitStorageInfo.requestQuota function. |origin_url| is the
  # origin of the page making the request. |new_size| is the requested quota
  # size in bytes. Return true (1) to continue the request and call
  # cef_request_tCallback::cont() either in this function or at a later time to
  # grant or deny the request. Return false (0) to cancel the request
  # immediately.
  proc OnQuotaRequest*(self: T, browser: NCBrowser, origin_url: string,
    new_size: int64, callback: NCRequestCallback): bool

  # Called on the UI thread to handle requests for URLs with an unknown
  # protocol component. Set |allow_os_execution| to true (1) to attempt
  # execution via the registered OS protocol handler, if any. SECURITY WARNING:
  # YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR
  # OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
  proc OnProtocolExecution*(self: T, browser: NCBrowser,
    url: string, allow_os_execution: var bool)

  # Called on the UI thread to handle requests for URLs with an invalid SSL
  # certificate. Return true (1) and call cef_request_tCallback::cont() either
  # in this function or at a later time to continue or cancel the request.
  # Return false (0) to cancel the request immediately. If
  # CefSettings.ignore_certificate_errors is set all invalid certificates will
  # be accepted without calling this function.
  proc OnCertificateError*(self: T,
      browser: NCBrowser, cert_error: cef_errorcode,
      request_url: string, ssl_info: NCSslInfo,
      callback: NCRequestCallback): bool

  # Called on the browser process UI thread when a plugin has crashed.
  # |plugin_path| is the path of the plugin that crashed.
  proc OnPluginCrashed*(self: T, browser: NCBrowser, plugin_path: string)

  # Called on the browser process UI thread when the render view associated
  # with |browser| is ready to receive/handle IPC messages in the render
  # process.
  proc OnRenderViewReady*(self: T, browser: NCBrowser)

  # Called on the browser process UI thread when the render process terminates
  # unexpectedly. |status| indicates how the process terminated.
  proc OnRenderProcessTerminated*(self: T, browser: NCBrowser,
    status: cef_termination_status)