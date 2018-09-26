import nc_util, nc_stream, nc_time

# Structure that supports the reading of zip archives via the zlib unzip API.
# The functions of this structure should only be called on the thread that
# creates the object.
wrapAPI(NCZipReader, cef_zip_reader)

# Moves the cursor to the first file in the archive. Returns true (1) if the
# cursor position was set successfully.
proc moveToFirstFile*(self: NCZipReader): bool =
  self.wrapCall(move_to_first_file, result)

# Moves the cursor to the next file in the archive. Returns true (1) if the
# cursor position was set successfully.
proc moveToNextFile*(self: NCZipReader): bool =
  self.wrapCall(move_to_next_file, result)

# Moves the cursor to the specified file in the archive. If |caseSensitive|
# is true (1) then the search will be case sensitive. Returns true (1) if the
# cursor position was set successfully.
proc moveToFile*(self: NCZipReader, fileName: string, caseSensitive: bool): bool =
  self.wrapCall(move_to_file, result, fileName, caseSensitive)

# Closes the archive. This should be called directly to ensure that cleanup
# occurs on the correct thread.
proc close*(self: NCZipReader): bool =
  self.wrapCall(close, result)

# The below functions act on the file at the current cursor position.
# Returns the name of the file.
proc getFileName*(self: NCZipReader): string =
  self.wrapCall(get_file_name, result)

# Returns the uncompressed size of the file.
proc getFileSize*(self: NCZipReader): int64 =
  self.wrapCall(get_file_size, result)

# Returns the last modified timestamp for the file.
proc getFileLastModified*(self: NCZipReader): NCTime =
  self.wrapCall(get_file_last_modified, result)

# Opens the file for reading of uncompressed data. A read password may
# optionally be specified.
proc openFile*(self: NCZipReader, password: string = ""): bool =
  self.wrapCall(open_file, result, password)

# Closes the file.
proc closeFile*(self: NCZipReader): bool =
  self.wrapCall(close_file, result)

# Read uncompressed file contents into the specified buffer. Returns < 0 if
# an error occurred, 0 if at the end of file, or the number of bytes read.
proc readFile*(self: NCZipReader, buffer: pointer, bufferSize: int): int =
  self.wrapCall(read_file, result, buffer, bufferSize)

# Returns the current offset in the uncompressed file contents.
proc tell*(self: NCZipReader): int64 =
  self.wrapCall(tell, result)

# Returns true (1) if at end of the file contents.
proc eof*(self: NCZipReader): bool =
  self.wrapCall(eof, result)

# Create a new NCZipReader object. The returned object's functions can
# only be called from the thread that created the object.
proc ncZipReaderCreate*(stream: NCStreamReader): NCZipReader =
  wrapProc(cef_zip_reader_create, result, stream)