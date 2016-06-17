import nc_task, nc_types, nc_util, nc_time, nc_util_impl
include cef_import

# Structure representing a V8 context handle. V8 handles can only be accessed
# from the thread on which they are created. Valid threads for creating a V8
# handle include the render process main thread (TID_RENDERER) and WebWorker
# threads. A task runner for posting tasks on the associated thread can be
# retrieved via the NCV8Context::GetTaskRunner() function.
wrapAPI(NCV8Context, cef_v8context)

# Structure that should be implemented to handle V8 accessor calls. Accessor
# identifiers are registered by calling NCV8Value::SetValue(). The
# functions of this structure will be called on the thread associated with the
# V8 accessor.
wrapAPI(NCV8Accessor, cef_v8accessor, false)

# Structure representing a V8 exception. The functions of this structure may be
# called on any render process thread.
wrapAPI(NCV8Exception, cef_v8exception, false)

# Structure representing a V8 value handle. V8 handles can only be accessed
# from the thread on which they are created. Valid threads for creating a V8
# handle include the render process main thread (TID_RENDERER) and WebWorker
# threads. A task runner for posting tasks on the associated thread can be
# retrieved via the NCV8Context::GetTaskRunner() function.
wrapAPI(NCV8Value, cef_v8value, false)

# Structure representing a V8 stack trace handle. V8 handles can only be
# accessed from the thread on which they are created. Valid threads for
# creating a V8 handle include the render process main thread (TID_RENDERER)
# and WebWorker threads. A task runner for posting tasks on the associated
# thread can be retrieved via the NCV8Context::GetTaskRunner() function.
wrapAPI(NCV8StackTrace, cef_v8stacktrace, false)

# Structure representing a V8 stack frame handle. V8 handles can only be
# accessed from the thread on which they are created. Valid threads for
# creating a V8 handle include the render process main thread (TID_RENDERER)
# and WebWorker threads. A task runner for posting tasks on the associated
# thread can be retrieved via the NCV8Context::GetTaskRunner() function.
wrapAPI(NCV8StackFrame, cef_v8stackframe, false)

# Structure that should be implemented to handle V8 function calls. The
# functions of this structure will be called on the thread associated with the
# V8 function.
wrapCallback(NCV8Handler, cef_v8handler):
  proc execute*(self: T, name: string, obj: NCV8Value, args: seq[NCV8Value],
    retval: var NCV8Value, exception: string): bool

# Handle execution of the function identified by |name|. |object| is the
# receiver ('this' object) of the function. |arguments| is the list of
# arguments passed to the function. If execution succeeds set |retval| to the
# function return value. If execution fails set |exception| to the exception
# that will be thrown. Return true (1) if execution was handled.
proc execute*(self: NCV8Handler, name: string, obj: NCV8Value, args: seq[NCV8Value],
  retval: var NCV8Value, exception: string): bool =
  self.wrapCall(execute, result, name, obj, args, retval, exception)

# Returns the task runner associated with this context. V8 handles can only
# be accessed from the thread on which they are created. This function can be
# called on any render process thread.
proc getTaskRunner*(self: NCV8Context): NCTaskRunner =
  self.wrapCall(get_task_runner, result)

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc isValid*(self: NCV8Context): bool =
  self.wrapCall(is_valid, result)

# Returns the browser for this context. This function will return an NULL
# reference for WebWorker contexts.
proc getBrowser*(self: NCV8Context): NCBrowser =
  self.wrapCall(get_browser, result)

# Returns the frame for this context. This function will return an NULL
# reference for WebWorker contexts.
proc getFrame*(self: NCV8Context): NCFrame =
  self.wrapCall(get_frame, result)

# Returns the global object for this context. The context must be entered
# before calling this function.
proc getGlobal*(self: NCV8Context): NCV8Value =
  self.wrapCall(get_global, result)

# Enter this context. A context must be explicitly entered before creating a
# V8 Object, Array, Function or Date asynchronously. exit() must be called
# the same number of times as enter() before releasing this context. V8
# objects belong to the context in which they are created. Returns true (1)
# if the scope was entered successfully.
proc enter*(self: NCV8Context): bool =
  self.wrapCall(enter, result)

# Exit this context. Call this function only after calling enter(). Returns
# true (1) if the scope was exited successfully.
proc exit*(self: NCV8Context): bool =
  self.wrapCall(exit, result)

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc isSame*(self, that: NCV8Context): bool =
  self.wrapCall(is_same, result, that)

# Evaluates the specified JavaScript code using this context's global object.
# On success |retval| will be set to the return value, if any, and the
# function will return true (1). On failure |exception| will be set to the
# exception, if any, and the function will return false (0).
proc eval*(self: NCV8Context, code: string, retval: var NCV8Value, exception: var NCV8Exception): bool =
  self.wrapCall(eval, result, code, retval, exception)

# Handle retrieval the accessor value identified by |name|. |object| is the
# receiver ('this' object) of the accessor. If retrieval succeeds set
# |retval| to the return value. If retrieval fails set |exception| to the
# exception that will be thrown. Return true (1) if accessor retrieval was
# handled.
proc getValue*(self: NCV8Accessor, name: string, obj: NCV8Value, retval: var NCV8Value, exception: string): bool =
  self.wrapCall(get_value, result, name, obj, retval, exception)

# Handle assignment of the accessor value identified by |name|. |object| is
# the receiver ('this' object) of the accessor. |value| is the new value
# being assigned to the accessor. If assignment fails set |exception| to the
# exception that will be thrown. Return true (1) if accessor assignment was
# handled.
proc setValue*(self: NCV8Accessor, name: string, obj: NCV8Value,
  value: NCV8Value, exception: string): bool =
  self.wrapCall(set_value, result, name, obj, value, exception)

# Returns the exception message.
proc getMessage*(self: NCV8Exception): string =
  self.wrapCall(get_message, result)

# Returns the line of source code that the exception occurred within.
proc getSourceLine*(self: NCV8Exception): string =
  self.wrapCall(get_source_line, result)

# Returns the resource name for the script from where the function causing
# the error originates.
proc getScriptResourceName*(self: NCV8Exception): string =
  self.wrapCall(get_script_resource_name, result)

# Returns the 1-based number of the line where the error occurred or 0 if the
# line number is unknown.
proc getLineNumber*(self: NCV8Exception): int =
  self.wrapCall(get_line_number, result)

# Returns the index within the script of the first character where the error
# occurred.
proc getStartPosition*(self: NCV8Exception): int =
  self.wrapCall(get_start_position, result)

# Returns the index within the script of the last character where the error
# occurred.
proc getEndPosition*(self: NCV8Exception): int =
  self.wrapCall(get_end_position, result)

# Returns the index within the line of the first character where the error
# occurred.
proc getStartColumn*(self: NCV8Exception): int =
  self.wrapCall(get_start_column, result)

# Returns the index within the line of the last character where the error
# occurred.
proc getEndColumn*(self: NCV8Exception): int =
  self.wrapCall(get_end_column, result)

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc isValid*(self: NCV8Value): bool =
  self.wrapCall(is_valid, result)

# True if the value type is undefined.
proc isUndefined*(self: NCV8Value): bool =
  self.wrapCall(is_undefined, result)

# True if the value type is null.
proc isNull*(self: NCV8Value): bool =
  self.wrapCall(is_null, result)

# True if the value type is bool.
proc isBool*(self: NCV8Value): bool =
  self.wrapCall(is_bool, result)

# True if the value type is cint.
proc isInt*(self: NCV8Value): bool =
  self.wrapCall(is_int, result)

# True if the value type is unsigned cint.
proc isUint*(self: NCV8Value): bool =
  self.wrapCall(is_uint, result)

# True if the value type is double.
proc isDouble*(self: NCV8Value): bool =
  self.wrapCall(is_double, result)

# True if the value type is Date.
proc isDate*(self: NCV8Value): bool =
  self.wrapCall(is_date, result)

# True if the value type is string.
proc isString*(self: NCV8Value): bool =
  self.wrapCall(is_string, result)

# True if the value type is object.
proc isObject*(self: NCV8Value): bool =
  self.wrapCall(is_object, result)

# True if the value type is array.
proc isArray*(self: NCV8Value): bool =
  self.wrapCall(is_array, result)

# True if the value type is function.
proc isFunction*(self: NCV8Value): bool =
  self.wrapCall(is_function, result)

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc isSame*(self, that: NCV8Value): bool =
  self.wrapCall(is_same, result, that)

# Return a bool value.  The underlying data will be converted to if
# necessary.
proc getBoolValue*(self: NCV8Value): bool =
  self.wrapCall(get_bool_value, result)

# Return an cint value.  The underlying data will be converted to if
# necessary.
proc getIntValue*(self: NCV8Value): int32 =
  self.wrapCall(get_int_value, result)

# Return an unsigned cint value.  The underlying data will be converted to if
# necessary.
proc getUintValue*(self: NCV8Value): uint32 =
  self.wrapCall(get_uint_value, result)

# Return a double value.  The underlying data will be converted to if
# necessary.
proc getDoubleValue*(self: NCV8Value): float64 =
  self.wrapCall(get_double_value, result)

# Return a Date value.  The underlying data will be converted to if
# necessary.
proc getDateValue*(self: NCV8Value): NCTime =
  self.wrapCall(get_date_value, result)

# Return a string value.  The underlying data will be converted to if
# necessary.
proc getStringValue*(self: NCV8Value): string =
  self.wrapCall(get_string_value, result)

# OBJECT METHODS - These functions are only available on objects. Arrays and
# functions are also objects. String- and integer-based keys can be used
# interchangably with the framework converting between them as necessary.

# Returns true (1) if this is a user created object.
proc isUserCreated*(self: NCV8Value): bool =
  self.wrapCall(is_user_created, result)

# Returns true (1) if the last function call resulted in an exception. This
# attribute exists only in the scope of the current CEF value object.
proc hasException*(self: NCV8Value): bool =
  self.wrapCall(has_exception, result)

# Returns the exception resulting from the last function call. This attribute
# exists only in the scope of the current CEF value object.
proc getException*(self: NCV8Value): NCV8Exception =
  self.wrapCall(get_exception, result)

# Clears the last exception and returns true (1) on success.
proc clearException*(self: NCV8Value): bool =
  self.wrapCall(clear_exception, result)

# Returns true (1) if this object will re-throw future exceptions. This
# attribute exists only in the scope of the current CEF value object.
proc willRethrowExceptions*(self: NCV8Value): bool =
  self.wrapCall(will_rethrow_exceptions, result)

# Set whether this object will re-throw future exceptions. By default
# exceptions are not re-thrown. If a exception is re-thrown the current
# context should not be accessed again until after the exception has been
# caught and not re-thrown. Returns true (1) on success. This attribute
# exists only in the scope of the current CEF value object.
proc setRethrowExceptions*(self: NCV8Value, rethrow: bool): bool =
  self.wrapCall(set_rethrow_exceptions, result, rethrow)

# Returns true (1) if the object has a value with the specified identifier.
proc hasValueByKey*(self: NCV8Value, key: string): bool =
  self.wrapCall(has_value_bykey, result, key)

# Returns true (1) if the object has a value with the specified identifier.
proc hasValueByIndex*(self: NCV8Value, index: int): bool =
  self.wrapCall(has_value_byindex, result, index)

# Deletes the value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly or an
# exception is thrown. For read-only and don't-delete values this function
# will return true (1) even though deletion failed.
proc deleteValueByKey*(self: NCV8Value, key: string): bool =
  self.wrapCall(delete_value_bykey, result, key)

# Deletes the value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly, deletion
# fails or an exception is thrown. For read-only and don't-delete values this
# function will return true (1) even though deletion failed.
proc deleteValueByIndex*(self: NCV8Value, index: int): bool =
  self.wrapCall(delete_value_byindex, result, index)

# Returns the value with the specified identifier on success. Returns NULL if
# this function is called incorrectly or an exception is thrown.
proc getValueByKey*(self: NCV8Value, key: string): NCV8Value =
  self.wrapCall(get_value_bykey, result, key)

# Returns the value with the specified identifier on success. Returns NULL if
# this function is called incorrectly or an exception is thrown.
proc getValueByIndex*(self: NCV8Value, index: int): NCV8Value =
  self.wrapCall(get_value_byindex, result, index)

# Associates a value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly or an
# exception is thrown. For read-only values this function will return true
# (1) even though assignment failed.
proc setValueByKey*(self: NCV8Value, key: string, value: NCV8Value,
  attribute: cef_v8_propertyattribute) : bool =
  self.wrapCall(set_value_bykey, result, key, value, attribute)

# Associates a value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly or an
# exception is thrown. For read-only values this function will return true
# (1) even though assignment failed.
proc setValueByIndex*(self: NCV8Value, index: int, value: NCV8Value): bool =
  self.wrapCall(set_value_byindex, result, index, value)

# Registers an identifier and returns true (1) on success. Access to the
# identifier will be forwarded to the NCV8Accessor instance passed to
# NCV8Value::NCV8ValueCreateObject(). Returns false (0) if this
# function is called incorrectly or an exception is thrown. For read-only
# values this function will return true (1) even though assignment failed.
proc setValueByAccessor*(self: NCV8Value, key: string, settings: cef_v8_accesscontrol,
  attribute: cef_v8_propertyattribute): bool =
  self.wrapCall(set_value_byaccessor, result, key, settings, attribute)

# Read the keys for the object's values into the specified vector. Integer-
# based keys will also be returned as strings.
proc getKeys*(self: NCV8Value): seq[string] =
  self.wrapCall(get_keys, result)

# Sets the user data for this object and returns true (1) on success. Returns
# false (0) if this function is called incorrectly. This function can only be
# called on user created objects.
proc setUserData*(self: NCV8Value, user_data: ptr cef_base): bool =
  user_data.add_ref(user_data)
  self.wrapCall(set_user_data, result, user_data)

# Returns the user data, if any, assigned to this object.
proc getUserData*(self: NCV8Value): ptr cef_base =
  self.wrapCall(get_user_data, result)

# Returns the amount of externally allocated memory registered for the
# object.
proc getExternallyAllocatedMemory*(self: NCV8Value): int =
  self.wrapCall(get_externally_allocated_memory, result)

# Adjusts the amount of registered external memory for the object. Used to
# give V8 an indication of the amount of externally allocated memory that is
# kept alive by JavaScript objects. V8 uses this information to decide when
# to perform global garbage collection. Each NCV8Value tracks the amount
# of external memory associated with it and automatically decreases the
# global total by the appropriate amount on its destruction.
# |change_in_bytes| specifies the number of bytes to adjust by. This function
# returns the number of bytes associated with the object after the
# adjustment. This function can only be called on user created objects.
proc adjustExternallyAllocatedMemory*(self: NCV8Value, change_in_bytes: int): int =
  self.wrapCall(adjust_externally_allocated_memory, result, change_in_bytes)

# ARRAY METHODS - These functions are only available on arrays.
# Returns the number of elements in the array.
proc getArrayLength*(self: NCV8Value): int =
  self.wrapCall(get_array_length, result)

# FUNCTION METHODS - These functions are only available on functions.
# Returns the function name.
proc getFunctionName*(self: NCV8Value): string =
  self.wrapCall(get_function_name, result)

# Returns the function handler or NULL if not a CEF-created function.
proc getFunctionHandler*(self: NCV8Value): NCV8Handler =
  self.wrapCall(get_function_handler, result)

# Execute the function using the current V8 context. This function should
# only be called from within the scope of a NCV8Handler or
# NCV8Accessor callback, or in combination with calling enter() and
# exit() on a stored NCV8Context reference. |object| is the receiver
# ('this' object) of the function. If |object| is NULL the current context's
# global object will be used. |arguments| is the list of arguments that will
# be passed to the function. Returns the function return value on success.
# Returns NULL if this function is called incorrectly or an exception is
# thrown.
proc executeFunction*(self: NCV8Value, obj: NCV8Value, args: seq[NCV8Value]): NCV8Value =
  self.wrapCall(execute_function, result, obj, args)

# Execute the function using the specified V8 context. |object| is the
# receiver ('this' object) of the function. If |object| is NULL the specified
# context's global object will be used. |arguments| is the list of arguments
# that will be passed to the function. Returns the function return value on
# success. Returns NULL if this function is called incorrectly or an
# exception is thrown.
proc executeFunctionWithContext*(self: NCV8Value, context: NCV8Context,
  obj: NCV8Value, args: seq[NCV8Value]): NCV8Value =
  self.wrapCall(execute_function_with_context, result, context, obj, args)

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc isValid*(self: NCV8StackTrace): bool =
  self.wrapCall(is_valid, result)

# Returns the number of stack frames.
proc getFrameCount*(self: NCV8StackTrace): int =
  self.wrapCall(get_frame_count, result)

# Returns the stack frame at the specified 0-based index.
proc getFrame*(self: NCV8StackTrace, index: int): NCV8StackFrame =
  self.wrapCall(get_frame, result, index)

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc isValid*(self: NCV8StackFrame): bool =
  self.wrapCall(is_valid, result)

# Returns the name of the resource script that contains the function.
proc getScriptName*(self: NCV8StackFrame): string =
  self.wrapCall(get_script_name, result)

# Returns the name of the resource script that contains the function or the
# sourceURL value if the script name is undefined and its source ends with a
# "#@ sourceURL=..." string.
proc getScriptNameOrSourceUrl*(self: NCV8StackFrame): string =
  self.wrapCall(get_script_name_or_source_url, result)

# Returns the name of the function.
proc getFunctionName*(self: NCV8StackFrame): string =
  self.wrapCall(get_function_name, result)

# Returns the 1-based line number for the function call or 0 if unknown.
proc getLineNumber*(self: NCV8StackFrame): int =
  self.wrapCall(get_line_number, result)

# Returns the 1-based column offset on the line for the function call or 0 if
# unknown.
proc getColumn*(self: NCV8StackFrame): int =
  self.wrapCall(get_column, result)

# Returns true (1) if the function was compiled using eval().
proc isEval*(self: NCV8StackFrame): bool =
  self.wrapCall(is_eval, result)

# Returns true (1) if the function was called as a constructor via "new".
proc isConstructor*(self: NCV8StackFrame): bool =
  self.wrapCall(is_constructor, result)

# Register a new V8 extension with the specified JavaScript extension code and
# handler. Functions implemented by the handler are prototyped using the
# keyword 'native'. The calling of a native function is restricted to the scope
# in which the prototype of the native function is defined. This function may
# only be called on the render process main thread.
#
# Example JavaScript extension code: <pre>
#   # create the 'example' global object if it doesn't already exist.
#   if (!example)
#     example = {};
#   # create the 'example.test' global object if it doesn't already exist.
#   if (!example.test)
#     example.test = {};
#   (function() {
#     # Define the function 'example.test.myfunction'.
#     example.test.myfunction = function() {
#       # Call CefV8Handler::Execute() with the function name 'MyFunction'
#       # and no arguments.
#       native function MyFunction() =
#       return MyFunction() =
#     };
#     # Define the getter function for parameter 'example.test.myparam'.
#     example.test.__defineGetter__('myparam', function() {
#       # Call CefV8Handler::Execute() with the function name 'GetMyParam'
#       # and no arguments.
#       native function GetMyParam() =
#       return GetMyParam() =
#     }) =
#     # Define the setter function for parameter 'example.test.myparam'.
#     example.test.__defineSetter__('myparam', function(b) {
#       # Call CefV8Handler::Execute() with the function name 'SetMyParam'
#       # and a single argument.
#       native function SetMyParam() =
#       if(b) SetMyParam(b) =
#     }) =
#
#     # Extension definitions can also contain normal JavaScript variables
#     # and functions.
#     var myint = 0;
#     example.test.increment = function() {
#       myint += 1;
#       return myint;
#     };
#   })() =
# </pre> Example usage in the page: <pre>
#   # Call the function.
#   example.test.myfunction() =
#   # Set the parameter.
#   example.test.myparam = value;
#   # Get the parameter.
#   value = example.test.myparam;
#   # Call another function.
#   example.test.increment() =
# </pre>

proc ncRegisterExtension*(extension_name: string,
  javascript_code: string, handler: NCV8Handler): bool =
  wrapProc(cef_register_extension, result, extension_name, javascript_code, handler)

# Returns the current (top) context object in the V8 context stack.
proc ncV8ContexGetCurrentContext*(): NCV8Context =
  wrapProc(cef_v8context_get_current_context, result)

# Returns the entered (bottom) context object in the V8 context stack.
proc ncV8ContextGetEnteredContext*(): NCV8Context =
  wrapProc(cef_v8context_get_entered_context, result)

# Returns true (1) if V8 is currently inside a context.
proc ncV8ContextInContext*(): bool =
  wrapProc(cef_v8context_in_context, result)

# Create a new NCV8Value object of type undefined.
proc ncV8ValueCreateUndefined*(): NCV8Value =
  wrapProc(cef_v8value_create_undefined, result)

# Create a new NCV8Value object of type null.
proc ncV8ValueCreateNull*(): NCV8Value =
  wrapProc(cef_v8value_create_null, result)

# Create a new NCV8Value object of type bool.
proc ncV8ValueCreateBool*(value: bool): NCV8Value =
  wrapProc(cef_v8value_create_bool, result, value)

# Create a new NCV8Value object of type cint.
proc ncV8ValueCreateInt*(value: int32): NCV8Value =
  wrapProc(cef_v8value_create_int, result, value)

# Create a new NCV8Value object of type unsigned cint.
proc ncV8ValueCreateUint*(value: uint32): NCV8Value =
  wrapProc(cef_v8value_create_uint, result, value)

# Create a new NCV8Value object of type double.
proc ncV8ValueCreateDouble*(value: float64): NCV8Value =
  wrapProc(cef_v8value_create_double, result, value)

# Create a new NCV8Value object of type Date. This function should only be
# called from within the scope of a NCRenderProcessHandler,
# NCV8Handler or NCV8Accessor callback, or in combination with calling
# enter() and exit() on a stored NCV8Context reference.
proc ncV8ValueCreateDate*(value: NCTime): NCV8Value =
  wrapProc(cef_v8value_create_date, result, value)

# Create a new NCV8Value object of type string.
proc ncV8ValueCreateString*(value: string): NCV8Value =
  wrapProc(cef_v8value_create_string, result, value)

# Create a new NCV8Value object of type object with optional accessor. This
# function should only be called from within the scope of a
# NCRenderProcessHandler, NCV8Handler or NCV8Accessor callback,
# or in combination with calling enter() and exit() on a stored NCV8Context
# reference.
proc ncV8ValueCreateObject*(accessor: NCV8Accessor): NCV8Value =
  wrapProc(cef_v8value_create_object, result, accessor)

# Create a new NCV8Value object of type array with the specified |length|.
# If |length| is negative the returned array will have length 0. This function
# should only be called from within the scope of a
# NCRenderProcessHandler, NCV8Handler or NCV8Accessor callback,
# or in combination with calling enter() and exit() on a stored NCV8Context
# reference.
proc ncV8ValueCreateArray*(length: int): NCV8Value =
  wrapProc(cef_v8value_create_array, result, length)

# Create a new NCV8Value object of type function. This function should only
# be called from within the scope of a NCRenderProcessHandler,
# NCV8Handler or NCV8Accessor callback, or in combination with calling
# enter() and exit() on a stored NCV8Context reference.
proc ncV8ValueCreateFunction*(name: string, handler: NCV8Handler): NCV8Value =
  wrapProc(cef_v8value_create_function, result, name, handler)

# Returns the stack trace for the currently active context. |frame_limit| is
# the maximum number of frames that will be captured.
proc ncV8StackTraceGetCurrent*(frame_limit: int): NCV8StackTrace =
  wrapProc(cef_v8stack_trace_get_current, result, frame_limit)