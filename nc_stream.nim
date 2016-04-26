import cef/cef_stream_api, nc_util, nc_types

type
  NCReadHandler* = ref object of RootObj
    handler: cef_read_handler
  
  NCStreamReader* = ptr cef_stream_reader
  
  NCWriteHandler* = ref object of RootObj
    handler: cef_write_handler
  
  NCStreamWriter* = ptr cef_stream_writer
  
# Read raw binary data.
method OnRead*(self: NCReadHandler, data: pointer, size: int, n: int): int {.base.} =
  result = 0

# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
method OnReadSeek*(self: NCReadHandler, offset: int64, whence: int): bool {.base.} =
  result = true

# Return the current offset position.
method OnReadTell*(self: NCReadHandler): int64 {.base.} =
  result = 0

# Return non-zero if at end of file.
method OnReadEof*(self: NCReadHandler): bool {.base.} =
  result = true

# Return true (1) if this handler performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the handler from.
method OnReadMayBlock*(self: NCReadHandler): bool {.base.} =
  result = false
  
# Read raw binary data.
proc Read*(self: NCStreamReader, data: pointer, size: int, n: int): int =
  result = self.read(self, data, size.csize, n.csize).int
  
# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
proc Seek*(self: NCStreamReader, offset: int64, whence: int): bool =
  result = self.seek(self, offset, whence.cint) == 0.cint
  
# Return the current offset position.
proc Tell*(self: NCStreamReader): int64 =
  result = self.tell(self)
  
# Return non-zero if at end of file.
proc Eof*(self: NCStreamReader): bool =
  result = self.eof(self) != 0.cint
  
# Returns true (1) if this reader performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the reader from.
proc MayBlock*(self: NCStreamReader): bool =
  result = self.may_block(self) == 1.cint
  
# Write raw binary data.
method OnWrite*(self: NCWriteHandler, data: pointer, size: int, n: int): int {.base.} =
  result = 0
  
# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
method OnWriteSeek*(self: NCWriteHandler, offset: int64, whence: int): bool {.base.} =
  result = true
  
# Return the current offset position.
method OnWriteTell*(self: NCWriteHandler): int64 {.base.} =
  result = 0
  
# Flush the stream.
method OnWriteFlush*(self: NCWriteHandler): bool {.base.} =
  result = false
  
# Return true (1) if this handler performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the handler from.
method OnWriteMayBlock*(self: NCWriteHandler): bool {.base.} =
  result = false
  
    
# Write raw binary data.
proc Write*(self: NCStreamWriter, data: pointer, size: int, n: int): int =
  result = self.write(self, data, size.csize, n.csize).int
  
# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
proc Seek*(self: NCStreamWriter, offset: int64, whence: int): bool =
  result = self.seek(self, offset, whence.cint) == 0.cint

# Return the current offset position.
proc Tell*(self: NCStreamWriter): int64 =
  result = self.tell(self)

# Flush the stream.
proc Flush*(self: NCStreamWriter): bool =
  result = self.flush(self) == 1.cint
  
# Returns true (1) if this writer performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the writer from.
proc MayBlock*(self: NCStreamWriter): bool =
  result = self.may_block(self) == 1.cint
    
include nc_stream_internal

proc nrh_finalizer(handler: NCReadHandler) =
  release(handler.handler.addr)
  
proc makeNCReadHandler*(): NCReadHandler =
  new(result, nrh_finalizer)
  initialize_read_handler(result.handler.addr)

proc nwh_finalizer(handler: NCWriteHandler) =
  release(handler.handler.addr)
  
proc makeNCWriteHandler*(): NCWriteHandler =
  new(result, nwh_finalizer)
  initialize_write_handler(result.handler.addr)

# Create a new cef_stream_reader_t object from a file.
proc NCStreamReaderCreateForFile*(fileName: string): NCStreamReader =
  let cname = to_cef(fileName)
  result = cef_stream_reader_create_for_file(cname)
  nc_free(cname)

# Create a new cef_stream_reader_t object from data.
proc NCSreamReaderCreateForData*(data: pointer, size: csize): NCStreamReader =
  result = cef_stream_reader_create_for_data(data, size)

# Create a new cef_stream_reader_t object from a custom handler.
proc NCStreamReaderCreateForHandler*(handler: NCReadHandler): NCStreamReader =
  add_ref(handler.handler.addr)
  result = cef_stream_reader_create_for_handler(handler.handler.addr)
    
# Create a new cef_stream_writer_t object for a file.
proc NCStreamWriterCreateForFile*(fileName: string): NCStreamWriter =
  let cname = to_cef(fileName)
  result = cef_stream_writer_create_for_file(cname)
  nc_free(cname)

# Create a new cef_stream_writer_t object for a custom handler.
proc NCStreamWriterCreateForHandler*(handler: NCWriteHandler): NCStreamWriter =
  add_ref(handler.handler.addr)
  result = cef_stream_writer_create_for_handler(handler.handler.addr)