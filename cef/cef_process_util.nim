import cef_base, cef_command_line
include cef_import

# Launches the process specified via |command_line|. Returns true (1) upon
# success. Must be called on the browser process TID_PROCESS_LAUNCHER thread.
#
# Unix-specific notes: - All file descriptors open in the parent process will
# be closed in the
#   child process except for stdin, stdout, and stderr.
# - If the first argument on the command line does not contain a slash,
#   PATH will be searched. (See man execvp.)

proc cef_launch_process*(command_line: ptr cef_command_line): cint {.cef_import.}