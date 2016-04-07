import cef_base_api, cef_request_api, cef_auth_callback_api, cef_request_context_api
import cef_response_api
include cef_import

type
  # Structure used to make a URL request. URL requests are not associated with a
  # browser instance so no cef_client_t callbacks will be executed. URL requests
  # can be created on any valid CEF thread in either the browser or render
  # process. Once created the functions of the URL request object must be
  # accessed on the same thread that created it.
  cef_urlrequest* = object
    base*: cef_base

    # Returns the request object used to create this URL request. The returned
    # object is read-only and should not be modified.
    get_request*: proc(self: ptr cef_urlrequest): ptr cef_request {.cef_callback.}
  
    # Returns the client.
    get_client*: proc(self: ptr cef_urlrequest): ptr cef_urlrequest_client {.cef_callback.}
  
    # Returns the request status.
    get_request_status*: proc(self: ptr cef_urlrequest): cef_urlrequest_status {.cef_callback.}
  
    # Returns the request error if status is UR_CANCELED or UR_FAILED_api, or 0
    # otherwise.
    get_request_error*: proc(self: ptr cef_urlrequest): cef_errorcode {.cef_callback.}
  
    # Returns the response_api, or NULL if no response information is available.
    # Response information will only be available after the upload has completed.
    # The returned object is read-only and should not be modified.
    get_response*: proc(self: ptr cef_urlrequest): ptr cef_response {.cef_callback.}
  
    # Cancel the request.
    cancel*: proc(self: ptr cef_urlrequest) {.cef_callback.}


  # Structure that should be implemented by the cef_urlrequest_t client. The
  # functions of this structure will be called on the same thread that created
  # the request unless otherwise documented.
  cef_urlrequest_client* = object
    base*: cef_base

    # Notifies the client that the request has completed. Use the
    # cef_urlrequest_t::GetRequestStatus function to determine if the request was
    # successful or not.
    on_request_complete*: proc(self: ptr cef_urlrequest_client,
        request: ptr cef_urlrequest) {.cef_callback.}
  
    # Notifies the client of upload progress. |current| denotes the number of
    # bytes sent so far and |total| is the total size of uploading data (or -1 if
    # chunked upload is enabled). This function will only be called if the
    # UR_FLAG_REPORT_UPLOAD_PROGRESS flag is set on the request.
    on_upload_progress*: proc(self: ptr cef_urlrequest_client,
        request: ptr cef_urlrequest, current, total: int64) {.cef_callback.}
  
    # Notifies the client of download progress. |current| denotes the number of
    # bytes received up to the call and |total| is the expected total size of the
    # response (or -1 if not determined).
    on_download_progress*: proc(self: ptr cef_urlrequest_client, 
      request: ptr cef_urlrequest, current, total: int64) {.cef_callback.}
  
    # Called when some part of the response is read. |data| contains the current
    # bytes received since the last call. This function will not be called if the
    # UR_FLAG_NO_DOWNLOAD_DATA flag is set on the request.
    on_download_data*: proc(self: ptr cef_urlrequest_client,
        request: ptr cef_urlrequest, data: pointer,
        data_length: csize) {.cef_callback.}
  
    # Called on the IO thread when the browser needs credentials from the user.
    # |isProxy| indicates whether the host is a proxy server. |host| contains the
    # hostname and |port| contains the port number. Return true (1) to continue
    # the request and call cef_auth_callback_t::cont() when the authentication
    # information is available. Return false (0) to cancel the request. This
    # function will only be called for requests initiated from the browser
    # process.
    get_auth_credentials*: proc(self: ptr cef_urlrequest_client, 
      isProxy: cint, host: ptr cef_string, port: cint, realm: ptr cef_string,
      scheme: ptr cef_string, callback: ptr cef_auth_callback): cint {.cef_callback.}
      
      
# Create a new URL request. Only GET_api, POST_api, HEAD_api, DELETE and PUT request
# functions are supported. Multiple post data elements are not supported and
# elements of type PDE_TYPE_FILE are only supported for requests originating
# from the browser process. Requests originating from the render process will
# receive the same handling as requests originating from Web content -- if the
# response contains Content-Disposition or Mime-Type header values that would
# not normally be rendered then the response may receive special handling
# inside the browser (for example_api, via the file download code path instead of
# the URL request code path). The |request| object will be marked as read-only
# after calling this function. In the browser process if |request_context| is
# NULL the global request context will be used. In the render process
# |request_context| must be NULL and the context associated with the current
# renderer process' browser will be used.
proc cef_urlrequest_create*(request: ptr cef_request, clinet: ptr cef_urlrequest_client,
    request_context: ptr cef_request_context): ptr cef_urlrequest {.cef_import.}