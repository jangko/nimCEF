import cef_dynlib

when defined(windows):
  {.pragma: cef_import, stdcall, importc, dynlib: CEF_LIB_NAME.}
  {.pragma: cef_callback, stdcall.}
else:
  {.pragma: cef_import, cdecl, importc, dynlib: CEF_LIB_NAME.}
  {.pragma: cef_callback, cdecl.}
