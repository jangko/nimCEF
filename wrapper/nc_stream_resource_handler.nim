import nc_util, nc_types, nc_resource_handler, nc_stream
import nc_request, nc_response, nc_cookie, nc_callback, nc_task

type
  # Object that represents a readable/writable character buffer.
  LocalBuffer = ref object
    buffer: string
    size: int
    bytesRequested: int
    bytesWritten: int
    bytesRead: int
    
  NCStreamResourceHandler* = ref object of NCResourceHandler
    statusCode: int
    statusText: string
    mimeType: string
    headerMap: NCStringMultiMap
    stream: NCStreamReader
    readOnFileThread: bool
    buffer: LocalBuffer
  
proc newBuffer(): LocalBuffer =
  new(result)
  result.size = 0
  result.bytesRequested = 0
  result.bytesWritten = 0
  result.bytesRead = 0

proc Reset(buf: LocalBuffer, newSize: int) =
  if buf.size < newSize:
    buf.size = newSize
    buf.buffer = newString(buf.size)

  buf.bytesRequested = newSize
  buf.bytesWritten = 0
  buf.bytesRead = 0
  
proc IsEmpty(buf: LocalBuffer): bool =
  result = buf.bytesWritten == 0

proc CanRead(buf: LocalBuffer): bool =
  result = buf.bytesRead < buf.bytesWritten

proc WriteTo(buf: LocalBuffer, data_out: pointer, bytesToRead: int): int =
  let writeSize = min(bytesToRead, buf.bytesWritten - buf.bytesRead)
  if writeSize > 0:
    copyMem(data_out, buf.buffer[buf.bytesRead].addr, writeSize)
    inc(buf.bytesRead, writeSize)
  result = writeSize

proc ReadFrom(buf: LocalBuffer, reader: NCStreamReader): int =
  # Read until the buffer is full or until Read() returns 0 to indicate no
  # more data.
  var bytesRead: int
  while true:
    bytesRead = reader.Read(addr(buf.buffer[buf.bytesWritten]), 1, buf.bytesRequested - buf.bytesWritten)
    inc(buf.bytesWritten, bytesRead)
    if not ((bytesRead != 0) and (buf.bytesWritten < buf.bytesRequested)): break

  result = buf.bytesWritten
  
#forward declaration
proc ReadOnFileThread(self: NCStreamResourceHandler, bytesToRead: int, callback: NCCallback)

handlerImpl(NCStreamResourceHandler):
  proc ProcessRequest*(self: NCStreamResourceHandler, request: NCRequest, callback: NCCallback): bool =
    callback.Continue()
    result = true

  proc GetResponseHeaders*(self: NCStreamResourceHandler, response: NCResponse,
    response_length: var int64, redirectUrl: var string) =
    if self.headerMap.len != 0:
      response.SetHeaderMap(self.headerMap)
    response_length = -1
    
  proc ReadResponse*(self: NCStreamResourceHandler, data_out: cstring, 
    bytesToRead: int, bytesRead: var int, callback: NCCallback): bool =
    doAssert(bytesToRead > 0)

    if self.readOnFileThread:
      if (self.buffer != nil) and (self.buffer.CanRead() or self.buffer.IsEmpty()):
        if self.buffer.CanRead():
          # Provide data from the buffer.
          bytesRead = self.buffer.WriteTo(data_out, bytesToRead)
          return bytesRead > 0
        else:
          # End of the steam.
          bytesRead = 0
          return false
      else:
        # Perform another read on the file thread.
        bytesRead = 0
        #NCBindTask(readOnFileTask, ReadOnFileThread)
        #discard NCPostTask(TID_FILE, readOnFileTask(self, bytesToRead, callback))
        ReadOnFileThread(self, bytesToRead, callback)
        return true
    else:
      #Read until the buffer is full or until Read() returns 0 to indicate no
      # more data.
      bytesRead = 0
      var read = 0
      var buf = data_out
      while true:
        read = self.stream.Read(addr(buf[bytesRead]), 1, bytesToRead - bytesRead)
        inc(bytesRead, read)
        if not ((read != 0) and (bytesRead < bytesToRead)): break

      return bytesRead > 0
  
proc newNCStreamResourceHandler*(mimeType: string, stream: NCStreamReader): NCStreamResourceHandler =
  result = NCStreamResourceHandler.NCCreate()
  result.statusCode = 200
  result.statusText = "OK"
  result.mimeType = mimeType
  result.stream = stream
  result.headerMap = newNCStringMultiMap()
  doAssert(result.mimeType != "")
  doAssert(stream.GetHandler() != nil)
  result.readOnFileThread = stream.MayBlock()

proc newNCStreamResourceHandler*(statusCode: int, statusText, mimeType: string, 
  headerMap: NCStringMultiMap, stream: NCStreamReader): NCStreamResourceHandler =
  result = NCStreamResourceHandler.NCCreate()
  result.statusCode = statusCode
  result.statusText = statusText
  result.mimeType = mimeType
  result.headerMap = headerMap
  result.stream = stream
  doAssert(result.mimeType != "")
  doAssert(stream.GetHandler() != nil)
  result.readOnFileThread = stream.MayBlock()

proc ReadOnFileThread(self: NCStreamResourceHandler, bytesToRead: int, callback: NCCallback) =
  #NC_REQUIRE_FILE_THREAD()
  if self.buffer == nil:
    self.buffer = newBuffer()
    
  self.buffer.Reset(bytesToRead)
  discard self.buffer.ReadFrom(self.stream)
  callback.Continue()