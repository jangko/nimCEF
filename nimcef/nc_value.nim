import nc_util, cef_types

# Structure that wraps other data value types. Complex types (binary,
# dictionary and list) will be referenced but not owned by this object. Can be
# used on any process and thread.
wrapAPI(NCValue, cef_value)

# Structure representing a binary value. Can be used on any process and thread.
wrapAPI(NCBinaryValue, cef_binary_value, false)

# Structure representing a dictionary value. Can be used on any process and
# thread.
wrapAPI(NCDictionaryValue, cef_dictionary_value, false)

# Structure representing a list value. Can be used on any process and thread.
wrapAPI(NCListValue, cef_list_value, false)


# Returns true (1) if the underlying data is valid. This will always be true
# (1) for simple types. For complex types (binary, dictionary and list) the
# underlying data may become invalid if owned by another object (e.g. list or
# dictionary) and that other object is then modified or destroyed. This value
# object can be re-used by calling Set*() even if the underlying data is
# invalid.
proc isValid*(self: NCValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if the underlying data is owned by another object.
proc isOwned*(self: NCValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if the underlying data is read-only. Some APIs may expose
# read-only objects.
proc isReadOnly*(self: NCValue): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc isSame*(self, that: NCValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc isEqual*(self, that: NCValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a copy of this object. The underlying data will also be copied.
proc copy*(self: NCValue): NCValue =
  self.wrapCall(copy, result)

# Returns the underlying value type.
proc getYype*(self: NCValue): cef_value_type =
  self.wrapCall(get_type, result)

# Returns the underlying value as type bool.
proc getBool*(self: NCValue): bool =
  self.wrapCall(get_bool, result)

# Returns the underlying value as type cint.
proc getInt*(self: NCValue): int =
  self.wrapCall(get_int, result)

# Returns the underlying value as type double.
proc getDouble*(self: NCValue): float64 =
  self.wrapCall(get_double, result)

# Returns the underlying value as type string.
proc getString*(self: NCValue): string =
  self.wrapCall(get_string, result)

# Returns the underlying value as type binary. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_binary().
proc getBinary*(self: NCValue): NCBinaryValue =
  self.wrapCall(get_binary, result)

# Returns the underlying value as type dictionary. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_dictionary().
proc getDictionary*(self: NCValue): NCDictionaryValue =
  self.wrapCall(get_dictionary, result)

# Returns the underlying value as type list. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_list().
proc getList*(self: NCValue): NCListValue =
  self.wrapCall(get_list, result)

# Sets the underlying value as type null. Returns true (1) if the value was
# set successfully.
proc setNull*(self: NCValue): bool =
  self.wrapCall(set_null, result)

# Sets the underlying value as type bool. Returns true (1) if the value was
# set successfully.
proc setBool*(self: NCValue, value: bool): bool =
  self.wrapCall(set_bool, result, value)

# Sets the underlying value as type cint. Returns true (1) if the value was
# set successfully.
proc setInt*(self: NCValue, value: int): bool =
  self.wrapCall(set_int, result, value)

# Sets the underlying value as type double. Returns true (1) if the value was
# set successfully.
proc setDouble*(self: NCValue, value: float64): bool =
  self.wrapCall(set_double, result, value)

# Sets the underlying value as type string. Returns true (1) if the value was
# set successfully.
proc setString*(self: NCValue, value: string): bool =
  self.wrapCall(set_string, result, value)

# Sets the underlying value as type binary. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc setBinary*(self: NCValue, value: NCBinaryValue): bool =
  self.wrapCall(set_binary, result, value)

# Sets the underlying value as type dict. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc setDictionary*(self: NCValue, value: NCDictionaryValue): bool =
  self.wrapCall(set_dictionary, result, value)

# Sets the underlying value as type list. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc setList*(self: NCValue, value: NCListValue): bool =
  self.wrapCall(set_list, result, value)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc isValid*(self: NCBinaryValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this object is currently owned by another object.
proc isOwned*(self: NCBinaryValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if this object and |that| object have the same underlying
# data.
proc isSame*(self, that: NCBinaryValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc isEqual*(self, that: NCBinaryValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a copy of this object. The data in this object will also be copied.
proc copy*(self: NCBinaryValue): NCBinaryValue =
  self.wrapCall(copy, result)

# Returns the data size.
proc getSize*(self: NCBinaryValue): int =
  self.wrapCall(get_size, result)

# Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
# the specified byte |data_offset|. Returns the number of bytes read.
proc getData*(self: NCBinaryValue, buffer: pointer, buffer_size, data_offset: int): int =
  self.wrapCall(get_data, result, buffer, buffer_size, data_offset)

# Get all contained data into string
proc getDataAsString*(self: NCBinaryValue): string =
  result = newString(self.getSize())
  if self.getData(result.cstring, result.len, 0) != result.len: doAssert(false)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc isValid*(self: NCDictionaryValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this object is currently owned by another object.
proc isOwned*(self: NCDictionaryValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc isReadOnly*(self: NCDictionaryValue): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc isSame*(self, that: NCDictionaryValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc isEqual*(self, that: NCDictionaryValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a writable copy of this object. If |exclude_NULL_children| is true
# (1) any NULL dictionaries or lists will be excluded from the copy.
proc copy*(self: NCDictionaryValue, exclude_empty_children: bool): NCDictionaryValue =
  self.wrapCall(copy, result, exclude_empty_children)

# Returns the number of values.
proc getSize*(self: NCDictionaryValue): int =
  self.wrapCall(get_size, result)

# Removes all values. Returns true (1) on success.
proc clear*(self: NCDictionaryValue): bool =
  self.wrapCall(clear, result)

# Returns true (1) if the current dictionary has a value for the given key.
proc hasKey*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(has_key, result, key)

# Reads all keys for this dictionary into the specified vector.
proc getKeys*(self: NCDictionaryValue): seq[string] =
  self.wrapCall(get_keys, result)

# Removes the value at the specified key. Returns true (1) is the value was
# removed successfully.
proc remove*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(remove, result, key)

# Returns the value type for the specified key.
proc getType*(self: NCDictionaryValue, key: string): cef_value_type =
  self.wrapCall(get_type, result, key)

# Returns the value at the specified key. For simple types the returned value
# will copy existing data and modifications to the value will not modify this
# object. For complex types (binary, dictionary and list) the returned value
# will reference existing data and modifications to the value will modify
# this object.
proc getValue*(self: NCDictionaryValue, key: string): NCValue =
  self.wrapCall(get_value, result, key)

# Returns the value at the specified key as type bool.
proc getBool*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(get_bool, result, key)

# Returns the value at the specified key as type cint.
proc getInt*(self: NCDictionaryValue, key: string): int =
  self.wrapCall(get_int, result, key)

# Returns the value at the specified key as type double.
proc getDouble*(self: NCDictionaryValue, key: string): float64 =
  self.wrapCall(get_double, result, key)

# Returns the value at the specified key as type string.
proc getString*(self: NCDictionaryValue, key: string): string =
  self.wrapCall(get_string, result, key)

# Returns the value at the specified key as type binary. The returned value
# will reference existing data.
proc getBinary*(self: NCDictionaryValue, key: string): NCBinaryValue =
  self.wrapCall(get_binary, result, key)

# Returns the value at the specified key as type dictionary. The returned
# value will reference existing data and modifications to the value will
# modify this object.
proc getDictionary*(self: NCDictionaryValue, key: string): NCDictionaryValue =
  self.wrapCall(get_dictionary, result, key)

# Returns the value at the specified key as type list. The returned value
# will reference existing data and modifications to the value will modify
# this object.
proc getList*(self: NCDictionaryValue, key: string): NCListValue =
  self.wrapCall(get_list, result, key)

# Sets the value at the specified key. Returns true (1) if the value was set
# successfully. If |value| represents simple data then the underlying data
# will be copied and modifications to |value| will not modify this object. If
# |value| represents complex data (binary, dictionary or list) then the
# underlying data will be referenced and modifications to |value| will modify
# this object.
proc setValue*(self: NCDictionaryValue, key: string, value: NCValue): bool =
  self.wrapCall(set_value, result, key, value)

# Sets the value at the specified key as type null. Returns true (1) if the
# value was set successfully.
proc setNull*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(set_null, result, key)

# Sets the value at the specified key as type bool. Returns true (1) if the
# value was set successfully.
proc setBool*(self: NCDictionaryValue, key: string, value: bool): bool =
  self.wrapCall(set_bool, result, key, value)

# Sets the value at the specified key as type cint. Returns true (1) if the
# value was set successfully.
proc setInt*(self: NCDictionaryValue, key: string, value: int): bool =
  self.wrapCall(set_int, result, key, value)

# Sets the value at the specified key as type double. Returns true (1) if the
# value was set successfully.
proc setDouble*(self: NCDictionaryValue, key: string, value: float64): bool =
  self.wrapCall(set_double, result, key, value)

# Sets the value at the specified key as type string. Returns true (1) if the
# value was set successfully.
proc setString*(self: NCDictionaryValue, key: string, value: string): bool =
  self.wrapCall(set_string, result, key, value)

# Sets the value at the specified key as type binary. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc setBinary*(self: NCDictionaryValue, key: string, value: NCBinaryValue): bool =
  self.wrapCall(set_binary, result, key, value)

# Sets the value at the specified key as type dict. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc setDictionary*(self: NCDictionaryValue, key: string, value: NCDictionaryValue): bool =
  self.wrapCall(set_dictionary, result, key, value)

# Sets the value at the specified key as type list. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc setList*(self: NCDictionaryValue, key: string, value: NCListValue): bool =
  self.wrapCall(set_list, result, key, value)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc isValid*(self: NCListValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this object is currently owned by another object.
proc isOwned*(self: NCListValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc isReadOnly*(self: NCListValue): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc isSame*(self, that: NCListValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc isEqual*(self, that: NCListValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a writable copy of this object.
proc copy*(self: NCListValue): NCListValue =
  self.wrapCall(copy, result)

# Sets the number of values. If the number of values is expanded all new
# value slots will default to type null. Returns true (1) on success.
proc setSize*(self: NCListValue, size: int): bool =
  self.wrapCall(set_size, result, size)

# Returns the number of values.
proc getSize*(self: NCListValue): int =
  self.wrapCall(get_size, result)

# Removes all values. Returns true (1) on success.
proc clear*(self: NCListValue): bool =
  self.wrapCall(clear, result)

# Removes the value at the specified index.
proc remove*(self: NCListValue, index: int): bool =
  self.wrapCall(remove, result, index)

# Returns the value type at the specified index.
proc getType*(self: NCListValue, index: int): cef_value_type =
  self.wrapCall(get_type, result, index)

# Returns the value at the specified index. For simple types the returned
# value will copy existing data and modifications to the value will not
# modify this object. For complex types (binary, dictionary and list) the
# returned value will reference existing data and modifications to the value
# will modify this object.
proc getValue*(self: NCListValue, index: int): NCValue =
  self.wrapCall(get_value, result, index)

# Returns the value at the specified index as type bool.
proc getBool*(self: NCListValue, index: int): bool =
  self.wrapCall(get_bool, result, index)

# Returns the value at the specified index as type cint.
proc getInt*(self: NCListValue, index: int): int =
  self.wrapCall(get_int, result, index)

# Returns the value at the specified index as type double.
proc getDouble*(self: NCListValue, index: int): float64 =
  self.wrapCall(get_double, result, index)

# Returns the value at the specified index as type string.
proc getString*(self: NCListValue, index: int): string =
  self.wrapCall(get_string, result, index)

# Returns the value at the specified index as type binary. The returned value
# will reference existing data.
proc getBinary*(self: NCListValue, index: int): NCBinaryValue =
  self.wrapCall(get_binary, result, index)

# Returns the value at the specified index as type dictionary. The returned
# value will reference existing data and modifications to the value will
# modify this object.
proc getDictionary*(self: NCListValue, index: int): NCDictionaryValue =
  self.wrapCall(get_dictionary, result, index)

# Returns the value at the specified index as type list. The returned value
# will reference existing data and modifications to the value will modify
# this object.
proc getList*(self: NCListValue, index: int): NCListValue =
  self.wrapCall(get_list, result, index)

# Sets the value at the specified index. Returns true (1) if the value was
# set successfully. If |value| represents simple data then the underlying
# data will be copied and modifications to |value| will not modify this
# object. If |value| represents complex data (binary, dictionary or list)
# then the underlying data will be referenced and modifications to |value|
# will modify this object.
proc setValue*(self: NCListValue, index: int, value: NCValue): bool =
  self.wrapCall(set_value, result, index, value)

# Sets the value at the specified index as type null. Returns true (1) if the
# value was set successfully.
proc setNull*(self: NCListValue, index: int): bool =
  self.wrapCall(set_null, result, index)

# Sets the value at the specified index as type bool. Returns true (1) if the
# value was set successfully.
proc setBool*(self: NCListValue, index: int, value: bool): bool =
  self.wrapCall(set_bool, result, index, value)

# Sets the value at the specified index as type cint. Returns true (1) if the
# value was set successfully.
proc setInt*(self: NCListValue, index: int, value: int): bool =
  self.wrapCall(set_int, result, index, value)

# Sets the value at the specified index as type double. Returns true (1) if
# the value was set successfully.
proc setDouble*(self: NCListValue, index: int, value: float64): bool =
  self.wrapCall(set_double, result, index, value)

# Sets the value at the specified index as type string. Returns true (1) if
# the value was set successfully.
proc setString*(self: NCListValue, index: int, value: string): bool =
  self.wrapCall(set_string, result, index, value)

# Sets the value at the specified index as type binary. Returns true (1) if
# the value was set successfully. If |value| is currently owned by another
# object then the value will be copied and the |value| reference will not
# change. Otherwise, ownership will be transferred to this object and the
# |value| reference will be invalidated.
proc setBinary*(self: NCListValue, index: int, value: NCBinaryValue): bool =
  self.wrapCall(set_binary, result, index, value)

# Sets the value at the specified index as type dict. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc setDictionary*(self: NCListValue, index: int, value: NCDictionaryValue): bool =
  self.wrapCall(set_dictionary, result, index, value)

# Sets the value at the specified index as type list. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc setList*(self: NCListValue, index: int, value: NCListValue): bool =
  self.wrapCall(set_list, result, index, value)

# Creates a new object.
proc ncValueCreate*(): NCValue =
  wrapProc(cef_value_create, result)

# Creates a new object that is not owned by any other object.
proc ncListValueCreate*(): NCListValue =
  wrapProc(cef_list_value_create, result)

# Creates a new object that is not owned by any other object. The specified
# |data| will be copied.
proc ncBinaryValueCreate*(data: pointer, data_size: int): NCBinaryValue =
  wrapProc(cef_binary_value_create, result, data, data_size)

# Creates a new object that is not owned by any other object.
proc ncDictionaryValueCreate*(): NCDictionaryValue =
  wrapProc(cef_dictionary_value_create, result)