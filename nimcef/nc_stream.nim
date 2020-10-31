import cef_stream_api, nc_util, nc_types, nc_util_impl
include cef_import

wrapAPI(NCStreamReader, cef_stream_reader, false)
wrapAPI(NCStreamWriter, cef_stream_writer, false)

const
  NC_SEEK_SET* = 0
  NC_SEEK_CUR* = 1
  NC_SEEK_END* = 2
  
wrapCallback(NCReadHandler, cef_read_handler):
  # Read raw binary data.
  proc read*(self: T, data: pointer, size: uint, n: uint): uint

  # Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
  # SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
  proc seek*(self: T, offset: int64, whence: int): uint

  # Return the current offset position.
  proc tell*(self: T): int64

  # Return non-zero if at end of file.
  proc eof*(self: T): bool

  # Return true (1) if this handler performs work like accessing the file
  # system which may block. Used as a hint for determining the thread to access
  # the handler from.
  proc mayBlock*(self: T): bool

wrapCallback(NCWriteHandler, cef_write_handler):
  # Write raw binary data.
  proc write*(self: T, data: pointer, size: uint, n: uint): uint

  # Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
  # SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
  proc seek*(self: T, offset: int64, whence: int): int

  # Return the current offset position.
  proc tell*(self: T): int64

  # Flush the stream.
  proc Flush*(self: T): bool

  # Return true (1) if this handler performs work like accessing the file
  # system which may block. Used as a hint for determining the thread to access
  # the handler from.
  proc mayBlock*(self: T): bool

# Read raw binary data.
proc read*(self: NCStreamReader, data: pointer, size: int, n: int): int =
  self.wrapCall(read, result, data, size, n)

# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
proc seek*(self: NCStreamReader, offset: int64, whence: int): int =
  self.wrapCall(seek, result, offset, whence)

# Return the current offset position.
proc tell*(self: NCStreamReader): int64 =
  self.wrapCall(tell, result)

# Return non-zero if at end of file.
proc eof*(self: NCStreamReader): bool =
  self.wrapCall(eof, result)

# Returns true (1) if this reader performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the reader from.
proc mayBlock*(self: NCStreamReader): bool =
  self.wrapCall(may_block, result)

# Write raw binary data.
proc write*(self: NCStreamWriter, data: pointer, size: int, n: int): int =
  self.wrapCall(write, result, data, size, n)

# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
proc seek*(self: NCStreamWriter, offset: int64, whence: int): int =
  self.wrapCall(seek, result, offset, whence)

# Return the current offset position.
proc tell*(self: NCStreamWriter): int64 =
  self.wrapCall(tell, result)

# Flush the stream.
proc Flush*(self: NCStreamWriter): bool =
  self.wrapCall(flush, result)

# Returns true (1) if this writer performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the writer from.
proc mayBlock*(self: NCStreamWriter): bool =
  self.wrapCall(may_block, result)

# Create a new NCStreamReader object from a file.
proc ncStreamReaderCreateForFile*(fileName: string): NCStreamReader =
  wrapProc(cef_stream_reader_create_for_file, result, fileName)

# Create a new NCStreamReader object from data.
proc ncStreamReaderCreateForData*(data: pointer, size: int): NCStreamReader =
  wrapProc(cef_stream_reader_create_for_data, result, data, size)

proc ncStreamReaderCreateForData*(data: string): NCStreamReader =
  result = ncStreamReaderCreateForData(data.cstring, data.len)

# Create a new NCStreamReader object from a custom handler.
proc ncStreamReaderCreateForHandler*(handler: NCReadHandler): NCStreamReader =
  wrapProc(cef_stream_reader_create_for_handler, result, handler)

# Create a new NCStreamWriter object for a file.
proc ncStreamWriterCreateForFile*(fileName: string): NCStreamWriter =
  wrapProc(cef_stream_writer_create_for_file, result, fileName)

# Create a new NCStreamWriter object for a custom handler.
proc ncStreamWriterCreateForHandler*(handler: NCWriteHandler): NCStreamWriter =
  wrapProc(cef_stream_writer_create_for_handler, result, handler)
