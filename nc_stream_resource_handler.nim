import nc_util, nc_types, nc_resource_handler, nc_stream
import nc_request, nc_response, nc_cookie, nc_callback, nc_task

type
  # Object that represents a readable/writable character buffer.
  LocalBuffer = ref object
    buffer: string
    size: int
    bytes_requested: int
    bytes_written: int
    bytes_read: int
    
  NCStreamResourceHandler = ref object of NCResourceHandler
    status_code: int
    status_text: string
    mime_type: string
    header_map: NCStringMultiMap
    stream: NCStreamReader
    read_on_file_thread: bool
    buffer: LocalBuffer
  
  StreamResourceTask = ref object of NCTask
    stream_handler: NCStreamResourceHandler
    bytes_to_read: int
    callback: NCCallback
    
proc newBuffer(): LocalBuffer =
  new(result)
  result.size = 0
  result.bytes_requested = 0
  result.bytes_written = 0
  result.bytes_read = 0

proc Reset(buf: LocalBuffer, new_size: int) =
  if buf.size < new_size:
    buf.size = new_size
    buf.buffer = newString(buf.size)

  buf.bytes_requested = new_size
  buf.bytes_written = 0
  buf.bytes_read = 0
  
proc IsEmpty(buf: LocalBuffer): bool =
  result = buf.bytes_written == 0

proc CanRead(buf: LocalBuffer): bool =
  result = buf.bytes_read < buf.bytes_written

proc WriteTo(buf: LocalBuffer, data_out: pointer, bytes_to_read: int): int =
  let write_size = min(bytes_to_read, buf.bytes_written - buf.bytes_read)
  if write_size > 0:
    copyMem(data_out, buf.buffer[buf.bytes_read].addr, write_size)
    inc(buf.bytes_read, write_size)
  result = write_size

proc ReadFrom(buf: LocalBuffer, reader: NCStreamReader): int =
  # Read until the buffer is full or until Read() returns 0 to indicate no
  # more data.
  var bytes_read: int
  while true:
    bytes_read = reader.Read(addr(buf.buffer[buf.bytes_written]), 1, buf.bytes_requested - buf.bytes_written)
    inc(buf.bytes_written, bytes_read)
    if (bytes_read != 0) and (buf.bytes_written < buf.bytes_requested): break

  result = buf.bytes_written
  
#forward declaration
proc ReadOnFileThread(self: NCStreamResourceHandler, bytes_to_read: int, callback: NCCallback)
   
handlerImpl(stream_resource_task, StreamResourceTask):
  proc Execute*(self: StreamResourceTask) =
    ReadOnFileThread(self.stream_handler, self.bytes_to_read, self.callback)
  
proc newStreamResourceTask(handler: NCStreamResourceHandler, 
  bytes_to_read: int, callback: NCCallback): StreamResourceTask =
  result = stream_resource_task.NCCreate()
  result.bytes_to_read = bytes_to_read
  result.callback = callback
  result.stream_handler = handler
  
handlerImpl(stream_resource_handler, NCStreamResourceHandler):
  proc ProcessRequest*(self: NCStreamResourceHandler, request: NCRequest, callback: NCCallback): bool =
    callback.Continue()
    result = true

  proc GetResponseHeaders*(self: NCStreamResourceHandler, response: NCResponse,
    response_length: var int64, redirectUrl: var string) =
    if self.header_map.len != 0:
      response.SetHeaderMap(self.header_map)
    response_length = -1
    
  proc ReadResponse*(self: NCStreamResourceHandler, data_out: cstring, 
    bytes_to_read: int, bytes_read: var int, callback: NCCallback): bool =
    doAssert(bytes_to_read > 0)

    if self.read_on_file_thread:
      if (self.buffer != nil) and (self.buffer.CanRead() or self.buffer.IsEmpty()):
        if self.buffer.CanRead():
          # Provide data from the buffer.
          bytes_read = self.buffer.WriteTo(data_out, bytes_to_read)
          return bytes_read > 0
        else:
          # End of the steam.
          bytes_read = 0
          return false
      else:
        # Perform another read on the file thread.
        bytes_read = 0
        discard NCPostTask(TID_FILE, newStreamResourceTask(self, bytes_to_read, callback))
        return true
    else:
      #Read until the buffer is full or until Read() returns 0 to indicate no
      # more data.
      bytes_read = 0
      var read = 0
      var buf = data_out
      while true:
        read = self.stream.Read(addr(buf[bytes_read]), 1, bytes_to_read - bytes_read)
        inc(bytes_read, read)
        if (read != 0) and (bytes_read < bytes_to_read): break

      return bytes_read > 0
  
proc newNCStreamResourceHandler*(mime_type: string, stream: NCStreamReader): NCStreamResourceHandler =
  result = stream_resource_handler.NCCreate()
  result.status_code = 200
  result.status_text = "OK"
  result.mime_type = mime_type
  result.stream = stream
  result.header_map = newNCStringMultiMap()
  doAssert(result.mime_type != "")
  doAssert(stream.GetHandler() != nil)
  result.read_on_file_thread = stream.MayBlock()

proc newNCStreamResourceHandler*(status_code: int, status_text, mime_type: string, 
  header_map: NCStringMultiMap, stream: NCStreamReader): NCStreamResourceHandler =
  result = stream_resource_handler.NCCreate()
  result.status_code = status_code
  result.status_text = status_text
  result.mime_type = mime_type
  result.header_map = header_map
  result.stream = stream
  doAssert(result.mime_type != "")
  doAssert(stream.GetHandler() != nil)
  result.read_on_file_thread = stream.MayBlock()

proc ReadOnFileThread(self: NCStreamResourceHandler, bytes_to_read: int, callback: NCCallback) =
  NC_REQUIRE_FILE_THREAD()
  if self.buffer == nil:
    self.buffer = newBuffer()
    
  self.buffer.Reset(bytes_to_read)
  discard self.buffer.ReadFrom(self.stream)
  callback.Continue()