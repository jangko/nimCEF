import cef_base
include cef_import

type
  cef_read_handler* = object
  
    base*: cef_base
    # Read raw binary data.
    read*: proc(self: ptr cef_read_handler, data: pointer,
        size: csize, n: csize): csize {.cef_callback.}
    
    # Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    # SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
    seek*: proc(self: ptr cef_read_handler, offset: int64,
        whence: int): int {.cef_callback.}
    
    # Return the current offset position.
    tell*: proc(self: ptr cef_read_handler): int64 {.cef_callback.}
    
    # Return non-zero if at end of file.
    eof*: proc(self: ptr cef_read_handler): int {.cef_callback.}
    
    # Return true (1) if this handler performs work like accessing the file
    # system which may block. Used as a hint for determining the thread to access
    # the handler from.
    may_block*: proc(self: ptr cef_read_handler): int {.cef_callback.}
  
  cef_stream_reader* = object
    base*: cef_base
  
    # Read raw binary data.
    read*: proc(self: ptr cef_stream_reader, data: pointer,
      size: csize, n: csize): csize {.cef_callback.}

    # Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    # SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
    seek*: proc(self: ptr cef_stream_reader, offset: int64,
      whence: int): int {.cef_callback.}

    # Return the current offset position.
    tell*: proc(self: ptr cef_stream_reader): int64 {.cef_callback.}

    # Return non-zero if at end of file.
    eof*: proc(self: ptr cef_stream_reader): int {.cef_callback.}

    # Returns true (1) if this reader performs work like accessing the file
    # system which may block. Used as a hint for determining the thread to access
    # the reader from.
    may_block*: proc(self: ptr cef_stream_reader): int {.cef_callback.}
  
  cef_write_handler* = object
    base*: cef_base
    
    # Write raw binary data.
    write*: proc(self: ptr cef_write_handler,
      data: pointer, size: csize, n: csize): csize {.cef_callback.}

    # Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    # SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
    seek*: proc(self: ptr cef_write_handler, offset: int64,
      whence: int): int {.cef_callback.}

    # Return the current offset position.
    tell*: proc(self: ptr cef_write_handler): int64 {.cef_callback.}

    # Flush the stream.
    flush*: proc(self: ptr cef_write_handler): int {.cef_callback.}

    # Return true (1) if this handler performs work like accessing the file
    # system which may block. Used as a hint for determining the thread to access
    # the handler from.
    may_block*: proc(self: ptr cef_write_handler): int {.cef_callback.}
  
  cef_stream_writer* = object
    base*: cef_base
    
    # Write raw binary data.
    write*: proc(self: ptr cef_stream_writer,
      data: pointer, size: csize, n: csize): csize {.cef_callback.}

    # Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    # SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
    seek*: proc(self: ptr cef_stream_writer, offset: int64,
      whence: int): int {.cef_callback.}

    # Return the current offset position.
    tell*: proc(self: ptr cef_stream_writer): int64 {.cef_callback.}

    # Flush the stream.
    flush*: proc(self: ptr cef_stream_writer): int {.cef_callback.}

    # Returns true (1) if this writer performs work like accessing the file
    # system which may block. Used as a hint for determining the thread to access
    # the writer from.
    may_block*: proc(self: ptr cef_stream_writer): int {.cef_callback.}

# Create a new cef_stream_reader_t object from a file.
proc cef_stream_reader_create_for_file*(fileName: ptr cef_string): ptr cef_stream_reader {.cef_import.}

# Create a new cef_stream_reader_t object from data.
proc cef_stream_reader_create_for_data*(data: pointer, size: csize): ptr cef_stream_reader {.cef_import.}

# Create a new cef_stream_reader_t object from a custom handler.
proc cef_stream_reader_create_for_handler*(handler: ptr cef_read_handler): ptr cef_stream_reader {.cef_import.}
    
# Create a new cef_stream_writer_t object for a file.
proc cef_stream_writer_create_for_file*(fileName: ptr cef_string): ptr cef_stream_writer {.cef_import.}

# Create a new cef_stream_writer_t object for a custom handler.
proc cef_stream_writer_create_for_handler*(handler: ptr cef_write_handler): ptr cef_stream_writer {.cef_import.}
