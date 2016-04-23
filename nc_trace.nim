import cef/cef_trace_api, nc_callback, nc_util, nc_types
include cef/cef_import

type
  # Implement this structure to receive notification when tracing has completed.
  # The functions of this structure will be called on the browser process UI
  # thread.
  NCEndTracingCallback* = ref object of RootObj
    handler: cef_end_tracing_callback
    
# Called after all processes have sent their trace data. |tracing_file| is
# the path at which tracing data was written. The client is responsible for
# deleting |tracing_file|.
method OnEndTracingComplete*(self: NCEndTracingCallback, tracing_file: string) {.base.} =
  discard

proc on_end_tracing_complete(self: ptr cef_end_tracing_callback, tracing_file: ptr cef_string) {.cef_callback.} =
  var handler = type_to_type(NCEndTracingCallback, self)
  handler.OnEndTracingComplete($tracing_file)

proc GetHandler*(self: NCEndTracingCallback): ptr cef_end_tracing_callback {.inline.} =
  result = self.handler.addr
  
proc initialize_end_tracing_callback(handler: ptr cef_end_tracing_callback) =
  init_base(handler)
  handler.on_end_tracing_complete = on_end_tracing_complete
  
proc makeNCEndTracingCallback*(T: typedesc): auto =
  result = new(T)
  initialize_end_tracing_callback(result.GetHandler())
  
# Start tracing events on all processes. Tracing is initialized asynchronously
# and |callback| will be executed on the UI thread after initialization is
# complete.
#
# If CefBeginTracing was called previously, or if a CefEndTracingAsync call is
# pending, CefBeginTracing will fail and return false (0).
#
# |categories| is a comma-delimited list of category wildcards. A category can
# have an optional '-' prefix to make it an excluded category. Having both
# included and excluded categories in the same list is not supported.
#
# Example: "test_MyTest*" Example: "test_MyTest*,test_OtherStuff" Example:
# "-excluded_category1,-excluded_category2"
#
# This function must be called on the browser process UI thread.
proc NCBeginTracing*(categories: string, callback: NCCompletionCallback): bool =
  let ccat = to_cef(categories)
  result = cef_begin_tracing(ccat, callback.GetHandler()) == 1.cint
  cef_string_userfree_free(ccat)

# Stop tracing events on all processes.
#
# This function will fail and return false (0) if a previous call to
# CefEndTracingAsync is already pending or if CefBeginTracing was not called.
#
# |tracing_file| is the path at which tracing data will be written and
# |callback| is the callback that will be executed once all processes have sent
# their trace data. If |tracing_file| is NULL a new temporary file path will be
# used. If |callback| is NULL no trace data will be written.
#
# This function must be called on the browser process UI thread.
proc NCEndTracing*(tracing_file: string, callback: NCEndTracingCallback): bool =
  let cfile = to_cef(tracing_file)
  result = cef_end_tracing(cfile, callback.GetHandler()) == 1.cint
  cef_string_userfree_free(cfile)

# Returns the current system trace time or, if none is defined, the current
# high-res time. Can be used by clients to synchronize with the time
# information in trace events.
proc NCNowFromSystemTraceTime*(): int64 =
  result = cef_now_from_system_trace_time()
