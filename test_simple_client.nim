import winapi, os, strutils
import nc_menu_model, nc_process_message, nc_app, nc_client, nc_types
import nc_context_menu_params, nc_browser, nc_settings, nc_context_menu_handler
import nc_life_span_handler, nc_util

type
  myClient = ref object of NCClient
    abc: int
    name: string
    cmh: NCContextMenuHandler
    lsh: NCLifeSpanHandler

  myApp = ref object of NCApp

handlerImpl(NCLifeSpanHandler):
  proc onBeforeClose(self: NCLifeSpanHandler, browser: NCBrowser) =
    ncQuitMessageLoop()    

const
  MY_MENU_ID = USER_MENU_ID(1)
  MY_QUIT_ID = USER_MENU_ID(2)

handlerImpl(NCContextMenuHandler):
  proc onBeforeContextMenu(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
    discard model.addSeparator()
    discard model.addItem(MY_MENU_ID, "Hello There")
    discard model.addItem(MY_QUIT_ID, "Quit")
    echo "page URL: ", params.getPageUrl()
    echo "frame URL: ", params.getFrameUrl()
    echo "link URL: ", params.getLinkUrl()

  proc onContextMenuCommand(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =

    if command_id == MY_MENU_ID:
      echo "Hello There Clicked"

    if command_id == MY_QUIT_ID:
      var host = browser.getHost()
      host.closeBrowser(true)

handlerImpl(myClient):
  proc getContextMenuHandler*(self: myClient): NCContextMenuHandler =
    return self.cmh

  proc getLifeSpanHandler*(self: myClient): NCLifeSpanHandler =
    return self.lsh

proc newClient(no: int, name: string): myClient =
  result = myClient.ncCreate()
  result.abc = no
  result.name = name
  result.cmh = NCContextMenuHandler.ncCreate()
  result.lsh = NCLifeSpanHandler.ncCreate()

handlerImpl(myApp)

proc main() =
  # Main args.
  var mainArgs = makeNCMainArgs()
  var app = myApp.ncCreate()

  var code = ncExecuteProcess(mainArgs, app)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)

  var settings = NCSettings()
  settings.no_sandbox = true
  discard ncInitialize(mainArgs, settings, app)
  echo "cef_initialize thread id: ", getCurrentThreadId()

  var windowInfo: NCWindowInfo
  windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE
  windowInfo.parent_window = cef_window_handle(0)
  windowInfo.x = CW_USEDEFAULT
  windowInfo.y = CW_USEDEFAULT
  windowInfo.width = CW_USEDEFAULT
  windowInfo.height = CW_USEDEFAULT

  #Initial url.
  let cwd = getCurrentDir()
  let url = "file://$1/resources/nimapi_example.html" % [cwd]

  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings = NCBrowserSettings()
  var client = newClient(123, "hello")

  # Create browser.
  echo "cef_browser_host_create_browser"
  discard ncBrowserHostCreateBrowser(windowInfo, client, url, browserSettings)

  # Message loop.
  ncRunMessageLoop()
  ncShutdown()

main()
