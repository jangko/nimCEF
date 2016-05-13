import nc_util, nc_stream, nc_time

# Structure that supports the reading of zip archives via the zlib unzip API.
# The functions of this structure should only be called on the thread that
# creates the object.
wrapAPI(NCZipReader, cef_zip_reader)

# Moves the cursor to the first file in the archive. Returns true (1) if the
# cursor position was set successfully.
proc MoveToFirstFile*(self: NCZipReader): bool =
  result = self.handler.move_to_first_file(self.handler) == 1.cint

# Moves the cursor to the next file in the archive. Returns true (1) if the
# cursor position was set successfully.
proc MoveToNextFile*(self: NCZipReader): bool =
  result = self.handler.move_to_next_file(self.handler) == 1.cint

# Moves the cursor to the specified file in the archive. If |caseSensitive|
# is true (1) then the search will be case sensitive. Returns true (1) if the
# cursor position was set successfully.
proc MoveToFile*(self: NCZipReader, fileName: string, caseSensitive: bool): bool =
  let cname = to_cef(fileName)
  result = self.handler.move_to_file(self.handler, cname, caseSensitive.cint) == 1.cint
  nc_free(cname)

# Closes the archive. This should be called directly to ensure that cleanup
# occurs on the correct thread.
proc Close*(self: NCZipReader): bool =
  result = self.handler.close(self.handler) == 1.cint

# The below functions act on the file at the current cursor position.
# Returns the name of the file.
proc GetFileName*(self: NCZipReader): string =
  result = to_nim(self.handler.get_file_name(self.handler))

# Returns the uncompressed size of the file.
proc GetFileSize*(self: NCZipReader): int64 =
  result = self.handler.get_file_size(self.handler)

# Returns the last modified timestamp for the file.
proc GetFileLastModified*(self: NCZipReader): NCTime =
  result = to_nim(self.handler.get_file_last_modified(self.handler))

# Opens the file for reading of uncompressed data. A read password may
# optionally be specified.
proc OpenFile*(self: NCZipReader, password: string = nil): bool =
  let cpass = to_cef(password)
  result = self.handler.open_file(self.handler, cpass) == 1.cint
  nc_free(cpass)
  
# Closes the file.
proc CloseFile*(self: NCZipReader): bool =
  result = self.handler.close_file(self.handler) == 1.cint

# Read uncompressed file contents into the specified buffer. Returns < 0 if
# an error occurred, 0 if at the end of file, or the number of bytes read.
proc ReadFile*(self: NCZipReader, buffer: pointer, bufferSize: int): int =
  result = self.handler.read_file(self.handler, buffer, bufferSize.cint).int

# Returns the current offset in the uncompressed file contents.
proc Tell*(self: NCZipReader): int64 =
  result = self.handler.tell(self.handler)

# Returns true (1) if at end of the file contents.
proc Eof*(self: NCZipReader): bool =
  result = self.handler.eof(self.handler) == 1.cint

# Create a new cef_zip_reader_t object. The returned object's functions can
# only be called from the thread that created the object.
proc NCZipReaderCreate*(stream: NCStreamReader): NCZipReader =
  add_ref(stream)
  result = nc_wrap(cef_zip_reader_create(stream))

