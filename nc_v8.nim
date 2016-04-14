import cef/cef_v8_api

type
  NCV8Context* = ptr cef_v8context
  NCV8Exception* = ptr cef_v8exception
  NCV8StackTrace* = ptr cef_v8stack_trace