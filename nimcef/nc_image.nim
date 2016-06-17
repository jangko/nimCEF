import nc_util, nc_types, nc_value

# Container for a single image represented at different scale factors. All
# image representations should be the same size in density independent pixel
# (DIP) units. For example, if the image at scale factor 1.0 is 100x100 pixels
# then the image at scale factor 2.0 should be 200x200 pixels -- both images
# will display with a DIP size of 100x100 units. The functions of this
# structure must be called on the browser process UI thread.
wrapAPI(NCImage, cef_image)

# Returns true (1) if this Image is NULL.
proc isEmpty*(self: NCImage): bool =
  self.wrapCall(is_empty, result)

# Returns true (1) if this Image and |that| Image share the same underlying
# storage. Will also return true (1) if both images are NULL.
proc isSame*(self, that: NCImage): bool =
  self.wrapCall(is_same, result, that)

# Add a bitmap image representation for |scale_factor|. Only 32-bit RGBA/BGRA
# formats are supported. |pixel_width| and |pixel_height| are the bitmap
# representation size in pixel coordinates. |pixel_data| is the array of
# pixel data and should be |pixel_width| x |pixel_height| x 4 bytes in size.
# |color_type| and |alpha_type| values specify the pixel format.
proc addBitmap*(self: NCImage, scale_factor: float32,
  pixel_width, pixel_height: int, color_type: cef_color_type,
  alpha_type: cef_alpha_type, pixel_data: cstring,
  pixel_data_size: int): int =
  self.wrapCall(add_bitmap, result, scale_factor, pixel_width, pixel_height, color_type,
    alpha_type, pixel_data, pixel_data_size)

# Add a PNG image representation for |scale_factor|. |png_data| is the image
# data of size |png_data_size|. Any alpha transparency in the PNG data will
# be maintained.
proc addPNG*(self: NCImage, scale_factor: float32,
  png_data: cstring, png_data_size: int): int =
  self.wrapCall(add_png, result, scale_factor, png_data, png_data_size)

# Create a JPEG image representation for |scale_factor|. |jpeg_data| is the
# image data of size |jpeg_data_size|. The JPEG format does not support
# transparency so the alpha byte will be set to 0xFF for all pixels.
proc addJPEG*(self: NCImage, scale_factor: float32,
  jpeg_data: cstring, jpeg_data_size: int): int =
  self.wrapCall(add_jpeg, result, scale_factor, jpeg_data, jpeg_data_size)

# Returns the image width in density independent pixel (DIP) units.
proc getWidth*(self: NCImage): int =
  self.wrapCall(get_width, result)

# Returns the image height in density independent pixel (DIP) units.
proc getHeight*(self: NCImage): int =
  self.wrapCall(get_height, result)

# Returns true (1) if this image contains a representation for
# |scale_factor|.
proc hasRepresentation*(self: NCImage, scale_factor: float32): int =
  self.wrapCall(has_representation, result, scale_factor)

# Removes the representation for |scale_factor|. Returns true (1) on success.
proc removeRepresentation*(self: NCImage, scale_factor: float32): int =
  self.wrapCall(remove_representation, result, scale_factor)

# Returns information for the representation that most closely matches
# |scale_factor|. |actual_scale_factor| is the actual scale factor for the
# representation. |pixel_width| and |pixel_height| are the representation
# size in pixel coordinates. Returns true (1) on success.
proc getRepresentationInfo*(self: NCImage,
  scale_factor: float32, actual_scale_factor: var float32, pixel_width: var int,
  pixel_height: var int): int =
  self.wrapCall(get_representation_info, result, scale_factor, actual_scale_factor,
    pixel_width, pixel_height)

# Returns the bitmap representation that most closely matches |scale_factor|.
# Only 32-bit RGBA/BGRA formats are supported. |color_type| and |alpha_type|
# values specify the desired output pixel format. |pixel_width| and
# |pixel_height| are the output representation size in pixel coordinates.
# Returns a cef_binary_value_t containing the pixel data on success or NULL
# on failure.
proc getAsBitmap*(self: NCImage, scale_factor: float32,
  color_type: cef_color_type, alpha_type: cef_alpha_type,
  pixel_width: var int, pixel_height: var int): NCBinaryValue =
  self.wrapCall(get_as_bitmap, result, scale_factor, color_type, alpha_type,
    pixel_width, pixel_height)

# Returns the PNG representation that most closely matches |scale_factor|. If
# |with_transparency| is true (1) any alpha transparency in the image will be
# represented in the resulting PNG data. |pixel_width| and |pixel_height| are
# the output representation size in pixel coordinates. Returns a
# cef_binary_value_t containing the PNG image data on success or NULL on
# failure.
proc getAsPNG*(self: NCImage, scale_factor: float32, with_transparency: int,
  pixel_width: var int, pixel_height: var int): ptr cef_binary_value =
  self.wrapCall(get_as_png, result, scale_factor, with_transparency,
    pixel_width, pixel_height)

# Returns the JPEG representation that most closely matches |scale_factor|.
# |quality| determines the compression level with 0 == lowest and 100 ==
# highest. The JPEG format does not support alpha transparency and the alpha
# channel, if any, will be discarded. |pixel_width| and |pixel_height| are
# the output representation size in pixel coordinates. Returns a
# cef_binary_value_t containing the JPEG image data on success or NULL on
# failure.
proc getAsJPEG*(self: NCImage, scale_factor: float32, quality: int,
  pixel_width: var int, pixel_height: var int): ptr cef_binary_value =
  self.wrapCall(get_as_jpeg, result, scale_factor, quality, pixel_width, pixel_height)

# Create a new cef_image_t. It will initially be NULL. Use the Add*() functions
# to add representations at different scale factors.

proc ncImageCreate(): NCImage =
  wrapProc(cef_image_create, result)
