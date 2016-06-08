import cef_base_api, cef_frame_api, cef_request_api, cef_resource_handler_api
import cef_auth_callback_api, cef_sslinfo_api, cef_response_api, cef_response_filter_api
include cef_import

type
  # Callback structure used for asynchronous continuation of url requests.
  cef_request_callback* = object
    # Base structure.
    base*: cef_base

    # Continue the url request. If |allow| is true (1) the request will be
    # continued. Otherwise, the request will be canceled.
    cont*: proc(self: ptr cef_request_callback, allow: cint) {.cef_callback.}

    # Cancel the url request.
    cancel*: proc(self: ptr cef_request_callback) {.cef_callback.}

  # Implement this structure to handle events related to browser requests. The
  # functions of this structure will be called on the thread indicated.
  cef_request_handler* = object
    # Base structure.
    base*: cef_base

    # Called on the UI thread before browser navigation. Return true (1) to
    # cancel the navigation or false (0) to allow the navigation to proceed. The
    # |request| object cannot be modified in this callback.
    # cef_load_handler_t::OnLoadingStateChange will be called twice in all cases.
    # If the navigation is allowed cef_load_handler_t::OnLoadStart and
    # cef_load_handler_t::OnLoadEnd will be called. If the navigation is canceled
    # cef_load_handler_t::OnLoadError will be called with an |errorCode| value of
    # ERR_ABORTED.
    on_before_browse*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame,
        request: ptr cef_request, is_redirect: cint): cint {.cef_callback.}

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
    on_open_urlfrom_tab*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame,
        target_url: ptr cef_string,
        target_disposition: cef_window_open_disposition, user_gesture: cint): cint {.cef_callback.}

    # Called on the IO thread before a resource request is loaded. The |request|
    # object may be modified. Return RV_CONTINUE to continue the request
    # immediately. Return RV_CONTINUE_ASYNC and call cef_request_callback::
    # cont() at a later time to continue or cancel the request asynchronously.
    # Return RV_CANCEL to cancel the request immediately.
    on_before_resource_load*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame, request: ptr cef_request,
        callback: ptr cef_request_callback): cef_return_value {.cef_callback.}

    # Called on the IO thread before a resource is loaded. To allow the resource
    # to load normally return NULL. To specify a handler for the resource return
    # a cef_resource_handler_t object. The |request| object should not be
    # modified in this callback.
    get_resource_handler*: proc(self: ptr cef_request_handler, browser: ptr_cef_browser,
        frame: ptr cef_frame, request: ptr cef_request): ptr cef_resource_handler {.cef_callback.}

    # Called on the IO thread when a resource load is redirected. The |request|
    # parameter will contain the old URL and other request-related information.
    # The |new_url| parameter will contain the new URL and can be changed if
    # desired. The |request| object cannot be modified in this callback.
    on_resource_redirect*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame,
        request: ptr cef_request, new_url: ptr cef_string) {.cef_callback.}

    # Called on the IO thread when a resource response is received. To allow the
    # resource to load normally return false (0). To redirect or retry the
    # resource modify |request| (url, headers or post body) and return true (1).
    # The |response| object cannot be modified in this callback.
    on_resource_response*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame,
        request: ptr cef_request, response: ptr cef_response): cint {.cef_callback.}

    # Called on the IO thread to optionally filter resource response content.
    # |request| and |response| represent the request and response respectively
    # and cannot be modified in this callback.
    get_resource_response_filter*: proc(self: ptr cef_request_handler, browser: ptr_cef_browser,
        frame: ptr cef_frame, request: ptr cef_request,
        response: ptr cef_response): ptr cef_response_filter {.cef_callback.}

    # Called on the IO thread when a resource load has completed. |request| and
    # |response| represent the request and response respectively and cannot be
    # modified in this callback. |status| indicates the load completion status.
    # |received_content_length| is the number of response bytes actually read.
    on_resource_load_complete*: proc(self: ptr cef_request_handler, browser: ptr_cef_browser,
        frame: ptr cef_frame, request: ptr cef_request,
        response: ptr cef_response, status: cef_urlrequest_status,
        received_content_length: int64) {.cef_callback.}

    # Called on the IO thread when the browser needs credentials from the user.
    # |isProxy| indicates whether the host is a proxy server. |host| contains the
    # hostname and |port| contains the port number. |realm| is the realm of the
    # challenge and may be NULL. |scheme| is the authentication scheme used, such
    # as "basic" or "digest", and will be NULL if the source of the request is an
    # FTP server. Return true (1) to continue the request and call
    # cef_auth_callback_t::cont() either in this function or at a later time when
    # the authentication information is available. Return false (0) to cancel the
    # request immediately.
    get_auth_credentials*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame, isProxy: cint,
        host: ptr cef_string, port: cint, realm: ptr cef_string,
        scheme: ptr cef_string, callback: ptr cef_auth_callback): cint {.cef_callback.}

    # Called on the IO thread when JavaScript requests a specific storage quota
    # size via the webkitStorageInfo.requestQuota function. |origin_url| is the
    # origin of the page making the request. |new_size| is the requested quota
    # size in bytes. Return true (1) to continue the request and call
    # cef_request_tCallback::cont() either in this function or at a later time to
    # grant or deny the request. Return false (0) to cancel the request
    # immediately.
    on_quota_request*: proc(self: ptr cef_request_handler,
      browser: ptr_cef_browser, origin_url: ptr cef_string,
      new_size: int64, callback: ptr cef_request_callback): cint {.cef_callback.}

    # Called on the UI thread to handle requests for URLs with an unknown
    # protocol component. Set |allow_os_execution| to true (1) to attempt
    # execution via the registered OS protocol handler, if any. SECURITY WARNING:
    # YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR
    # OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
    on_protocol_execution*: proc(self: ptr cef_request_handler, browser: ptr_cef_browser,
      url: ptr cef_string, allow_os_execution: var cint) {.cef_callback.}

    # Called on the UI thread to handle requests for URLs with an invalid SSL
    # certificate. Return true (1) and call cef_request_tCallback::cont() either
    # in this function or at a later time to continue or cancel the request.
    # Return false (0) to cancel the request immediately. If
    # CefSettings.ignore_certificate_errors is set all invalid certificates will
    # be accepted without calling this function.
    on_certificate_error*: proc(self: ptr cef_request_handler,
        browser: ptr_cef_browser, cert_error: cef_errorcode,
        request_url: ptr cef_string, ssl_info: ptr cef_sslinfo,
        callback: ptr cef_request_callback): cint {.cef_callback.}

    # Called on the browser process UI thread when a plugin has crashed.
    # |plugin_path| is the path of the plugin that crashed.
    on_plugin_crashed*: proc(self: ptr cef_request_handler,
      browser: ptr_cef_browser, plugin_path: ptr cef_string) {.cef_callback.}

    # Called on the browser process UI thread when the render view associated
    # with |browser| is ready to receive/handle IPC messages in the render
    # process.
    on_render_view_ready*: proc(self: ptr cef_request_handler,
      browser: ptr_cef_browser) {.cef_callback.}

    # Called on the browser process UI thread when the render process terminates
    # unexpectedly. |status| indicates how the process terminated.
    on_render_process_terminated*: proc(self: ptr cef_request_handler, browser: ptr_cef_browser,
      status: cef_termination_status) {.cef_callback.}