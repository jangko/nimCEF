import winapi, os, strutils
import nc_menu_model, nc_process_message, nc_app, nc_client, nc_types
import nc_context_menu_params, nc_browser, nc_settings

type
  myClient = ref object of NCClient
    abc: int
    name: string

  myApp = ref object of NCApp

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

  if command_id == MY_QUIT_ID:
    var host = browser.get_host(browser)
    host.close_browser(host, 1)

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
  echo "cef_initialize thread id: ", getCurrentThreadId()

  var windowInfo: cef_window_info
  windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE
  windowInfo.parent_window = cef_window_handle(0)
  windowInfo.x = CW_USEDEFAULT
  windowInfo.y = CW_USEDEFAULT
  windowInfo.width = CW_USEDEFAULT
  windowInfo.height = CW_USEDEFAULT

  #Initial url.
  let cwd = getCurrentDir()
  let url = "file://$1/example.html" % [cwd]

  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings = makeNCBrowserSettings()
  var client = newClient(123, "hello")

  # Create browser.
  echo "cef_browser_host_create_browser"
  discard NCBrowserHostCreateBrowser(windowInfo.addr, client, url, browserSettings)

  # Message loop.
  NCRunMessageLoop()
  NCShutdown()

main()
