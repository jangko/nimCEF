include cef/cef_import

proc rh_read(self: ptr cef_read_handler, data: pointer, size: csize, n: csize): csize {.cef_callback.} =
  var handler = type_to_type(NCReadHandler, self)
  result = handler.OnRead(data, size.int, n.int).csize

proc rh_seek(self: ptr cef_read_handler, offset: int64, whence: cint): cint {.cef_callback.} =
  var handler = type_to_type(NCReadHandler, self)
  result = if handler.OnReadSeek(offset, whence.int): 0 else: 1

proc rh_tell(self: ptr cef_read_handler): int64 {.cef_callback.} =
  var handler = type_to_type(NCReadHandler, self)
  result = handler.OnReadTell()

proc rh_eof(self: ptr cef_read_handler): cint {.cef_callback.} =
  var handler = type_to_type(NCReadHandler, self)
  result = handler.OnReadEof().cint

proc rh_may_block(self: ptr cef_read_handler): cint {.cef_callback.} =
  var handler = type_to_type(NCReadHandler, self)
  result = handler.OnReadMayBlock().cint

proc initialize_read_handler(handler: ptr cef_read_handler) =
  init_base(handler)
  handler.read = rh_read
  handler.seek = rh_seek
  handler.tell = rh_tell
  handler.eof = rh_eof
  handler.may_block = rh_may_block

# Write raw binary data.
proc wh_write*(self: ptr cef_write_handler, data: pointer, size: csize, n: csize): csize {.cef_callback.} =
  var handler = type_to_type(NCWriteHandler, self)
  result = handler.OnWrite(data, size.int, n.int).csize

# Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
# SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
proc wh_seek*(self: ptr cef_write_handler, offset: int64, whence: cint): cint {.cef_callback.} =
  var handler = type_to_type(NCWriteHandler, self)
  result = if handler.OnWriteSeek(offset, whence.int): 0 else: 1

# Return the current offset position.
proc wh_tell*(self: ptr cef_write_handler): int64 {.cef_callback.} =
  var handler = type_to_type(NCWriteHandler, self)
  result = handler.OnWriteTell()

# Flush the stream.
proc wh_flush*(self: ptr cef_write_handler): cint {.cef_callback.} =
  var handler = type_to_type(NCWriteHandler, self)
  result = handler.OnWriteFlush().cint

# Return true (1) if this handler performs work like accessing the file
# system which may block. Used as a hint for determining the thread to access
# the handler from.
proc wh_may_block*(self: ptr cef_write_handler): cint {.cef_callback.} =
  var handler = type_to_type(NCWriteHandler, self)
  result = handler.OnWriteMayBlock().cint

proc initialize_write_handler(handler: ptr cef_write_handler) =
  init_base(handler)
  handler.write = wh_write
  handler.seek = wh_seek
  handler.tell = wh_tell
  handler.flush = wh_flush
  handler.may_block = wh_may_block
