import cef/cef_v8_api, cef/cef_task_api, nc_types, nc_util, cef/cef_time_api

type
  # Structure representing a V8 context handle. V8 handles can only be accessed
  # from the thread on which they are created. Valid threads for creating a V8
  # handle include the render process main thread (TID_RENDERER) and WebWorker
  # threads. A task runner for posting tasks on the associated thread can be
  # retrieved via the cef_v8context_t::get_task_runner() function.
  NCV8Context* = ptr cef_v8context
  
  # Structure that should be implemented to handle V8 function calls. The
  # functions of this structure will be called on the thread associated with the
  # V8 function.
  NCV8Handler* = ptr cef_v8handler
    
  # Structure that should be implemented to handle V8 accessor calls. Accessor
  # identifiers are registered by calling cef_v8value_t::set_value(). The
  # functions of this structure will be called on the thread associated with the
  # V8 accessor.
  NCV8Accessor* = ptr cef_v8accessor
  
  # Structure representing a V8 exception. The functions of this structure may be
  # called on any render process thread.
  NCV8Exception* = ptr cef_v8exception
  
  # Structure representing a V8 value handle. V8 handles can only be accessed
  # from the thread on which they are created. Valid threads for creating a V8
  # handle include the render process main thread (TID_RENDERER) and WebWorker
  # threads. A task runner for posting tasks on the associated thread can be
  # retrieved via the cef_v8context_t::get_task_runner() function.
  NCV8Value* = ptr cef_v8value
  
  # Structure representing a V8 stack trace handle. V8 handles can only be
  # accessed from the thread on which they are created. Valid threads for
  # creating a V8 handle include the render process main thread (TID_RENDERER)
  # and WebWorker threads. A task runner for posting tasks on the associated
  # thread can be retrieved via the cef_v8context_t::get_task_runner() function.
  NCV8StackTrace* = ptr cef_v8stacktrace
  
  # Structure representing a V8 stack frame handle. V8 handles can only be
  # accessed from the thread on which they are created. Valid threads for
  # creating a V8 handle include the render process main thread (TID_RENDERER)
  # and WebWorker threads. A task runner for posting tasks on the associated
  # thread can be retrieved via the cef_v8context_t::get_task_runner() function.
  NCV8StackFrame* = ptr cef_v8stackframe

# Returns the task runner associated with this context. V8 handles can only
# be accessed from the thread on which they are created. This function can be
# called on any render process thread.
proc GetTaskRunner*(self: NCV8Context): ptr cef_task_runner =
  result = self.get_task_runner(self)

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc IsValid*(self: NCV8Context): bool =
  result = self.is_valid(self) == 1.cint
  
# Returns the browser for this context. This function will return an NULL
# reference for WebWorker contexts.
proc GetBrowser*(self: NCV8Context): NCBrowser =
  result = cast[NCBrowser](self.get_browser(self))

# Returns the frame for this context. This function will return an NULL
# reference for WebWorker contexts.
proc GetFrame*(self: NCV8Context): NCFrame =
  result = cast[NCFrame](self.get_frame(self))

# Returns the global object for this context. The context must be entered
# before calling this function.
proc GetGlobal*(self: NCV8Context): NCV8Value =
  result = self.get_global(self)

# Enter this context. A context must be explicitly entered before creating a
# V8 Object, Array, Function or Date asynchronously. exit() must be called
# the same number of times as enter() before releasing this context. V8
# objects belong to the context in which they are created. Returns true (1)
# if the scope was entered successfully.
proc Enter*(self: NCV8Context): bool =
  result = self.enter(self) == 1.cint

# Exit this context. Call this function only after calling enter(). Returns
# true (1) if the scope was exited successfully.
proc Exit*(self: NCV8Context): bool =
  result = self.exit(self) == 1.cint

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc IsSame*(self, that: NCV8Context): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Evaluates the specified JavaScript code using this context's global object.
# On success |retval| will be set to the return value, if any, and the
# function will return true (1). On failure |exception| will be set to the
# exception, if any, and the function will return false (0).
proc Eval*(self: NCV8Context, code: string, retval: var NCV8Value, exception: var NCV8Exception): bool =
  let ccode = to_cef_string(code)
  result = self.eval(self, ccode, retval, exception) == 1.cint
  cef_string_userfree_free(ccode)

# Handle execution of the function identified by |name|. |object| is the
# receiver ('this' object) of the function. |arguments| is the list of
# arguments passed to the function. If execution succeeds set |retval| to the
# function return value. If execution fails set |exception| to the exception
# that will be thrown. Return true (1) if execution was handled.
proc Execute*(self: NCV8Handler, name: string, obj: NCV8Value, args: seq[NCV8Value],
  retval: var NCV8Value, exception: string): bool =
  add_ref(obj)
  for c in args: add_ref(c)
  let cname = to_cef_string(name)
  let cexception = to_cef_string(exception)
  result = self.execute(self, cname, obj, args.len.csize, cast[ptr NCV8Value](args[0].unsafeAddr), retval, cexception) == 1.cint
  cef_string_userfree_free(cname)
  cef_string_userfree_free(cexception)

# Handle retrieval the accessor value identified by |name|. |object| is the
# receiver ('this' object) of the accessor. If retrieval succeeds set
# |retval| to the return value. If retrieval fails set |exception| to the
# exception that will be thrown. Return true (1) if accessor retrieval was
# handled.
proc GetValue*(self: NCV8Accessor, name: string, obj: NCV8Value,
  retval: var NCV8Value, exception: string): bool =
  add_ref(obj)
  let cname = to_cef_string(name)
  let cexception = to_cef_string(exception)
  result = self.get_value(self, cname, obj, retval, cexception) == 1.cint
  cef_string_userfree_free(cname)
  cef_string_userfree_free(cexception)
  
# Handle assignment of the accessor value identified by |name|. |object| is
# the receiver ('this' object) of the accessor. |value| is the new value
# being assigned to the accessor. If assignment fails set |exception| to the
# exception that will be thrown. Return true (1) if accessor assignment was
# handled.
proc SetValue*(self: NCV8Accessor, name: string, obj: NCV8Value,
  value: NCV8Value, exception: string): bool =
  add_ref(obj)
  add_ref(value)
  let cname = to_cef_string(name)
  let cexception = to_cef_string(exception)
  result = self.set_value(self, cname, obj, value, cexception) == 1.cint
  cef_string_userfree_free(cname)
  cef_string_userfree_free(cexception)

# Returns the exception message.
# The resulting string must be freed by calling string_free().
proc GetMessage*(self: NCV8Exception): string =
  result = to_nim_string(self.get_message(self))

# Returns the line of source code that the exception occurred within.
# The resulting string must be freed by calling string_free().
proc GetSourceLine*(self: NCV8Exception): string =
  result = to_nim_string(self.get_source_line(self))

# Returns the resource name for the script from where the function causing
# the error originates.
# The resulting string must be freed by calling string_free().
proc GetScriptResourceName*(self: NCV8Exception): string =
  result = to_nim_string(self.get_script_resource_name(self))

# Returns the 1-based number of the line where the error occurred or 0 if the
# line number is unknown.
proc GetLineNumber*(self: NCV8Exception): int =
  result = self.get_line_number(self).cint

# Returns the index within the script of the first character where the error
# occurred.
proc GetStartPosition*(self: NCV8Exception): int =
  result = self.get_start_position(self).cint

# Returns the index within the script of the last character where the error
# occurred.
proc GetEndPosition*(self: NCV8Exception): int =
  result = self.get_end_position(self).cint

# Returns the index within the line of the first character where the error
# occurred.
proc GetStartColumn*(self: NCV8Exception): int =
  result = self.get_start_column(self).cint

# Returns the index within the line of the last character where the error
# occurred.
proc GetEndColumn*(self: NCV8Exception): int =
  result = self.get_end_column(self).cint

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc IsValid*(self: NCV8Value): bool =
  result = self.is_valid(self) == 1.cint

# True if the value type is undefined.
proc IsUndefined*(self: NCV8Value): bool =
  result = self.is_undefined(self) == 1.cint

# True if the value type is null.
proc IsNull*(self: NCV8Value): bool =
  result = self.is_null(self) == 1.cint

# True if the value type is bool.
proc IsNool*(self: NCV8Value): bool =
  result = self.is_bool(self) == 1.cint

# True if the value type is cint.
proc IsInt*(self: NCV8Value): bool =
  result = self.is_int(self) == 1.cint

# True if the value type is unsigned cint.
proc IsUint*(self: NCV8Value): bool =
  result = self.is_uint(self) == 1.cint

# True if the value type is double.
proc IsDouble*(self: NCV8Value): bool =
  result = self.is_double(self) == 1.cint

# True if the value type is Date.
proc IsDate*(self: NCV8Value): bool =
  result = self.is_date(self) == 1.cint

# True if the value type is string.
proc IsString*(self: NCV8Value): bool =
  result = self.is_string(self) == 1.cint

# True if the value type is object.
proc IsObject*(self: NCV8Value): bool =
  result = self.is_object(self) == 1.cint

# True if the value type is array.
proc IsArray*(self: NCV8Value): bool =
  result = self.is_array(self) == 1.cint

# True if the value type is function.
proc IsFunction*(self: NCV8Value): bool =
  result = self.is_function(self) == 1.cint

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc IsSame*(self, that: NCV8Value): bool =
  result = self.is_same(self, that) == 1.cint

# Return a bool value.  The underlying data will be converted to if
# necessary.
proc GetBoolValue*(self: NCV8Value): bool =
  result = self.get_bool_value(self) == 1.cint

# Return an cint value.  The underlying data will be converted to if
# necessary.
proc GetIntValue*(self: NCV8Value): int32 =
  result = self.get_int_value(self).int32

# Return an unisgned cint value.  The underlying data will be converted to if
# necessary.
proc GetUintValue*(self: NCV8Value): uint32 =
  result = self.get_uint_value(self).uint32

# Return a double value.  The underlying data will be converted to if
# necessary.
proc GetDoubleValue*(self: NCV8Value): float64 =
  result = self.get_double_value(self).float64

# Return a Date value.  The underlying data will be converted to if
# necessary.
proc GetDateValue*(self: NCV8Value): cef_time =
  result = self.get_date_value(self)

# Return a string value.  The underlying data will be converted to if
# necessary.
# The resulting string must be freed by calling string_free().
proc GetStringValue*(self: NCV8Value): string =
  result = to_nim_string(self.get_string_value(self))

# OBJECT METHODS - These functions are only available on objects. Arrays and
# functions are also objects. String- and integer-based keys can be used
# interchangably with the framework converting between them as necessary.

# Returns true (1) if this is a user created object.
proc IsUserCreated*(self: NCV8Value): bool =
  result = self.is_user_created(self) == 1.cint

# Returns true (1) if the last function call resulted in an exception. This
# attribute exists only in the scope of the current CEF value object.
proc HasException*(self: NCV8Value): bool =
  result = self.has_exception(self) == 1.cint

# Returns the exception resulting from the last function call. This attribute
# exists only in the scope of the current CEF value object.
proc GetException*(self: NCV8Value): NCV8Exception =
  result = self.get_exception(self)

# Clears the last exception and returns true (1) on success.
proc ClearException*(self: NCV8Value): bool =
  result = self.clear_exception(self) == 1.cint

# Returns true (1) if this object will re-throw future exceptions. This
# attribute exists only in the scope of the current CEF value object.
proc WillRethrowExceptions*(self: NCV8Value): bool =
  result = self.will_rethrow_exceptions(self) == 1.cint

# Set whether this object will re-throw future exceptions. By default
# exceptions are not re-thrown. If a exception is re-thrown the current
# context should not be accessed again until after the exception has been
# caught and not re-thrown. Returns true (1) on success. This attribute
# exists only in the scope of the current CEF value object.
proc SetRethrowExceptions*(self: NCV8Value, rethrow: bool): bool =
  result = self.set_rethrow_exceptions(self, rethrow.cint) == 1.cint

# Returns true (1) if the object has a value with the specified identifier.
proc HasValueByKey*(self: NCV8Value, key: string): bool =
  let ckey = to_cef_string(key)
  result = self.has_ValueByKey(self, ckey) == 1.cint
  cef_string_userfree_free(ckey)

# Returns true (1) if the object has a value with the specified identifier.
proc HasValueByIndex*(self: NCV8Value, index: int): bool =
  result = self.has_ValueByIndex(self, index.cint) == 1.cint

# Deletes the value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly or an
# exception is thrown. For read-only and don't-delete values this function
# will return true (1) even though deletion failed.
proc DeleteValueByKey*(self: NCV8Value, key: string): bool =
  let ckey = to_cef_string(key)
  result = self.delete_ValueByKey(self, ckey) == 1.cint
  cef_string_userfree_free(ckey)

# Deletes the value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly, deletion
# fails or an exception is thrown. For read-only and don't-delete values this
# function will return true (1) even though deletion failed.
proc DeleteValueByIndex*(self: NCV8Value, index: int): bool =
  result = self.delete_ValueByIndex(self, index.cint) == 1.cint

# Returns the value with the specified identifier on success. Returns NULL if
# this function is called incorrectly or an exception is thrown.
proc GetValueByKey*(self: NCV8Value, key: string): NCV8Value =
  let ckey = to_cef_string(key)
  result = self.get_ValueByKey(self, ckey)
  cef_string_userfree_free(ckey)
  
# Returns the value with the specified identifier on success. Returns NULL if
# this function is called incorrectly or an exception is thrown.
proc GetValueByIndex*(self: NCV8Value, index: int): NCV8Value =
  result = self.get_ValueByIndex(self, index.cint)

# Associates a value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly or an
# exception is thrown. For read-only values this function will return true
# (1) even though assignment failed.
proc SetValueByKey*(self: NCV8Value, key: string, value: NCV8Value,
  attribute: cef_v8_propertyattribute): bool =
  add_ref(value)
  let ckey = to_cef_string(key)
  result = self.set_ValueByKey(self, ckey, value, attribute) == 1.cint
  cef_string_userfree_free(ckey)
  
# Associates a value with the specified identifier and returns true (1) on
# success. Returns false (0) if this function is called incorrectly or an
# exception is thrown. For read-only values this function will return true
# (1) even though assignment failed.
proc SetValueByIndex*(self: NCV8Value, index: int, value: NCV8Value): bool =
  add_ref(value)
  result = self.set_ValueByIndex(self, index.cint, value) == 1.cint

# Registers an identifier and returns true (1) on success. Access to the
# identifier will be forwarded to the cef_v8accessor_t instance passed to
# cef_v8value_t::cef_v8value_create_object(). Returns false (0) if this
# function is called incorrectly or an exception is thrown. For read-only
# values this function will return true (1) even though assignment failed.
proc SetValueByAccessor*(self: NCV8Value, key: string, settings: cef_v8_accesscontrol,
  attribute: cef_v8_propertyattribute): bool =
  let ckey = to_cef_string(key)
  result = self.set_ValueByAccessor(self, ckey, settings, attribute) == 1.cint
  cef_string_userfree_free(ckey)

# Read the keys for the object's values into the specified vector. Integer-
# based keys will also be returned as strings.
proc GetKeys*(self: NCV8Value, keys: var seq[string]): bool =
  var ckeys = cef_string_list_alloc()
  result = self.get_keys(self, ckeys) == 1.cint
  keys = to_nim_and_free(ckeys)

# Sets the user data for this object and returns true (1) on success. Returns
# false (0) if this function is called incorrectly. This function can only be
# called on user created objects.
proc SetUserData*(self: NCV8Value, user_data: ptr cef_base): bool =
  user_data.add_ref(user_data)
  result = self.set_user_data(self, user_data) == 1.cint

# Returns the user data, if any, assigned to this object.
proc GetUserData*(self: NCV8Value): ptr cef_base =
  result = self.get_user_data(self)

# Returns the amount of externally allocated memory registered for the
# object.
proc GetExternallyAllocatedMemory*(self: NCV8Value): int =
  result = self.get_externally_allocated_memory(self).int

# Adjusts the amount of registered external memory for the object. Used to
# give V8 an indication of the amount of externally allocated memory that is
# kept alive by JavaScript objects. V8 uses this information to decide when
# to perform global garbage collection. Each cef_v8value_t tracks the amount
# of external memory associated with it and automatically decreases the
# global total by the appropriate amount on its destruction.
# |change_in_bytes| specifies the number of bytes to adjust by. This function
# returns the number of bytes associated with the object after the
# adjustment. This function can only be called on user created objects.
proc AdjustExternallyAllocatedMemory*(self: NCV8Value, change_in_bytes: int): int =
  result = self.adjust_externally_allocated_memory(self, change_in_bytes.cint).int

# ARRAY METHODS - These functions are only available on arrays.
# Returns the number of elements in the array.
proc GetArrayLength*(self: NCV8Value): int =
  result = self.get_array_length(self).int

# FUNCTION METHODS - These functions are only available on functions.
# Returns the function name.
# The resulting string must be freed by calling string_free().
proc GetFunctionName*(self: NCV8Value): string =
  result = to_nim_string(self.get_function_name(self))

# Returns the function handler or NULL if not a CEF-created function.
proc GetFunctionHandler*(self: NCV8Value): NCV8Handler =
  result = self.get_function_handler(self)

# Execute the function using the current V8 context. This function should
# only be called from within the scope of a cef_v8handler_t or
# cef_v8accessor_t callback, or in combination with calling enter() and
# exit() on a stored cef_v8context_t reference. |object| is the receiver
# ('this' object) of the function. If |object| is NULL the current context's
# global object will be used. |arguments| is the list of arguments that will
# be passed to the function. Returns the function return value on success.
# Returns NULL if this function is called incorrectly or an exception is
# thrown.
proc ExecuteFunction*(self: NCV8Value, obj: NCV8Value, args: seq[NCV8Value]): NCV8Value =
  add_ref(obj)
  for c in args: add_ref(c)
  result = self.execute_function(self, obj, args.len.csize, cast[ptr NCV8Value](args[0].unsafeAddr))

# Execute the function using the specified V8 context. |object| is the
# receiver ('this' object) of the function. If |object| is NULL the specified
# context's global object will be used. |arguments| is the list of arguments
# that will be passed to the function. Returns the function return value on
# success. Returns NULL if this function is called incorrectly or an
# exception is thrown.
proc ExecuteFunctionWithContext*(self: NCV8Value, context: NCV8Context,
  obj: NCV8Value, args: seq[NCV8Value]): NCV8Value =
  add_ref(context)
  add_ref(obj)
  for c in args: add_ref(c)
  result = self.execute_function_with_context(self, context, obj, args.len.csize, cast[ptr NCV8Value](args[0].unsafeAddr))

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc IsValid*(self: NCV8StackTrace): bool =
  result = self.is_valid(self) == 1.cint

# Returns the number of stack frames.
proc GetFrameCount*(self: NCV8StackTrace): int =
  result = self.get_frame_count(self).int

# Returns the stack frame at the specified 0-based index.
proc GetFrame*(self: NCV8StackTrace, index: int): NCV8StackFrame =
  result = self.get_frame(self, index.cint)

# Returns true (1) if the underlying handle is valid and it can be accessed
# on the current thread. Do not call any other functions if this function
# returns false (0).
proc IsValid*(self: NCV8StackFrame): bool =
  result = self.is_valid(self) == 1.cint

# Returns the name of the resource script that contains the function.
# The resulting string must be freed by calling string_free().
proc GetScriptName*(self: NCV8StackFrame): string =
  result = to_nim_string(self.get_script_name(self))

# Returns the name of the resource script that contains the function or the
# sourceURL value if the script name is undefined and its source ends with a
# "#@ sourceURL=..." string.

# The resulting string must be freed by calling string_free().
proc GetScriptNameOrSourceUrl*(self: NCV8StackFrame): string =
  result = to_nim_string(self.get_script_name_or_source_url(self))

# Returns the name of the function.
# The resulting string must be freed by calling string_free().
proc GetFunctionName*(self: NCV8StackFrame): string =
  result = to_nim_string(self.get_function_name(self))

# Returns the 1-based line number for the function call or 0 if unknown.
proc GetLineNumber*(self: NCV8StackFrame): int =
  result = self.get_line_number(self).int

# Returns the 1-based column offset on the line for the function call or 0 if
# unknown.
proc GetColumn*(self: NCV8StackFrame): int =
  result = self.get_column(self).int

# Returns true (1) if the function was compiled using eval().
proc IsEval*(self: NCV8StackFrame): bool =
  result = self.is_eval(self) == 1.cint

# Returns true (1) if the function was called as a constructor via "new".
proc IsConstructor*(self: NCV8StackFrame): bool =
  result = self.is_constructor(self) == 1.cint

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

proc NCRegisterExtension*(extension_name: string,
  javascript_code: string, handler: NCV8Handler): bool =
  add_ref(handler)
  let cname = to_cef_string(extension_name)
  let ccode = to_cef_string(javascript_code)
  result = cef_register_extension(cname, ccode, handler) == 1.cint
  cef_string_userfree_free(cname)
  cef_string_userfree_free(ccode)
  
# Returns the current (top) context object in the V8 context stack.
proc NCV8ContexGetCurrentContext*(): NCV8Context =
  result = cef_v8context_get_current_context()

# Returns the entered (bottom) context object in the V8 context stack.
proc NCV8ContextGetEnteredContext*(): NCV8Context =
  result = cef_v8context_get_entered_context()

# Returns true (1) if V8 is currently inside a context.
proc NCV8ContextInContext*(): bool =
  result = cef_v8context_in_context() == 1.cint
  
# Create a new cef_v8value_t object of type undefined.
proc NCV8ValueCreateUndefined*(): NCV8Value =
  result = cef_v8value_create_undefined()

# Create a new cef_v8value_t object of type null.
proc NCV8ValueCreateNull*(): NCV8Value =
  result = cef_v8value_create_null()
  
# Create a new cef_v8value_t object of type bool.
proc NCV8ValueCreateBool*(value: bool): NCV8Value =
  result = cef_v8value_create_bool(value.cint)

# Create a new cef_v8value_t object of type cint.
proc NCV8ValueCreateInt*(value: int32): NCV8Value =
  result = cef_v8value_create_int(value)

# Create a new cef_v8value_t object of type unsigned cint.
proc NCV8ValueCreateUint*(value: uint32): NCV8Value =
  result = cef_v8value_create_uint(value)

# Create a new cef_v8value_t object of type double.
proc NCV8ValueCreateDouble*(value: cdouble): NCV8Value =
  result = cef_v8value_create_double(value.cdouble)
  
# Create a new cef_v8value_t object of type Date. This function should only be
# called from within the scope of a cef_render_process_handler_t,
# cef_v8handler_t or cef_v8accessor_t callback, or in combination with calling
# enter() and exit() on a stored cef_v8context_t reference.
proc NCV8ValueCreateDate*(date: ptr cef_time): NCV8Value =
  result = cef_v8value_create_date(date)

# Create a new cef_v8value_t object of type string.
proc NCV8ValueCreatestring*(value: string): NCV8Value =
  let cval = to_cef_string(value)
  result = cef_v8value_create_string(cval)
  cef_string_userfree_free(cval)

# Create a new cef_v8value_t object of type object with optional accessor. This
# function should only be called from within the scope of a
# cef_render_process_handler_t, cef_v8handler_t or cef_v8accessor_t callback,
# or in combination with calling enter() and exit() on a stored cef_v8context_t
# reference.
proc NCV8ValueCreateobject*(accessor: NCV8Accessor): NCV8Value =
  add_ref(accessor)
  result = cef_v8value_create_object(accessor)

# Create a new cef_v8value_t object of type array with the specified |length|.
# If |length| is negative the returned array will have length 0. This function
# should only be called from within the scope of a
# cef_render_process_handler_t, cef_v8handler_t or cef_v8accessor_t callback,
# or in combination with calling enter() and exit() on a stored cef_v8context_t
# reference.
proc NCV8ValueCreatearray*(length: int): NCV8Value =
  result = cef_v8value_create_array(length.cint)

# Create a new cef_v8value_t object of type function. This function should only
# be called from within the scope of a cef_render_process_handler_t,
# cef_v8handler_t or cef_v8accessor_t callback, or in combination with calling
# enter() and exit() on a stored cef_v8context_t reference.
proc NCV8ValueCreatefunction*(name: string, handler: NCV8Handler): NCV8Value =
  add_ref(handler)
  let cname = to_cef_string(name)
  result = cef_v8value_create_function(cname, handler)
  cef_string_userfree_free(cname)
  
# Returns the stack trace for the currently active context. |frame_limit| is
# the maximum number of frames that will be captured.
proc cef_v8stack_trace_get_current*(frame_limit: int): NCV8StackTrace =
  result = cef_v8stack_trace_get_current(frame_limit.cint)