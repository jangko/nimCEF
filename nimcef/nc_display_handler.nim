import nc_util, nc_util_impl, cef_display_handler_api, nc_types
include cef_import

# Implement this structure to handle events related to browser display state.
# The functions of this structure will be called on the UI thread.
wrapCallback(NCDisplayHandler, cef_display_handler):
  # Called when a frame's address has changed.
  proc onAddressChange*(self: T, browser: NCBrowser, frame: NCFrame, url: string)

  # Called when the page title changes.
  proc onTitleChange*(self: T, browser: NCBrowser, title: string)

  # Called when the page icon changes.
  proc onFaviconUrlchange*(self: T, browser: NCBrowser, icon_urls: seq[string])

  # Called when web content in the page has toggled fullscreen mode. If
  # |fullscreen| is true (1) the content will automatically be sized to fill
  # the browser content area. If |fullscreen| is false (0) the content will
  # automatically return to its original size and position. The client is
  # responsible for resizing the browser if desired.
  proc onFullscreenModeChange*(self: T, browser: NCBrowser, fullscreen: bool)

  # Called when the browser is about to display a tooltip. |text| contains the
  # text that will be displayed in the tooltip. To handle the display of the
  # tooltip yourself return true (1). Otherwise, you can optionally modify
  # |text| and then return false (0) to allow the browser to display the
  # tooltip. When window rendering is disabled the application is responsible
  # for drawing tooltips and the return value is ignored.
  proc onTooltip*(self: T, browser: NCBrowser, text: var string): bool

  # Called when the browser receives a status message. |value| contains the
  # text that will be displayed in the status message.
  proc onStatusMessage*(self: T, browser: NCBrowser, value: string)

  # Called to display a console message. Return true (1) to stop the message
  # from being output to the console.
  proc onConsoleMessage*(self: T, browser: NCBrowser, message, source: string, line: int): bool