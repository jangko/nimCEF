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

callbackImpl(lshimpl, NCLifeSpanHandler):
  proc OnBeforeClose(self: NCLifeSpanHandler, browser: NCBrowser) =
    NCQuitMessageLoop()    

const
  MY_MENU_ID = USER_MENU_ID(1)
  MY_QUIT_ID = USER_MENU_ID(2)

callbackImpl(cmhimpl, NCContextMenuHandler):
  proc OnBeforeContextMenu(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
    discard model.AddSeparator()
    discard model.AddItem(MY_MENU_ID, "Hello There")
    discard model.AddItem(MY_QUIT_ID, "Quit")
    echo "page URL: ", params.GetPageUrl()
    echo "frame URL: ", params.GetFrameUrl()
    echo "link URL: ", params.GetLinkUrl()

  proc OnContextMenuCommand(self: NCContextMenuHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =

    if command_id == MY_MENU_ID:
      echo "Hello There Clicked"

    if command_id == MY_QUIT_ID:
      var host = browser.GetHost()
      host.CloseBrowser(true)

callbackImpl(clientimpl, myClient):
  proc GetContextMenuHandler*(self: myClient): NCContextMenuHandler =
    return self.cmh

  proc GetLifeSpanHandler*(self: myClient): NCLifeSpanHandler =
    return self.lsh

proc newClient(no: int, name: string): myClient =
  result = clientimpl.NCCreate()
  result.abc = no
  result.name = name
  result.cmh = cmhimpl.NCCreate()
  result.lsh = lshimpl.NCCreate()

callbackImpl(appimpl, myApp)

proc main() =
  # Main args.
  var mainArgs = makeNCMainArgs()
  var app = appimpl.NCCreate()

  var code = NCExecuteProcess(mainArgs, app)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)

  var settings = NCSettings()
  settings.no_sandbox = true
  discard NCInitialize(mainArgs, settings, app)
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
  let url = "file://$1/resources/example.html" % [cwd]

  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings = NCBrowserSettings()
  var client = newClient(123, "hello")

  # Create browser.
  echo "cef_browser_host_create_browser"
  discard NCBrowserHostCreateBrowser(windowInfo, client, url, browserSettings)

  # Message loop.
  NCRunMessageLoop()
  NCShutdown()

main()
