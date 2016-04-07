import winapi, os, strutils
import ncapi

type
  myClient = ref object of NCClient
    abc: int
    name: string

proc newClient(no: int, name: string): myClient =
  result = makeNCClient(myClient, {NCCF_LIFE_SPAN, NCCF_CONTEXT_MENU})
  result.abc = no
  result.name = name
 
method OnBeforeClose(self: myClient, browser: ptr cef_browser) =
  cef_quit_message_loop()
  echo "close: ", self.name, " no: ", self.abc
   
proc main() =
  # Main args.
  var mainArgs: cef_main_args
  mainArgs.instance = getModuleHandle(nil)

  var app: cef_app
  initialize_app_handler(app.addr)

  var code = cef_execute_process(mainArgs.addr, app.addr, nil)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)
  
  var settings: cef_settings
  settings.size = sizeof(settings)
  settings.no_sandbox = 1
  discard cef_initialize(mainArgs.addr, settings.addr, app.addr, nil)
  
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
  #echo url
  
  #There is no _cef_string_t type.
  var cefUrl: cef_string
  discard cef_string_utf8_to_utf16(url.cstring, url.len, cefUrl.addr)
    
  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings: cef_browser_settings
  browserSettings.size = sizeof(browserSettings)
    
  var client = newClient(123, "hello")
  
  # Create browser.
  echo "cef_browser_host_create_browser"
  discard cef_browser_host_create_browser(windowInfo.addr, client.GetHandler(), cefUrl.addr, browserSettings.addr, nil)
  
  # Message loop.
  cef_run_message_loop()
  cef_shutdown()
    
main()
