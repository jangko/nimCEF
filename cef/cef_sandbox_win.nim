include cef_import

# The sandbox is used to restrict sub-processes (renderer, plugin, GPU, etc)
# from directly accessing system resources. This helps to protect the user
# from untrusted and potentially malicious Web content.
# See http://www.chromium.org/developers/design-documents/sandbox for
# complete details.
#
# To enable the sandbox on Windows the following requirements must be met:
# 1. Use the same executable for the browser process and all sub-processes.
# 2. Link the executable with the cef_sandbox static library.
# 3. Call the cef_sandbox_info_create() function from within the executable
#    (not from a separate DLL) and pass the resulting pointer into both the
#    CefExecutProcess() and CefInitialize() functions via the
#    |windows_sandbox_info| parameter.
#
#
# Create the sandbox information object for this process. It is safe to create
# multiple of this object and to destroy the object immediately after passing
# into the CefExecutProcess() and/or CefInitialize() functions.

when defined(NC_SANDBOX_ENABLED):
  proc cef_sandbox_info_create*(): pointer {.cef_import.}

  # Destroy the specified sandbox information object.
  proc cef_sandbox_info_destroy*(sandbox_info: pointer) {.cef_import.}

else:
  proc cef_sandbox_info_create*(): pointer = nil

  # Destroy the specified sandbox information object.
  proc cef_sandbox_info_destroy*(sandbox_info: pointer) = discard