import cef_base, cef_stream, cef_time
include cef_import

type
  # Structure that supports the reading of zip archives via the zlib unzip API.
  # The functions of this structure should only be called on the thread that
  # creates the object.
  cef_zip_reader* = object
    # Base structure.
    base*: cef_base

    # Moves the cursor to the first file in the archive. Returns true (1) if the
    # cursor position was set successfully.
    move_to_first_file*: proc(self: ptr cef_zip_reader): cint {.cef_callback.}

    # Moves the cursor to the next file in the archive. Returns true (1) if the
    # cursor position was set successfully.
    move_to_next_file*: proc(self: ptr cef_zip_reader): cint {.cef_callback.}

    # Moves the cursor to the specified file in the archive. If |caseSensitive|
    # is true (1) then the search will be case sensitive. Returns true (1) if the
    # cursor position was set successfully.
    move_to_file*: proc(self: ptr cef_zip_reader,
      fileName: ptr cef_string, caseSensitive: cint): cint {.cef_callback.}

    # Closes the archive. This should be called directly to ensure that cleanup
    # occurs on the correct thread.
    close*: proc(self: ptr cef_zip_reader): cint {.cef_callback.}

    # The below functions act on the file at the current cursor position.
    # Returns the name of the file.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_file_name*: proc(self: ptr cef_zip_reader): cef_string_userfree {.cef_callback.}

    # Returns the uncompressed size of the file.
    get_file_size*: proc(self: ptr cef_zip_reader): int64 {.cef_callback.}
  
    # Returns the last modified timestamp for the file.
    get_file_last_modified*: proc(self: ptr cef_zip_reader): ptr cef_time {.cef_callback.}

    # Opens the file for reading of uncompressed data. A read password may
    # optionally be specified.
    open_file*: proc(self: ptr cef_zip_reader,
      password: ptr cef_string): cint {.cef_callback.}

    # Closes the file.
    close_file*: proc(self: ptr cef_zip_reader): cint {.cef_callback.}

    # Read uncompressed file contents into the specified buffer. Returns < 0 if
    # an error occurred, 0 if at the end of file, or the number of bytes read.
    read_file*: proc(self: ptr cef_zip_reader, buffer: pointer, bufferSize: csize): cint {.cef_callback.}
  
    # Returns the current offset in the uncompressed file contents.
    tell*: proc(self: ptr cef_zip_reader): int64 {.cef_callback.}
  
    # Returns true (1) if at end of the file contents.
    eof*: proc(self: ptr cef_zip_reader): cint {.cef_callback.}

# Create a new cef_zip_reader_t object. The returned object's functions can
# only be called from the thread that created the object.
proc cef_zip_reader_create*(stream: ptr cef_stream_reader): ptr cef_zip_reader {.cef_import.}

