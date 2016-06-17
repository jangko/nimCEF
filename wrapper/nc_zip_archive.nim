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

proc initialize(self: NCZipFile, dataSize: int): bool =
  self.data = newString(dataSize)
  result = true

proc getData*(self: NCZipFile): string =
  result = self.data

proc getDataSize*(self: NCZipFile): int =
  result = self.data.len

proc getStreamReader*(self: NCZipFile): NCStreamReader =
  let handler = newNCByteReadHandler(self.data.cstring, self.data.len, self)
  result = ncStreamReaderCreateForHandler(handler)


proc clear*(self: NCZipArchive) =
  acquire(self.lock)
  self.contents = initTable[string, NCZipFile]()
  release(self.lock)

proc getFileCount*(self: NCZipArchive): int =
  acquire(self.lock)
  result = self.contents.len
  release(self.lock)

proc hasFile*(self: NCZipArchive, fileName: string): bool =
  acquire(self.lock)
  result = self.contents.hasKey(uniToLower(fileName))
  release(self.lock)

proc getFile*(self: NCZipArchive, fileName: string): NCZipFile =
  acquire(self.lock)
  result = self.contents[uniToLower(fileName)]
  release(self.lock)

proc removeFile*(self: NCZipArchive, fileName: string): bool =
  acquire(self.lock)
  self.contents.del(uniToLower(fileName))
  release(self.lock)

proc getFiles*(self: NCZipArchive): FileMap =
  acquire(self.lock)
  result = self.contents
  release(self.lock)

proc newZipArchive(): NCZipArchive =
  new(result)
  result.contents = initTable[string, NCZipFile]()
  initRLock(result.lock)
  
proc loadZipArchive*(stream: NCStreamReader, password: string, overwriteExisting: bool): NCZipArchive =
  var reader = ncZipReaderCreate(stream)
  if reader.getHandler() == nil:
    return nil

  if not reader.moveToFirstFile():
    return nil

  var za = newZipArchive()
  while true:
    let size = reader.getFileSize()
    if size == 0:
      #Skip directories and empty files.
      discard reader.moveToNextFile()
      continue
    
    if not reader.openFile(password):
      break

    let name = uniToLower(reader.getFileName())

    if za.contents.hasKey(name):
      if overwriteExisting:
        za.contents.del(name)
      else:
        #Skip files that already exist.
        discard reader.moveToNextFile()
        continue

    var contents = NCZipFile()
    discard contents.initialize(size.int)
      
    var data = contents.data.cstring
    var offset = 0

    # Read the file contents.
    while true:
      let bytesRead = reader.readFile(data[offset].addr, (size - offset).int)
      inc(offset, bytesRead)
      if not ((offset < size) and (not reader.Eof())): break

    doAssert(offset == size)
    discard reader.closeFile()
    
    # Add the file to the map.
    za.contents[name] = contents
    if not reader.moveToNextFile(): break

  result = za