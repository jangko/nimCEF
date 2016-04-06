import cef_base, cef_frame
include cef_import

type
  # Implement this structure to handle events related to browser display state.
  # The functions of this structure will be called on the UI thread.
  cef_display_handler* = object
    # Base structure.
    base*: cef_base

    # Called when a frame's address has changed.
    on_address_change*: proc(self: ptr cef_display_handler,
      browser: ptr_cef_browser, frame: ptr cef_frame,
      url: ptr cef_string) {.cef_callback.}

    # Called when the page title changes.
    on_title_change*: proc(self: ptr cef_display_handler,
      browser: ptr_cef_browser, title: ptr cef_string) {.cef_callback.}

    # Called when the page icon changes.
    on_favicon_urlchange*: proc(self: ptr cef_display_handler,
      browser: ptr_cef_browser, icon_urls: cef_string_list) {.cef_callback.}

    # Called when web content in the page has toggled fullscreen mode. If
    # |fullscreen| is true (1) the content will automatically be sized to fill
    # the browser content area. If |fullscreen| is false (0) the content will
    # automatically return to its original size and position. The client is
    # responsible for resizing the browser if desired.
    on_fullscreen_mode_change*: proc(self: ptr cef_display_handler, browser: ptr_cef_browser,
      fullscreen: int) {.cef_callback.}

    # Called when the browser is about to display a tooltip. |text| contains the
    # text that will be displayed in the tooltip. To handle the display of the
    # tooltip yourself return true (1). Otherwise, you can optionally modify
    # |text| and then return false (0) to allow the browser to display the
    # tooltip. When window rendering is disabled the application is responsible
    # for drawing tooltips and the return value is ignored.
    on_tooltip*: proc(self: ptr cef_display_handler,
      browser: ptr_cef_browser, text: ptr cef_string): int {.cef_callback.}

    # Called when the browser receives a status message. |value| contains the
    # text that will be displayed in the status message.
    on_status_message*: proc(self: ptr cef_display_handler,
      browser: ptr_cef_browser, value: ptr cef_string) {.cef_callback.}

    # Called to display a console message. Return true (1) to stop the message
    # from being output to the console.
    on_console_message*: proc(self: ptr cef_display_handler,
      browser: ptr_cef_browser, message, source: ptr cef_string, line: int): int {.cef_callback.}

