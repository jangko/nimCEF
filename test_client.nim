import winapi, os, strutils, streams
import nc_menu_model, nc_process_message, nc_app, nc_client, nc_types
import nc_context_menu_params, nc_browser, nc_scheme, nc_resource_handler
import nc_request, nc_callback, nc_util, nc_response, nc_settings, nc_task
import nc_urlrequest, nc_auth_callback, nc_frame, nc_web_plugin
import nc_request_context_handler, nc_request_context
import nc_life_span_handler, nc_context_menu_handler

type
  myApp = ref object of NCApp

  myScheme = ref object of NCResourceHandler
    mData: string
    mMimeType: string
    mOffset: int

  myUrlRequestClient = ref object of NCUrlRequestClient
    name: string

  myClient = ref object of NCClient
    abc: int
    name: string
    cmh: NCContextMenuHandler
    lsh: NCLifeSpanHandler


MENU_ID:
  MY_MENU_ID
  MY_QUIT_ID
  MY_PLUGIN_ID
  MY_SHOW_DEVTOOLS
  MY_CLOSE_DEVTOOLS
  MY_INSPECT_ELEMENT

handlerImpl(stdClient, NCClient)

proc showDevTool(host: NCBrowserHost; x, y: int = 0) =
  var windowInfo: NCWindowInfo
  windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE
  windowInfo.parent_window = cef_window_handle(0)
  windowInfo.x = CW_USEDEFAULT
  windowInfo.y = CW_USEDEFAULT
  windowInfo.width = CW_USEDEFAULT
  windowInfo.height = CW_USEDEFAULT

  var setting: NCBrowserSettings
  host.ShowDevTools(windowInfo, stdClient.NCCreate(), setting, NCPoint(x:x, y:y))

handlerImpl(cmhimpl, NCContextMenuHandler):
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
    discard model.AddItem(MY_QUIT_ID, "Quit")
    echo "page URL: ", params.GetPageUrl()
    echo "frame URL: ", params.GetFrameUrl()
    echo "link URL: ", params.GetLinkUrl()

  proc OnContextMenuCommand(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =

    case command_id
    of MY_MENU_ID:
      echo "Hello There Clicked"
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

    else:
      echo "unsupported MENU ID"
    #if command_id == MY_PLUGIN_ID:
    #  echo "PLUGIN INFO"
    #  let visitor = makeNCWebPluginInfoVisitor(visitor_impl)
    #  NCVisitWebPluginInfo(visitor)

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
  result = ss.data

handlerImpl(scheme, myScheme):
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

handlerImpl(appimpl, myApp):
  proc OnRegisterCustomSchemes*(self: myApp, registrar: NCSchemeRegistrar) =
    discard registrar.AddCustomScheme("client", true, false, false)

handlerImpl(scimpl, NCSchemeHandlerFactory):
  proc Create*(self: NCSchemeHandlerFactory, browser: NCBrowser, frame: NCFrame, schemeName: string, request: NCRequest): NCResourceHandler =
    NC_REQUIRE_IO_THREAD()
    result = scheme.NCCreate()

proc RegisterSchemeHandler() =
  NCRegisterSchemeHandlerFactory("client", "tests", scimpl.NCCreate())

handlerImpl(lshimpl, NCLifeSpanHandler):
  proc OnBeforeClose(self: NCLifeSpanHandler, browser: NCBrowser) =
    var client = getClient[myClient](browser)
    echo client.name
    NCQuitMessageLoop()

handlerImpl(client_impl, myClient):
  proc GetContextMenuHandler*(self: myClient): NCContextMenuHandler =
    return self.cmh

  proc GetLifeSpanHandler*(self: myClient): NCLifeSpanHandler =
    return self.lsh

proc newClient(no: int, name: string): myClient =
  result = client_impl.NCCreate()
  result.abc = no
  result.name = name
  result.cmh = cmhimpl.NCCreate()
  result.lsh = lshimpl.NCCreate()

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
  var app = appimpl.NCCreate()

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
  var client = newClient(123, "hello")

  #var rch = makeNCRequestContextHandler(rch_impl)
  #var rcsetting: NCRequestContextSettings
  #var ctx = NCRequestContextCreateContext(rcsetting, rch)

  # Create browser.
  discard NCBrowserHostCreateBrowser(windowInfo, client, url, browserSettings)

  # Message loop.
  NCRunMessageLoop()
  NCShutdown()

main()