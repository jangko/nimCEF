import unicode, nc_byte_read_handler, nc_util, nc_types, nc_stream
import nc_zip_reader, tables, rlocks

type
  NCZipFile* = ref object of RootObj
    data: string

  FileMap = Table[string, NCZipFile]

  NCZipArchive* = ref object
    contents: FileMap
    lock: RLock

# Convert |str| to lowercase in a Unicode-friendly manner.
proc uniToLower(str: string): string =
  result = newStringOfCap(str.len)
  for c in runes(str):
    result.add $toLower(c)

proc Initialize(self: NCZipFile, dataSize: int): bool =
  self.data = newString(dataSize)
  result = true

proc GetData*(self: NCZipFile): string =
  result = self.data

proc GetDataSize*(self: NCZipFile): int =
  result = self.data.len

proc GetStreamReader*(self: NCZipFile): NCStreamReader =
  let handler = newNCByteReadHandler(self.data.cstring, self.data.len, self)
  result = NCStreamReaderCreateForHandler(handler)


proc Clear*(self: NCZipArchive) =
  acquire(self.lock)
  self.contents = initTable[string, NCZipFile]()
  release(self.lock)

proc GetFileCount*(self: NCZipArchive): int =
  acquire(self.lock)
  result = self.contents.len
  release(self.lock)

proc HasFile*(self: NCZipArchive, fileName: string): bool =
  acquire(self.lock)
  result = self.contents.hasKey(uniToLower(fileName))
  release(self.lock)

proc GetFile*(self: NCZipArchive, fileName: string): NCZipFile =
  acquire(self.lock)
  result = self.contents[uniToLower(fileName)]
  release(self.lock)

proc RemoveFile*(self: NCZipArchive, fileName: string): bool =
  acquire(self.lock)
  self.contents.del(uniToLower(fileName))
  release(self.lock)

proc GetFiles*(self: NCZipArchive): FileMap =
  acquire(self.lock)
  result = self.contents
  release(self.lock)

proc newZipArchive(): NCZipArchive =
  new(result)
  result.contents = initTable[string, NCZipFile]()
  initRLock(result.lock)
  
proc LoadZipArchive*(stream: NCStreamReader, password: string, overwriteExisting: bool): NCZipArchive =
  var reader = NCZipReaderCreate(stream)
  if reader.GetHandler() == nil:
    return nil

  if not reader.MoveToFirstFile():
    return nil

  var za = newZipArchive()
  while true:
    let size = reader.GetFileSize()
    if size == 0:
      #Skip directories and empty files.
      discard reader.MoveToNextFile()
      continue
    
    if not reader.OpenFile(password):
      break

    let name = uniToLower(reader.GetFileName())

    if za.contents.hasKey(name):
      if overwriteExisting:
        za.contents.del(name)
      else:
        #Skip files that already exist.
        discard reader.MoveToNextFile()
        continue

    var contents = NCZipFile()
    discard contents.Initialize(size.int)
      
    var data = contents.data.cstring
    var offset = 0

    # Read the file contents.
    while true:
      let bytesRead = reader.ReadFile(data[offset].addr, (size - offset).int)
      inc(offset, bytesRead)
      if not ((offset < size) and (not reader.Eof())): break

    doAssert(offset == size)
    discard reader.CloseFile()
    
    # Add the file to the map.
    za.contents[name] = contents
    if not reader.MoveToNextFile(): break

  result = za