when defined(MACOSX):
  const
    CEF_LIB_NAME* = "libcef.dylib"
elif defined(UNIX):
  const
    CEF_LIB_NAME* = "libcef.so"
else:
  const
    CEF_LIB_NAME* = "libcef.dll"