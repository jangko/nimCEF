import nc_time, nc_util

# Structure used to represent a download item.
wrapAPI(NCDownloadItem, cef_download_item)

# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc isValid*(self: NCDownloadItem): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if the download is in progress.
proc isInProgress*(self: NCDownloadItem): bool =
  self.wrapCall(is_in_progress, result)

# Returns true (1) if the download is complete.
proc isComplete*(self: NCDownloadItem): bool =
  self.wrapCall(is_complete, result)

# Returns true (1) if the download has been canceled or interrupted.
proc isCanceled*(self: NCDownloadItem): bool =
  self.wrapCall(is_canceled, result)

# Returns a simple speed estimate in bytes/s.
proc getCurrentSpeed*(self: NCDownloadItem): int64 =
  self.wrapCall(get_current_speed, result)

# Returns the rough percent complete or -1 if the receive total size is
# unknown.
proc getPercentComplete*(self: NCDownloadItem): int =
  self.wrapCall(get_percent_complete, result)

# Returns the total number of bytes.
proc getTotalBytes*(self: NCDownloadItem): int64 =
  self.wrapCall(get_total_bytes, result)

# Returns the number of received bytes.
proc getReceivedBytes*(self: NCDownloadItem): int64 =
  self.wrapCall(get_received_bytes, result)

# Returns the time that the download started.
proc getStartTime*(self: NCDownloadItem): NCTime =
  self.wrapCall(get_start_time, result)

# Returns the time that the download ended.
proc getEndTime*(self: NCDownloadItem): NCTime =
  self.wrapCall(get_end_time, result)

# Returns the full path to the downloaded or downloading file.
proc getFullPath*(self: NCDownloadItem): string =
  self.wrapCall(get_full_path, result)

# Returns the unique identifier for this download.
proc getId*(self: NCDownloadItem): uint32 =
  self.wrapCall(get_id, result)

# Returns the URL.
proc getUrl*(self: NCDownloadItem): string =
  self.wrapCall(get_url, result)

# Returns the original URL before any redirections.
proc getOriginalUrl*(self: NCDownloadItem): string =
  self.wrapCall(get_original_url, result)

# Returns the suggested file name.
proc getSuggestedFileName*(self: NCDownloadItem): string =
  self.wrapCall(get_suggested_file_name, result)

# Returns the content disposition.
proc getContentDisposition*(self: NCDownloadItem): string =
  self.wrapCall(get_content_disposition, result)

# Returns the mime type.
proc getMimeType*(self: NCDownloadItem): string =
  self.wrapCall(get_mime_type, result)