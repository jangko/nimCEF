import winapi, os, strutils
import nc_menu_model, nc_process_message, nc_app, nc_client, nc_types
import nc_context_menu_params, nc_browser, nc_scheme, nc_resource_handler
import nc_request, nc_callback, nc_util, nc_response, nc_settings, nc_task
import nc_urlrequest, nc_auth_callback, nc_frame, nc_web_plugin
import nc_request_context_handler, nc_request_context
import nc_life_span_handler, nc_context_menu_handler
import test_runner, nc_resource_manager, nc_request_handler
import nc_display_handler

type
  myApp = ref object of NCApp

  myScheme = ref object of NCResourceHandler
    mData: string
    mMimeType: string
    mOffset: int

  myClient = ref object of NCClient
    abc: int
    name: string
    cmh: NCContextMenuHandler
    lsh: NCLifeSpanHandler
    reqh: NCRequestHandler
    disph: NCDisplayHandler

MENU_ID:
  MY_MENU_ID
  MY_QUIT_ID
  MY_PLUGIN_ID
  MY_SHOW_DEVTOOLS
  MY_CLOSE_DEVTOOLS
  MY_INSPECT_ELEMENT
  MY_OTHER_TESTS

handlerImpl(NCClient)

proc showDevTool(host: NCBrowserHost; x, y: int = 0) =
  let screenW = GetSystemMetrics(SM_CXSCREEN)
  let screenH = GetSystemMetrics(SM_CYSCREEN)
  let devToolW = screenW - screenW div 3
  let devToolH = screenH - screenH div 3
  var windowInfo: NCWindowInfo
  windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE
  windowInfo.parent_window = cef_window_handle(0)
  windowInfo.x = (screenW - devToolW) div 2
  windowInfo.y = (screenH - devToolH) div 2
  windowInfo.width = devToolW
  windowInfo.height = devToolH

  var setting: NCBrowserSettings
  host.ShowDevTools(windowInfo, NCClient.NCCreate(), setting, NCPoint(x:x, y:y))

handlerImpl(NCContextMenuHandler):
  proc OnBeforeContextMenu(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
    discard model.AddSeparator()
    discard model.AddItem(MY_PLUGIN_ID, "Plugin Info")
    discard model.AddItem(MY_MENU_ID, "Hello There")
    discard model.AddSeparator()
    discard model.AddItem(MY_SHOW_DEVTOOLS, "Show DevTools")
    discard model.AddItem(MY_CLOSE_DEVTOOLS, "Close DevTools")
    discard model.AddItem(MY_INSPECT_ELEMENT, "Inspect Element")
    discard model.AddSeparator()
    discard model.AddItem(MY_OTHER_TESTS, "Other Tests")
    discard model.AddItem(MY_QUIT_ID, "Quit")

  proc OnContextMenuCommand(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =

    case command_id
    of MY_MENU_ID:
      frame.ExecuteJavaScript("alert('Hello There Clicked!');", frame.GetURL(), 0)

    of MY_QUIT_ID:
      var host = browser.GetHost()
      host.CloseBrowser(true)

    of MY_SHOW_DEVTOOLS:
      showDevTool(browser.GetHost())

    of MY_CLOSE_DEVTOOLS:
      browser.GetHost().CloseDevTools()

    of MY_INSPECT_ELEMENT:
      showDevTool(browser.GetHost(), params.GetXCoord(), params.GetYCoord())

    of MY_OTHER_TESTS:
      browser.GetMainFrame().LoadURL("http://tests/other_tests")
    else:
      echo "unsupported MENU ID"
    #if command_id == MY_PLUGIN_ID:
    #  echo "PLUGIN INFO"
    #  let visitor = makeNCWebPluginInfoVisitor(visitor_impl)
    #  NCVisitWebPluginInfo(visitor)

handlerImpl(myScheme):
  proc ProcessRequest(self: myScheme, request: NCRequest, callback: NCCallback): bool =
    NC_REQUIRE_IO_THREAD()

    var handled = false
    var url = request.GetURL()
    if url.find("handler.html") != -1:
      #Build the response html
      self.mData = """<html><head><title>Client Scheme Handler</title></head>
<body bgcolor="white">
This contents of this page are served by the
myScheme object handling the client:// protocol.
<h2>Google</h2>
<a href="https://www.google.com/">https://www.google.com/</a>
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

  proc GetResponseHeaders(self: myScheme, response: NCResponse, response_length: var int64, redirectUrl: var string) =
    NC_REQUIRE_IO_THREAD()
    doAssert(self.mData != nil and self.mData.len != 0)

    response.SetMimeType(self.mMimeType)
    response.SetStatus(200)

    #Set the resulting response length
    response_length = self.mData.len

  proc ReadResponse(self: myScheme, data_out: cstring, bytes_to_read: int, bytes_read: var int, callback: NCCallback): bool =
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

handlerImpl(myApp):
  proc OnRegisterCustomSchemes*(self: myApp, registrar: NCSchemeRegistrar) =
    discard registrar.AddCustomScheme("client", true, false, false)

handlerImpl(NCSchemeHandlerFactory):
  proc Create*(self: NCSchemeHandlerFactory, browser: NCBrowser, frame: NCFrame, schemeName: string, request: NCRequest): NCResourceHandler =
    NC_REQUIRE_IO_THREAD()
    result = myScheme.NCCreate()

proc RegisterSchemeHandler() =
  NCRegisterSchemeHandlerFactory("client", "tests", NCSchemeHandlerFactory.NCCreate())

handlerImpl(NCLifeSpanHandler):
  proc OnBeforeClose(self: NCLifeSpanHandler, browser: NCBrowser) =
    NCQuitMessageLoop()

handlerImpl(NCRequestHandler):
  proc OnBeforeResourceLoad*(self: NCRequestHandler, browser: NCBrowser,
  frame: NCFrame, request: NCRequest, callback: NCRequestCallback): cef_return_value =
    NC_REQUIRE_IO_THREAD()
    var resourceManager = getResourceManager()
    result = resourceManager.OnBeforeResourceLoad(browser, frame, request, callback)
    
  proc GetResourceHandler*(self: NCRequestHandler, browser: NCBrowser,
    frame: NCFrame, request: NCRequest): NCResourceHandler =
    NC_REQUIRE_IO_THREAD()
    var resourceManager = getResourceManager()
    result = resourceManager.GetResourceHandler(browser, frame, request)

handlerImpl(NCDisplayHandler):
  proc OnTitleChange*(self: NCDisplayHandler, browser: NCBrowser, title: string) =
    var host = browser.GetHost()
    var hWnd = host.GetWindowHandle()
    discard setWindowText(hWnd, title)
  
handlerImpl(myClient):
  proc GetContextMenuHandler*(self: myClient): NCContextMenuHandler =
    return self.cmh

  proc GetLifeSpanHandler*(self: myClient): NCLifeSpanHandler =
    return self.lsh

  proc GetRequestHandler*(self: myClient): NCRequestHandler =
    return self.reqh

  proc GetDisplayHandler*(self: myClient): NCDisplayHandler =
    return self.disph
    
proc newClient(no: int, name: string): myClient =
  result = myClient.NCCreate()
  result.abc = no
  result.name = name
  result.cmh = NCContextMenuHandler.NCCreate()
  result.lsh = NCLifeSpanHandler.NCCreate()
  result.reqh = NCRequestHandler.NCCreate()
  result.disph = NCDisplayHandler.NCCreate()
  SetupResourceManager()

proc OnBeforePluginLoad*(self: NCRequestContextHandler, mime_type, plugin_url, top_origin_url: string,
  plugin_info: NCWebPluginInfo, plugin_policy: var cef_plugin_policy): bool =

  # Always allow the PDF plugin to load.
  if plugin_policy != PLUGIN_POLICY_ALLOW and mime_type == "application/pdf":
    plugin_policy = PLUGIN_POLICY_ALLOW
    return true

  result = false

proc main() =
  # Main args.
  var mainArgs = makeNCMainArgs()
  var app = myApp.NCCreate()

  var code = NCExecuteProcess(mainArgs, app)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)

  var settings: NCSettings
  settings.no_sandbox = true
  discard NCInitialize(mainArgs, settings, app)

  var windowInfo: NCWindowInfo
  windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE
  windowInfo.parent_window = cef_window_handle(0)
  windowInfo.x = 0
  windowInfo.y = 0
  windowInfo.width = GetSystemMetrics(SM_CXSCREEN)
  windowInfo.height = GetSystemMetrics(SM_CYSCREEN)

  RegisterSchemeHandler()

  #Initial url.
  #let cwd = getCurrentDir()
  #let url = "file://$1/example.html" % [cwd]
  let url = "client://tests/handler.html"

  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings: NCBrowserSettings
  #browserSettings.plugins = STATE_ENABLED
  var client = newClient(123, "myClient")

  #var rch = makeNCRequestContextHandler(rch_impl)
  #var rcsetting: NCRequestContextSettings
  #var ctx = NCRequestContextCreateContext(rcsetting, rch)

  # Create browser.
  discard NCBrowserHostCreateBrowser(windowInfo, client, url, browserSettings)

  # Message loop.
  NCRunMessageLoop()
  NCShutdown()

main()