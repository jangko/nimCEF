import nc_util, nc_types, nc_request, os, strutils, nc_parser, tables
import nc_resource_handler, nc_request_handler, nc_task, hashes
import nc_stream, nc_stream_resource_handler, lists

type
  UrlFilter = proc(url: string): string
  MimeTypeResolver = proc(url: string): string
  
  # Values that stay with a request as it moves between providers.
  RequestParams = object
    url: string
    browser: NCBrowser
    frame: NCFrame
    request: NCRequest
    url_filter: UrlFilter
    mime_type_resolver: MimeTypeResolver

  ProviderIterator = DoublyLinkedNode[ProviderEntry]
  RequestIterator = DoublyLinkedNode[Request]
    
  # Values associated with the pending request only. Ownership will be passed
  # between requests and the resource manager as request handling proceeds.
  RequestState = ref object
    manager: NCResourceManager

    # Callback to execute once request handling is complete.
    callback: NCRequestCallback

    # Position of the currently associated ProviderEntry in the |providers_|
    # list.
    current_entry_pos: ProviderIterator

    # Position of this request object in the currently associated
    # ProviderEntry's |pending_requests_| list.
    current_request_pos: RequestIterator

    # Params that will be copied to each request object.
    params: RequestParams
  
  # Object representing a request. Each request object is used for a single
  # call to Provider::OnRequest and will become detached (meaning the callbacks
  # will no longer trigger) after Request::Continue or Request::Stop is called.
  # A request passed to Provider::OnRequestCanceled will already have been
  # detached. The methods of this class may be called on any browser process
  # thread. 
  Request = ref object
    # Will be non-NULL while the request is pending. Only accessed on the
    # browser process IO thread.
    state: RequestState

    # Params that stay with this request object. Safe to access on any thread.
    params: RequestParams

  # Interface implemented by resource providers. A provider may be created on
  # any thread but the methods will be called on, and the object will be
  # destroyed on, the browser process IO thread.
  Provider = ref object of RootObj
    # Called to handle a request. If the provider knows immediately that it
    # will not handle the request return false. Otherwise, return true and call
    # Request::Continue or Request::Stop either in this method or
    # asynchronously to indicate completion. See comments on Request for
    # additional usage information.
    OnRequestImpl: proc(prov: Provider, request: Request): bool

    # Called when a request has been canceled. It is still safe to dereference
    # |request| but any calls to Request::Continue or Request::Stop will be
    # ignored.
    OnRequestCanceledImpl: proc(prov: Provider, request: Request)

  ContentProvider = ref object of Provider
    url: string
    content: string
    mime_type: string

  ProviderEntry = ref object
    provider: Provider
    order: int
    identifier: string
    # List of pending requests currently associated with this provider.
    pending_requests: DoublyLinkedList[Request]
    # True if deletion of this provider is pending.
    deletion_pending: bool
    
  PendingHandlersMap = Table[int64, NCResourceHandler]  

  NCResourceManager = ref object
    # The below members are only accessed on the browser process IO thread.
    # List of providers including additional associated information.
    providers: DoublyLinkedList[ProviderEntry]

    # Map of response ID to pending NCResourceHandler object.    
    pending_handlers: PendingHandlersMap

    url_filter: UrlFilter
    mime_type_resolver: MimeTypeResolver
  
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

proc newProviderEntry(provider: Provider, order: int, identifier: string): ProviderEntry =
  new(result)
  result.provider = provider
  result.order = order
  result.identifier = identifier
  result.deletion_pending = false
  
# Returns the URL associated with this request. The returned value will be
# fully qualified but will not contain query or fragment components. It
# will already have been passed through the URL filter.
proc url(self: Request): string = 
  result = self.params.url

# Returns the CefBrowser associated with this request.
proc browser(self: Request): NCBrowser =
  result = self.params.browser
 
# Returns the CefFrame associated with this request.
proc frame(self: Request): NCFrame =
  result = self.params.frame

# Returns the CefRequest associated with this request.
proc request(self: Request): NCRequest =
  result = self.params.request

# Returns the current URL filter.
proc url_filter(self: Request): UrlFilter =
  result = self.params.url_filter

# Returns the current mime type resolver.
proc mime_type_resolver(self: Request): MimeTypeResolver =
  result = self.params.mime_type_resolver
  
proc ContinueOnIOThread(self: Request, state: RequestState, handler: NCResourceHandler)
proc StopOnIOThread(self: Request, state: RequestState)
proc ContinueRequest(self: NCResourceManager, state: RequestState, handler: NCResourceHandler)
proc StopRequest(self: NCResourceManager, state: RequestState)
proc DetachRequestFromProvider(self: NCResourceManager, state: RequestState)
proc IncrementProvider(self: NCResourceManager, state: RequestState): bool

# Continue handling the request. If |handler| is non-NULL then no
# additional providers will be called and the |handler| value will be
# returned via CefResourceManager::GetResourceHandler. If |handler| is NULL
# then the next provider in order, if any, will be called. If there are no
# additional providers then NULL will be returned via CefResourceManager::
# GetResourceHandler. 
proc Continue(self: Request, handler: NCResourceHandler) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(bindContinue, Continue(self, handler))
    discard NCPostTask(TID_IO, bindContinue(self, handler))
    return

  if self.state != nil:
    return

  # Disassociate |state_| immediately so that Provider::OnRequestCanceled is
  # not called unexpectedly if Provider::OnRequest calls this method and then
  # calls CefResourceManager::Remove*.
  NCBindTask(bindContIO, ContinueOnIOThread)
  discard NCPostTask(TID_IO, bindContIO(self, self.state, handler))
  
# Stop handling the request. No additional providers will be called and
# NULL will be returned via CefResourceManager::GetResourceHandler.
proc Stop(self: Request) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(bindStop, Stop(self))
    discard NCPostTask(TID_IO, bindStop(self))
    return

  if self.state != nil:
    return

  # Disassociate |state_| immediately so that Provider::OnRequestCanceled is
  # not called unexpectedly if Provider::OnRequest calls this method and then
  # calls CefResourceManager::Remove*.
  NCBindTask(bindStopIO, StopOnIOThread)  
  discard NCPostTask(TID_IO, bindStopIO(self, self.state))
    
# The below methods are called on the browser process IO thread.
proc newRequest(state: RequestState): Request =
  NC_REQUIRE_IO_THREAD()
  
  new(result)
  result.state = state
  result.params = state.params  
  var entry = state.current_entry_pos.value
  
  # Should not be on a deleted entry
  doAssert(not entry.deletion_pending)

  # Add this request to the entry's pending request list.
  entry.pending_requests.append(result)
  state.current_request_pos = nil
    
proc SendRequest(self: Request): RequestState =
  NC_REQUIRE_IO_THREAD()
  var provider = self.state.current_entry_pos.value.provider
  
  if not provider.OnRequest(self):
    return self.state
    
  result = RequestState()
  
proc HasState(self: Request): bool =
  NC_REQUIRE_IO_THREAD()
  result = self.state != nil
  
proc ContinueOnIOThread(self: Request, state: RequestState, handler: NCResourceHandler) =
  NC_REQUIRE_IO_THREAD()
  # The manager may already have been deleted.
  var manager = state.manager
  if manager != nil:
    manager.ContinueRequest(state, handler)
    
proc StopOnIOThread(self: Request, state: RequestState) =   
  NC_REQUIRE_IO_THREAD()
  # The manager may already have been deleted.
  var manager = state.manager
  if manager != nil:
    manager.StopRequest(state)

proc newNCResourceManager(): NCResourceManager =
  new(result)
  result.url_filter = GetFilteredUrl
  result.mime_type_resolver = GetMimeType    
  result.providers = initDoublyLinkedList[ProviderEntry]()
  result.pending_handlers = initTable[int64, NCResourceHandler]()

# Send the request to providers in order until one potentially handles it or we
# run out of providers. Returns true if the request is potentially handled.
proc SendRequest(self: NCResourceManager, state: RequestState): bool =
  var potentially_handled = false
  var xstate = state

  while true:
    # Should not be on the last provider entry.
    doAssert(state.current_entry_pos != nil)
    var request = newRequest(xstate)

    # Give the provider an opportunity to handle the request.
    xstate = request.SendRequest()
    if xstate.callback != nil:
      # The provider will not handle the request. Move to the next provider if
      # any.
      if not self.IncrementProvider(xstate):
        self.StopRequest(xstate)
      else:
        potentially_handled = true
        
    if xstate.callback == nil: break
  
  result = potentially_handled

proc ContinueRequest(self: NCResourceManager, state: RequestState, handler: NCResourceHandler) =
  NC_REQUIRE_IO_THREAD()

  if handler != nil:
    # The request has been handled. Associate the request ID with the handler.
    let id = state.params.request.GetIdentifier()
    self.pending_handlers[id] = handler
    self.StopRequest(state)
  else:
    # Move to the next provider if any.
    if self.IncrementProvider(state):
      discard self.SendRequest(state)
    else:
      self.StopRequest(state)
  
proc StopRequest(self: NCResourceManager, state: RequestState) =
  NC_REQUIRE_IO_THREAD()
  
  # Detach from the current provider.
  self.DetachRequestFromProvider(state)

  # Delete the state object and execute the callback.
  state.callback.Continue(true)
  state.callback = nil

proc is_empty[T](L: var DoublyLinkedList[T]): bool =
  result = L.tail == L.head and L.tail == nil
  
# The new provider, if any, should be determined before calling this method.
proc DetachRequestFromProvider(self: NCResourceManager, state: RequestState) =
  if state.current_entry_pos != nil:
    # Remove the association from the current provider entry.
    var current_entry_pos = state.current_entry_pos
    var current_entry = current_entry_pos.value
    current_entry.pending_requests.remove(state.current_request_pos)

    if current_entry.deletion_pending and current_entry.pending_requests.is_empty():
      # Delete the current provider entry now.
      self.providers.remove(current_entry_pos)

    # Set to the end for error checking purposes.
    state.current_entry_pos = nil
 
# Move to the next provider that is not pending deletion.
proc GetNextValidProvider(self: NCResourceManager, it: var int) =
  while (it != nil) and it.value.deletion_pending:
    it = it.next
  
# Move state to the next provider if any and return true if there are more
# providers.
proc IncrementProvider(self: NCResourceManager, state: RequestState): bool =
  # Identify the next provider.
  var next_entry_pos = state.current_entry_pos
  inc(next_entry_pos)
  self.GetNextValidProvider(next_entry_pos)

  # Detach from the current provider.
  self.DetachRequestFromProvider(state)

  if next_entry_pos != self.providers.len:
    # Update the state to reference the new provider entry.
    state.current_entry_pos = next_entry_pos
    return true

  result = false

proc AddProvider(self: NCResourceManager, provider: Provider, order: int, identifier: string) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(bindAddProvider, AddProvider)
    discard NCPostTask(TID_IO, bindAddProvider(self, provider, order, identifier))
    return
  
  var new_entry = newProviderEntry(provider, order, identifier)
  if self.providers.is_empty():
    self.providers.add(new_entry)
    return

  # Insert before the first entry with a higher |order| value.
  for i in 0.. <self.providers.len:
    if self.providers[i].order > order:
      self.providers.insert(new_entry, i)
      break
      
proc DeleteProvider(self: NCResourceManager, it: int, stop: bool) =
  NC_REQUIRE_IO_THREAD()
  var current_entry = self.providers[it]
  if current_entry.deletion_pending:
    return

  if current_entry.pending_requests.len != 0:
    # Don't delete the provider entry until all pending requests have cleared.
    current_entry.deletion_pending = true

    # Continue pending requests immediately.
    for request in current_entry.pending_requests:
      if request.HasState():
        if stop: request.Stop()
        else: request.Continue(nil)
        current_entry.provider.OnRequestCanceled(request)
  else:
    # Delete the provider entry now.
    self.providers.delete(it)

proc RemoveProviders(self: NCResourceManager, identifier: string) =
  if not NCCurrentlyOn(TID_IO):
    NCBindTask(bindRemoveProviders, RemoveProviders)
    discard NCPostTask(TID_IO, bindRemoveProviders(self, identifier))
    return

  if self.providers.len == 0:
    return

  for it in 0.. <self.providers.len:
    if self.providers[it].identifier == identifier:
      DeleteProvider(it, false)
    
 #[  
void CefResourceManager::RemoveAllProviders() {
  if (!CefCurrentlyOn(TID_IO)) {
    CefPostTask(TID_IO,
        base::Bind(&CefResourceManager::RemoveAllProviders, this));
    return;
  }

  if (providers_.empty())
    return;

  ProviderEntryList::iterator it = providers_.begin();
  while (it != providers_.end())
    DeleteProvider(it, true);
}

void CefResourceManager::SetMimeTypeResolver(const MimeTypeResolver& resolver) {
  if (!CefCurrentlyOn(TID_IO)) {
    CefPostTask(TID_IO,
        base::Bind(&CefResourceManager::SetMimeTypeResolver, this, resolver));
    return;
  }

  if (!resolver.is_null())
    mime_type_resolver_ = resolver;
  else
    mime_type_resolver_ = base::Bind(GetMimeType);
}

void CefResourceManager::SetUrlFilter(const UrlFilter& filter) {
  if (!CefCurrentlyOn(TID_IO)) {
    CefPostTask(TID_IO,
        base::Bind(&CefResourceManager::SetUrlFilter, this, filter));
    return;
  }

  if (!filter.is_null())
    url_filter_ = filter;
  else
    url_filter_ = base::Bind(GetFilteredUrl);
}

  ]#
  
proc cpOnRequest(prov: Provider, request: Request): bool =
  var self = ContentProvider(prov)
  NC_REQUIRE_IO_THREAD()
  let url = request.url()
  
  if url != self.url:
    # Not handled by this provider.
    return false

  var stream = NCStreamReaderCreateForData(self.content.cstring, self.content.len)
  # Determine the mime type a single time if it isn't already set.
  if self.mime_type.len == 0:
    self.mime_type = request.mime_type_resolver()(url)

  request.Continue(newNCStreamResourceHandler(self.mime_type, stream))
  result = true

proc newContentProvider(url, content, mime_type: string): ContentProvider =
  new(result)
  result.url = url
  result.content = content
  result.mime_type = mime_type
  doAssert(result.url.len != 0)
  doAssert(result.content.len != 0)
  result.OnRequestImpl = cpOnRequest
