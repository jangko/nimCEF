import cef/cef_process_message_api, cef/cef_base_api, nc_util, cef/cef_values_api

type
  # Structure representing a message. Can be used on any process and thread.
  NCProcessMessage* = ptr cef_process_message

# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCProcessMessage): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCProcessMessage): bool =
  result = self.is_read_only(self) == 1.cint

# Returns a writable copy of this object.
proc Copy*(self: NCProcessMessage): NCProcessMessage =
  result = self.copy(self)

# Returns the message name.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetName*(self: NCProcessMessage): string =
  result = to_nim_string(self.get_name(self))

# Returns the list of arguments.
proc GetArgumentList*(self: NCProcessMessage): ptr cef_list_value =
  result = self.get_argument_list(self)

# Create a new cef_process_message_t object with the specified name.
proc CreateProcessMessage*(name: string): NCProcessMessage =
  var cname = to_cef_string(name)
  result = cef_process_message_create(cname)
  cef_string_userfree_free(cname)