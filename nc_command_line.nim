import nc_util

# Structure used to create and/or parse command line arguments. Arguments with
# '--', '-' and, on Windows, '/' prefixes are considered switches. Switches
# will always precede any arguments without switch prefixes. Switches can
# optionally have a value specified using the '=' delimiter (e.g.
# "-switch=value"). An argument of "--" will terminate switch parsing with all
# subsequent tokens, regardless of prefix, being interpreted as non-switch
# arguments. Switch names are considered case-insensitive. This structure can
# be used before cef_initialize() is called.
wrapAPI(NCCommandLine, cef_command_line)

# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCCommandLine): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCCommandLine): bool =
  self.wrapCall(is_read_only, result)

# Returns a writable copy of this object.
proc Copy*(self: NCCommandLine): NCCommandLine =
  self.wrapCall(copy, result)

# Initialize the command line with the specified |argc| and |argv| values.
# The first argument must be the name of the program. This function is only
# supported on non-Windows platforms.
proc InitFromArgv*(self: NCCommandLine, argc: cint, argv: ptr cstring) =
  self.handler.init_from_argv(self.handler, argc, argv)

# Initialize the command line with the string returned by calling
# GetCommandLineW(). This function is only supported on Windows.
proc InitFromString*(self: NCCommandLine, command_line: string) =
  self.wrapCall(init_from_string, command_line)

# Reset the command-line switches and arguments but leave the program
# component unchanged.
proc Reset*(self: NCCommandLine) =
  self.wrapCall(reset)

# Retrieve the original command line string as a vector of strings. The argv
# array: { program, [(--|-|/)switch[=value]]*, [--], [argument]* }
proc GetArgv*(self: NCCommandLine): seq[string] =
  self.wrapCall(get_argv, result)

# Constructs and returns the represented command line string. Use this
# function cautiously because quoting behavior is unclear.
# The resulting string must be freed by calling nc_free().
proc GetCommandLineString*(self: NCCommandLine): string =
  self.wrapCall(get_command_line_string, result)

# Get the program part of the command line string (the first item).
# The resulting string must be freed by calling nc_free().
proc GetProgram*(self: NCCommandLine): string =
  self.wrapCall(get_program, result)

# Set the program part of the command line string (the first item).
proc SetProgram*(self: NCCommandLine, program: string) =
  self.wrapCall(set_program, program)

# Returns true (1) if the command line has switches.
proc HasSwitches*(self: NCCommandLine): bool =
  self.wrapCall(has_switches, result)

# Returns true (1) if the command line contains the given switch.
proc HasSwitch*(self: NCCommandLine, name: string): bool =
  self.wrapCall(has_switch, result, name)

# Returns the value associated with the given switch. If the switch has no
# value or isn't present this function returns the NULL string.
# The resulting string must be freed by calling nc_free().
proc GetSwitchValue*(self: NCCommandLine, name: string): string =
  self.wrapCall(get_switch_value, result, name)

# Returns the map of switch names and values. If a switch has no value an
# NULL string is returned.
proc GetSwitches*(self: NCCommandLine): StringTableRef =
  self.wrapCall(get_switches, result)

# Add a switch to the end of the command line. If the switch has no value
# pass an NULL value string.
proc AppendSwitch*(self: NCCommandLine, name: string) =
  self.wrapCall(append_switch, name)

# Add a switch with the specified value to the end of the command line.
proc AppendSwitchWithValue*(self: NCCommandLine, name, value: string) =
  self.wrapCall(append_switch_with_value, name, value)

# True if there are remaining command line arguments.
proc HasArguments*(self: NCCommandLine): bool =
  self.wrapCall(has_arguments, result)

# Get the remaining command line arguments.
proc GetArguments*(self: NCCommandLine): seq[string] =
  self.wrapCall(get_arguments, result)

# Add an argument to the end of the command line.
proc AppendArgument*(self: NCCommandLine, argument: string) =
  self.wrapCall(append_argument, argument)

# Insert a command before the current command. Common for debuggers, like
# "valgrind" or "gdb --args".
proc PrependWrapper*(self: NCCommandLine, wrapper: string) =
  self.wrapCall(prepend_wrapper, wrapper)

# Create a new cef_command_line_t instance.
proc CommandLineCreate*(): NCCommandLine =
  wrapProc(cef_command_line_create, result)

# Returns the singleton global cef_command_line_t object. The returned object
# will be read-only.
proc CommandLineGetGlobal*(): NCCommandLine =
  wrapProc(cef_command_line_get_global, result)