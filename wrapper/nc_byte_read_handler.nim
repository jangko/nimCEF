import nc_util, nc_types, nc_stream, rlocks

type
  # Create a new object for reading an array of bytes. An optional |source|
  # reference can be kept to keep the underlying data source from being
  # released while the reader exists.
  NCByteReadHandler* = ref object of NCReadHandler
    bytes: cstring
    size: int64
    offset: int64
    source: ref RootObj
    lock: RLock

handlerImpl(NCByteReadHandler):
  proc read*(self: NCByteReadHandler, data: pointer, size: int, n: int): int =
    acquire(self.lock)
    let s = (self.size - self.offset) div size
    let ret = min(n, s)
    copyMem(data, addr(self.bytes[self.offset.int]), ret * size)
    self.offset = self.offset + (ret * size).int64
    result = ret.int
    release(self.lock)
  
  proc seek*(self: NCByteReadHandler, offset: int64, whence: int): int =
    var rv = -1
    acquire(self.lock)
    case whence
    of NC_SEEK_CUR:
      if not (((self.offset + offset) > self.size) or ((self.offset + offset) < 0)):
        self.offset = self.offset + offset
        rv = 0
  
    of NC_SEEK_END:
      let offset_abs = abs(offset)
      if not (offset_abs > self.size):
        self.offset = self.size - offset_abs
        rv = 0
  
    of NC_SEEK_SET:
      if not ((offset > self.size) or (offset < 0)):
        self.offset = offset
        rv = 0
        
    else:
      #should not reach here
      doAssert(false)
  
    result = rv
    release(self.lock)
  
  proc tell*(self: NCByteReadHandler): int64 =
    acquire(self.lock)
    result = self.offset
    release(self.lock)
  
  proc eof*(self: NCByteReadHandler): bool =
    acquire(self.lock)
    result = self.offset >= self.size
    release(self.lock)
  
  proc mayBlock*(self: NCByteReadHandler): bool = false

proc newNCByteReadHandler*(bytes: cstring, size: int, source: ref RootObj): NCByteReadHandler =
  result = NCByteReadHandler.ncCreate()
  result.bytes = bytes
  result.size = size
  result.offset = 0
  result.source = source
  initRLock(result.lock)

