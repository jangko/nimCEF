import cef_base, cef_time
include cef_import

type
  # Structure used to represent a download item.
  cef_download_item* = object
    base*: cef_base

    # Returns true (1) if this object is valid. Do not call any other functions
    # if this function returns false (0).
    is_valid*: proc(self: ptr cef_download_item): cint {.cef_callback.}
  
    # Returns true (1) if the download is in progress.
    is_in_progress*: proc(self: ptr cef_download_item): cint {.cef_callback.}
  
    # Returns true (1) if the download is complete.
    is_complete*: proc(self: ptr cef_download_item): cint {.cef_callback.}
  
    # Returns true (1) if the download has been canceled or interrupted.
    is_canceled*: proc(self: ptr cef_download_item): cint {.cef_callback.}
  
    # Returns a simple speed estimate in bytes/s.
    get_current_speed*: proc(self: ptr cef_download_item): int64 {.cef_callback.}
  
    # Returns the rough percent complete or -1 if the receive total size is
    # unknown.
    get_percent_complete*: proc(self: ptr cef_download_item): cint {.cef_callback.}
  
    # Returns the total number of bytes.
    get_total_bytes*: proc(self: ptr cef_download_item): int64 {.cef_callback.}
  
    # Returns the number of received bytes.
    get_received_bytes*: proc(self: ptr cef_download_item): int64 {.cef_callback.}
  
    # Returns the time that the download started.
    get_start_time*: proc(self: ptr cef_download_item): cef_time {.cef_callback.}
  
    # Returns the time that the download ended.
    get_end_time*: proc(self: ptr cef_download_item): cef_time {.cef_callback.}
  
    # Returns the full path to the downloaded or downloading file.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_full_path*: proc(self: ptr cef_download_item): cef_string_userfree {.cef_callback.}
  
    # Returns the unique identifier for this download.
    get_id*: proc(self: ptr cef_download_item): uint32 {.cef_callback.}
  
    # Returns the URL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_url*: proc(self: ptr cef_download_item): cef_string_userfree {.cef_callback.}
  
    # Returns the original URL before any redirections.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_original_url*: proc(self: ptr cef_download_item): cef_string_userfree {.cef_callback.}
  
    # Returns the suggested file name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_suggested_file_name*: proc(self: ptr cef_download_item): cef_string_userfree {.cef_callback.}
  
    # Returns the content disposition.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_content_disposition*: proc(self: ptr cef_download_item): cef_string_userfree {.cef_callback.}
  
    # Returns the mime type.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_mime_type*: proc(self: ptr cef_download_item): cef_string_userfree {.cef_callback.}