import cef_base, cef_task, cef_time
include cef_import

type
  # Structure representing a V8 context handle. V8 handles can only be accessed
  # from the thread on which they are created. Valid threads for creating a V8
  # handle include the render process main thread (TID_RENDERER) and WebWorker
  # threads. A task runner for posting tasks on the associated thread can be
  # retrieved via the cef_v8context_t::get_task_runner() function.
  cef_v8context* = object
    # Base structure.
    base* : cef_base

    # Returns the task runner associated with this context. V8 handles can only
    # be accessed from the thread on which they are created. This function can be
    # called on any render process thread.
    get_task_runner*: proc(self: ptr cef_v8context): ptr cef_task_runner {.cef_callback.}
  
    # Returns true (1) if the underlying handle is valid and it can be accessed
    # on the current thread. Do not call any other functions if this function
    # returns false (0).
    is_valid*: proc(self: ptr cef_v8context): cint {.cef_callback.}
  
    # Returns the browser for this context. This function will return an NULL
    # reference for WebWorker contexts.
    get_browser*: proc(self: ptr cef_v8context): ptr_cef_browser {.cef_callback.}
  
    # Returns the frame for this context. This function will return an NULL
    # reference for WebWorker contexts.
    get_frame*: proc(self: ptr cef_v8context): ptr_cef_frame {.cef_callback.}
  
    # Returns the global object for this context. The context must be entered
    # before calling this function.
    get_global*: proc(self: ptr cef_v8context): ptr cef_v8value {.cef_callback.}
  
    # Enter this context. A context must be explicitly entered before creating a
    # V8 Object, Array, Function or Date asynchronously. exit() must be called
    # the same number of times as enter() before releasing this context. V8
    # objects belong to the context in which they are created. Returns true (1)
    # if the scope was entered successfully.
    enter*: proc(self: ptr cef_v8context): cint {.cef_callback.}
  
    # Exit this context. Call this function only after calling enter(). Returns
    # true (1) if the scope was exited successfully.
    exit*: proc(self: ptr cef_v8context): cint {.cef_callback.}
  
    # Returns true (1) if this object is pointing to the same handle as |that|
    # object.
    is_same*: proc(self, that: ptr cef_v8context): cint {.cef_callback.}
  
    # Evaluates the specified JavaScript code using this context's global object.
    # On success |retval| will be set to the return value, if any, and the
    # function will return true (1). On failure |exception| will be set to the
    # exception, if any, and the function will return false (0).
    eval*: proc(self: ptr cef_v8context,
      code: ptr cef_string, retval: ptr ptr cef_v8value,
      exception: ptr ptr cef_v8exception): cint {.cef_callback.}

  # Structure that should be implemented to handle V8 function calls. The
  # functions of this structure will be called on the thread associated with the
  # V8 function.
  cef_v8handler* = object
    # Base structure.
    base* : cef_base

    # Handle execution of the function identified by |name|. |object| is the
    # receiver ('this' object) of the function. |arguments| is the list of
    # arguments passed to the function. If execution succeeds set |retval| to the
    # function return value. If execution fails set |exception| to the exception
    # that will be thrown. Return true (1) if execution was handled.
    execute*: proc(self: ptr cef_v8handler,
      name: ptr cef_string, obj: ptr cef_v8value,
      argumentsCount: csize, arguments: ptr ptr cef_v8value,
      retval: ptr ptr cef_v8value, exception: ptr cef_string): cint {.cef_callback.}

  # Structure that should be implemented to handle V8 accessor calls. Accessor
  # identifiers are registered by calling cef_v8value_t::set_value(). The
  # functions of this structure will be called on the thread associated with the
  # V8 accessor.
  cef_v8accessor* = object
    # Base structure.
    base* : cef_base

    # Handle retrieval the accessor value identified by |name|. |object| is the
    # receiver ('this' object) of the accessor. If retrieval succeeds set
    # |retval| to the return value. If retrieval fails set |exception| to the
    # exception that will be thrown. Return true (1) if accessor retrieval was
    # handled.
    get_value*: proc(self: ptr cef_v8accessor,
      name: ptr cef_string, obj: ptr cef_v8value,
      retval: ptr ptr cef_v8value, exception: ptr cef_string): cint {.cef_callback.}
  
    # Handle assignment of the accessor value identified by |name|. |object| is
    # the receiver ('this' object) of the accessor. |value| is the new value
    # being assigned to the accessor. If assignment fails set |exception| to the
    # exception that will be thrown. Return true (1) if accessor assignment was
    # handled.
    set_value*: proc(self: ptr cef_v8accessor,
      name: ptr cef_string, obj: ptr cef_v8value,
      value: ptr cef_v8value, exception: ptr cef_string): cint {.cef_callback.}

  # Structure representing a V8 exception. The functions of this structure may be
  # called on any render process thread.
  cef_v8exception* = object
    # Base structure.
    base* : cef_base

    # Returns the exception message.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_message*: proc(self: ptr cef_v8exception): cef_string_userfree {.cef_callback.}

    # Returns the line of source code that the exception occurred within.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_source_line*: proc(self: ptr cef_v8exception): cef_string_userfree {.cef_callback.}

    # Returns the resource name for the script from where the function causing
    # the error originates.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_script_resource_name*: proc(self: ptr cef_v8exception): cef_string_userfree {.cef_callback.}

    # Returns the 1-based number of the line where the error occurred or 0 if the
    # line number is unknown.
    get_line_number*: proc(self: ptr cef_v8exception): cint {.cef_callback.}

    # Returns the index within the script of the first character where the error
    # occurred.
    get_start_position*: proc(self: ptr cef_v8exception): cint {.cef_callback.}

    # Returns the index within the script of the last character where the error
    # occurred.
    get_end_position*: proc(self: ptr cef_v8exception): cint {.cef_callback.}
  
    # Returns the index within the line of the first character where the error
    # occurred.
    get_start_column*: proc(self: ptr cef_v8exception): cint {.cef_callback.}

    # Returns the index within the line of the last character where the error
    # occurred.
    get_end_column*: proc(self: ptr cef_v8exception): cint {.cef_callback.}

  # Structure representing a V8 value handle. V8 handles can only be accessed
  # from the thread on which they are created. Valid threads for creating a V8
  # handle include the render process main thread (TID_RENDERER) and WebWorker
  # threads. A task runner for posting tasks on the associated thread can be
  # retrieved via the cef_v8context_t::get_task_runner() function.
  cef_v8value* = object
    # Base structure.
    base* : cef_base
    
    # Returns true (1) if the underlying handle is valid and it can be accessed
    # on the current thread. Do not call any other functions if this function
    # returns false (0).
    is_valid*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # True if the value type is undefined.
    is_undefined*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # True if the value type is null.
    is_null*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # True if the value type is bool.
    is_bool*: proc(self: ptr cef_v8value): cint {.cef_callback.}
  
    # True if the value type is cint.
    is_int*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # True if the value type is unsigned cint.
    is_uint*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # True if the value type is double.
    is_double*: proc(self: ptr cef_v8value): cint {.cef_callback.}
  
    # True if the value type is Date.
    is_date*: proc(self: ptr cef_v8value): cint {.cef_callback.}
  
    # True if the value type is string.
    is_string*: proc(self: ptr cef_v8value): cint {.cef_callback.}
    
    # True if the value type is object.
    is_object*: proc(self: ptr cef_v8value): cint {.cef_callback.}
  
    # True if the value type is array.
    is_array*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # True if the value type is function.
    is_function*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # Returns true (1) if this object is pointing to the same handle as |that|
    # object.
    is_same*: proc(self, that: ptr cef_v8value): cint {.cef_callback.}

    # Return a bool value.  The underlying data will be converted to if
    # necessary.
    get_bool_value*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # Return an cint value.  The underlying data will be converted to if
    # necessary.
    get_int_value*: proc(self: ptr cef_v8value): int32 {.cef_callback.}

    # Return an unisgned cint value.  The underlying data will be converted to if
    # necessary.
    get_uint_value*: proc(self: ptr cef_v8value): uint32 {.cef_callback.}

    # Return a double value.  The underlying data will be converted to if
    # necessary.
    get_double_value*: proc(self: ptr cef_v8value): cdouble {.cef_callback.}

    # Return a Date value.  The underlying data will be converted to if
    # necessary.
    get_date_value*: proc(self: ptr cef_v8value): cef_time {.cef_callback.}

    # Return a string value.  The underlying data will be converted to if
    # necessary.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_string_value*: proc(self: ptr cef_v8value): cef_string_userfree {.cef_callback.}

    # OBJECT METHODS - These functions are only available on objects. Arrays and
    # functions are also objects. String- and integer-based keys can be used
    # interchangably with the framework converting between them as necessary.

    # Returns true (1) if this is a user created object.
    is_user_created*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # Returns true (1) if the last function call resulted in an exception. This
    # attribute exists only in the scope of the current CEF value object.
    has_exception*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # Returns the exception resulting from the last function call. This attribute
    # exists only in the scope of the current CEF value object.
    get_exception*: proc(self: ptr cef_v8value): ptr cef_v8exception {.cef_callback.}

    # Clears the last exception and returns true (1) on success.
    clear_exception*: proc(self: ptr cef_v8value): cint {.cef_callback.}
  
    # Returns true (1) if this object will re-throw future exceptions. This
    # attribute exists only in the scope of the current CEF value object.
    will_rethrow_exceptions*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # Set whether this object will re-throw future exceptions. By default
    # exceptions are not re-thrown. If a exception is re-thrown the current
    # context should not be accessed again until after the exception has been
    # caught and not re-thrown. Returns true (1) on success. This attribute
    # exists only in the scope of the current CEF value object.
    set_rethrow_exceptions*: proc(self: ptr cef_v8value, rethrow: cint): cint {.cef_callback.}

    # Returns true (1) if the object has a value with the specified identifier.
    has_value_bykey*: proc(self: ptr cef_v8value, key: ptr cef_string): cint {.cef_callback.}

    # Returns true (1) if the object has a value with the specified identifier.
    has_value_byindex*: proc(self: ptr cef_v8value, index: cint): cint {.cef_callback.}

    # Deletes the value with the specified identifier and returns true (1) on
    # success. Returns false (0) if this function is called incorrectly or an
    # exception is thrown. For read-only and don't-delete values this function
    # will return true (1) even though deletion failed.
    delete_value_bykey*: proc(self: ptr cef_v8value, key: ptr cef_string): cint {.cef_callback.}
  
    # Deletes the value with the specified identifier and returns true (1) on
    # success. Returns false (0) if this function is called incorrectly, deletion
    # fails or an exception is thrown. For read-only and don't-delete values this
    # function will return true (1) even though deletion failed.
    delete_value_byindex*: proc(self: ptr cef_v8value, index: cint): cint {.cef_callback.}

    # Returns the value with the specified identifier on success. Returns NULL if
    # this function is called incorrectly or an exception is thrown.
    get_value_bykey*: proc(self: ptr cef_v8value, key: ptr cef_string): ptr cef_v8value {.cef_callback.}

    # Returns the value with the specified identifier on success. Returns NULL if
    # this function is called incorrectly or an exception is thrown.
    get_value_byindex*: proc(self: ptr cef_v8value, index: cint): ptr cef_v8value {.cef_callback.}

    # Associates a value with the specified identifier and returns true (1) on
    # success. Returns false (0) if this function is called incorrectly or an
    # exception is thrown. For read-only values this function will return true
    # (1) even though assignment failed.
    set_value_bykey*: proc(self: ptr cef_v8value,
      key: ptr cef_string, value: ptr cef_v8value,
      attribute: cef_v8_propertyattribute): cint {.cef_callback.}

    # Associates a value with the specified identifier and returns true (1) on
    # success. Returns false (0) if this function is called incorrectly or an
    # exception is thrown. For read-only values this function will return true
    # (1) even though assignment failed.
    set_value_byindex*: proc(self: ptr cef_v8value, index: cint,
      value: ptr cef_v8value): cint {.cef_callback.}
  
    # Registers an identifier and returns true (1) on success. Access to the
    # identifier will be forwarded to the cef_v8accessor_t instance passed to
    # cef_v8value_t::cef_v8value_create_object(). Returns false (0) if this
    # function is called incorrectly or an exception is thrown. For read-only
    # values this function will return true (1) even though assignment failed.
    set_value_byaccessor*: proc(self: ptr cef_v8value,
      key: ptr cef_string, settings: cef_v8_accesscontrol,
      attribute: cef_v8_propertyattribute): cint {.cef_callback.}

    # Read the keys for the object's values into the specified vector. Integer-
    # based keys will also be returned as strings.
    get_keys*: proc(self: ptr cef_v8value,
      keys: cef_string_list): cint {.cef_callback.}

    # Sets the user data for this object and returns true (1) on success. Returns
    # false (0) if this function is called incorrectly. This function can only be
    # called on user created objects.
    set_user_data*: proc(self: ptr cef_v8value,
      user_data: ptr cef_base): cint {.cef_callback.}

    # Returns the user data, if any, assigned to this object.
    get_user_data*: proc(self: ptr cef_v8value): ptr cef_base {.cef_callback.}
  
    # Returns the amount of externally allocated memory registered for the
    # object.
    get_externally_allocated_memory*: proc(self: ptr cef_v8value): cint {.cef_callback.}

    # Adjusts the amount of registered external memory for the object. Used to
    # give V8 an indication of the amount of externally allocated memory that is
    # kept alive by JavaScript objects. V8 uses this information to decide when
    # to perform global garbage collection. Each cef_v8value_t tracks the amount
    # of external memory associated with it and automatically decreases the
    # global total by the appropriate amount on its destruction.
    # |change_in_bytes| specifies the number of bytes to adjust by. This function
    # returns the number of bytes associated with the object after the
    # adjustment. This function can only be called on user created objects.
    adjust_externally_allocated_memory*: proc(self: ptr cef_v8value, change_in_bytes: cint): cint {.cef_callback.}

    # ARRAY METHODS - These functions are only available on arrays.
    # Returns the number of elements in the array.
    get_array_length*: proc(self: ptr cef_v8value): cint {.cef_callback.}
  
    # FUNCTION METHODS - These functions are only available on functions.
    # Returns the function name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_function_name*: proc(self: ptr cef_v8value): cef_string_userfree {.cef_callback.}

    # Returns the function handler or NULL if not a CEF-created function.
    get_function_handler*: proc(self: ptr cef_v8value): ptr cef_v8handler {.cef_callback.}

    # Execute the function using the current V8 context. This function should
    # only be called from within the scope of a cef_v8handler_t or
    # cef_v8accessor_t callback, or in combination with calling enter() and
    # exit() on a stored cef_v8context_t reference. |object| is the receiver
    # ('this' object) of the function. If |object| is NULL the current context's
    # global object will be used. |arguments| is the list of arguments that will
    # be passed to the function. Returns the function return value on success.
    # Returns NULL if this function is called incorrectly or an exception is
    # thrown.
    execute_function*: proc(self: ptr cef_v8value, obj: ptr cef_v8value,
      argumentsCount: csize, arguments: ptr ptr cef_v8value): ptr cef_v8value {.cef_callback.}

    # Execute the function using the specified V8 context. |object| is the
    # receiver ('this' object) of the function. If |object| is NULL the specified
    # context's global object will be used. |arguments| is the list of arguments
    # that will be passed to the function. Returns the function return value on
    # success. Returns NULL if this function is called incorrectly or an
    # exception is thrown.
    execute_function_with_context*: proc(self: ptr cef_v8value, context: ptr cef_v8context,
      obj: ptr cef_v8value, argumentsCount: csize,
      arguments: ptr ptr cef_v8value): ptr cef_v8value {.cef_callback.}

  # Structure representing a V8 stack trace handle. V8 handles can only be
  # accessed from the thread on which they are created. Valid threads for
  # creating a V8 handle include the render process main thread (TID_RENDERER)
  # and WebWorker threads. A task runner for posting tasks on the associated
  # thread can be retrieved via the cef_v8context_t::get_task_runner() function.
  cef_v8stack_trace* = object
    # Base structure.
    base* : cef_base

    # Returns true (1) if the underlying handle is valid and it can be accessed
    # on the current thread. Do not call any other functions if this function
    # returns false (0).
    is_valid*: proc(self: ptr cef_v8stack_trace): cint {.cef_callback.}
  
    # Returns the number of stack frames.
    get_frame_count*: proc(self: ptr cef_v8stack_trace): cint {.cef_callback.}

    # Returns the stack frame at the specified 0-based index.
    get_frame*: proc(self: ptr cef_v8stack_trace, index: cint): ptr cef_v8stack_frame {.cef_callback.}

  # Structure representing a V8 stack frame handle. V8 handles can only be
  # accessed from the thread on which they are created. Valid threads for
  # creating a V8 handle include the render process main thread (TID_RENDERER)
  # and WebWorker threads. A task runner for posting tasks on the associated
  # thread can be retrieved via the cef_v8context_t::get_task_runner() function.
  cef_v8stack_frame* = object
    # Base structure.
    base* : cef_base

    # Returns true (1) if the underlying handle is valid and it can be accessed
    # on the current thread. Do not call any other functions if this function
    # returns false (0).
    is_valid*: proc(self: ptr cef_v8stack_frame): cint {.cef_callback.}

    # Returns the name of the resource script that contains the function.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_script_name*: proc(self: ptr cef_v8stack_frame): cef_string_userfree {.cef_callback.}

    # Returns the name of the resource script that contains the function or the
    # sourceURL value if the script name is undefined and its source ends with a
    # "#@ sourceURL=..." string.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_script_name_or_source_url*: proc(self: ptr cef_v8stack_frame): cef_string_userfree {.cef_callback.}


    # Returns the name of the function.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_function_name*: proc(self: ptr cef_v8stack_frame): cef_string_userfree {.cef_callback.}

    # Returns the 1-based line number for the function call or 0 if unknown.
    get_line_number*: proc(self: ptr cef_v8stack_frame): cint {.cef_callback.}

    # Returns the 1-based column offset on the line for the function call or 0 if
    # unknown.
    get_column*: proc(self: ptr cef_v8stack_frame): cint {.cef_callback.}

    # Returns true (1) if the function was compiled using eval().
    is_eval*: proc(self: ptr cef_v8stack_frame): cint {.cef_callback.}

    # Returns true (1) if the function was called as a constructor via "new".
    is_constructor*: proc(self: ptr cef_v8stack_frame): cint {.cef_callback.}

    
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
#       native function MyFunction() {.cef_callback.}
#       return MyFunction() {.cef_callback.}
#     };
#     # Define the getter function for parameter 'example.test.myparam'.
#     example.test.__defineGetter__('myparam', function() {
#       # Call CefV8Handler::Execute() with the function name 'GetMyParam'
#       # and no arguments.
#       native function GetMyParam() {.cef_callback.}
#       return GetMyParam() {.cef_callback.}
#     }) {.cef_callback.}
#     # Define the setter function for parameter 'example.test.myparam'.
#     example.test.__defineSetter__('myparam', function(b) {
#       # Call CefV8Handler::Execute() with the function name 'SetMyParam'
#       # and a single argument.
#       native function SetMyParam() {.cef_callback.}
#       if(b) SetMyParam(b) {.cef_callback.}
#     }) {.cef_callback.}
#
#     # Extension definitions can also contain normal JavaScript variables
#     # and functions.
#     var myint = 0;
#     example.test.increment = function() {
#       myint += 1;
#       return myint;
#     };
#   })() {.cef_callback.}
# </pre> Example usage in the page: <pre>
#   # Call the function.
#   example.test.myfunction() {.cef_callback.}
#   # Set the parameter.
#   example.test.myparam = value;
#   # Get the parameter.
#   value = example.test.myparam;
#   # Call another function.
#   example.test.increment() {.cef_callback.}
# </pre>

proc cef_register_extension*(extension_name: ptr cef_string,
  javascript_code: ptr cef_string, handler: ptr cef_v8handler): cint {.cef_import.}
    
# Returns the current (top) context object in the V8 context stack.
proc cef_v8context_get_current_context*(): ptr cef_v8context {.cef_import.}

# Returns the entered (bottom) context object in the V8 context stack.
proc cef_v8context_get_entered_context*(): ptr cef_v8context {.cef_import.}

# Returns true (1) if V8 is currently inside a context.
proc cef_v8context_in_context*(): cint {.cef_import.}

# Create a new cef_v8value_t object of type undefined.
proc cef_v8value_create_undefined*(): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type null.
proc cef_v8value_create_null*(): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type bool.
proc cef_v8value_create_bool*(value: cint): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type cint.
proc cef_v8value_create_int*(value: int32): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type unsigned cint.
proc cef_v8value_create_uint*(value: uint32): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type double.
proc cef_v8value_create_double*(value: cdouble): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type Date. This function should only be
# called from within the scope of a cef_render_process_handler_t,
# cef_v8handler_t or cef_v8accessor_t callback, or in combination with calling
# enter() and exit() on a stored cef_v8context_t reference.
proc cef_v8value_create_date*(date: ptr cef_time): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type string.
proc cef_v8value_create_string*(value: ptr cef_string): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type object with optional accessor. This
# function should only be called from within the scope of a
# cef_render_process_handler_t, cef_v8handler_t or cef_v8accessor_t callback,
# or in combination with calling enter() and exit() on a stored cef_v8context_t
# reference.
proc cef_v8value_create_object*(accessor: ptr cef_v8accessor): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type array with the specified |length|.
# If |length| is negative the returned array will have length 0. This function
# should only be called from within the scope of a
# cef_render_process_handler_t, cef_v8handler_t or cef_v8accessor_t callback,
# or in combination with calling enter() and exit() on a stored cef_v8context_t
# reference.
proc cef_v8value_create_array*(length: cint): ptr cef_v8value {.cef_import.}

# Create a new cef_v8value_t object of type function. This function should only
# be called from within the scope of a cef_render_process_handler_t,
# cef_v8handler_t or cef_v8accessor_t callback, or in combination with calling
# enter() and exit() on a stored cef_v8context_t reference.
proc cef_v8value_create_function*(name: ptr cef_string,
    handler: ptr cef_v8handler): ptr cef_v8value {.cef_import.}
    
# Returns the stack trace for the currently active context. |frame_limit| is
# the maximum number of frames that will be captured.
proc cef_v8stack_trace_get_current*(frame_limit: cint): ptr cef_v8stack_trace {.cef_import.}
