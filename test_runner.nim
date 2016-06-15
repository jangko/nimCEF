import strutils, nc_resource_manager, nc_util, nc_types, nc_task
import nc_request, nc_stream_resource_handler, streams, nc_stream
import nc_path_util, os

const
  kTestOrigin = "http://tests/"

# Add a file extension to |url| if none is currently specified.
proc RequestUrlFilter(url: string): string =
  if url.find(kTestOrigin) != 0:
    # Don't filter anything outside of the test origin.
    return url

  # Identify where the query or fragment component, if any, begins.
  var suffixPos = url.find('?')
  if suffixPos == -1:
    suffixPos = url.find('#')
  
  var 
    urlBase = ""
    urlSuffix = ""

  if suffixPos == -1:
    urlBase = url
  else:
    urlBase = url.substr(0, suffixPos)
    urlSuffix = url.substr(suffixPos)

  # Identify the last path component.
  var pathPos = urlBase.rfind('/')
  if pathPos == -1:
    return url

  let pathComponent = urlBase.substr(pathPos)

  # Identify if a file extension is currently specified.
  let extPos = pathComponent.rfind('.')
  if extPos != -1:
    return url
  
  # Rebuild the URL with a file extension.
  result = urlBase & ".html" & urlSuffix

proc DumpRequestContents*(request: NCRequest): string =
  var ss = newStringStream()

  ss.write "URL: "
  ss.write request.GetURL()
  ss.write "\nMethod: "
  ss.write request.GetMethod()

  var headerMap = request.GetHeaderMap()

  if headerMap.len > 0:
    ss.write "\nHeaders:"
    for k, v in pairs(headerMap):
      ss.write "\n\t"
      ss.write k
      ss.write ": "
      ss.write $v

  var postData = request.GetPostData()
  if postData != nil:
    var elements = postData.GetElements()
    if elements.len > 0:
      ss.write "\nPost Data:"
      for it in elements:
        if it.GetType() == PDE_TYPE_BYTES:
          #the element is composed of bytes
          ss.write "\n\tBytes: "
          if it.GetBytesCount() == 0:
            ss.write "(empty)"
          else:
            #retrieve the data.
            ss.write it.GetBytes()
        elif it.GetType() == PDE_TYPE_FILE:
          ss.write "\n\tFile: "
          ss.write it.GetFile()

  result = ss.data

# Provider that dumps the request contents.
type
  RequestDumpResourceProvider = ref object of Provider
    url: string

proc rdpOnRequest(prov: Provider, request: Request): bool =
  var self = RequestDumpResourceProvider(prov)
  NC_REQUIRE_IO_THREAD()

  let url = request.getUrl()
  if url != self.url:
    # Not handled by this provider.
    return false

  let dump = DumpRequestContents(request.getRequest())
  let str = "<html><body bgcolor=\"white\"><pre>" & dump & "</pre></body></html>"
  var stream = NCStreamReaderCreateForData(str)
  doAssert(stream.GetHandler() != nil)
  request.Continue(newNCStreamResourceHandler("text/html", stream))
  result = true

proc newRequestDumpResourceProvider(url: string): RequestDumpResourceProvider =
  new(result)
  result.url = url
  doAssert(result.url.len != 0)
  result.OnRequestImpl = rdpOnRequest

var resourceManager: NCResourceManager

proc getResourceManager*(): NCResourceManager =
  result = resourceManager
  
proc SetupResourceManager*() =
  if not NCCurrentlyOn(TID_IO):
    # Execute on the browser IO thread.
    NCBindTask(setupResourceManagerTask, SetupResourceManager)
    discard NCPostTask(TID_IO, setupResourceManagerTask())
    return

  setupForeignThreadGC()
  resourceManager = newNCResourceManager()  
  
  let testOrigin = kTestOrigin

  # Add the URL filter.
  resourceManager.SetUrlFilter(RequestUrlFilter)

  # Add provider for resource dumps.
  resourceManager.AddProvider(newRequestDumpResourceProvider(testOrigin & "request.html"), 0, "")

  # Read resources from a directory on disk.
  var resourceDir: string
  if NCGetPath(PK_DIR_EXE, resourceDir):
    resourceManager.AddDirectoryProvider(testOrigin, resourceDir & DirSep & "resources", 100, "")
