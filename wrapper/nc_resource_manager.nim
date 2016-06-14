import nc_util, nc_types, nc_request, os, strutils, nc_parser, tables
import nc_resource_handler, nc_request_handler, nc_task
import nc_stream, nc_stream_resource_handler, sequtils, nc_zip_archive

type
  UrlFilter = proc(url: string): string
  MimeTypeResolver = proc(url: string): string

  # Values that stay with a request as it moves between providers.
  RequestParams = object
    url: string
    browser: NCBrowser
    frame: NCFrame
    request: NCRequest
    urlFilter: UrlFilter
    mimeTypeResolver: MimeTypeResolver

  # Values associated with the pending request only. Ownership will be passed
  # between requests and the resource manager as request handling proceeds.
  RequestState = ref object
    manager: NCResourceManager

    # Callback to execute once request handling is complete.
    callback: NCRequestCallback

    # Position of the currently associated ProviderEntry in the |providers_|
    # list.
    currentProviderPos: int

    # Position of this request object in the currently associated
    # ProviderEntry's |pending_requests_| list.
    currentRequestPos: int

    # Params that will be copied to each request object.
    params: RequestParams

  # Object representing a request. Each request object is used for a single
  # call to Provider::OnRequest and will become detached (meaning the callbacks
  # will no longer trigger) after Request::Continue or Request::Stop is called.
  # A request passed to Provider::OnRequestCanceled will already have been
  # detached. The methods of this class may be called on any browser process
  # thread.
  Request* = ref object
    # Will be non-NULL while the request is pending. Only accessed on the
    # browser process IO thread.
    state: RequestState

    # Params that stay with this request object. Safe to access on any thread.
    params: RequestParams

  # Interface implemented by resource providers. A provider may be created on
  # any thread but the methods will be called on, and the object will be
  # destroyed on the browser process IO thread.
  Provider* = ref object of RootObj
    # Called to handle a request. If the provider knows immediately that it
    # will not handle the request return false. Otherwise, return true and call
    # Request::Continue or Request::Stop either in this method or
    # asynchronously to indicate completion. See comments on Request for
    # additional usage information.
    OnRequestImpl*: proc(prov: Provider, request: Request): bool

    # Called when a request has been canceled. It is still safe to dereference
    # |request| but any calls to Request::Continue or Request::Stop will be
    # ignored.
    OnRequestCanceledImpl*: proc(prov: Provider, request: Request)

    order: int
    identifier: string
    # List of pending requests currently associated with this provider.
    pendingRequests: seq[Request]

    # True if deletion of this provider is pending.
    deletionPending: bool

  PendingHandlersMap = Table[int64, NCResourceHandler]

  NCResourceManager* = ref object
    # The below members are only accessed on the browser process IO thread.
    # List of providers including additional associated information.
    providers: seq[Provider]

    # Map of response ID to pending NCResourceHandler object.
    pendingHandlers: PendingHandlersMap

    urlFilter: UrlFilter
    mimeTypeResolver: MimeTypeResolver

  ContentProvider = ref object of Provider
    url: string
    content: string
    mimeType: string

  DirectoryProvider = ref object of Provider
    urlPath: string
    directoryPath: string

  ArchiveProvider = ref object of Provider
    urlPath: string
    archivePath: string
    password: string
    archiveLoadStarted: bool
    archiveLoadEnded: bool
    archive: NCZipArchive

    #List of requests that are pending while the archive is being loaded.
    zipPendingRequests: seq[Request]

# Returns |url| without the query or fragment components, if any.
proc GetUrlWithoutQueryOrFragment(url: string): string =
  # Find the first instance of '?' or '#'.
  let pos = min(url.find('?'), url.find('#'))
  if pos != -1: return url.substr(0, pos)
  result = url

# Determine the mime type based on the |url| file extension.
proc GetMimeType(url: string): string =
  let url_without_query = GetUrlWithoutQueryOrFragment(url)
  let sep = url_without_query.rfind('.')
  if sep != -1:
    let mime_type = NCGetMimeType(url_without_query.substr(sep + 1))
    if mime_type.len != 0: return mime_type
  result = "text/html"

# Default no-op filter.
proc GetFilteredUrl(url: string): string = url

proc OnRequest(prov: Provider, request: Request): bool =
  result = prov.OnRequestImpl(prov, request)

proc OnRequestCanceled(prov: Provider, request: Request) =
  if prov.OnRequestCanceledImpl != nil:
    prov.OnRequestCanceledImpl(prov, request)

# The below methods are called on the browser process IO thread.
proc newRequest(state: RequestState): Request =
  NC_REQUIRE_IO_THREAD()

  new(result)
  result.state = state
  result.params = state.params
  var prov = state.manager.providers[state.currentProviderPos]

  # Should not be on a deleted provider
  doAssert(not prov.deletionPending)

  # Add this request to the provider's pending request list.
  prov.pendingRequests.add result
  state.currentRequestPos = prov.pendingRequests.len - 1

# Returns the URL associated with this request. The returned value will be
# fully qualified but will not contain query or fragment components. It
# will already have been passed through the URL filter.
proc getUrl*(self: Request): string =
  result = self.params.url

# Returns the CefBrowser associated with this request.
proc getBrowser*(self: Request): NCBrowser =
  result = self.params.browser

# Returns the CefFrame associated with this request.
proc getFrame*(self: Request): NCFrame =
  result = self.params.frame

# Returns the CefRequest associated with this request.
proc getRequest*(self: Request): NCRequest =
  result = self.params.request

# Returns the current URL filter.
proc getUrlFilter*(self: Request): UrlFilter =
  result = self.params.urlFilter

# Returns the current mime type resolver.
proc getMimeTypeResolver*(self: Request): MimeTypeResolver =
  result = self.params.mimeTypeResolver

proc initProvider(prov: Provider, order: int, identifier: string) =
  prov.order = order
  prov.identifier = identifier
  prov.deletionPending = false
  prov.pendingRequests = @[]

proc newNCResourceManager*(): NCResourceManager =
  new(result)
  result.urlFilter = GetFilteredUrl
  result.mimeTypeResolver = GetMimeType
  result.providers = @[]
  result.pendingHandlers = initTable[int64, NCResourceHandler]()

# Move to the next provider that is not pending deletion.
proc GetNextValidProvider(self: NCResourceManager, pos: int): int =
  result = pos
  while result != self.providers.len and self.providers[result].deletionPending:
    inc(result)

proc SendRequest(self: Request): RequestState =
  NC_REQUIRE_IO_THREAD()
  let manager  = self.state.manager
  var provider = manager.providers[self.state.currentProviderPos]

  if not provider.OnRequest(self):
    return self.state

  result = nil

proc removeElementAt[T](list: var seq[T], idx: int) =
  var temp: seq[T] = @[]
  for i in 0.. <list.len:
    if i != idx: temp.add list[i]
  list = temp

# The new provider, if any, should be determined before calling this method.
proc DetachRequestFromProvider(self: NCResourceManager, state: RequestState) =
  if state.currentProviderPos != self.providers.len:
    # Remove the association from the current provider entry.
    var currentProviderPos = state.currentProviderPos
    var currentProvider = self.providers[currentProviderPos]
    removeElementAt(currentProvider.pendingRequests, state.currentRequestPos)

    if currentProvider.deletionPending and (currentProvider.pendingRequests.len == 0):
      # Delete the current provider entry now.
      removeElementAt(self.providers, state.currentProviderPos)

    # Set to the end for error checking purposes.
    #state.currentProviderPos = self.providers.len

# Move state to the next provider if any and return true if there are more
# providers.
proc IncrementProvider(self: NCResourceManager, state: RequestState): bool =
  # Identify the next provider.
  var nextProviderPos = state.currentProviderPos
  inc(nextProviderPos)
  nextProviderPos = self.GetNextValidProvider(nextProviderPos)

  # Detach from the current provider.
  self.DetachRequestFromProvider(state)

  if nextProviderPos != self.providers.len:
    # Update the state to reference the new provider entry.
    state.currentProviderPos = nextProviderPos
    return true

  result = false

proc StopRequest(self: NCResourceManager, state: RequestState) =
  NC_REQUIRE_IO_THREAD()

  # Detach from the current provider.
  self.DetachRequestFromProvider(state)
  
  # Delete the state object and execute the callback.
  state.callback.Continue(true)  
  
# Send the request to providers in order until one potentially handles it or we
# run out of providers. Returns true if the request is potentially handled.
proc SendRequest(self: NCResourceManager, state: RequestState): bool =
  var potentiallyHandled = false
  var nextState = state

  while true:
    # Should not be on the last provider entry.
    doAssert(nextState.currentProviderPos != self.providers.len)
    var request = newRequest(nextState)

    # Give the provider an opportunity to handle the request.
    nextState = request.SendRequest()

    if nextState != nil:
      # The provider will not handle the request. Move to the next provider if
      # any.
      if not self.IncrementProvider(nextState):
        self.StopRequest(nextState)
        break
    else:
      potentiallyHandled = true
    if nextState == nil: break
    
  result = potentiallyHandled

proc AddProvider*(self: NCResourceManager, provider: Provider, order: int, identifier: string) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(AddProviderTask, AddProvider)
    discard NCPostTask(TID_IO, AddProviderTask(self, provider, order, identifier))
    return

  initProvider(provider, order, identifier)
  if self.providers.len == 0:
    self.providers.add provider
    return

  # Insert before the first entry with a higher |order| value.
  for i in 0.. <self.providers.len:
    if self.providers[i].order > order:
      self.providers.insert(provider, i)
      return

  self.providers.add provider

proc HasState(self: Request): bool =
  NC_REQUIRE_IO_THREAD()
  result = self.state != nil

proc StopOnIOThread(state: RequestState) =
  NC_REQUIRE_IO_THREAD()
  # The manager may already have been deleted.
  var manager = state.manager
  if manager != nil:
    manager.StopRequest(state)

# Stop handling the request. No additional providers will be called and
# NULL will be returned via CefResourceManager::GetResourceHandler.
proc Stop(self: Request) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(StopTask, Stop(self))
    discard NCPostTask(TID_IO, StopTask(self))
    return

  if self.state == nil:
    return

  # Disassociate |state_| immediately so that Provider::OnRequestCanceled is
  # not called unexpectedly if Provider::OnRequest calls this method and then
  # calls CefResourceManager::Remove*.
  NCBindTask(StopIOTask, StopOnIOThread)
  let task = StopIOTask(self.state)
  self.state = nil
  discard NCPostTask(TID_IO, task)

proc ContinueRequest(self: NCResourceManager, state: RequestState, handler: NCResourceHandler) =
  NC_REQUIRE_IO_THREAD()

  if handler != nil:
    # The request has been handled. Associate the request ID with the handler.
    let id = state.params.request.GetIdentifier()
    self.pendingHandlers[id] = handler
    self.StopRequest(state)
  else:
    # Move to the next provider if any.
    if self.IncrementProvider(state):
      discard self.SendRequest(state)
    else:
      self.StopRequest(state)

proc ContinueOnIOThread(state: RequestState, handler: NCResourceHandler) =
  NC_REQUIRE_IO_THREAD()
  # The manager may already have been deleted.
  var manager = state.manager
  if manager != nil:
    manager.ContinueRequest(state, handler)

# Continue handling the request. If |handler| is non-NULL then no
# additional providers will be called and the |handler| value will be
# returned via CefResourceManager::GetResourceHandler. If |handler| is NULL
# then the next provider in order, if any, will be called. If there are no
# additional providers then NULL will be returned via CefResourceManager::
# GetResourceHandler.
proc Continue*(self: Request, handler: NCResourceHandler) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(ContinueTask, Continue(self, handler))
    discard NCPostTask(TID_IO, ContinueTask(self, handler))
    return

  if self.state == nil:
    return

  # Disassociate |state_| immediately so that Provider::OnRequestCanceled is
  # not called unexpectedly if Provider::OnRequest calls this method and then
  # calls CefResourceManager::Remove*.
  NCBindTask(ContinueIOTask, ContinueOnIOThread)
  let task = ContinueIOTask(self.state, handler)
  self.state = nil
  discard NCPostTask(TID_IO, task)

proc DeleteNow(provider: Provider, stop: bool): bool =
  NC_REQUIRE_IO_THREAD()
  if provider.deletionPending:
    return false

  if provider.pendingRequests.len != 0:
    # Don't delete the provider entry until all pending requests have cleared.
    provider.deletionPending = true

    # Continue pending requests immediately.
    for request in provider.pendingRequests:
      if request.HasState():
        if stop: request.Stop()
        else: request.Continue(nil)
        provider.OnRequestCanceled(request)
    return false

  # Delete the provider entry now.
  result = true

proc RemoveProviders*(self: NCResourceManager, identifier: string) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(removeProvidersTask, RemoveProviders)
    discard NCPostTask(TID_IO, removeProvidersTask(self, identifier))
    return

  if self.providers.len == 0:
    return

  var temp: seq[Provider] = @[]
  for i in 0.. <temp.len:
    var provider = self.providers[i]
    if provider.identifier == identifier:
      if not provider.DeleteNow(false):
        temp.add provider

  self.providers = temp

proc RemoveAllProviders*(self: NCResourceManager) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(removeAllProvidersTask, RemoveAllProviders)
    discard NCPostTask(TID_IO, removeAllProvidersTask(self))
    return

  if self.providers.len == 0:
    return

  for prov in self.providers:
    discard prov.DeleteNow(true)

  self.providers = @[]

proc SetMimeTypeResolver*(self: NCResourceManager, resolver: MimeTypeResolver) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(setMimeTask, SetMimeTypeResolver)
    discard NCPostTask(TID_IO, setMimeTask(self, resolver))
    return

  if resolver != nil:
    self.mimeTypeResolver = resolver
  else:
    self.mimeTypeResolver = GetMimeType

proc SetUrlFilter*(self: NCResourceManager, filter: UrlFilter) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(setUrlFilterTask, SetUrlFilter)
    discard NCPostTask(TID_IO, setUrlFilterTask(self, filter))
    return

  if filter != nil:
    self.urlFilter = filter
  else:
    self.urlFilter = GetFilteredUrl

proc OnBeforeResourceLoad*(self: NCResourceManager, browser: NCBrowser,
  frame: NCFrame, request: NCRequest, callback: NCRequestCallback): cef_return_value =
  NC_REQUIRE_IO_THREAD()

  # Find the first provider that is not pending deletion.
  var currentProviderPos = 0
  currentProviderPos = self.GetNextValidProvider(currentProviderPos)

  if self.providers.len == currentProviderPos:
    # No providers so continue the request immediately.
    return RV_CONTINUE

  var state = new(RequestState)
  let url = request.GetURL()
  let filteredURL = self.urlFilter(url)

  state.manager  = self
  state.callback = callback
  state.params.url     = GetUrlWithoutQueryOrFragment(filteredURL)
  state.params.browser = browser
  state.params.frame   = frame
  state.params.request = request
  state.params.urlFilter = self.urlFilter
  state.params.mimeTypeResolver = self.mimeTypeResolver
  state.currentProviderPos = currentProviderPos

  #If the request is potentially handled we need to continue asynchronously.
  result = if self.SendRequest(state): RV_CONTINUE_ASYNC else: RV_CONTINUE

proc GetResourceHandler*(self: NCResourceManager, browser: NCBrowser,
  frame: NCFrame, request: NCRequest): NCResourceHandler =
  NC_REQUIRE_IO_THREAD()

  if self.pendingHandlers.len == 0:
    return nil

  let key = request.GetIdentifier()
  if self.pendingHandlers.hasKey(key):
    result = self.pendingHandlers[key]
    self.pendingHandlers.del key
  else:
    result = nil
  
proc cpOnRequest(prov: Provider, request: Request): bool =
  var self = ContentProvider(prov)
  NC_REQUIRE_IO_THREAD()
  let url = request.getUrl()

  if url != self.url:
    # Not handled by this provider.
    return false

  var stream = NCStreamReaderCreateForData(self.content.cstring, self.content.len)
  # Determine the mime type a single time if it isn't already set.
  if self.mimeType.len == 0:
    self.mimeType = request.getMimeTypeResolver()(url)

  request.Continue(newNCStreamResourceHandler(self.mimeType, stream))
  result = true

proc newContentProvider(url, content, mimeType: string): ContentProvider =
  new(result)
  result.url = url
  result.content = content
  result.mimeType = mimeType
  doAssert(result.url.len != 0)
  doAssert(result.content.len != 0)
  result.OnRequestImpl = cpOnRequest

proc AddContentProvider*(self: NCResourceManager, url, content, mimeType: string,
  order: int, identifier: string) =
  self.AddProvider(newContentProvider(url, content, mimeType), order, identifier)

proc GetFilePath(self: DirectoryProvider, url: string): string =
  var pathPart = url.substr(self.urlPath.len)

  when defined(windows):
    pathPart = pathPart.replace('/', '\\')

  result = self.directoryPath & pathPart

proc ContinueOpenOnIOThread(request: Request, stream: NCStreamReader) =
  NC_REQUIRE_IO_THREAD()

  if stream.GetHandler() != nil:
    let mimeType = request.getMimeTypeResolver()(request.getUrl())
    let handler = newNCStreamResourceHandler(mimeType, stream)
    request.Continue(handler)

proc OpenOnFileThread(filePath: string, request: Request) =
  #NC_REQUIRE_FILE_THREAD()

  #setupForeignThreadGC()
  var stream = NCStreamReaderCreateForFile(filePath)
  
  # Continue loading on the IO thread.
  #NCBindTask(ContinueOpenFileTask, ContinueOpenOnIOThread)
  #discard NCPostTask(TID_IO, ContinueOpenFileTask(request, stream))
  ContinueOpenOnIOThread(request, stream)

proc dpOnRequest(prov: Provider, request: Request): bool =
  var self = DirectoryProvider(prov)
  NC_REQUIRE_IO_THREAD()

  let url = request.getUrl()
  if url.find(self.urlPath) != 0:
    return false

  let filePath = self.GetFilePath(url)

  # Open |file_path| on the FILE thread.
  #NCBindTask(OpenFileTask, OpenOnFileThread)
  #discard NCPostTask(TID_FILE, OpenFileTask(filePath, request))
  OpenOnFileThread(filePath, request)
  result = true

# Provider of contents loaded from a directory on the file system.
proc newDirectoryProvider(urlPath, directoryPath: string): DirectoryProvider =
  new(result)

  result.urlPath = urlPath
  result.directoryPath = directoryPath

  doAssert(result.urlPath.len != 0)
  doAssert(result.directoryPath.len != 0)
  result.OnRequestImpl = dpOnRequest

  # Normalize the path values.
  if urlPath[urlPath.len - 1] != '/':
    result.urlPath.add '/'

  if directoryPath[directoryPath.len - 1] != DirSep:
    result.directoryPath.add DirSep

proc AddDirectoryProvider*(self: NCResourceManager, urlPath, directoryPath: string,
  order: int, identifier: string) =
  self.AddProvider(newDirectoryProvider(urlPath, directoryPath), order, identifier)

proc ContinueRequest(self: ArchiveProvider, request: Request): bool =
  # |archive_| will be NULL if the archive file failed to load or was empty.

  if self.archive == nil: return false

  let url = request.getUrl()
  let relativePath = url.substr(self.urlPath.len)
  if self.archive.HasFile(relativePath):
    var file = self.archive.GetFile(relativePath)
    let mimeType = request.getMimeTypeResolver()(url)
    let handler = newNCStreamResourceHandler(mimeType, file.GetStreamReader())
    if handler.GetHandler() == nil:
      return false

    request.Continue(handler)
    result = true

proc ContinueOnIOThread(self: ArchiveProvider, archive: NCZipArchive) =
  NC_REQUIRE_IO_THREAD()

  self.archiveLoadEnded = true
  self.archive = archive

  if self.zipPendingRequests.len != 0:
    # Continue all pending requests.
    for request in self.zipPendingRequests:
      discard self.ContinueRequest(request)
    self.zipPendingRequests = @[]

proc LoadOnFileThread(self: ArchiveProvider, archivePath, password: string) =
  NC_REQUIRE_FILE_THREAD()
  var stream = NCStreamReaderCreateForFile(archivePath)
  var archive: NCZipArchive

  if stream.GetHandler() != nil:
    archive = LoadZipArchive(stream, password, true)
    if archive == nil:
      echo "Failed to open archive file: ", archivePath
    else:
      if archive.GetFileCount() == 0:
        echo "Empty archive file: ", archivePath
  else:
    echo "Failed to load archive file: ", archivePath

  NCBindTask(continueOnIOThreadTask, ContinueOnIOThread(self, archive))
  discard NCPostTask(TID_IO, continueOnIOThreadTask(self, archive))

proc arOnRequest(prov: Provider, request: Request): bool =
  var self = ArchiveProvider(prov)
  NC_REQUIRE_IO_THREAD()

  let url = request.getUrl()
  if url.find(self.urlPath) != 0:
    # Not handled by this provider.
    return false

  if not self.archiveLoadStarted:
    # Initiate archive loading and queue the pending request.
    self.archiveLoadStarted = true
    self.zipPendingRequests.add(request)

    #Load the archive file on the FILE thread.
    NCBindTask(loadOnFileThreadTask, LoadOnFileThread)
    discard NCPostTask(TID_FILE, loadOnFileThreadTask(self, self.archivePath, self.password))
    return true

  if self.archiveLoadStarted and not self.archiveLoadEnded:
    # The archive load has already started. Queue the pending request.
    self.zipPendingRequests.add request
    return true

  # Archive loading is done.
  result = self.ContinueRequest(request)

# Provider of contents loaded from an archive file.
proc newArchiveProvider(urlPath, archivePath, password: string): ArchiveProvider =
  new(result)
  result.urlPath = urlPath
  result.archivePath = archivePath
  result.password = password
  result.archiveLoadStarted = false
  result.archiveLoadEnded = false

  doAssert(result.urlPath.len != 0)
  doAssert(result.archivePath.len != 0)
  result.OnRequestImpl = arOnRequest

  # Normalize the path values.
  if urlPath[urlPath.len - 1] != '/':
    result.urlPath.add '/'

proc AddArchiveProvider*(self: NCResourceManager, urlPath, archivePath, password: string,
  order: int, identifier: string) =
  self.AddProvider(newArchiveProvider(urlPath, archivePath, password), order, identifier)
