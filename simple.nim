import os, strutils
import nc_types, nc_browser, nc_view, nc_life_span_handler
import nc_load_handler, nc_display_handler, nc_util, nc_task
import nc_client, nc_util_impl, nc_app, nc_frame, nc_browser_process_handler
import nc_command_line, nc_settings

 #, nc_menu_model, nc_process_message, nc_app, nc_client
#import nc_context_menu_params, nc_browser, nc_scheme, nc_resource_handler
#import nc_request, nc_callback, nc_util, nc_response, nc_settings, nc_task
#import nc_urlrequest, nc_auth_callback, nc_frame, nc_web_plugin
#import nc_request_context_handler, nc_request_context
#import nc_life_span_handler, nc_context_menu_handler
#import test_runner, nc_resource_manager, nc_request_handler
#import nc_display_handler, layout, nc_view

when defined(macosx):
  const libX11* = "libX11.dylib"
else:
  const libX11* = "libX11.so.6"

{.pragma: libx11, cdecl, dynlib: libX11, importc.}
{.pragma: libx11c, cdecl, dynlib: libX11.}

type
  PPChar* = ptr cstring
  PAtom* = ptr TAtom
  TAtom* = culong
  TBool* = cint
  TStatus* = cint
  TWindow* = culong
  Pcuchar* = cstring
  TXID* = culong
  PXErrorEvent* = ptr TXErrorEvent
  TXErrorEvent*{.final.} = object
    theType*: cint
    display*: XDisplay
    resourceid*: TXID
    serial*: culong
    error_code*: cuchar
    request_code*: cuchar
    minor_code*: cuchar
    
  TXErrorHandler* = proc(para1: XDisplay, para2: PXErrorEvent): cint {.cdecl.}
  TXIOErrorHandler* = proc(para1: XDisplay): cint {.cdecl.}
  
const
  PropModeReplace* = 0

proc XInternAtoms*(para1: XDisplay, para2: PPchar, para3: cint, para4: TBool, para5: PAtom): TStatus {.libx11.}

proc XChangeProperty*(para1: XDisplay, para2: TWindow, para3: TAtom,
                      para4: TAtom, para5: cint, para6: cint, para7: Pcuchar,
                      para8: cint): cint {.libx11.}

proc XStoreName*(para1: XDisplay, para2: TWindow, para3: cstring): cint {.libx11.}
proc XSetErrorHandler*(para1: TXErrorHandler): TXErrorHandler {.libx11.}
proc XSetIOErrorHandler*(para1: TXIOErrorHandler): TXIOErrorHandler {.libx11.}

let
  atom1 = "_NET_WM_NAME"
  atom2 = "UTF8_STRING"

var kAtoms = [atom1.cstring, atom2.cstring]

type
  MyClient = ref object of NCClient
    lifespanh: NCLifeSpanHandler
    loadh: NCLoadHandler
    disph: NCDisplayHandler
    #True if the application is using the Views framework.
    useViews: bool

    #List of existing browser windows. Only accessed on the CEF UI thread.
    browserList: seq[NCBrowser]
    isClosing: bool
    
  MyApp = ref object of NCApp
    bph: NCBrowserProcessHandler
  
  SimpleWindowDelegate = ref object of NCWindowDelegate
    browserView: NCBrowserView
    
proc PlatformTitleChange(browser: NCBrowser, title: string) =
  # Retrieve the X11 display shared with Chromium.
  var display = cef_get_xdisplay()
  doAssert(display.pointer != nil)

  # Retrieve the X11 window handle for the browser.
  var window = browser.getHost().getWindowHandle()
  doAssert(window != kNullWindowHandle.culong)

  # Retrieve the atoms required by the below XChangeProperty call.
  var atoms: array[2, TAtom]
  var result = XInternAtoms(display, kAtoms[0].addr, 2, 0.cint, atoms[0].addr)
  if result == 0: return

  # Set the window title.
  discard XChangeProperty(display,
                  window,
                  atoms[0],
                  atoms[1],
                  8.cint,
                  PropModeReplace.cint,
                  title,
                  title.len.cint)

  # TODO(erg): This is technically wrong. So XStoreName and friends expect
  # this in Host Portable Character Encoding instead of UTF-8, which I believe
  # is Compound Text. This shouldn't matter 90% of the time since this is the
  # fallback to the UTF8 property above.
  discard XStoreName(display, window, title)

handlerImpl(NCDisplayHandler):
  proc onTitleChange*(self: NCDisplayHandler, browser: NCBrowser, title: string) =
    NC_REQUIRE_UI_THREAD()
    var client = getClient[MyClient](browser)
    if client.useViews:
      #Set the title of the window using the Views framework.
      var browserView = ncBrowserViewGetForBrowser(browser)
      if browserView != nil:
        var window = browserView.getWindow()
        if window != nil: window.setTitle(title)
    else:
      #Set the title of the window using platform APIs.
      PlatformTitleChange(browser, title)

handlerImpl(NCLifeSpanHandler):
  proc onAfterCreated(self: NCLifeSpanHandler, browser: NCBrowser) =
    NC_REQUIRE_UI_THREAD()
    var client = getClient[MyClient](browser)
    #Add to the list of existing browsers.
    client.browserList.add(browser)
    
  proc doClose(self: NCLifeSpanHandler, browser: NCBrowser): bool =
    NC_REQUIRE_UI_THREAD()
    var client = getClient[MyClient](browser)

    # Closing the main window requires special handling. See the DoClose()
    # documentation in the CEF header for a detailed destription of this
    # process.
    if client.browserList.len == 1:
      #Set a flag to indicate that the window close should be allowed.
      client.isClosing = true
  
    # Allow the close. For windowed browsers this will result in the OS close
    # event being sent.
    result = false

  proc onBeforeClose(self: NCLifeSpanHandler, browser: NCBrowser) =
    # Remove from the list of existing browsers.
    var client = getClient[MyClient](browser)
    var i = 0
    for bit in client.browserList:
      if bit.isSame(browser):
        client.browserList.del(i)
        break
      inc i
    
    if client.browserList.len == 0:
      # All browser windows have closed. Quit the application message loop.
      ncQuitMessageLoop()
      
handlerImpl(NCLoadHandler):
  proc onLoadError(self: NCLoadHandler, browser: NCBrowser, frame: NCFrame,
    errorCode: cef_errorcode, errorText, failedUrl: string) =
    NC_REQUIRE_UI_THREAD()

    # Don't display an error for downloaded files.
    if errorCode == ERR_ABORTED: return

    # Display a load error message.
    var ss = "<html><body bgcolor=\"white\"><h2>Failed to load URL $1 with error $2 ($3).</h2></body></html>" % 
      [failedUrl, errorText, $errorCode]
      
    frame.loadString(ss, failedUrl)

handlerImpl(MyClient):
  proc getLifeSpanHandler*(self: MyClient): NCLifeSpanHandler =
    return self.lifespanh

  proc getLoadHandler*(self: MyClient): NCLoadHandler =
    return self.loadh

  proc getDisplayHandler*(self: MyClient): NCDisplayHandler =
    return self.disph

proc newClient(useViews: bool): MyClient =
  result = MyClient.ncCreate()

  result.useViews = useViews
  result.browserList = @[]
  result.isClosing = false

  result.lifespanh = NCLifeSpanHandler.ncCreate()
  result.loadh = NCLoadHandler.ncCreate()
  result.disph = NCDisplayHandler.ncCreate()
  
#proc closeAllBrowsers(client: MyClient, forceClose: bool) =
#  if not ncCurrentlyOn(TID_UI):
#    #Execute on the UI thread.
#    ncPostTask(TID_UI,  base::Bind(&SimpleHandler::CloseAllBrowsers, this, force_close))
#    return
#
#  if (browser_list_.empty())
#    return;
#
#  BrowserList::const_iterator it = browser_list_.begin();
#  for (; it != browser_list_.end(); ++it)
#    (*it)->GetHost()->CloseBrowser(force_close);
#}

handlerImpl(SimpleWindowDelegate):
  proc onWindowCreated*(self: SimpleWindowDelegate, window: NCWindow) =
    # Add the browser view and show the window.
    window.addChildView(self.browserView)
    window.show()

    #Give keyboard focus to the browser view.
    self.browserView.requestFocus()

  proc onWindowDestroyed*(self: SimpleWindowDelegate, window: NCWindow) =
    self.browserView = nil
    
  proc canClose*(self: SimpleWindowDelegate, window: NCWindow): bool =
    # Allow the window to close if the browser says it's OK.
    var browser = self.browserView.getBrowser()
    if browser != nil:
      return browser.getHost().tryCloseBrowser()
      
    result = true
  
proc newSimpleWindowDelegate(browserView: NCBrowserView): SimpleWindowDelegate =
  result = SimpleWindowDelegate.ncCreate()
  result.browserView = browserView
  
handlerImpl(NCBrowserProcessHandler):
  proc onContextInitialized*(self: NCBrowserProcessHandler) =
    NC_REQUIRE_UI_THREAD()
    var commandLine = ncCommandLineGetGlobal()

    when defined(windows) or defined(linux):
      # Create the browser using the Views framework if "--use-views" is specified
      # via the command-line. Otherwise, create the browser using the native
      # platform framework. The Views framework is currently only supported on
      # Windows and Linux.
      let useViews = commandLine.hasSwitch("use-views")
    else:
      let useViews = false

    # SimpleHandler implements browser-level callbacks.
    var client = newClient(useViews)

    # Specify CEF browser settings here.
    var browserSettings: NCBrowserSettings
  
    # Check if a "--url=" value was provided via the command-line. If so, use
    # that instead of the default URL.
    var url = commandLine.getSwitchValue("url")
    if url.len == 0:
      url = "http://www.google.com"

    if useViews:
      #Create the BrowserView.
      var browserView = ncBrowserViewCreate(client, url, browserSettings, nil, nil)

      #Create the Window. It will show itself after creation.
      discard ncWindowCreateTopLevel(newSimpleWindowDelegate(browserView))
    else:
      #Information used when creating the native window.
      var windowInfo: NCWindowInfo

      when defined(windows):
        # On Windows we need to specify certain flags that will be passed to
        # CreateWindowEx().
        windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE

      # Create the first browser window.
      discard ncBrowserHostCreateBrowser(windowInfo, client, url, browserSettings, nil)
  
handlerImpl(MyApp):
  proc getBrowserProcessHandler*(self: MyApp): NCBrowserProcessHandler =
    result = self.bph
    
proc newApp(): MyApp =
  result = MyApp.ncCreate()
  result.bph = NCBrowserProcessHandler.ncCreate()
  
proc XErrorHandlerImpl(display: XDisplay, event: PXErrorEvent): cint {.cdecl.} = 0
proc XIOErrorHandlerImpl(display: XDisplay): cint {.cdecl.} = 0

proc main() =
  # Main args.
  var mainArgs = makeNCMainArgs()  

  var code = ncExecuteProcess(mainArgs, nil, nil)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)
    
  # Install xlib error handlers so that the application won't be terminated
  # on non-fatal errors.
  discard XSetErrorHandler(XErrorHandlerImpl)
  discard XSetIOErrorHandler(XIOErrorHandlerImpl)

  # Specify CEF global settings here.
  var settings: NCSettings

  # SimpleApp implements application-level callbacks for the browser process.
  # It will create the first browser instance in OnContextInitialized() after
  # CEF has initialized.
  var app = newApp()

  # Initialize CEF for the browser process.
  discard ncInitialize(mainArgs, settings, app)

  # Run the CEF message loop. This will block until CefQuitMessageLoop() is
  # called.
  ncRunMessageLoop()

  # Shut down CEF.
  ncShutdown()

main()