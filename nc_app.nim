import cef/cef_app_api, cef/cef_load_handler_api, cef/cef_print_handler_api
import nc_command_line, nc_values, nc_types, nc_dom, nc_v8, nc_request, nc_process_message
import nc_scheme

type
  NCBase*[T, C] = object
    refcount*: int
    container*: C
    handler*: T

  NCResourceBundleHandler* = NCBase[cef_resource_bundle_handler, NCApp]
  NCBrowserProcessHandler* = NCBase[cef_browser_process_handler, NCApp]
  NCRenderProcessHandler*  = NCBase[cef_render_process_handler, NCApp]

  # Implement this structure to provide handler implementations. Methods will be
  # called by the process and/or thread indicated.
  NCApp* = ref object of RootObj
    app_handler*: cef_app
    resource_bundle_handler: ptr NCResourceBundleHandler
    render_process_handler: ptr NCRenderProcessHandler
    browser_process_handler: ptr NCBrowserProcessHandler

  #choose what kind of handler you want to exposed to your app
  NCAppCreateFlag* = enum
    # Return the handler for resource bundle events. If
    # CefSettings.pack_loading_disabled is true (1) a handler must be returned.
    # If no handler is returned resources will be loaded from pack files. This
    # function is called by the browser and render processes on multiple threads.
    NCAF_RESOURCE_BUNDLE
    # Return the handler for functionality specific to the browser process. This
    # function is called on multiple threads in the browser process.
    NCAF_BROWSER_PROCESS
    # Return the handler for functionality specific to the render process. This
    # function is called on the render process main thread.
    NCAF_RENDER_PROCESS

  NCAFS* = set[NCAppCreateFlag]

#--NCApp
# Provides an opportunity to view and/or modify command-line arguments before
# processing by CEF and Chromium. The |process_type| value will be NULL for
# the browser process. Do not keep a reference to the cef_command_line_t
# object passed to this function. The CefSettings.command_line_args_disabled
# value can be used to start with an NULL command-line object. Any values
# specified in CefSettings that equate to command-line arguments will be set
# before this function is called. Be cautious when using this function to
# modify command-line arguments for non-browser processes as this may result
# in undefined behavior including crashes.
method OnBeforeCommandLineProcessing*(self: NCApp, process_type: string, command_line: NCCommandLine) {.base.} =
  discard

#--NCApp
# Provides an opportunity to register custom schemes. Do not keep a reference
# to the |registrar| object. This function is called on the main thread for
# each process and the registered schemes should be the same across all
# processes.
method OnRegisterCustomSchemes*(self: NCApp, registrar: NCSchemeRegistrar) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called after the render process main thread has been created. |extra_info|
# is a read-only value originating from
# cef_browser_process_handler_t::on_render_process_thread_created(). Do not
# keep a reference to |extra_info| outside of this function.
method OnRenderThreadCreated*(self: NCApp, extra_info: NCListValue) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called after WebKit has been initialized.
method OnWebKitInitialized*(self: NCApp) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called after a browser has been created. When browsing cross-origin a new
# browser will be created before the old browser with the same identifier is
# destroyed.
method OnBrowserCreated*(self: NCApp, browser: NCBrowser) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called before a browser is destroyed.
method OnBrowserDestroyed*(self: NCApp, browser: NCBrowser) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Return the handler for browser load status events.
method GetLoadHandler*(self: NCApp): ptr cef_load_handler {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called before browser navigation. Return true (1) to cancel the navigation
# or false (0) to allow the navigation to proceed. The |request| object
# cannot be modified in this callback.
method OnBeforeNavigation*(self: NCApp, browser: NCBrowser, frame: NCFrame,
  request: NCRequest, navigation_type: cef_navigation_type, is_redirect: bool): bool {.base.} =
  result = true

#--NCAF_RENDER_PROCESS
# Called immediately after the V8 context for a frame has been created. To
# retrieve the JavaScript 'window' object use the
# cef_v8context_t::get_global() function. V8 handles can only be accessed
# from the thread on which they are created. A task runner for posting tasks
# on the associated thread can be retrieved via the
# cef_v8context_t::get_task_runner() function.
method OnContextCreated*(self: NCApp, browser: NCBrowser, frame: NCFrame,
  context: NCV8Context) {.base.} =
  discard
  
#--NCAF_RENDER_PROCESS
# Called immediately before the V8 context for a frame is released. No
# references to the context should be kept after this function is called.
method OnContextReleased*(self: NCApp, browser: NCBrowser, frame: NCFrame,
  context: NCV8Context) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called for global uncaught exceptions in a frame. Execution of this
# callback is disabled by default. To enable set
# CefSettings.uncaught_exception_stack_size > 0.
method OnUncaughtException*(self: NCApp, browser: NCBrowser, frame: NCFrame,
  context: NCV8Context, exception: NCV8Exception,
  stackTrace: NCV8StackTrace) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called when a new node in the the browser gets focus. The |node| value may
# be NULL if no specific node has gained focus. The node object passed to
# this function represents a snapshot of the DOM at the time this function is
# executed. DOM objects are only valid for the scope of this function. Do not
# keep references to or attempt to access any DOM objects outside the scope
# of this function.
method OnFocusedNodeChanged*(self: NCApp, browser: NCBrowser, frame: NCFrame,
  node: NCDomNode) {.base.} =
  discard

#--NCAF_RENDER_PROCESS
# Called when a new message is received from a different process. Return true
# (1) if the message was handled or false (0) otherwise. Do not keep a
# reference to or attempt to access the message outside of this callback.
method OnBrowserProcessMessageReceived*(self: NCApp, browser: NCBrowser, source_process: cef_process_id,
  message: NCProcessMessage): bool {.base.} =
  result = false

#--NCAF_BROWSER_PROCESS
# Called on the browser process UI thread immediately after the CEF context
# has been initialized.
method OnContextInitialized*(self: NCApp) {.base.} =
  discard

#--NCAF_BROWSER_PROCESS  
# Called before a child process is launched. Will be called on the browser
# process UI thread when launching a render process and on the browser
# process IO thread when launching a GPU or plugin process. Provides an
# opportunity to modify the child process command line. Do not keep a
# reference to |command_line| outside of this function.
method OnBeforeChildProcessLaunch*(self: NCApp, command_line: NCCommandLine) {.base.} =
  discard
  
#--NCAF_BROWSER_PROCESS
# Called on the browser process IO thread after the main thread has been
# created for a new render process. Provides an opportunity to specify extra
# information that will be passed to
# cef_render_process_handler_t::on_render_thread_created() in the render
# process. Do not keep a reference to |extra_info| outside of this function.
method OnRenderProcessThreadCreated*(self: NCApp, extra_info: NCListValue) {.base.} =
  discard
  
#--NCAF_BROWSER_PROCESS
# Return the handler for printing on Linux. If a print handler is not
# provided then printing will not be supported on the Linux platform.
method GetPrintHandler*(self: NCApp): ptr cef_print_handler {.base.} =
  result = nil

#--NCAF_RESOURCE_BUNDLE
# Called to retrieve a localized translation for the specified |string_id|.
# To provide the translation set |string| to the translation string and
# return true (1). To use the default translation return false (0). Include
# cef_pack_strings.h for a listing of valid string ID values.
method GetLocalizedString*(self: NCApp, string_id: int, str: var string): bool {.base.} =
  result = false

#--NCAF_RESOURCE_BUNDLE
# Called to retrieve data for the specified scale independent |resource_id|.
# To provide the resource data set |data| and |data_size| to the data pointer
# and size respectively and return true (1). To use the default resource data
# return false (0). The resource data will not be copied and must remain
# resident in memory. Include cef_pack_resources.h for a listing of valid
# resource ID values.
method GetDataResource*(self: NCApp, resource_id: int, data: var pointer, data_size: var csize): bool {.base.} =
  result = false

#--NCAF_RESOURCE_BUNDLE
# Called to retrieve data for the specified |resource_id| nearest the scale
# factor |scale_factor|. To provide the resource data set |data| and
# |data_size| to the data pointer and size respectively and return true (1).
# To use the default resource data return false (0). The resource data will
# not be copied and must remain resident in memory. Include
# cef_pack_resources.h for a listing of valid resource ID values.
method GetDataResourceForScale*(self: NCApp, resource_id: int,
  scale_factor: cef_scale_factor, data: var pointer, data_size: var csize): bool {.base.} =
  result = false
      
proc GetHandler*(app: NCApp): ptr cef_app = app.app_handler.addr

include nc_app_internal

proc app_finalizer[T](app: T) =
  if app.render_process_handler != nil: freeShared(app.render_process_handler)
  if app.browser_process_handler != nil: freeShared(app.browser_process_handler)
  if app.resource_bundle_handler != nil: freeShared(app.resource_bundle_handler)

proc makeNCApp*(T: typedesc, flags: NCAFS = {}): auto =
  var app: T
  new(app, app_finalizer)

  initialize_app_handler(app.app_handler.addr)

  if NCAF_RENDER_PROCESS in flags:
    app.render_process_handler = createShared(NCRenderProcessHandler)
    app.render_process_handler.container = app
    initialize_render_process_handler(app.render_process_handler.handler.addr)

  if NCAF_RENDER_PROCESS in flags:
    app.browser_process_handler = createShared(NCBrowserProcessHandler)
    app.browser_process_handler.container = app
    initialize_browser_process_handler(app.browser_process_handler.handler.addr)

  if NCAF_RENDER_PROCESS in flags:
    app.resource_bundle_handler = createShared(NCResourceBundleHandler)
    app.resource_bundle_handler.container = app
    initialize_resource_bundle_handler(app.resource_bundle_handler.handler.addr)
  return app
