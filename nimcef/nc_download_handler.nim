import nc_util, nc_util_impl, cef_download_handler_api
import nc_types, nc_drag_data, nc_download_item
include cef_import

# Callback structure used to asynchronously cancel a download.
wrapAPI(NCDownloadItemCallback, cef_download_item_callback, false)

# Call to cancel the download.
proc Cancel*(self: NCDownloadItemCallback) =
  self.wrapCall(cancel)

# Call to pause the download.
proc Pause*(self: NCDownloadItemCallback) =
  self.wrapCall(pause)

# Call to resume the download.
proc Resume*(self: NCDownloadItemCallback) =
  self.wrapCall(resume)

# Callback structure used to asynchronously continue a download.
wrapAPI(NCBeforeDownloadCallback, cef_before_download_callback, false)

# Call to continue the download. Set |download_path| to the full file path
# for the download including the file name or leave blank to use the
# suggested name and the default temp directory. Set |show_dialog| to true
# (1) if you do wish to show the default "Save As" dialog.
proc Continue*(self: NCBeforeDownloadCallback, download_path: string, show_dialog: bool) =
  self.wrapCall(cont, download_path, show_dialog)

# Structure used to handle file downloads. The functions of this structure will
# called on the browser process UI thread.
wrapCallback(NCDownloadHandler, cef_download_handler):
  # Called before a download begins. |suggested_name| is the suggested name for
  # the download file. By default the download will be canceled. Execute
  # |callback| either asynchronously or in this function to continue the
  # download if desired. Do not keep a reference to |download_item| outside of
  # this function.
  proc onBeforeDownload*(self: T, browser: NCBrowser,
    download_item: NCDownloadItem, suggested_name: string,
    callback: NCBeforeDownloadCallback)

  #--Download Handler
  # Called when a download's status or progress information has been updated.
  # This may be called multiple times before and after on_before_download().
  # Execute |callback| either asynchronously or in this function to cancel the
  # download if desired. Do not keep a reference to |download_item| outside of
  # this function.
  proc onDownloadUpdated*(self: T, browser: NCBrowser,
    download_item: NCDownloadItem, callback: NCDownloadItemCallback)