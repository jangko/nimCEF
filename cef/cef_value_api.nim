import cef_base_api
include cef_import

type
  # Structure that wraps other data value types. Complex types (binary,
  # dictionary and list) will be referenced but not owned by this object. Can be
  # used on any process and thread.
  cef_value* = object
    base*: cef_base

    # Returns true (1) if the underlying data is valid. This will always be true
    # (1) for simple types. For complex types (binary, dictionary and list) the
    # underlying data may become invalid if owned by another object (e.g. list or
    # dictionary) and that other object is then modified or destroyed. This value
    # object can be re-used by calling Set*() even if the underlying data is
    # invalid.
    is_valid*: proc(self: ptr cef_value): cint {.cef_callback.}

    # Returns true (1) if the underlying data is owned by another object.
    is_owned*: proc(self: ptr cef_value): cint {.cef_callback.}

    # Returns true (1) if the underlying data is read-only. Some APIs may expose
    # read-only objects.
    is_read_only*: proc(self: ptr cef_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have the same underlying
    # data. If true (1) modifications to this object will also affect |that|
    # object and vice-versa.
    is_same*: proc(self, that: ptr cef_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have an equivalent
    # underlying value but are not necessarily the same object.
    is_equal*: proc(self, that: ptr cef_value): cint {.cef_callback.}

    # Returns a copy of this object. The underlying data will also be copied.
    copy*: proc(self: ptr cef_value): ptr cef_value {.cef_callback.}

    # Returns the underlying value type.
    get_type*: proc(self: ptr cef_value): cef_value_type {.cef_callback.}

    # Returns the underlying value as type bool.
    get_bool*: proc(self: ptr cef_value): cint {.cef_callback.}

    # Returns the underlying value as type cint.
    get_int*: proc(self: ptr cef_value): cint {.cef_callback.}

    # Returns the underlying value as type double.
    get_double*: proc(self: ptr cef_value): cdouble {.cef_callback.}

    # Returns the underlying value as type string.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_string*: proc(self: ptr cef_value): cef_string_userfree {.cef_callback.}

    # Returns the underlying value as type binary. The returned reference may
    # become invalid if the value is owned by another object or if ownership is
    # transferred to another object in the future. To maintain a reference to the
    # value after assigning ownership to a dictionary or list pass this object to
    # the set_value() function instead of passing the returned reference to
    # set_binary().
    get_binary*: proc(self: ptr cef_value): ptr cef_binary_value {.cef_callback.}

    # Returns the underlying value as type dictionary. The returned reference may
    # become invalid if the value is owned by another object or if ownership is
    # transferred to another object in the future. To maintain a reference to the
    # value after assigning ownership to a dictionary or list pass this object to
    # the set_value() function instead of passing the returned reference to
    # set_dictionary().
    get_dictionary*: proc(self: ptr cef_value): ptr cef_dictionary_value {.cef_callback.}

    # Returns the underlying value as type list. The returned reference may
    # become invalid if the value is owned by another object or if ownership is
    # transferred to another object in the future. To maintain a reference to the
    # value after assigning ownership to a dictionary or list pass this object to
    # the set_value() function instead of passing the returned reference to
    # set_list().
    get_list*: proc(self: ptr cef_value): ptr cef_list_value {.cef_callback.}

    # Sets the underlying value as type null. Returns true (1) if the value was
    # set successfully.
    set_null*: proc(self: ptr cef_value): cint {.cef_callback.}

    # Sets the underlying value as type bool. Returns true (1) if the value was
    # set successfully.
    set_bool*: proc(self: ptr cef_value, value: cint): cint {.cef_callback.}

    # Sets the underlying value as type cint. Returns true (1) if the value was
    # set successfully.
    set_int*: proc(self: ptr cef_value, value: cint): cint {.cef_callback.}

    # Sets the underlying value as type double. Returns true (1) if the value was
    # set successfully.
    set_double*: proc(self: ptr cef_value, value: cdouble): cint {.cef_callback.}

    # Sets the underlying value as type string. Returns true (1) if the value was
    # set successfully.
    set_string*: proc(self: ptr cef_value, value: ptr cef_string): cint {.cef_callback.}

    # Sets the underlying value as type binary. Returns true (1) if the value was
    # set successfully. This object keeps a reference to |value| and ownership of
    # the underlying data remains unchanged.
    set_binary*: proc(self: ptr cef_value, value: ptr cef_binary_value): cint {.cef_callback.}

    # Sets the underlying value as type dict. Returns true (1) if the value was
    # set successfully. This object keeps a reference to |value| and ownership of
    # the underlying data remains unchanged.
    set_dictionary*: proc(self: ptr cef_value, value: ptr cef_dictionary_value): cint {.cef_callback.}

    # Sets the underlying value as type list. Returns true (1) if the value was
    # set successfully. This object keeps a reference to |value| and ownership of
    # the underlying data remains unchanged.
    set_list*: proc(self: ptr cef_value, value: ptr cef_list_value): cint {.cef_callback.}

  # Structure representing a binary value. Can be used on any process and thread.
  cef_binary_value* = object
    base*: cef_base

    # Returns true (1) if this object is valid. This object may become invalid if
    # the underlying data is owned by another object (e.g. list or dictionary)
    # and that other object is then modified or destroyed. Do not call any other
    # functions if this function returns false (0).
    is_valid*: proc(self: ptr cef_binary_value): cint {.cef_callback.}

    # Returns true (1) if this object is currently owned by another object.
    is_owned*: proc(self: ptr cef_binary_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have the same underlying
    # data.
    is_same*: proc(self, that: ptr cef_binary_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have an equivalent
    # underlying value but are not necessarily the same object.
    is_equal*: proc(self, that: ptr cef_binary_value): cint {.cef_callback.}

    # Returns a copy of this object. The data in this object will also be copied.
    copy*: proc(self: ptr cef_binary_value): ptr cef_binary_value {.cef_callback.}

    # Returns the data size.
    get_size*: proc(self: ptr cef_binary_value): csize {.cef_callback.}

    # Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
    # the specified byte |data_offset|. Returns the number of bytes read.
    get_data*: proc(self: ptr cef_binary_value,
      buffer: pointer, buffer_size, data_offset: csize): csize {.cef_callback.}

  # Structure representing a dictionary value. Can be used on any process and
  # thread.
  cef_dictionary_value* = object
    base*: cef_base

    # Returns true (1) if this object is valid. This object may become invalid if
    # the underlying data is owned by another object (e.g. list or dictionary)
    # and that other object is then modified or destroyed. Do not call any other
    # functions if this function returns false (0).

    is_valid*: proc(self: ptr cef_dictionary_value): cint {.cef_callback.}

    # Returns true (1) if this object is currently owned by another object.
    is_owned*: proc(self: ptr cef_dictionary_value): cint {.cef_callback.}

    # Returns true (1) if the values of this object are read-only. Some APIs may
    # expose read-only objects.
    is_read_only*: proc(self: ptr cef_dictionary_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have the same underlying
    # data. If true (1) modifications to this object will also affect |that|
    # object and vice-versa.

    is_same*: proc(self, that: ptr cef_dictionary_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have an equivalent
    # underlying value but are not necessarily the same object.
    is_equal*: proc(self, that: ptr cef_dictionary_value): cint {.cef_callback.}

    # Returns a writable copy of this object. If |exclude_NULL_children| is true
    # (1) any NULL dictionaries or lists will be excluded from the copy.
    copy*: proc(self: ptr cef_dictionary_value,
      exclude_empty_children: cint): ptr cef_dictionary_value {.cef_callback.}

    # Returns the number of values.
    get_size*: proc(self: ptr cef_dictionary_value): csize {.cef_callback.}

    # Removes all values. Returns true (1) on success.
    clear*: proc(self: ptr cef_dictionary_value): cint {.cef_callback.}

    # Returns true (1) if the current dictionary has a value for the given key.
    has_key*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string): cint {.cef_callback.}

    # Reads all keys for this dictionary into the specified vector.
    get_keys*: proc(self: ptr cef_dictionary_value,
      keys: cef_string_list): cint {.cef_callback.}

    # Removes the value at the specified key. Returns true (1) is the value was
    # removed successfully.
    remove*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string): cint {.cef_callback.}

    # Returns the value type for the specified key.
    get_type*: proc(self: ptr cef_dictionary_value, key: ptr cef_string): cef_value_type {.cef_callback.}

    # Returns the value at the specified key. For simple types the returned value
    # will copy existing data and modifications to the value will not modify this
    # object. For complex types (binary, dictionary and list) the returned value
    # will reference existing data and modifications to the value will modify
    # this object.
    get_value*: proc(self: ptr cef_dictionary_value, key: ptr cef_string): ptr cef_value {.cef_callback.}

    # Returns the value at the specified key as type bool.
    get_bool*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string): cint {.cef_callback.}

    # Returns the value at the specified key as type cint.
    get_int*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string): cint {.cef_callback.}

    # Returns the value at the specified key as type double.
    get_double*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string): cdouble {.cef_callback.}

    # Returns the value at the specified key as type string.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_string*: proc(self: ptr cef_dictionary_value, key: ptr cef_string): cef_string_userfree {.cef_callback.}

    # Returns the value at the specified key as type binary. The returned value
    # will reference existing data.
    get_binary*: proc(self: ptr cef_dictionary_value, key: ptr cef_string): ptr cef_binary_value {.cef_callback.}

    # Returns the value at the specified key as type dictionary. The returned
    # value will reference existing data and modifications to the value will
    # modify this object.
    get_dictionary*: proc(self: ptr cef_dictionary_value, key: ptr cef_string): ptr cef_dictionary_value {.cef_callback.}

    # Returns the value at the specified key as type list. The returned value
    # will reference existing data and modifications to the value will modify
    # this object.
    get_list*: proc(self: ptr cef_dictionary_value, key: ptr cef_string): ptr cef_list_value {.cef_callback.}

    # Sets the value at the specified key. Returns true (1) if the value was set
    # successfully. If |value| represents simple data then the underlying data
    # will be copied and modifications to |value| will not modify this object. If
    # |value| represents complex data (binary, dictionary or list) then the
    # underlying data will be referenced and modifications to |value| will modify
    # this object.
    set_value*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: ptr cef_value): cint {.cef_callback.}

    # Sets the value at the specified key as type null. Returns true (1) if the
    # value was set successfully.
    set_null*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string): cint {.cef_callback.}

    # Sets the value at the specified key as type bool. Returns true (1) if the
    # value was set successfully.
    set_bool*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: cint): cint {.cef_callback.}

    # Sets the value at the specified key as type cint. Returns true (1) if the
    # value was set successfully.
    set_int*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: cint): cint {.cef_callback.}

    # Sets the value at the specified key as type double. Returns true (1) if the
    # value was set successfully.
    set_double*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: cdouble): cint {.cef_callback.}

    # Sets the value at the specified key as type string. Returns true (1) if the
    # value was set successfully.
    set_string*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: ptr cef_string): cint {.cef_callback.}

    # Sets the value at the specified key as type binary. Returns true (1) if the
    # value was set successfully. If |value| is currently owned by another object
    # then the value will be copied and the |value| reference will not change.
    # Otherwise, ownership will be transferred to this object and the |value|
    # reference will be invalidated.
    set_binary*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: ptr cef_binary_value): cint {.cef_callback.}

    # Sets the value at the specified key as type dict. Returns true (1) if the
    # value was set successfully. If |value| is currently owned by another object
    # then the value will be copied and the |value| reference will not change.
    # Otherwise, ownership will be transferred to this object and the |value|
    # reference will be invalidated.
    set_dictionary*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: ptr cef_dictionary_value): cint {.cef_callback.}

    # Sets the value at the specified key as type list. Returns true (1) if the
    # value was set successfully. If |value| is currently owned by another object
    # then the value will be copied and the |value| reference will not change.
    # Otherwise, ownership will be transferred to this object and the |value|
    # reference will be invalidated.
    set_list*: proc(self: ptr cef_dictionary_value,
      key: ptr cef_string, value: ptr cef_list_value): cint {.cef_callback.}

  # Structure representing a list value. Can be used on any process and thread.
  cef_list_value* = object
    base*: cef_base

    # Returns true (1) if this object is valid. This object may become invalid if
    # the underlying data is owned by another object (e.g. list or dictionary)
    # and that other object is then modified or destroyed. Do not call any other
    # functions if this function returns false (0).
    is_valid*: proc(self: ptr cef_list_value): cint {.cef_callback.}

    # Returns true (1) if this object is currently owned by another object.
    is_owned*: proc(self: ptr cef_list_value): cint {.cef_callback.}

    # Returns true (1) if the values of this object are read-only. Some APIs may
    # expose read-only objects.
    is_read_only*: proc(self: ptr cef_list_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have the same underlying
    # data. If true (1) modifications to this object will also affect |that|
    # object and vice-versa.
    is_same*: proc(self, that: ptr cef_list_value): cint {.cef_callback.}

    # Returns true (1) if this object and |that| object have an equivalent
    # underlying value but are not necessarily the same object.
    is_equal*: proc(self, that: ptr cef_list_value): cint {.cef_callback.}

    # Returns a writable copy of this object.
    copy*: proc(self: ptr cef_list_value): ptr cef_list_value {.cef_callback.}

    # Sets the number of values. If the number of values is expanded all new
    # value slots will default to type null. Returns true (1) on success.
    set_size*: proc(self: ptr cef_list_value, size: csize): cint {.cef_callback.}

    # Returns the number of values.
    get_size*: proc(self: ptr cef_list_value): csize {.cef_callback.}

    # Removes all values. Returns true (1) on success.
    clear*: proc(self: ptr cef_list_value): cint {.cef_callback.}

    # Removes the value at the specified index.
    remove*: proc(self: ptr cef_list_value, index: cint): cint {.cef_callback.}

    # Returns the value type at the specified index.
    get_type*: proc(self: ptr cef_list_value, index: cint): cef_value_type {.cef_callback.}

    # Returns the value at the specified index. For simple types the returned
    # value will copy existing data and modifications to the value will not
    # modify this object. For complex types (binary, dictionary and list) the
    # returned value will reference existing data and modifications to the value
    # will modify this object.
    get_value*: proc(self: ptr cef_list_value, index: cint): ptr cef_value {.cef_callback.}

    # Returns the value at the specified index as type bool.
    get_bool*: proc(self: ptr cef_list_value, index: cint): cint {.cef_callback.}

    # Returns the value at the specified index as type cint.
    get_int*: proc(self: ptr cef_list_value, index: cint): cint {.cef_callback.}

    # Returns the value at the specified index as type double.
    get_double*: proc(self: ptr cef_list_value, index: cint): cdouble {.cef_callback.}

    # Returns the value at the specified index as type string.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_string*: proc(self: ptr cef_list_value, index: cint): cef_string_userfree {.cef_callback.}

    # Returns the value at the specified index as type binary. The returned value
    # will reference existing data.
    get_binary*: proc(self: ptr cef_list_value, index: cint): ptr cef_binary_value {.cef_callback.}

    # Returns the value at the specified index as type dictionary. The returned
    # value will reference existing data and modifications to the value will
    # modify this object.
    get_dictionary*: proc(self: ptr cef_list_value, index: cint): ptr cef_dictionary_value {.cef_callback.}

    # Returns the value at the specified index as type list. The returned value
    # will reference existing data and modifications to the value will modify
    # this object.
    get_list*: proc(self: ptr cef_list_value, index: cint): ptr cef_list_value {.cef_callback.}

    # Sets the value at the specified index. Returns true (1) if the value was
    # set successfully. If |value| represents simple data then the underlying
    # data will be copied and modifications to |value| will not modify this
    # object. If |value| represents complex data (binary, dictionary or list)
    # then the underlying data will be referenced and modifications to |value|
    # will modify this object.
    set_value*: proc(self: ptr cef_list_value, index: cint,
        value: ptr cef_value): cint {.cef_callback.}

    # Sets the value at the specified index as type null. Returns true (1) if the
    # value was set successfully.
    set_null*: proc(self: ptr cef_list_value, index: cint): cint {.cef_callback.}

    # Sets the value at the specified index as type bool. Returns true (1) if the
    # value was set successfully.
    set_bool*: proc(self: ptr cef_list_value, index: cint,
        value: cint): cint {.cef_callback.}

    # Sets the value at the specified index as type cint. Returns true (1) if the
    # value was set successfully.
    set_int*: proc(self: ptr cef_list_value, index: cint,
        value: cint): cint {.cef_callback.}

    # Sets the value at the specified index as type double. Returns true (1) if
    # the value was set successfully.
    set_double*: proc(self: ptr cef_list_value, index: cint,
        value: cdouble): cint {.cef_callback.}

    # Sets the value at the specified index as type string. Returns true (1) if
    # the value was set successfully.
    set_string*: proc(self: ptr cef_list_value, index: cint,
        value: ptr cef_string): cint {.cef_callback.}

    # Sets the value at the specified index as type binary. Returns true (1) if
    # the value was set successfully. If |value| is currently owned by another
    # object then the value will be copied and the |value| reference will not
    # change. Otherwise, ownership will be transferred to this object and the
    # |value| reference will be invalidated.
    set_binary*: proc(self: ptr cef_list_value, index: cint,
        value: ptr cef_binary_value): cint {.cef_callback.}

    # Sets the value at the specified index as type dict. Returns true (1) if the
    # value was set successfully. If |value| is currently owned by another object
    # then the value will be copied and the |value| reference will not change.
    # Otherwise, ownership will be transferred to this object and the |value|
    # reference will be invalidated.
    set_dictionary*: proc(self: ptr cef_list_value, index: cint,
        value: ptr cef_dictionary_value): cint {.cef_callback.}

    # Sets the value at the specified index as type list. Returns true (1) if the
    # value was set successfully. If |value| is currently owned by another object
    # then the value will be copied and the |value| reference will not change.
    # Otherwise, ownership will be transferred to this object and the |value|
    # reference will be invalidated.
    set_list*: proc(self: ptr cef_list_value, index: cint,
      value: ptr cef_list_value): cint {.cef_callback.}

# Creates a new object.
proc cef_value_create*(): ptr cef_value {.cef_import.}

# Creates a new object that is not owned by any other object.
proc cef_list_value_create*(): ptr cef_list_value {.cef_import.}

# Creates a new object that is not owned by any other object. The specified
# |data| will be copied.
proc cef_binary_value_create*(data: pointer, data_size: csize): ptr cef_binary_value {.cef_import.}

# Creates a new object that is not owned by any other object.
proc cef_dictionary_value_create*(): ptr cef_dictionary_value {.cef_import.}
