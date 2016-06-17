import winapi, os, strutils
import cef_base_api, cef_app_api, cef_client_api, cef_browser_api
include cef_import

# Structure defining the reference count implementation functions. All
# framework structures must include the cef_base_t structure first.

# Increment the reference count.
proc add_ref(self: ptr cef_base) {.cef_callback.} =
  discard

# Decrement the reference count.  Delete this object when no references
# remain.
proc release(self: ptr cef_base): cint {.cef_callback.} =
  result = 1

# Returns the current number of references.
proc has_one_ref(self: ptr cef_base): cint {.cef_callback.} =
   result = 1

proc initialize_cef_base(base: ptr cef_base) =
  # Check if "size" member was set.
  let size = base.size
  # Let's print the size in case sizeof was used
  # on a pointer instead of a structure. In such
  # case the number will be very high.
  if size <= 0:
    echo "FATAL: initialize_cef_base failed, size member not set"
    quit(1)

  base.add_ref = add_ref;
  base.release = release;
  base.has_one_ref = has_one_ref


# Called on the IO thread before a new popup browser is created. The
# |browser| and |frame| values represent the source of the popup request. The
# |target_url| and |target_frame_name| values indicate where the popup
# browser should navigate and may be NULL if not specified with the request.
# The |target_disposition| value indicates where the user intended to open
# the popup (e.g. current tab, new tab, etc). The |user_gesture| value will
# be true (1) if the popup was opened via explicit user gesture (e.g.
# clicking a link) or false (0) if the popup opened automatically (e.g. via
# the DomContentLoaded event). The |popupFeatures| structure contains
# additional information about the requested popup window. To allow creation
# of the popup browser optionally modify |windowInfo|, |client|, |settings|
# and |no_javascript_access| and return false (0). To cancel creation of the
# popup browser return true (1). The |client| and |settings| values will
# default to the source browser's values. If the |no_javascript_access| value
# is set to false (0) the new browser will not be scriptable and may not be
# hosted in the same renderer process as the source browser.
proc on_before_popup(self: ptr cef_life_span_handler,
    browser: ptr_cef_browser, frame: ptr cef_frame,
    target_url, target_frame_name: ptr cef_string,
    target_disposition: cef_window_open_disposition, user_gesture: cint,
    popupFeatures: ptr cef_popup_features,
    windowInfo: ptr cef_window_info, client: var ptr_cef_client,
    settings: ptr cef_browser_settings, no_javascript_access: var cint): cint {.cef_callback.} =
  result = 0

# Called after a new browser is created.
proc on_after_created(self: ptr cef_life_span_handler, browser: ptr_cef_browser) {.cef_callback.} =
  discard

# Called when a browser has recieved a request to close. This may result
# directly from a call to cef_browser_host_t::close_browser() or indirectly
# if the browser is a top-level OS window created by CEF and the user
# attempts to close the window. This function will be called after the
# JavaScript 'onunload' event has been fired. It will not be called for
# browsers after the associated OS window has been destroyed (for those
# browsers it is no longer possible to cancel the close).
#
# If CEF created an OS window for the browser returning false (0) will send
# an OS close notification to the browser window's top-level owner (e.g.
# WM_CLOSE on Windows, performClose: on OS-X and "delete_event" on Linux). If
# no OS window exists (window rendering disabled) returning false (0) will
# cause the browser object to be destroyed immediately. Return true (1) if
# the browser is parented to another window and that other window needs to
# receive close notification via some non-standard technique.
#
# If an application provides its own top-level window it should handle OS
# close notifications by calling cef_browser_host_t::CloseBrowser(false (0))
# instead of immediately closing (see the example below). This gives CEF an
# opportunity to process the 'onbeforeunload' event and optionally cancel the
# close before do_close() is called.
#
# The cef_life_span_handler_t::on_before_close() function will be called
# immediately before the browser object is destroyed. The application should
# only exit after on_before_close() has been called for all existing
# browsers.
#
# If the browser represents a modal window and a custom modal loop
# implementation was provided in cef_life_span_handler_t::run_modal() this
# callback should be used to restore the opener window to a usable state.
#
# By way of example consider what should happen during window close when the
# browser is parented to an application-provided top-level OS window. 1.
# User clicks the window close button which sends an OS close
#     notification (e.g. WM_CLOSE on Windows, performClose: on OS-X and
#     "delete_event" on Linux).
# 2.  Application's top-level window receives the close notification and:
#     A. Calls CefBrowserHost::CloseBrowser(false).
#     B. Cancels the window close.
# 3.  JavaScript 'onbeforeunload' handler executes and shows the close
#     confirmation dialog (which can be overridden via
#     CefJSDialogHandler::OnBeforeUnloadDialog()).
# 4.  User approves the close. 5.  JavaScript 'onunload' handler executes. 6.
# Application's do_close() handler is called. Application will:
#     A. Set a flag to indicate that the next close attempt will be allowed.
#     B. Return false.
# 7.  CEF sends an OS close notification. 8.  Application's top-level window
# receives the OS close notification and
#     allows the window to close based on the flag from #6B.
# 9.  Browser OS window is destroyed. 10. Application's
# cef_life_span_handler_t::on_before_close() handler is called and
#     the browser object is destroyed.
# 11. Application exits by calling cef_quit_message_loop() if no other
# browsers
#     exist.
proc do_close(self: ptr cef_life_span_handler, browser: ptr_cef_browser): cint {.cef_callback.} =
  discard

# Called just before a browser is destroyed. Release all references to the
# browser object and do not attempt to execute any functions on the browser
# object after this callback returns. If this is a modal window and a custom
# modal loop implementation was provided in run_modal() this callback should
# be used to exit the custom modal loop. See do_close() documentation for
# additional usage information.
proc on_before_close(self: ptr cef_life_span_handler, browser: ptr_cef_browser) {.cef_callback.} =
  cef_quit_message_loop()

proc initialize_life_span_handler(span: ptr cef_life_span_handler) =
  span.size = sizeof(span[])
  initialize_cef_base(cast[ptr cef_base](span))

  span.on_before_popup = on_before_popup
  span.on_after_created = on_after_created
  span.do_close = do_close
  span.on_before_close = on_before_close

# Implement this structure to provide handler implementations. Methods will be
# called by the process and/or thread indicated.


# Provides an opportunity to view and/or modify command-line arguments before
# processing by CEF and Chromium. The |process_type| value will be NULL for
# the browser process. Do not keep a reference to the cef_command_line_t
# object passed to this function. The CefSettings.command_line_args_disabled
# value can be used to start with an NULL command-line object. Any values
# specified in CefSettings that equate to command-line arguments will be set
# before this function is called. Be cautious when using this function to
# modify command-line arguments for non-browser processes as this may result
# in undefined behavior including crashes.
proc on_before_command_line_processing(self: ptr cef_app,
  process_type: ptr cef_string, command_line: ptr cef_command_line) {.cef_callback.} =
  discard

# Provides an opportunity to register custom schemes. Do not keep a reference
# to the |registrar| object. This function is called on the main thread for
# each process and the registered schemes should be the same across all
# processes.
proc on_register_custom_schemes(self: ptr cef_app, registrar: ptr cef_scheme_registrar) {.cef_callback.} =
  discard

# Return the handler for resource bundle events. If
# CefSettings.pack_loading_disabled is true (1) a handler must be returned.
# If no handler is returned resources will be loaded from pack files. This
# function is called by the browser and render processes on multiple threads.
proc get_resource_bundle_handler(self: ptr cef_app): ptr cef_resource_bundle_handler {.cef_callback.} =
  result = nil

# Return the handler for functionality specific to the browser process. This
# function is called on multiple threads in the browser process.
proc get_browser_process_handler(self: ptr cef_app): ptr cef_browser_process_handler {.cef_callback.} =
  result = nil


# Return the handler for functionality specific to the render process. This
# function is called on the render process main thread.
proc get_render_process_handler(self: ptr cef_app): ptr cef_render_process_handler {.cef_callback.} =
  result = nil

proc initialize_app_handler(app: ptr cef_app) =
  app.size = sizeof(app[])
  initialize_cef_base(cast[ptr cef_base](app))

  # callbacks
  app.on_before_command_line_processing = on_before_command_line_processing
  app.on_register_custom_schemes = on_register_custom_schemes
  app.get_resource_bundle_handler = get_resource_bundle_handler
  app.get_browser_process_handler = get_browser_process_handler
  app.get_render_process_handler = get_render_process_handler


type
  my_client = object
    handler: cef_client
    span: cef_life_span_handler

# Implement this structure to provide handler implementations.

# Return the handler for context menus. If no handler is provided the default
# implementation will be used.

proc get_context_menu_handler(self: ptr cef_client): ptr cef_context_menu_handler {.cef_callback.} =
  result = nil

# Return the handler for dialogs. If no handler is provided the default
# implementation will be used.

proc get_dialog_handler(self: ptr cef_client): ptr cef_dialog_handler {.cef_callback.} =
  result = nil

# Return the handler for browser display state events.
proc get_display_handler(self: ptr cef_client): ptr cef_display_handler {.cef_callback.} =
  result = nil

# Return the handler for download events. If no handler is returned downloads
# will not be allowed.
proc get_download_handler(self: ptr cef_client): ptr cef_download_handler {.cef_callback.} =
  result = nil

# Return the handler for drag events.
proc get_drag_handler(self: ptr cef_client): ptr cef_drag_handler {.cef_callback.} =
  result = nil

# Return the handler for focus events.
proc get_focus_handler(self: ptr cef_client): ptr cef_focus_handler {.cef_callback.} =
  result = nil

# Return the handler for geolocation permissions requests. If no handler is
# provided geolocation access will be denied by default.
proc get_geolocation_handler(self: ptr cef_client): ptr cef_geolocation_handler {.cef_callback.} =
  result = nil

# Return the handler for JavaScript dialogs. If no handler is provided the
# default implementation will be used.

proc get_jsdialog_handler(self: ptr cef_client): ptr cef_jsdialog_handler {.cef_callback.} =
  result = nil

# Return the handler for keyboard events.
proc get_keyboard_handler(self: ptr cef_client): ptr cef_keyboard_handler {.cef_callback.} =
  result = nil

# Return the handler for browser life span events.
proc get_life_span_handler(self: ptr cef_client): ptr cef_life_span_handler {.cef_callback.} =
  result = cast[ptr my_client](self).span.addr

# Return the handler for browser load status events.
proc get_load_handler(self: ptr cef_client): ptr cef_load_handler {.cef_callback.} =
  result = nil

# Return the handler for off-screen rendering events.
proc get_render_handler(self: ptr cef_client): ptr cef_render_handler {.cef_callback.} =
  result = nil

# Return the handler for browser request events.
proc get_request_handler(self: ptr cef_client): ptr cef_request_handler {.cef_callback.} =
  result = nil

# Called when a new message is received from a different process. Return true
# (1) if the message was handled or false (0) otherwise. Do not keep a
# reference to or attempt to access the message outside of this callback.
proc on_process_message_received(self: ptr cef_client,
  browser: ptr_cef_browser, source_process: cef_process_id,
  message: ptr cef_process_message): cint {.cef_callback.} =
  result = 0

proc initialize_client_handler(client: ptr my_client) =
  client.handler.size = sizeof(my_client)
  initialize_cef_base(cast[ptr cef_base](client))

  # callbacks
  client.handler.get_context_menu_handler = get_context_menu_handler
  client.handler.get_dialog_handler = get_dialog_handler
  client.handler.get_display_handler = get_display_handler
  client.handler.get_download_handler = get_download_handler
  client.handler.get_drag_handler = get_drag_handler
  client.handler.get_focus_handler = get_focus_handler
  client.handler.get_geolocation_handler = get_geolocation_handler
  client.handler.get_jsdialog_handler = get_jsdialog_handler
  client.handler.get_keyboard_handler = get_keyboard_handler
  client.handler.get_life_span_handler = get_life_span_handler
  client.handler.get_load_handler = get_load_handler
  client.handler.get_render_handler = get_render_handler
  client.handler.get_request_handler = get_request_handler
  client.handler.on_process_message_received = on_process_message_received

  initialize_life_span_handler(client.span.addr)

const
  appName = "cefcapi"

proc main() =
  # Main args.
  var mainArgs: cef_main_args

  when defined(windows):
    mainArgs.instance = getModuleHandle(nil)
  elif defined(linux):
    var argv: array[2, cstring] = [appName.cstring, nil]
    mainArgs.argc = 1
    mainArgs.argv = argv[0].addr

  # Application handler and its callbacks.
  # cef_app_t structure must be filled. It must implement
  # reference counting. You cannot pass a structure
  # initialized with zeroes.
  var app: cef_app
  initialize_app_handler(app.addr)

  #Execute subprocesses.
  #let argc = paramCount()
  echo "cef_execute_process, app size: ", app.size
  var code = cef_execute_process(mainArgs.addr, app.addr, nil)
  if code >= 0:
    echo "failure execute process ", code
    quit(code)

  # Application settings.
  # It is mandatory to set the "size" member.
  var settings: cef_settings
  #zeroMem(settings.addr, sizeof(settings))
  settings.size = sizeof(settings)
  settings.no_sandbox = 1
  echo "settings size: ", settings.size

  #Initialize CEF.
  echo "cef_initialize"
  discard cef_initialize(mainArgs.addr, settings.addr, app.addr, nil)

  var windowInfo: cef_window_info

  when defined(linux):
    # Create GTK window. You can pass a NULL handle
    # to CEF and then it will create a window of its own.
    initialize_gtk()
    var hwnd = create_gtk_window("cefcapi example", 1024, 768)
    windowInfo.parent_widget = hwnd
  elif defined(windows):
    windowInfo.style = WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or  WS_CLIPSIBLINGS or WS_VISIBLE or WS_MAXIMIZE
    windowInfo.parent_window = cef_window_handle(0)
    windowInfo.x = CW_USEDEFAULT
    windowInfo.y = CW_USEDEFAULT
    windowInfo.width = CW_USEDEFAULT
    windowInfo.height = CW_USEDEFAULT

  #Initial url.
  let cwd = getCurrentDir()
  let url = "file://$1/resources/example.html" % [cwd]
  #echo url

  #There is no _cef_string_t type.
  var cefUrl: cef_string
  discard cef_string_utf8_to_utf16(url.cstring, url.len, cefUrl.addr)

  #Browser settings.
  #It is mandatory to set the "size" member.
  var browserSettings: cef_browser_settings
  #zeroMem(browserSettings.addr, sizeof(browserSettings))
  browserSettings.size = sizeof(browserSettings)
  #echo "browser settings size: ", browserSettings.size

  #Client handler and its callbacks.
  # cef_client_t structure must be filled. It must implement
  # reference counting. You cannot pass a structure
  # initialized with zeroes.
  var client: my_client
  initialize_client_handler(client.addr)

  # Create browser.
  echo "cef_browser_host_create_browser"
  discard cef_browser_host_create_browser(windowInfo.addr, client.handler.addr, cefUrl.addr, browserSettings.addr, nil)

  # Message loop.
  #echo ("cef_run_message_loop")
  cef_run_message_loop()

  #echo "cef_shutdown"
  cef_shutdown()

main()
