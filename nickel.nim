import winapi, os, strutils
import nc_menu_model, nc_process_message, nc_app, nc_client, ncapi, nc_types
import nc_context_menu_params, nc_browser, nc_scheme, nc_resource_handler
import nc_request, nc_callback, nc_util, nc_response

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
  
proc newClient(no: int, name: string): myClient =
  result = makeNCClient(myClient, {NCCF_LIFE_SPAN, NCCF_CONTEXT_MENU})
  result.abc = no
  result.name = name

method OnBeforeClose(self: myClient, browser: NCBrowser) =
  cef_quit_message_loop()
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

  if command_id == MY_QUIT_ID:
    var host = browser.get_host(browser)
    host.close_browser(host, 1)
    
    
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
    #const std::string& dump = test_runner::DumpRequestContents(request);
    #data_.append(dump);

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
    self.mData = readFile("resources\\logo.png")
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
  
proc main() =
  # Main args.
  var mainArgs: cef_main_args
  mainArgs.instance = getModuleHandle(nil)

  var app = makeNCApp(myApp, {})

  var code = cef_execute_process(mainArgs.addr, app.GetHandler(), nil)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)

  var settings: cef_settings
  settings.size = sizeof(settings)
  settings.no_sandbox = 1
  discard cef_initialize(mainArgs.addr, settings.addr, app.GetHandler(), nil)
  echo "cef_initialize thread id: ", getCurrentThreadId()

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
  var browserSettings: cef_browser_settings
  browserSettings.size = sizeof(browserSettings)

  var client = newClient(123, "hello")

  # Create browser.
  echo "cef_browser_host_create_browser"
  discard NCBrowserHostCreateBrowser(windowInfo.addr, client, url, browserSettings.addr, nil)

  # Message loop.
  cef_run_message_loop()
  cef_shutdown()

main()
