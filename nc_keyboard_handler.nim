import nc_util, impl/nc_util_impl, cef/cef_keyboard_handler_api, nc_types
include cef/cef_import

# Implement this structure to handle events related to keyboard input. The
# functions of this structure will be called on the UI thread.
wrapCallback(NCKeyboardHandler, cef_keyboard_handler):
  # Called before a keyboard event is sent to the renderer. |event| contains
  # information about the keyboard event. |os_event| is the operating system
  # event message, if any. Return true (1) if the event was handled or false
  # (0) otherwise. If the event will be handled in on_key_event() as a keyboard
  # shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
  proc OnPreKeyEvent*(self: T, browser: NCBrowser, event: NCKeyEvent,
    os_event: cef_event_handle, is_keyboard_shortcut: var int): bool

  # Called after the renderer and JavaScript in the page has had a chance to
  # handle the event. |event| contains information about the keyboard event.
  # |os_event| is the operating system event message, if any. Return true (1)
  # if the keyboard event was handled or false (0) otherwise.
  proc OnKeyEvent*(self: T, browser: NCBrowser, event: NCKeyEvent,
    os_event: cef_event_handle): bool