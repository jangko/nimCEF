import cef/cef_stream_api, cef/cef_time_api, cef/cef_zip_reader_api
import nc_util, nc_stream

type
  # Structure that supports the reading of zip archives via the zlib unzip API.
  # The functions of this structure should only be called on the thread that
  # creates the object.
  NCZipReader* = ptr cef_zip_reader

# Moves the cursor to the first file in the archive. Returns true (1) if the
# cursor position was set successfully.
proc MoveToFirstFile*(self: NCZipReader): bool =
  result = self.move_to_first_file(self) == 1.cint

# Moves the cursor to the next file in the archive. Returns true (1) if the
# cursor position was set successfully.
proc MoveToNextFile*(self: NCZipReader): bool =
  result = self.move_to_next_file(self) == 1.cint

# Moves the cursor to the specified file in the archive. If |caseSensitive|
# is true (1) then the search will be case sensitive. Returns true (1) if the
# cursor position was set successfully.
proc MoveToFile*(self: NCZipReader, fileName: string, caseSensitive: bool): bool =
  let cname = to_cef_string(fileName)
  result = self.move_to_file(self, cname, caseSensitive.cint) == 1.cint
  cef_string_userfree_free(cname)

# Closes the archive. This should be called directly to ensure that cleanup
# occurs on the correct thread.
proc Close*(self: NCZipReader): bool =
  result = self.close(self) == 1.cint

# The below functions act on the file at the current cursor position.
# Returns the name of the file.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetFileName*(self: NCZipReader): string =
  result = to_nim_string(self.get_file_name(self))

# Returns the uncompressed size of the file.
proc GetFileSize*(self: NCZipReader): int64 =
  result = self.get_file_size(self)

# Returns the last modified timestamp for the file.
proc GetFileLastModified*(self: NCZipReader): cef_time =
  result = self.get_file_last_modified(self)

# Opens the file for reading of uncompressed data. A read password may
# optionally be specified.
proc OpenFile*(self: NCZipReader, password: string): bool =
  let cpass = to_cef_string(password)
  result = self.open_file(self, cpass) == 1.cint
  cef_string_userfree_free(cpass)

# Closes the file.
proc CloseFile*(self: NCZipReader): bool =
  result = self.close_file(self) == 1.cint

# Read uncompressed file contents into the specified buffer. Returns < 0 if
# an error occurred, 0 if at the end of file, or the number of bytes read.
proc ReadFile*(self: NCZipReader, buffer: pointer, bufferSize: int): int =
  result = self.read_file(self, buffer, bufferSize.cint).int

# Returns the current offset in the uncompressed file contents.
proc Tell*(self: NCZipReader): int64 =
  result = self.tell(self)

# Returns true (1) if at end of the file contents.
proc Eof*(self: NCZipReader): bool =
  result = self.eof(self) == 1.cint

# Create a new cef_zip_reader_t object. The returned object's functions can
# only be called from the thread that created the object.
proc NCZipReaderCreate*(stream: NCStreamReader): NCZipReader =
  result = cef_zip_reader_create(stream)

