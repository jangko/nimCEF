import nc_util, nc_value, nc_types

# Structure representing a message. Can be used on any process and thread.
wrapAPI(NCProcessMessage, cef_process_message)

# Returns true (1) if this object is valid.
# Do not call any other functions if this function returns false (0).
proc isValid*(self: NCProcessMessage): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if the values of this object are read-only.
# Some APIs may expose read-only objects.
proc isReadOnly*(self: NCProcessMessage): bool =
  self.wrapCall(is_read_only, result)

# Returns a writable copy of this object.
proc copy*(self: NCProcessMessage): NCProcessMessage =
  self.wrapCall(copy, result)

# Returns the message name.
proc getName*(self: NCProcessMessage): string =
  self.wrapCall(get_name, result)

# Returns the list of arguments.
proc getArgumentList*(self: NCProcessMessage): NCListValue =
  self.wrapCall(get_argument_list, result)

# Create a new NCProcessMessage object with the specified name.
proc ncCreateProcessMessage*(name: string): NCProcessMessage =
  wrapProc(cef_process_message_create, result, name)
