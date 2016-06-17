import cef_base_api, cef_frame_api
include cef_import

type
  # Implement this structure to handle events related to browser load status. The
  # functions of this structure will be called on the browser process UI thread
  # or render process main thread (TID_RENDERER).
  cef_load_handler* = object of cef_base
    # Called when the loading state has changed. This callback will be executed
    # twice -- once when loading is initiated either programmatically or by user
    # action, and once when loading is terminated due to completion, cancellation
    # of failure. It will be called before any calls to OnLoadStart and after all
    # calls to OnLoadError and/or OnLoadEnd.
    on_loading_state_change*: proc(self: ptr cef_load_handler,
      browser: ptr_cef_browser, isLoading, canGoBack, canGoForward: cint) {.cef_callback.}

    # Called when the browser begins loading a frame. The |frame| value will
    # never be NULL -- call the is_main() function to check if this frame is the
    # main frame. Multiple frames may be loading at the same time. Sub-frames may
    # start or continue loading after the main frame load has ended. This
    # function will always be called for all frames irrespective of whether the
    # request completes successfully. For notification of overall browser load
    # status use OnLoadingStateChange instead.
    on_load_start*: proc(self: ptr cef_load_handler,
      browser: ptr_cef_browser, frame: ptr cef_frame) {.cef_callback.}

    # Called when the browser is done loading a frame. The |frame| value will
    # never be NULL -- call the is_main() function to check if this frame is the
    # main frame. Multiple frames may be loading at the same time. Sub-frames may
    # start or continue loading after the main frame load has ended. This
    # function will always be called for all frames irrespective of whether the
    # request completes successfully. For notification of overall browser load
    # status use OnLoadingStateChange instead.

    on_load_end*: proc(self: ptr cef_load_handler,
      browser: ptr_cef_browser, frame: ptr cef_frame,
      httpStatusCode: cint) {.cef_callback.}

    # Called when the resource load for a navigation fails or is canceled.
    # |errorCode| is the error code number, |errorText| is the error text and
    # |failedUrl| is the URL that failed to load. See net\base\net_error_list.h
    # for complete descriptions of the error codes.

    on_load_error*: proc(self: ptr cef_load_handler,
      browser: ptr_cef_browser, frame: ptr cef_frame,
      errorCode: cef_errorcode, errorText, failedUrl: ptr cef_string) {.cef_callback.}

