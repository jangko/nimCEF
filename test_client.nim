import winapi, os, strutils, streams
import nc_menu_model, nc_process_message, nc_app, nc_client, nc_types
import nc_context_menu_params, nc_browser, nc_scheme, nc_resource_handler
import nc_request, nc_callback, nc_util, nc_response, nc_settings, nc_task
import nc_urlrequest, nc_auth_callback, nc_frame

type
  myClient = ref object of NCClient
    abc: int
    name: string

  myApp = ref object of NCApp

  myFactory = ref object of NCSchemeHandlerFactory

  myScheme = ref object of NCResourceHandler
    mData: string
    mMimeType: string
    mOffset: int

  myUrlRequestClient = ref object of NCUrlRequestClient
    name: string

proc newClient(no: int, name: string): myClient =
  result = makeNCClient(myClient, {NCCF_LIFE_SPAN, NCCF_CONTEXT_MENU})
  result.abc = no
  result.name = name

method OnBeforeClose(self: myClient, browser: NCBrowser) =
  NCQuitMessageLoop()
  echo "close: ", self.name, " no: ", self.abc

const
  MY_MENU_ID = (MENU_ID_USER_FIRST.ord + 1).cef_menu_id
  MY_QUIT_ID = (MENU_ID_USER_FIRST.ord + 2).cef_menu_id

method OnBeforeContextMenu(self: myClient, browser: NCBrowser,
  frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
  discard model.AddSeparator()
  discard model.AddItem(MY_MENU_ID, "Hello There")
  discard model.AddItem(MY_QUIT_ID, "Quit")
  echo "page URL: ", params.GetPageUrl()
  echo "frame URL: ", params.GetFrameUrl()
  echo "link URL: ", params.GetLinkUrl()

method OnContextMenuCommand(self: myClient, browser: NCBrowser,
  frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
  event_flags: cef_event_flags): int =

  if command_id == MY_MENU_ID:
    echo "Hello There Clicked"
    frame.ExecuteJavaScript("alert('Hello There Clicked!');", frame.GetURL(), 0)

  if command_id == MY_QUIT_ID:
    var host = browser.GetHost()
    host.CloseBrowser(true)

proc DumpRequestContents(request: NCRequest): string =
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
        release(it)
    release(postData)
  result = ss.data


method ProcessRequest*(self: myScheme, request: NCRequest, callback: NCCallback): bool =
  NC_REQUIRE_IO_THREAD()

  var handled = false
  var url = request.GetURL()
  if url.find("handler.html") != -1:
    #Build the response html
    self.mData = """<html><head><title>Client Scheme Handler</title></head>
<body bgcolor="white">
This contents of this page page are served by the
myScheme object handling the client:// protocol.
<br/>You should see an image:
<br/><img src="client://tests/logo.png"><pre>"""

    #Output a string representation of the request
    self.mData.add DumpRequestContents(request)

    self.mData.add """</pre><br/>Try the test form:
<form method="POST" action="handler.html">
<input type="text" name="field1">
<input type="text" name="field2">
<input type="submit">
</form></body></html>"""

    handled = true

    #Set the resulting mime type
    self.mMimeType = "text/html"
  elif url.find("logo.png") != -1:
    #Load the response image
    self.mData = readFile("resources" & DirSep & "logo.png")
    handled = true
    #Set the resulting mime type
    self.mMimeType = "image/png"

  if handled:
    #Indicate the headers are available.
    callback.Continue()
    return true

  result = false

method GetResponseHeaders*(self: myScheme, response: NCResponse, response_length: var int64, redirectUrl: var string) =
  NC_REQUIRE_IO_THREAD()
  doAssert(self.mData != nil and self.mData.len != 0)

  response.SetMimeType(self.mMimeType)
  response.SetStatus(200)

  #Set the resulting response length
  response_length = self.mData.len

method ReadResponse*(self: myScheme, data_out: cstring, bytes_to_read: int, bytes_read: var int, callback: NCCallback): bool =
  NC_REQUIRE_IO_THREAD()
  var has_data = false
  bytes_read = 0

  if self.mOffset < self.mData.len:
    #Copy the next block of data into the buffer.
    let transfer_size = min(bytes_to_read, self.mData.len - self.mOffset)
    copyMem(data_out, self.mData[self.mOffset].addr, transfer_size)
    inc(self.mOffset, transfer_size)
    bytes_read = transfer_size
    has_data = true

  result = has_data

method OnRegisterCustomSchemes*(self: myApp, registrar: NCSchemeRegistrar) =
  discard registrar.AddCustomScheme("client", true, false, false)

method Create*(self: myFactory, browser: NCBrowser, frame: NCFrame, schemeName: string, request: NCRequest): NCResourceHandler =
  NC_REQUIRE_IO_THREAD()
  result = makeResourceHandler(myScheme)

proc RegisterSchemeHandler() =
  NCRegisterSchemeHandlerFactory("client", "tests", makeNCSchemeHandlerFactory(myFactory))

proc OnRequestComplete(self: myUrlRequestClient, request: NCUrlRequest) =
  echo "hello"

proc OnUploadProgress(self: myUrlRequestClient, request: NCUrlRequest, current, total: int64) =
  echo "progress: ", current, " ", total

proc OnDownloadProgress(self: myUrlRequestClient, request: NCUrlRequest, current, total: int64) =
  discard

proc OnDownloadData(self: myUrlRequestClient, request: NCUrlRequest, data: pointer, data_length: int) =
  discard

proc GetAuthCredentials(self: myUrlRequestClient, isProxy: bool, host: string, port: int, realm: string,
  scheme: string, callback: NCAuthCallback): bool =
  result = false

let uc_impl = nc_urlrequest_i[myUrlRequestClient](
  OnRequestComplete: OnRequestComplete,
  OnUploadProgress: OnUploadProgress,
  OnDownloadProgress: OnDownloadProgress,
  OnDownloadData: OnDownloadData,
  GetAuthCredentials: GetAuthCredentials
)

proc main() =
  # Main args.
  var mainArgs = makeNCMainArgs()
  var app = makeNCApp(myApp, {})

  var code = NCExecuteProcess(mainArgs, app)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)

  var settings = makeNCSettings()
  settings.no_sandbox = true
  discard NCInitialize(mainArgs, settings, app)

  var windowInfo: cef_window_info
  windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE
  windowInfo.parent_window = cef_window_handle(0)
  windowInfo.x = CW_USEDEFAULT
  windowInfo.y = CW_USEDEFAULT
  windowInfo.width = CW_USEDEFAULT
  windowInfo.height = CW_USEDEFAULT

  RegisterSchemeHandler()

  #Initial url.
  #let cwd = getCurrentDir()
  #let url = "file://$1/example.html" % [cwd]
  let url = "client://tests/handler.html"

  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings = makeNCBrowserSettings()
  var client = newClient(123, "hello")

  # Create browser.
  discard NCBrowserHostCreateBrowser(windowInfo.addr, client, url, browserSettings)

  # Message loop.
  NCRunMessageLoop()
  NCShutdown()

main()