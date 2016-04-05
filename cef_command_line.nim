# Structure used to create and/or parse command line arguments. Arguments with
# '--', '-' and, on Windows, '/' prefixes are considered switches. Switches
# will always precede any arguments without switch prefixes. Switches can
# optionally have a value specified using the '=' delimiter (e.g.
# "-switch=value"). An argument of "--" will terminate switch parsing with all
# subsequent tokens, regardless of prefix, being interpreted as non-switch
# arguments. Switch names are considered case-insensitive. This structure can
# be used before cef_initialize() is called.
type
  cef_command_line* = object of cef_base
    # Returns true (1) if this object is valid. Do not call any other functions
    # if this function returns false (0).
    is_valid*: proc(self: ptr cef_command_line): int {.cef_callback.}

    # Returns true (1) if the values of this object are read-only. Some APIs may
    # expose read-only objects.
    is_read_only*: proc(self: ptr cef_command_line): int {.cef_callback.}

    # Returns a writable copy of this object.
    copy*: proc(self: ptr cef_command_line): ptr cef_command_line {.cef_callback.}
      
    # Initialize the command line with the specified |argc| and |argv| values.
    # The first argument must be the name of the program. This function is only
    # supported on non-Windows platforms.
    init_from_argv*: proc(self: ptr cef_command_line, argc: int, argv: ptr ptr char) {.cef_callback.}    
  
    # Initialize the command line with the string returned by calling
    # GetCommandLineW(). This function is only supported on Windows.
    init_from_string*: proc(self: ptr cef_command_line, command_line: cef_string) {.cef_callback.}
    
    # Reset the command-line switches and arguments but leave the program
    # component unchanged.
    reset*: proc(self: ptr cef_command_line) {.cef_callback.}
    
    # Retrieve the original command line string as a vector of strings. The argv
    # array: { program, [(--|-|/)switch[=value]]*, [--], [argument]* }
    get_argv*: proc(self: ptr cef_command_line, argv: cef_string_list) {.cef_callback.}
      
    # Constructs and returns the represented command line string. Use this
    # function cautiously because quoting behavior is unclear.
  
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_command_line_string*: proc(self: ptr cef_command_line): cef_string_userfree {.cef_callback.}
      
    # Get the program part of the command line string (the first item).
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_program*: proc(self: ptr cef_command_line): cef_string_userfree {.cef_callback.}

    # Set the program part of the command line string (the first item).
    set_program*: proc(self: ptr cef_command_line, program: ptr cef_string) {.cef_callback.}
  
    # Returns true (1) if the command line has switches.
    has_switches*: proc(self: ptr cef_command_line): bool {.cef_callback.}

    # Returns true (1) if the command line contains the given switch.
    has_switch*: proc(self: ptr cef_command_line, name: ptr cef_string): bool {.cef_callback.}
    
    # Returns the value associated with the given switch. If the switch has no
    # value or isn't present this function returns the NULL string.
  
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_switch_value*: proc(self: ptr cef_command_line, name: ptr cef_string): cef_string_userfree {.cef_callback.}
  
    # Returns the map of switch names and values. If a switch has no value an
    # NULL string is returned.
    get_switches*: proc(self: ptr cef_command_line, switches: cef_string_map) {.cef_callback.}

    # Add a switch to the end of the command line. If the switch has no value
    # pass an NULL value string.
    append_switch*: proc(self: ptr cef_command_line, name: ptr cef_string) {.cef_callback.}
      
    # Add a switch with the specified value to the end of the command line.
    append_switch_with_value*: proc(self: ptr cef_command_line, name, value: ptr cef_string) {.cef_callback.}
      
    # True if there are remaining command line arguments.
    has_arguments*: proc(self: ptr cef_command_line): bool {.cef_callback.}
  
    # Get the remaining command line arguments.
    get_arguments*: proc(self: ptr cef_command_line, arguments: cef_string_list) {.cef_callback.}
  
    # Add an argument to the end of the command line.
    append_argument*: proc(self: ptr cef_command_line, argument: cef_string) {.cef_callback.}
  
    # Insert a command before the current command. Common for debuggers, like
    # "valgrind" or "gdb --args".
    prepend_wrapper*: proc(self: ptr cef_command_line, wrapper: cef_string) {.cef_callback.}
      
# Create a new cef_command_line_t instance.
proc cef_command_line_create*(): ptr cef_command_line {.cef_import.}

# Returns the singleton global cef_command_line_t object. The returned object
# will be read-only.

proc cef_command_line_get_global*(): ptr cef_command_line {.cef_import.}