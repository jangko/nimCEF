import nc_util, cef/cef_types

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
proc IsValid*(self: NCValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if the underlying data is owned by another object.
proc IsOwned*(self: NCValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if the underlying data is read-only. Some APIs may expose
# read-only objects.
proc IsReadOnly*(self: NCValue): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc IsSame*(self, that: NCValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a copy of this object. The underlying data will also be copied.
proc Copy*(self: NCValue): NCValue =
  self.wrapCall(copy, result)

# Returns the underlying value type.
proc GetYype*(self: NCValue): cef_value_type =
  self.wrapCall(get_type, result)

# Returns the underlying value as type bool.
proc GetBool*(self: NCValue): bool =
  self.wrapCall(get_bool, result)

# Returns the underlying value as type cint.
proc GetInt*(self: NCValue): int =
  self.wrapCall(get_int, result)

# Returns the underlying value as type double.
proc GetDouble*(self: NCValue): float64 =
  self.wrapCall(get_double, result)

# Returns the underlying value as type string.
proc GetString*(self: NCValue): string =
  self.wrapCall(get_string, result)

# Returns the underlying value as type binary. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_binary().
proc GetBinary*(self: NCValue): NCBinaryValue =
  self.wrapCall(get_binary, result)

# Returns the underlying value as type dictionary. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_dictionary().
proc GetDictionary*(self: NCValue): NCDictionaryValue =
  self.wrapCall(get_dictionary, result)

# Returns the underlying value as type list. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_list().
proc GetList*(self: NCValue): NCListValue =
  self.wrapCall(get_list, result)

# Sets the underlying value as type null. Returns true (1) if the value was
# set successfully.
proc SetNull*(self: NCValue): bool =
  self.wrapCall(set_null, result)

# Sets the underlying value as type bool. Returns true (1) if the value was
# set successfully.
proc SetBool*(self: NCValue, value: bool): bool =
  self.wrapCall(set_bool, result, value)

# Sets the underlying value as type cint. Returns true (1) if the value was
# set successfully.
proc SetInt*(self: NCValue, value: int): bool =
  self.wrapCall(set_int, result, value)

# Sets the underlying value as type double. Returns true (1) if the value was
# set successfully.
proc SetDouble*(self: NCValue, value: float64): bool =
  self.wrapCall(set_double, result, value)

# Sets the underlying value as type string. Returns true (1) if the value was
# set successfully.
proc SetString*(self: NCValue, value: string): bool =
  self.wrapCall(set_string, result, value)

# Sets the underlying value as type binary. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc SetBinary*(self: NCValue, value: NCBinaryValue): bool =
  self.wrapCall(set_binary, result, value)

# Sets the underlying value as type dict. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc SetDictionary*(self: NCValue, value: NCDictionaryValue): bool =
  self.wrapCall(set_dictionary, result, value)

# Sets the underlying value as type list. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc SetList*(self: NCValue, value: NCListValue): bool =
  self.wrapCall(set_list, result, value)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc IsValid*(self: NCBinaryValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this object is currently owned by another object.
proc IsOwned*(self: NCBinaryValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if this object and |that| object have the same underlying
# data.
proc IsSame*(self, that: NCBinaryValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCBinaryValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a copy of this object. The data in this object will also be copied.
proc Copy*(self: NCBinaryValue): NCBinaryValue =
  self.wrapCall(copy, result)

# Returns the data size.
proc GetSize*(self: NCBinaryValue): int =
  self.wrapCall(get_size, result)

# Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
# the specified byte |data_offset|. Returns the number of bytes read.
proc GetData*(self: NCBinaryValue, buffer: pointer, buffer_size, data_offset: int): int =
  self.wrapCall(get_data, result, buffer, buffer_size, data_offset)

# Get all contained data into string
proc GetDataAsString*(self: NCBinaryValue): string =
  result = newString(self.GetSize())
  if self.GetData(result.cstring, result.len, 0) != result.len: doAssert(false)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc IsValid*(self: NCDictionaryValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this object is currently owned by another object.
proc IsOwned*(self: NCDictionaryValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCDictionaryValue): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc IsSame*(self, that: NCDictionaryValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCDictionaryValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a writable copy of this object. If |exclude_NULL_children| is true
# (1) any NULL dictionaries or lists will be excluded from the copy.
proc Copy*(self: NCDictionaryValue, exclude_empty_children: bool): NCDictionaryValue =
  self.wrapCall(copy, result, exclude_empty_children)

# Returns the number of values.
proc GetSize*(self: NCDictionaryValue): int =
  self.wrapCall(get_size, result)

# Removes all values. Returns true (1) on success.
proc Clear*(self: NCDictionaryValue): bool =
  self.wrapCall(clear, result)

# Returns true (1) if the current dictionary has a value for the given key.
proc HasKey*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(has_key, result, key)

# Reads all keys for this dictionary into the specified vector.
proc GetKeys*(self: NCDictionaryValue): seq[string] =
  self.wrapCall(get_keys, result)

# Removes the value at the specified key. Returns true (1) is the value was
# removed successfully.
proc Remove*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(remove, result, key)

# Returns the value type for the specified key.
proc GetType*(self: NCDictionaryValue, key: string): cef_value_type =
  self.wrapCall(get_type, result, key)

# Returns the value at the specified key. For simple types the returned value
# will copy existing data and modifications to the value will not modify this
# object. For complex types (binary, dictionary and list) the returned value
# will reference existing data and modifications to the value will modify
# this object.
proc GetValue*(self: NCDictionaryValue, key: string): NCValue =
  self.wrapCall(get_value, result, key)

# Returns the value at the specified key as type bool.
proc GetBool*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(get_bool, result, key)

# Returns the value at the specified key as type cint.
proc GetInt*(self: NCDictionaryValue, key: string): int =
  self.wrapCall(get_int, result, key)

# Returns the value at the specified key as type double.
proc GetDouble*(self: NCDictionaryValue, key: string): float64 =
  self.wrapCall(get_double, result, key)

# Returns the value at the specified key as type string.
proc GetString*(self: NCDictionaryValue, key: string): string =
  self.wrapCall(get_string, result, key)

# Returns the value at the specified key as type binary. The returned value
# will reference existing data.
proc GetBinary*(self: NCDictionaryValue, key: string): NCBinaryValue =
  self.wrapCall(get_binary, result, key)

# Returns the value at the specified key as type dictionary. The returned
# value will reference existing data and modifications to the value will
# modify this object.
proc GetDictionary*(self: NCDictionaryValue, key: string): NCDictionaryValue =
  self.wrapCall(get_dictionary, result, key)

# Returns the value at the specified key as type list. The returned value
# will reference existing data and modifications to the value will modify
# this object.
proc GetList*(self: NCDictionaryValue, key: string): NCListValue =
  self.wrapCall(get_list, result, key)

# Sets the value at the specified key. Returns true (1) if the value was set
# successfully. If |value| represents simple data then the underlying data
# will be copied and modifications to |value| will not modify this object. If
# |value| represents complex data (binary, dictionary or list) then the
# underlying data will be referenced and modifications to |value| will modify
# this object.
proc SetValue*(self: NCDictionaryValue, key: string, value: NCValue): bool =
  self.wrapCall(set_value, result, key, value)

# Sets the value at the specified key as type null. Returns true (1) if the
# value was set successfully.
proc SetNull*(self: NCDictionaryValue, key: string): bool =
  self.wrapCall(set_null, result, key)

# Sets the value at the specified key as type bool. Returns true (1) if the
# value was set successfully.
proc SetBool*(self: NCDictionaryValue, key: string, value: bool): bool =
  self.wrapCall(set_bool, result, key, value)

# Sets the value at the specified key as type cint. Returns true (1) if the
# value was set successfully.
proc SetInt*(self: NCDictionaryValue, key: string, value: int): bool =
  self.wrapCall(set_int, result, key, value)

# Sets the value at the specified key as type double. Returns true (1) if the
# value was set successfully.
proc SetDouble*(self: NCDictionaryValue, key: string, value: float64): bool =
  self.wrapCall(set_double, result, key, value)

# Sets the value at the specified key as type string. Returns true (1) if the
# value was set successfully.
proc SetString*(self: NCDictionaryValue, key: string, value: string): bool =
  self.wrapCall(set_string, result, key, value)

# Sets the value at the specified key as type binary. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetBinary*(self: NCDictionaryValue, key: string, value: NCBinaryValue): bool =
  self.wrapCall(set_binary, result, key, value)

# Sets the value at the specified key as type dict. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetDictionary*(self: NCDictionaryValue, key: string, value: NCDictionaryValue): bool =
  self.wrapCall(set_dictionary, result, key, value)

# Sets the value at the specified key as type list. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetList*(self: NCDictionaryValue, key: string, value: NCListValue): bool =
  self.wrapCall(set_list, result, key, value)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc IsValid*(self: NCListValue): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this object is currently owned by another object.
proc IsOwned*(self: NCListValue): bool =
  self.wrapCall(is_owned, result)

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCListValue): bool =
  self.wrapCall(is_read_only, result)

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc IsSame*(self, that: NCListValue): bool =
  self.wrapCall(is_same, result, that)

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCListValue): bool =
  self.wrapCall(is_equal, result, that)

# Returns a writable copy of this object.
proc Copy*(self: NCListValue): NCListValue =
  self.wrapCall(copy, result)

# Sets the number of values. If the number of values is expanded all new
# value slots will default to type null. Returns true (1) on success.
proc SetSize*(self: NCListValue, size: int): bool =
  self.wrapCall(set_size, result, size)

# Returns the number of values.
proc GetSize*(self: NCListValue): int =
  self.wrapCall(get_size, result)

# Removes all values. Returns true (1) on success.
proc Clear*(self: NCListValue): bool =
  self.wrapCall(clear, result)

# Removes the value at the specified index.
proc Remove*(self: NCListValue, index: int): bool =
  self.wrapCall(remove, result, index)

# Returns the value type at the specified index.
proc GetType*(self: NCListValue, index: int): cef_value_type =
  self.wrapCall(get_type, result, index)

# Returns the value at the specified index. For simple types the returned
# value will copy existing data and modifications to the value will not
# modify this object. For complex types (binary, dictionary and list) the
# returned value will reference existing data and modifications to the value
# will modify this object.
proc GetValue*(self: NCListValue, index: int): NCValue =
  self.wrapCall(get_value, result, index)

# Returns the value at the specified index as type bool.
proc GetBool*(self: NCListValue, index: int): bool =
  self.wrapCall(get_bool, result, index)

# Returns the value at the specified index as type cint.
proc GetInt*(self: NCListValue, index: int): int =
  self.wrapCall(get_int, result, index)

# Returns the value at the specified index as type double.
proc GetDouble*(self: NCListValue, index: int): float64 =
  self.wrapCall(get_double, result, index)

# Returns the value at the specified index as type string.
proc GetString*(self: NCListValue, index: int): string =
  self.wrapCall(get_string, result, index)

# Returns the value at the specified index as type binary. The returned value
# will reference existing data.
proc GetBinary*(self: NCListValue, index: int): NCBinaryValue =
  self.wrapCall(get_binary, result, index)

# Returns the value at the specified index as type dictionary. The returned
# value will reference existing data and modifications to the value will
# modify this object.
proc GetDictionary*(self: NCListValue, index: int): NCDictionaryValue =
  self.wrapCall(get_dictionary, result, index)

# Returns the value at the specified index as type list. The returned value
# will reference existing data and modifications to the value will modify
# this object.
proc GetList*(self: NCListValue, index: int): NCListValue =
  self.wrapCall(get_list, result, index)

# Sets the value at the specified index. Returns true (1) if the value was
# set successfully. If |value| represents simple data then the underlying
# data will be copied and modifications to |value| will not modify this
# object. If |value| represents complex data (binary, dictionary or list)
# then the underlying data will be referenced and modifications to |value|
# will modify this object.
proc SetValue*(self: NCListValue, index: int, value: NCValue): bool =
  self.wrapCall(set_value, result, index, value)

# Sets the value at the specified index as type null. Returns true (1) if the
# value was set successfully.
proc SetNull*(self: NCListValue, index: int): bool =
  self.wrapCall(set_null, result, index)

# Sets the value at the specified index as type bool. Returns true (1) if the
# value was set successfully.
proc SetBool*(self: NCListValue, index: int, value: bool): bool =
  self.wrapCall(set_bool, result, index, value)

# Sets the value at the specified index as type cint. Returns true (1) if the
# value was set successfully.
proc SetInt*(self: NCListValue, index: int, value: int): bool =
  self.wrapCall(set_int, result, index, value)

# Sets the value at the specified index as type double. Returns true (1) if
# the value was set successfully.
proc SetDouble*(self: NCListValue, index: int, value: float64): bool =
  self.wrapCall(set_double, result, index, value)

# Sets the value at the specified index as type string. Returns true (1) if
# the value was set successfully.
proc SetString*(self: NCListValue, index: int, value: string): bool =
  self.wrapCall(set_string, result, index, value)

# Sets the value at the specified index as type binary. Returns true (1) if
# the value was set successfully. If |value| is currently owned by another
# object then the value will be copied and the |value| reference will not
# change. Otherwise, ownership will be transferred to this object and the
# |value| reference will be invalidated.
proc SetBinary*(self: NCListValue, index: int, value: NCBinaryValue): bool =
  self.wrapCall(set_binary, result, index, value)

# Sets the value at the specified index as type dict. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetDictionary*(self: NCListValue, index: int, value: NCDictionaryValue): bool =
  self.wrapCall(set_dictionary, result, index, value)

# Sets the value at the specified index as type list. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetList*(self: NCListValue, index: int, value: NCListValue): bool =
  self.wrapCall(set_list, result, index, value)

# Creates a new object.
proc NCValueCreate*(): NCValue =
  wrapProc(cef_value_create, result)

# Creates a new object that is not owned by any other object.
proc NCListValueCreate*(): NCListValue =
  wrapProc(cef_list_value_create, result)

# Creates a new object that is not owned by any other object. The specified
# |data| will be copied.
proc NCBinaryValueCreate*(data: pointer, data_size: int): NCBinaryValue =
  wrapProc(cef_binary_value_create, result, data, data_size)

# Creates a new object that is not owned by any other object.
proc NCDictionaryValueCreate*(): NCDictionaryValue =
  wrapProc(cef_dictionary_value_create, result)