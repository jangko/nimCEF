import cef_base, cef_callback
include cef_import

type
  # Implement this structure to receive notification when tracing has completed.
  # The functions of this structure will be called on the browser process UI
  # thread.
  cef_end_tracing_callback* = object
    # Base structure.
    base*: cef_base

    # Called after all processes have sent their trace data. |tracing_file| is
    # the path at which tracing data was written. The client is responsible for
    # deleting |tracing_file|.
    on_end_tracing_complete*: proc(self: ptr cef_end_tracing_callback,
      tracing_file: ptr cef_string) {.cef_callback.}


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
proc cef_begin_tracing*(categories: ptr cef_string,
  callback: ptr cef_completion_callback): int {.cef_import.}


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
proc cef_end_tracing*(tracing_file: ptr cef_string,
  callback: ptr cef_end_tracing_callback): int {.cef_import.}


# Returns the current system trace time or, if none is defined, the current
# high-res time. Can be used by clients to synchronize with the time
# information in trace events.
proc cef_now_from_system_trace_time*(): int64 {.cef_import.}

