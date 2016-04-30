import nc_util_impl
import cef/cef_types, cef/cef_auth_callback_api, cef/cef_request_context_api
include cef/cef_import

proc nc_wrap*(handler: ptr cef_urlrequest): NCUrlRequest =
  new(result, nc_finalizer[NCUrlRequest])
  result.handler = handler
  add_ref(handler)

type
  nc_urlrequest_client = object of nc_base[cef_urlrequest_client, NCUrlRequestClient]
    impl: nc_urlrequest_i[NCUrlRequestClient]
    
proc on_request_complete(self: ptr cef_urlrequest_client, request: ptr cef_urlrequest) {.cef_callback.} =
  var handler = toType(nc_urlrequest_client, self)
  if handler.impl.OnRequestComplete != nil:
    handler.impl.OnRequestComplete(handler.container, nc_wrap(request))
  release(request)

proc on_upload_progress(self: ptr cef_urlrequest_client,
  request: ptr cef_urlrequest, current, total: int64) {.cef_callback.} =
  var handler = toType(nc_urlrequest_client, self)
  if handler.impl.OnUploadProgress != nil:
    handler.impl.OnUploadProgress(handler.container, nc_wrap(request), current, total)
  release(request)

proc on_download_progress(self: ptr cef_urlrequest_client,
  request: ptr cef_urlrequest, current, total: int64) {.cef_callback.} =
  var handler = toType(nc_urlrequest_client, self)
  if handler.impl.OnDownloadProgress != nil:
    handler.impl.OnDownloadProgress(handler.container, nc_wrap(request), current, total)
  release(request)

proc on_download_data(self: ptr cef_urlrequest_client,
  request: ptr cef_urlrequest, data: pointer, data_length: csize) {.cef_callback.} =
  var handler = toType(nc_urlrequest_client, self)
  if handler.impl.OnDownloadData != nil:
    handler.impl.OnDownloadData(handler.container, nc_wrap(request), data, data_length.int)
  release(request)

proc get_auth_credentials(self: ptr cef_urlrequest_client,
  isProxy: cint, host: ptr cef_string, port: cint, realm: ptr cef_string,
  scheme: ptr cef_string, callback: ptr cef_auth_callback): cint {.cef_callback.} =
  var handler = toType(nc_urlrequest_client, self)
  if handler.impl.GetAuthCredentials != nil:
    result = handler.impl.GetAuthCredentials(handler.container, isProxy == 1.cint,
      $host, port.int, $realm, $scheme, callback).cint
  release(callback)
  
proc nc_wrap*(handler: ptr cef_urlrequest_client): NCUrlRequestClient =
  new(result, nc_finalizer[NCUrlRequestClient])
  result.handler = handler
  add_ref(handler)
  
proc makeNCUrlRequestClient[T](impl: nc_urlrequest_i[T]): T =
  nc_init(nc_urlrequest_client, T, impl)
  result.handler.on_request_complete = on_request_complete
  result.handler.on_upload_progress = on_upload_progress
  result.handler.on_download_progress = on_download_progress
  result.handler.on_download_data = on_download_data
  result.handler.get_auth_credentials = get_auth_credentials

proc NCUrlRequestCreate(request: NCRequest, client: NCUrlRequestClient, 
  request_context: NCRequestContext = nil): NCUrlRequest =
  var context: ptr cef_request_context = if request_context == nil: nil else: request_context.GetHandler()
  result = nc_wrap(cef_urlrequest_create(request, client.handler, context))