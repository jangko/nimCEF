import winapi

type
  cef_window_handle* = HWND
  cef_text_input_context* = distinct pointer
  cef_event_handle* = ptr MSG
  cef_cursor_handle* = HCURSOR