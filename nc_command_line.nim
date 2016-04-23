import cef/cef_command_line_api, nc_util

type
  # Structure used to create and/or parse command line arguments. Arguments with
  # '--', '-' and, on Windows, '/' prefixes are considered switches. Switches
  # will always precede any arguments without switch prefixes. Switches can
  # optionally have a value specified using the '=' delimiter (e.g.
  # "-switch=value"). An argument of "--" will terminate switch parsing with all
  # subsequent tokens, regardless of prefix, being interpreted as non-switch
  # arguments. Switch names are considered case-insensitive. This structure can
  # be used before cef_initialize() is called.
  NCCommandLine* = ptr cef_command_line

# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCCommandLine): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCCommandLine): bool =
  result = self.is_read_only(self) == 1.cint

# Returns a writable copy of this object.
proc Copy*(self: NCCommandLine): NCCommandLine =
  result = self.copy(self)

# Initialize the command line with the specified |argc| and |argv| values.
# The first argument must be the name of the program. This function is only
# supported on non-Windows platforms.
proc InitFromArgv*(self: NCCommandLine, argc: cint, argv: ptr cstring) =
  self.init_from_argv(self, argc, argv)

# Initialize the command line with the string returned by calling
# GetCommandLineW(). This function is only supported on Windows.
proc InitFromString*(self: NCCommandLine, command_line: string) =
  let ccmd = to_cef(command_line)
  self.init_from_string(self, ccmd)
  cef_string_userfree_free(ccmd)

# Reset the command-line switches and arguments but leave the program
# component unchanged.
proc Reset*(self: NCCommandLine) =
  self.reset(self)

# Retrieve the original command line string as a vector of strings. The argv
# array: { program, [(--|-|/)switch[=value]]*, [--], [argument]* }
proc GetArgv*(self: NCCommandLine): seq[string] =
  var clist = cef_string_list_alloc()
  self.get_argv(self, clist)
  result = to_nim(clist)

# Constructs and returns the represented command line string. Use this
# function cautiously because quoting behavior is unclear.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetCommandLineString*(self: NCCommandLine): string =
  result = to_nim(self.get_command_line_string(self))

# Get the program part of the command line string (the first item).
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetProgram*(self: NCCommandLine): string =
  result = to_nim(self.get_program(self))

# Set the program part of the command line string (the first item).
proc SetProgram*(self: NCCommandLine, program: string) =
  let cprogram = to_cef(program)
  self.set_program(self, cprogram)
  cef_string_userfree_free(cprogram)

# Returns true (1) if the command line has switches.
proc HasSwitches*(self: NCCommandLine): bool =
  result = self.has_switches(self) == 1.cint

# Returns true (1) if the command line contains the given switch.
proc HasSwitch*(self: NCCommandLine, name: string): bool =
  let cname = to_cef(name)
  result = self.has_switch(self, cname) == 1.cint
  cef_string_userfree_free(cname)

# Returns the value associated with the given switch. If the switch has no
# value or isn't present this function returns the NULL string.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetSwitchValue*(self: NCCommandLine, name: string): string =
  let cname = to_cef(name)
  result = to_nim(self.get_switch_value(self, cname))
  cef_string_userfree_free(cname)

# Returns the map of switch names and values. If a switch has no value an
# NULL string is returned.
proc GetSwitches*(self: NCCommandLine): StringTableRef =
  var cmap = cef_string_map_alloc()
  self.get_switches(self, cmap)
  result = to_nim(cmap)

# Add a switch to the end of the command line. If the switch has no value
# pass an NULL value string.
proc AppendSwitch*(self: NCCommandLine, name: string) =
  let cname = to_cef(name)
  self.append_switch(self, cname)
  cef_string_userfree_free(cname)

# Add a switch with the specified value to the end of the command line.
proc AppendSwitchWithValue*(self: NCCommandLine, name, value: string) =
  let cname = to_cef(name)
  let cvalue = to_cef(value)
  self.append_switch_with_value(self, cname, cvalue)
  cef_string_userfree_free(cname)
  cef_string_userfree_free(cvalue)

# True if there are remaining command line arguments.
proc HasArguments*(self: NCCommandLine): bool =
  result = self.has_arguments(self) == 1.cint

# Get the remaining command line arguments.
proc GetArguments*(self: NCCommandLine): seq[string] =
  var clist = cef_string_list_alloc()
  self.get_arguments(self, clist)
  result = to_nim(clist)

# Add an argument to the end of the command line.
proc AppendArgument*(self: NCCommandLine, argument: string) =
  let carg = to_cef(argument)
  self.append_argument(self, carg)
  cef_string_userfree_free(carg)

# Insert a command before the current command. Common for debuggers, like
# "valgrind" or "gdb --args".
proc PrependWrapper*(self: NCCommandLine, wrapper: string) =
  let cwrap = to_cef(wrapper)
  self.prepend_wrapper(self, cwrap)
  cef_string_userfree_free(cwrap)


# Create a new cef_command_line_t instance.
proc CommandLineCreate*(): NCCommandLine =
  result = cef_command_line_create()

# Returns the singleton global cef_command_line_t object. The returned object
# will be read-only.
proc CommandLineGetGlobal*(): NCCommandLine =
  result = cef_command_line_get_global()