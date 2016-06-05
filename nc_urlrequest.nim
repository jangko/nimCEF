import nc_request, nc_response, nc_util, nc_types, nc_auth_callback, nc_request_context
import impl/nc_util_impl
include cef/cef_import

# Structure used to make a URL request. URL requests are not associated with a
# browser instance so no cef_client_t callbacks will be executed. URL requests
# can be created on any valid CEF thread in either the browser or render
# process. Once created the functions of the URL request object must be
# accessed on the same thread that created it.
wrapAPI(NCUrlRequest, cef_urlrequest)

# Structure that should be implemented by the cef_urlrequest_t client. The
# functions of this structure will be called on the same thread that created
# the request unless otherwise documented.
wrapCallback(NCUrlRequestClient, cef_urlrequest_client):
  # Notifies the client that the request has completed. Use the
  # cef_urlrequest_t::GetRequestStatus function to determine if the request was
  # successful or not.
  proc OnRequestComplete*(self: T, request: NCUrlRequest)

  # Notifies the client of upload progress. |current| denotes the number of
  # bytes sent so far and |total| is the total size of uploading data (or -1 if
  # chunked upload is enabled). This function will only be called if the
  # UR_FLAG_REPORT_UPLOAD_PROGRESS flag is set on the request.
  proc OnUploadProgress*(self: T, request: NCUrlRequest, current, total: int64)

  # Notifies the client of download progress. |current| denotes the number of
  # bytes received up to the call and |total| is the expected total size of the
  # response (or -1 if not determined).
  proc OnDownloadProgress*(self: T, request: NCUrlRequest, current, total: int64)

  # Called when some part of the response is read. |data| contains the current
  # bytes received since the last call. This function will not be called if the
  # UR_FLAG_NO_DOWNLOAD_DATA flag is set on the request.
  proc OnDownloadData*(self: T, request: NCUrlRequest, data: pointer, data_length: int)

  # Called on the IO thread when the browser needs credentials from the user.
  # |isProxy| indicates whether the host is a proxy server. |host| contains the
  # hostname and |port| contains the port number. Return true (1) to continue
  # the request and call cef_auth_callback_t::cont() when the authentication
  # information is available. Return false (0) to cancel the request. This
  # function will only be called for requests initiated from the browser
  # process.
  proc GetAuthCredentials*(self: T, isProxy: bool, host: string, port: int, realm: string,
    scheme: string, callback: NCAuthCallback): bool

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
proc NCUrlRequestCreate*(request: NCRequest, client: NCUrlRequestClient,
  request_context: NCRequestContext = nil): NCUrlRequest =
  wrapProc(cef_url_request_create, result, request, client, request_context)

# Returns the request object used to create this URL request. The returned
# object is read-only and should not be modified.
proc GetRequest*(self: NCUrlRequest): NCRequest =
  self.wrapCall(get_request, result)

# Returns the client.
proc GetClient*(self: NCUrlRequest): NCUrlrequestClient =
  self.wrapCall(get_client, result)

# Returns the request status.
proc GetRequestStatus*(self: NCUrlRequest): cef_urlrequest_status =
  self.wrapCall(get_request_status, result)

# Returns the request error if status is UR_CANCELED or UR_FAILED_api, or 0
# otherwise.
proc GetRequestError*(self: NCUrlRequest): cef_errorcode =
  self.wrapCall(get_request_error, result)

# Returns the response_api, or NULL if no response information is available.
# Response information will only be available after the upload has completed.
# The returned object is read-only and should not be modified.
proc GetResponse*(self: NCUrlRequest): NCResponse =
  self.wrapCall(get_response, result)

# Cancel the request.
proc Cancel*(self: NCUrlRequest) =
  self.wrapCall(cancel)
