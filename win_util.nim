import winapi, nc_types, nc_browser

proc PlatformTitleChange*(browser: NCBrowser, title: string) =
  var hwnd = browser.getHost().getWindowHandle()
  discard setWindowText(hwnd, title)
