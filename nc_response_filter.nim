import cef/cef_response_filter_api, nc_util, nc_types
include cef/cef_import

type
  # Implement this structure to filter resource response content. The functions
  # of this structure will be called on the browser process IO thread.
  NCResponseFilter* = ref object of RootObj
    handler: cef_response_filter
    
proc GetHandler*(self: NCResponseFilter): ptr cef_response_filter {.inline.} =
  result = self.handler.addr
  
# Initialize the response filter. Will only be called a single time. The
# filter will not be installed if this function returns false (0).
method InitFilter*(self: NCResponseFilter): bool {.base.} =
  result = false

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

method Filter*(self: NCResponseFilter, data_in: pointer, data_in_size: int,
  data_in_read: var int, data_out: pointer, data_out_size: int,
  data_out_written: var int): cef_response_filter_status {.base.} =
  result = RESPONSE_FILTER_DONE

proc init_filter(self: ptr cef_response_filter): cint {.cef_callback.} =
  var handler = type_to_type(NCResponseFilter, self)
  result = handler.InitFilter().cint

proc filter(self: ptr cef_response_filter, data_in: pointer, data_in_size: csize,
  data_in_read: var csize, data_out: pointer, data_out_size: csize,
  data_out_written: var csize): cef_response_filter_status {.cef_callback.} =
  var handler = type_to_type(NCResponseFilter, self)
  var inRead = 0
  var outWrite = 0
  result = handler.Filter(data_in, data_in_size.int, inRead, data_out, data_out_size.int, outWrite)
  data_in_read = inRead.csize
  data_out_written = outWrite.csize
  
proc initialize_response_filter(handler: ptr cef_response_filter) =
  init_base(handler)
  handler.init_filter = init_filter
  handler.filter = filter
  
proc makeNCResponseFilter*(T: typedesc): auto =
  result = new(T)
  initialize_response_filter(result.GetHandler())