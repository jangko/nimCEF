import cef_base_api
include cef_import

# Implement this structure to handle events related to keyboard input. The
# functions of this structure will be called on the UI thread.
type
  cef_keyboard_handler* = object
    base*: cef_base

    # Called before a keyboard event is sent to the renderer. |event| contains
    # information about the keyboard event. |os_event| is the operating system
    # event message, if any. Return true (1) if the event was handled or false
    # (0) otherwise. If the event will be handled in on_key_event() as a keyboard
    # shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
    on_pre_key_event*: proc(self: ptr cef_keyboard_handler,
      browser: ptr_cef_browser, event: ptr cef_key_event,
      os_event: cef_event_handle, is_keyboard_shortcut: var cint): cint {.cef_callback.}

    # Called after the renderer and JavaScript in the page has had a chance to
    # handle the event. |event| contains information about the keyboard event.
    # |os_event| is the operating system event message, if any. Return true (1)
    # if the keyboard event was handled or false (0) otherwise.
    on_key_event*: proc(self: ptr cef_keyboard_handler,
      browser: ptr_cef_browser, event: ptr cef_key_event,
      os_event: cef_event_handle): cint {.cef_callback.}