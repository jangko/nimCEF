import cef/cef_values_api, nc_util, cef/cef_types

type
  # Structure that wraps other data value types. Complex types (binary,
  # dictionary and list) will be referenced but not owned by this object. Can be
  # used on any process and thread.
  NCValue* = ptr cef_value

  # Structure representing a binary value. Can be used on any process and thread.
  NCBinaryValue* = ptr cef_binary_value

  # Structure representing a dictionary value. Can be used on any process and
  # thread.
  NCDictionaryValue* = ptr cef_dictionary_value

  # Structure representing a list value. Can be used on any process and thread.
  NCListValue* = ptr cef_list_value


# Returns true (1) if the underlying data is valid. This will always be true
# (1) for simple types. For complex types (binary, dictionary and list) the
# underlying data may become invalid if owned by another object (e.g. list or
# dictionary) and that other object is then modified or destroyed. This value
# object can be re-used by calling Set*() even if the underlying data is
# invalid.
proc IsValid*(self: NCValue): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if the underlying data is owned by another object.
proc IsOwned*(self: NCValue): bool =
  result = self.is_owned(self) == 1.cint

# Returns true (1) if the underlying data is read-only. Some APIs may expose
# read-only objects.
proc IsReadOnly*(self: NCValue): bool =
  result = self.is_read_only(self) == 1.cint

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc IsSame*(self, that: NCValue): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCValue): bool =
  add_ref(that)
  result = self.is_equal(self, that) == 1.cint

# Returns a copy of this object. The underlying data will also be copied.
proc Copy*(self: NCValue): NCValue =
  result = self.copy(self)

# Returns the underlying value type.
proc GetYype*(self: NCValue): cef_value_type =
  result = self.get_type(self)

# Returns the underlying value as type bool.
proc GetBool*(self: NCValue): bool =
  result = self.get_bool(self) == 1.cint

# Returns the underlying value as type cint.
proc GetInt*(self: NCValue): int =
  result = self.get_int(self).int

# Returns the underlying value as type double.
proc GetDouble*(self: NCValue): float64 =
  result = self.get_double(self).float64

# Returns the underlying value as type string.

# The resulting string must be freed by calling string_free().
proc GetString*(self: NCValue): string =
  result = to_nim(self.get_string(self))

# Returns the underlying value as type binary. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_binary().
proc GetBinary*(self: NCValue): NCBinaryValue =
  result = self.get_binary(self)

# Returns the underlying value as type dictionary. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_dictionary().
proc GetDictionary*(self: NCValue): NCDictionaryValue =
  result = self.get_dictionary(self)

# Returns the underlying value as type list. The returned reference may
# become invalid if the value is owned by another object or if ownership is
# transferred to another object in the future. To maintain a reference to the
# value after assigning ownership to a dictionary or list pass this object to
# the set_value() function instead of passing the returned reference to
# set_list().
proc GetList*(self: NCValue): NCListValue =
  result = self.get_list(self)

# Sets the underlying value as type null. Returns true (1) if the value was
# set successfully.
proc SetNull*(self: NCValue): bool =
  result = self.set_null(self) == 1.cint

# Sets the underlying value as type bool. Returns true (1) if the value was
# set successfully.
proc SetBool*(self: NCValue, value: bool): bool =
  result = self.set_bool(self, value.cint) == 1.cint

# Sets the underlying value as type cint. Returns true (1) if the value was
# set successfully.
proc SetInt*(self: NCValue, value: int): bool =
  result = self.set_int(self, value.cint) == 1.cint

# Sets the underlying value as type double. Returns true (1) if the value was
# set successfully.
proc SetDouble*(self: NCValue, value: float64): bool =
  result = self.set_double(self, value.cdouble) == 1.cint

# Sets the underlying value as type string. Returns true (1) if the value was
# set successfully.
proc SetString*(self: NCValue, value: string): bool =
  let cvalue = to_cef(value)
  result = self.set_string(self, cvalue) == 1.cint
  nc_free(cvalue)

# Sets the underlying value as type binary. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc SetBinary*(self: NCValue, value: NCBinaryValue): bool =
  add_ref(value)
  result = self.set_binary(self, value) == 1.cint

# Sets the underlying value as type dict. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc SetDictionary*(self: NCValue, value: NCDictionaryValue): bool =
  add_ref(value)
  result = self.set_dictionary(self, value) == 1.cint

# Sets the underlying value as type list. Returns true (1) if the value was
# set successfully. This object keeps a reference to |value| and ownership of
# the underlying data remains unchanged.
proc SetList*(self: NCValue, value: NCListValue): bool =
  add_ref(value)
  result = self.set_list(self, value) == 1.cint

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc IsValid*(self: NCBinaryValue): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if this object is currently owned by another object.
proc IsOwned*(self: NCBinaryValue): bool =
  result = self.is_owned(self) == 1.cint

# Returns true (1) if this object and |that| object have the same underlying
# data.
proc IsSame*(self, that: NCBinaryValue): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCBinaryValue): bool =
  add_ref(that)
  result = self.is_equal(self, that) == 1.cint

# Returns a copy of this object. The data in this object will also be copied.
proc Copy*(self: NCBinaryValue): NCBinaryValue =
  result = self.copy(self)

# Returns the data size.
proc GetSize*(self: NCBinaryValue): int =
  result = self.get_size(self).int

# Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
# the specified byte |data_offset|. Returns the number of bytes read.
proc GetData*(self: NCBinaryValue, buffer: pointer, buffer_size, data_offset: int): int =
  result = self.get_data(self, buffer, buffer_size.csize, data_offset.csize).int

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc IsValid*(self: NCDictionaryValue): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if this object is currently owned by another object.
proc IsOwned*(self: NCDictionaryValue): bool =
  result = self.is_owned(self) == 1.cint

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCDictionaryValue): bool =
  result = self.is_read_only(self) == 1.cint

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc IsSame*(self, that: NCDictionaryValue): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCDictionaryValue): bool =
  add_ref(that)
  result = self.is_equal(self, that) == 1.cint

# Returns a writable copy of this object. If |exclude_NULL_children| is true
# (1) any NULL dictionaries or lists will be excluded from the copy.
proc Copy*(self: NCDictionaryValue, exclude_empty_children: bool): NCDictionaryValue =
  result = self.copy(self, exclude_empty_children.cint)

# Returns the number of values.
proc GetSize*(self: NCDictionaryValue): int =
  result = self.get_size(self).int

# Removes all values. Returns true (1) on success.
proc Clear*(self: NCDictionaryValue): bool =
  result = self.clear(self) == 1.cint

# Returns true (1) if the current dictionary has a value for the given key.
proc HasKey*(self: NCDictionaryValue, key: string): bool =
  let ckey = to_cef(key)
  result = self.has_key(self, ckey) == 1.cint
  nc_free(ckey)

# Reads all keys for this dictionary into the specified vector.
proc GetKeys*(self: NCDictionaryValue): seq[string] =
  var clist = cef_string_list_alloc()
  if self.get_keys(self, clist) == 1.cint:
    result = to_nim(clist)
  else:
    result = @[]

# Removes the value at the specified key. Returns true (1) is the value was
# removed successfully.
proc Remove*(self: NCDictionaryValue, key: string): bool =
  let ckey = to_cef(key)
  result = self.remove(self, ckey) == 1.cint
  nc_free(ckey)

# Returns the value type for the specified key.
proc GetType*(self: NCDictionaryValue, key: string): cef_value_type =
  let ckey = to_cef(key)
  result = self.get_type(self, ckey)
  nc_free(ckey)

# Returns the value at the specified key. For simple types the returned value
# will copy existing data and modifications to the value will not modify this
# object. For complex types (binary, dictionary and list) the returned value
# will reference existing data and modifications to the value will modify
# this object.
proc GetValue*(self: NCDictionaryValue, key: string): NCValue =
  let ckey = to_cef(key)
  result = self.get_value(self, ckey)
  nc_free(ckey)

# Returns the value at the specified key as type bool.
proc GetBool*(self: NCDictionaryValue, key: string): bool =
  let ckey = to_cef(key)
  result = self.get_bool(self, ckey) == 1.cint
  nc_free(ckey)

# Returns the value at the specified key as type cint.
proc GetInt*(self: NCDictionaryValue, key: string): int =
  let ckey = to_cef(key)
  result = self.get_int(self, ckey).int
  nc_free(ckey)

# Returns the value at the specified key as type double.
proc GetDouble*(self: NCDictionaryValue, key: string): float64 =
  let ckey = to_cef(key)
  result = self.get_double(self, ckey).float64
  nc_free(ckey)

# Returns the value at the specified key as type string.

# The resulting string must be freed by calling string_free().
proc GetString*(self: NCDictionaryValue, key: string): string =
  let ckey = to_cef(key)
  result = to_nim(self.get_string(self, ckey))
  nc_free(ckey)

# Returns the value at the specified key as type binary. The returned value
# will reference existing data.
proc GetBinary*(self: NCDictionaryValue, key: string): NCBinaryValue =
  let ckey = to_cef(key)
  result = self.get_binary(self, ckey)
  nc_free(ckey)

# Returns the value at the specified key as type dictionary. The returned
# value will reference existing data and modifications to the value will
# modify this object.
proc GetDictionary*(self: NCDictionaryValue, key: string): NCDictionaryValue =
  let ckey = to_cef(key)
  result = self.get_dictionary(self, ckey)
  nc_free(ckey)

# Returns the value at the specified key as type list. The returned value
# will reference existing data and modifications to the value will modify
# this object.
proc GetList*(self: NCDictionaryValue, key: string): NCListValue =
  let ckey = to_cef(key)
  result = self.get_list(self, ckey)
  nc_free(ckey)

# Sets the value at the specified key. Returns true (1) if the value was set
# successfully. If |value| represents simple data then the underlying data
# will be copied and modifications to |value| will not modify this object. If
# |value| represents complex data (binary, dictionary or list) then the
# underlying data will be referenced and modifications to |value| will modify
# this object.
proc SetValue*(self: NCDictionaryValue, key: string, value: NCValue): bool =
  add_ref(value)
  let ckey = to_cef(key)
  result = self.set_value(self, ckey, value) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type null. Returns true (1) if the
# value was set successfully.
proc SetNull*(self: NCDictionaryValue, key: string): bool =
  let ckey = to_cef(key)
  result = self.set_null(self, ckey) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type bool. Returns true (1) if the
# value was set successfully.
proc SetBool*(self: NCDictionaryValue, key: string, value: bool): bool =
  let ckey = to_cef(key)
  result = self.set_bool(self, ckey, value.cint) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type cint. Returns true (1) if the
# value was set successfully.
proc SetInt*(self: NCDictionaryValue, key: string, value: int): bool =
  let ckey = to_cef(key)
  result = self.set_int(self, ckey, value.cint) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type double. Returns true (1) if the
# value was set successfully.
proc SetDouble*(self: NCDictionaryValue, key: string, value: float64): bool =
  let ckey = to_cef(key)
  result = self.set_double(self, ckey, value.cdouble) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type string. Returns true (1) if the
# value was set successfully.
proc SetString*(self: NCDictionaryValue, key: string, value: string): bool =
  let ckey = to_cef(key)
  let cval = to_cef(value)
  result = self.set_string(self, ckey, cval) == 1.cint
  nc_free(ckey)
  nc_free(cval)

# Sets the value at the specified key as type binary. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetBinary*(self: NCDictionaryValue, key: string, value: NCBinaryValue): bool =
  add_ref(value)
  let ckey = to_cef(key)
  result = self.set_binary(self, ckey, value) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type dict. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetDictionary*(self: NCDictionaryValue, key: string, value: NCDictionaryValue): bool =
  add_ref(value)
  let ckey = to_cef(key)
  result = self.set_dictionary(self, ckey, value) == 1.cint
  nc_free(ckey)

# Sets the value at the specified key as type list. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetList*(self: NCDictionaryValue, key: string, value: NCListValue): bool =
  add_ref(value)
  let ckey = to_cef(key)
  result = self.set_list(self, ckey, value) == 1.cint
  nc_free(ckey)

# Returns true (1) if this object is valid. This object may become invalid if
# the underlying data is owned by another object (e.g. list or dictionary)
# and that other object is then modified or destroyed. Do not call any other
# functions if this function returns false (0).
proc IsValid*(self: NCListValue): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if this object is currently owned by another object.
proc IsOwned*(self: NCListValue): bool =
  result = self.is_owned(self) == 1.cint

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCListValue): bool =
  result = self.is_read_only(self) == 1.cint

# Returns true (1) if this object and |that| object have the same underlying
# data. If true (1) modifications to this object will also affect |that|
# object and vice-versa.
proc IsSame*(self, that: NCListValue): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Returns true (1) if this object and |that| object have an equivalent
# underlying value but are not necessarily the same object.
proc IsEqual*(self, that: NCListValue): bool =
  add_ref(that)
  result = self.is_equal(self, that) == 1.cint

# Returns a writable copy of this object.
proc Copy*(self: NCListValue): NCListValue =
  result = self.copy(self)

# Sets the number of values. If the number of values is expanded all new
# value slots will default to type null. Returns true (1) on success.
proc SetSize*(self: NCListValue, size: int): bool =
  result = self.set_size(self, size.csize) == 1.cint

# Returns the number of values.
proc GetSize*(self: NCListValue): int =
  result = self.get_size(self).int

# Removes all values. Returns true (1) on success.
proc Clear*(self: NCListValue): bool =
  result = self.clear(self) == 1.cint

# Removes the value at the specified index.
proc Remove*(self: NCListValue, index: int): bool =
  result = self.remove(self, index.cint) == 1.cint

# Returns the value type at the specified index.
proc GetType*(self: NCListValue, index: int): cef_value_type =
  result = self.get_type(self, index.cint)

# Returns the value at the specified index. For simple types the returned
# value will copy existing data and modifications to the value will not
# modify this object. For complex types (binary, dictionary and list) the
# returned value will reference existing data and modifications to the value
# will modify this object.
proc GetValue*(self: NCListValue, index: int): NCValue =
  result = self.get_value(self, index.cint)

# Returns the value at the specified index as type bool.
proc GetBool*(self: NCListValue, index: int): bool =
  result = self.get_bool(self, index.cint) == 1.cint

# Returns the value at the specified index as type cint.
proc GetInt*(self: NCListValue, index: int): int =
  result = self.get_int(self, index.cint)

# Returns the value at the specified index as type double.
proc GetDouble*(self: NCListValue, index: int): float64 =
  result = self.get_double(self, index.cint).float64

# Returns the value at the specified index as type string.

# The resulting string must be freed by calling string_free().
proc GetString*(self: NCListValue, index: int): string =
  result = to_nim(self.get_string(self, index.cint))

# Returns the value at the specified index as type binary. The returned value
# will reference existing data.
proc GetBinary*(self: NCListValue, index: int): NCBinaryValue =
  result = self.get_binary(self, index.cint)

# Returns the value at the specified index as type dictionary. The returned
# value will reference existing data and modifications to the value will
# modify this object.
proc GetDictionary*(self: NCListValue, index: int): NCDictionaryValue =
  result = self.get_dictionary(self, index.cint)

# Returns the value at the specified index as type list. The returned value
# will reference existing data and modifications to the value will modify
# this object.
proc GetList*(self: NCListValue, index: int): NCListValue =
  result = self.get_list(self, index.cint)

# Sets the value at the specified index. Returns true (1) if the value was
# set successfully. If |value| represents simple data then the underlying
# data will be copied and modifications to |value| will not modify this
# object. If |value| represents complex data (binary, dictionary or list)
# then the underlying data will be referenced and modifications to |value|
# will modify this object.
proc SetValue*(self: NCListValue, index: int, value: NCValue): bool =
  add_ref(value)
  result = self.set_value(self, index.cint, value) == 1.cint

# Sets the value at the specified index as type null. Returns true (1) if the
# value was set successfully.
proc SetNull*(self: NCListValue, index: int): bool =
  result = self.set_null(self, index.cint) == 1.cint

# Sets the value at the specified index as type bool. Returns true (1) if the
# value was set successfully.
proc SetBool*(self: NCListValue, index: int, value: bool): bool =
  result = self.set_bool(self, index.cint, value.cint) == 1.cint

# Sets the value at the specified index as type cint. Returns true (1) if the
# value was set successfully.
proc SetInt*(self: NCListValue, index: int, value: int): bool =
  result = self.set_int(self, index.cint, value.cint) == 1.cint

# Sets the value at the specified index as type double. Returns true (1) if
# the value was set successfully.
proc SetDouble*(self: NCListValue, index: int, value: float64): bool =
  result = self.set_double(self, index.cint, value.cdouble) == 1.cint

# Sets the value at the specified index as type string. Returns true (1) if
# the value was set successfully.
proc SetString*(self: NCListValue, index: int, value: string): bool =
  let cvalue = to_cef(value)
  result = self.set_string(self, index.cint, cvalue) == 1.cint
  nc_free(cvalue)

# Sets the value at the specified index as type binary. Returns true (1) if
# the value was set successfully. If |value| is currently owned by another
# object then the value will be copied and the |value| reference will not
# change. Otherwise, ownership will be transferred to this object and the
# |value| reference will be invalidated.
proc SetBinary*(self: NCListValue, index: int, value: NCBinaryValue): bool =
  add_ref(value)
  result = self.set_binary(self, index.cint, value) == 1.cint

# Sets the value at the specified index as type dict. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetDictionary*(self: NCListValue, index: int, value: NCDictionaryValue): bool =
  add_ref(value)
  result = self.set_dictionary(self, index.cint, value) == 1.cint

# Sets the value at the specified index as type list. Returns true (1) if the
# value was set successfully. If |value| is currently owned by another object
# then the value will be copied and the |value| reference will not change.
# Otherwise, ownership will be transferred to this object and the |value|
# reference will be invalidated.
proc SetList*(self: NCListValue, index: int, value: NCListValue): bool =
  add_ref(value)
  result = self.set_list(self, index.cint, value) == 1.cint

# Creates a new object.
proc NCValueCreate*(): NCValue =
  result = cef_value_create()

# Creates a new object that is not owned by any other object.
proc NCListValueCreate*(): NCListValue =
  result = cef_list_value_create()

# Creates a new object that is not owned by any other object. The specified
# |data| will be copied.
proc NCBinaryValueCreate*(data: pointer, data_size: int): NCBinaryValue =
  result = cef_binary_value_create(data, data_size.csize)

# Creates a new object that is not owned by any other object.
proc NCDictionaryValueCreate*(): NCDictionaryValue =
  result = cef_dictionary_value_create()