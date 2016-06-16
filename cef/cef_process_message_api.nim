import cef_base_api, cef_value_api
include cef_import

# Structure representing a message. Can be used on any process and thread.
type
  cef_process_message* = object of cef_base
    # Returns true (1) if this object is valid. Do not call any other functions
    # if this function returns false (0).
    is_valid*: proc(self: ptr cef_process_message): cint {.cef_callback.}

    # Returns true (1) if the values of this object are read-only. Some APIs may
    # expose read-only objects.
    is_read_only*: proc(self: ptr cef_process_message): cint {.cef_callback.}

    # Returns a writable copy of this object.
    copy*: proc(self: ptr cef_process_message): ptr cef_process_message {.cef_callback.}

    # Returns the message name.

    # The resulting string must be freed by calling cef_string_userfree_free().
    get_name*: proc(self: ptr cef_process_message): cef_string_userfree {.cef_callback.}

    # Returns the list of arguments.
    get_argument_list*: proc(self: ptr cef_process_message): ptr cef_list_value {.cef_callback.}

# Create a new cef_process_message_t object with the specified name.
proc cef_process_message_create*(name: ptr cef_string): ptr cef_process_message {.cef_import.}