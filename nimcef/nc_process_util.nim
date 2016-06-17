import cef_process_util_api, nc_command_line, nc_util, nc_types

# Launches the process specified via |command_line|. Returns true (1) upon
# success. Must be called on the browser process TID_PROCESS_LAUNCHER thread.
#
# Unix-specific notes: - All file descriptors open in the parent process will
# be closed in the
#   child process except for stdin, stdout, and stderr.
# - If the first argument on the command line does not contain a slash,
#   PATH will be searched. (See man execvp.)

proc ncLaunchProcess*(command_line: NCCommandLine): bool =
  wrapProc(cef_launch_process, result, command_line)