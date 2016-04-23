import cef/cef_download_item_api, cef/cef_time_api, nc_util

type
  # Structure used to represent a download item.
  NCDownloadItem* = ptr cef_download_item


# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCDownloadItem): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if the download is in progress.
proc IsInProgress*(self: NCDownloadItem): bool =
  result = self.is_in_progress(self) == 1.cint

# Returns true (1) if the download is complete.
proc IsComplete*(self: NCDownloadItem): bool =
  result = self.is_complete(self) == 1.cint

# Returns true (1) if the download has been canceled or interrupted.
proc IsCanceled*(self: NCDownloadItem): bool =
  result = self.is_canceled(self) == 1.cint

# Returns a simple speed estimate in bytes/s.
proc GetCurrentSpeed*(self: NCDownloadItem): int64 =
  result = self.get_current_speed(self)

# Returns the rough percent complete or -1 if the receive total size is
# unknown.
proc GetPercentComplete*(self: NCDownloadItem): int =
  result = self.get_percent_complete(self)

# Returns the total number of bytes.
proc GetTotalBytes*(self: NCDownloadItem): int64 =
  result = self.get_total_bytes(self)

# Returns the number of received bytes.
proc GetReceivedBytes*(self: NCDownloadItem): int64 =
  result = self.get_received_bytes(self)

# Returns the time that the download started.
proc GetStartTime*(self: NCDownloadItem): cef_time =
  result = self.get_start_time(self)

# Returns the time that the download ended.
proc GetEndTime*(self: NCDownloadItem): cef_time =
  result = self.get_end_time(self)

# Returns the full path to the downloaded or downloading file.
# The resulting string must be freed by calling string_free().
proc GetFullPath*(self: NCDownloadItem): string =
  result = to_nim(self.get_full_path(self))

# Returns the unique identifier for this download.
proc GetId*(self: NCDownloadItem): uint32 =
  result = self.get_id(self)

# Returns the URL.
# The resulting string must be freed by calling string_free().
proc GetUrl*(self: NCDownloadItem): string =
  result = to_nim(self.get_url(self))

# Returns the original URL before any redirections.
# The resulting string must be freed by calling string_free().
proc GetOriginalUrl*(self: NCDownloadItem): string =
  result = to_nim(self.get_original_url(self))

# Returns the suggested file name.
# The resulting string must be freed by calling string_free().
proc GetSuggestedFileName*(self: NCDownloadItem): string =
  result = to_nim(self.get_suggested_file_name(self))

# Returns the content disposition.
# The resulting string must be freed by calling string_free().
proc GetContentDisposition*(self: NCDownloadItem): string =
  result = to_nim(self.get_content_disposition(self))

# Returns the mime type.
# The resulting string must be freed by calling string_free().
proc GetMimeType*(self: NCDownloadItem): string =
  result = to_nim(self.get_mime_type(self))