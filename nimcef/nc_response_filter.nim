import cef_response_filter_api, nc_util, nc_types, nc_util_impl
include cef_import

# Implement this structure to filter resource response content. The functions
# of this structure will be called on the browser process IO thread.
wrapCallback(NCResponseFilter, cef_response_filter):
  # Initialize the response filter. Will only be called a single time. The
  # filter will not be installed if this function returns false (0).
  proc Init*(self: T): bool

  # Called to filter a chunk of data. |data_in| is the input buffer containing
  # |data_in_size| bytes of pre-filter data (|data_in| will be NULL if
  # |data_in_size| is zero). |data_out| is the output buffer that can accept up
  # to |data_out_size| bytes of filtered output data. Set |data_in_read| to the
  # number of bytes that were read from |data_in|. Set |data_out_written| to
  # the number of bytes that were written into |data_out|. If some or all of
  # the pre-filter data was read successfully but more data is needed in order
  # to continue filtering (filtered output is pending) return
  # RESPONSE_FILTER_NEED_MORE_DATA. If some or all of the pre-filter data was
  # read successfully and all available filtered output has been written return
  # RESPONSE_FILTER_DONE. If an error occurs during filtering return
  # RESPONSE_FILTER_ERROR. This function will be called repeatedly until there
  # is no more data to filter (resource response is complete), |data_in_read|
  # matches |data_in_size| (all available pre-filter bytes have been read), and
  # the function returns RESPONSE_FILTER_DONE or RESPONSE_FILTER_ERROR. Do not
  # keep a reference to the buffers passed to this function.
  proc Filter*(self: T, data_in: pointer, data_in_size: int,
    data_in_read: var int, data_out: pointer, data_out_size: int,
    data_out_written: var int): cef_response_filter_status
