import cef_base_api, cef_value_api
include cef_import

# Container for a single image represented at different scale factors. All
# image representations should be the same size in density independent pixel
# (DIP) units. For example, if the image at scale factor 1.0 is 100x100 pixels
# then the image at scale factor 2.0 should be 200x200 pixels -- both images
# will display with a DIP size of 100x100 units. The functions of this
# structure must be called on the browser process UI thread.
type
  cef_image* = object
    # Base structure.
    base*: cef_base

    # Returns true (1) if this Image is NULL.
    is_empty*: proc(self: ptr cef_image): cint {.cef_callback.}

    # Returns true (1) if this Image and |that| Image share the same underlying
    # storage. Will also return true (1) if both images are NULL.
    is_same*: proc(self, that: ptr cef_image): cint {.cef_callback.}

    # Add a bitmap image representation for |scale_factor|. Only 32-bit RGBA/BGRA
    # formats are supported. |pixel_width| and |pixel_height| are the bitmap
    # representation size in pixel coordinates. |pixel_data| is the array of
    # pixel data and should be |pixel_width| x |pixel_height| x 4 bytes in size.
    # |color_type| and |alpha_type| values specify the pixel format.
    add_bitmap*: proc(self: ptr cef_image, scale_factor: cfloat,
      pixel_width, pixel_height: cint, color_type: cef_color_type,
      alpha_type: cef_alpha_type, pixel_data: cstring,
      pixel_data_size: csize): cint {.cef_callback.}

    # Add a PNG image representation for |scale_factor|. |png_data| is the image
    # data of size |png_data_size|. Any alpha transparency in the PNG data will
    # be maintained.
    add_png*: proc(self: ptr cef_image, scale_factor: cfloat,
      png_data: cstring, png_data_size: csize): cint {.cef_callback.}

    # Create a JPEG image representation for |scale_factor|. |jpeg_data| is the
    # image data of size |jpeg_data_size|. The JPEG format does not support
    # transparency so the alpha byte will be set to 0xFF for all pixels.
    add_jpeg*: proc(self: ptr cef_image, scale_factor: cfloat,
      jpeg_data: cstring, jpeg_data_size: csize): cint {.cef_callback.}

    # Returns the image width in density independent pixel (DIP) units.
    get_width*: proc(self: ptr cef_image): csize {.cef_callback.}

    # Returns the image height in density independent pixel (DIP) units.
    get_height*: proc(self: ptr cef_image): csize {.cef_callback.}

    # Returns true (1) if this image contains a representation for
    # |scale_factor|.
    has_representation*: proc(self: ptr cef_image,
      scale_factor: cfloat): cint {.cef_callback.}

    # Removes the representation for |scale_factor|. Returns true (1) on success.
    remove_representation*: proc(self: ptr cef_image,
      scale_factor: cfloat): cint {.cef_callback.}
  
    # Returns information for the representation that most closely matches
    # |scale_factor|. |actual_scale_factor| is the actual scale factor for the
    # representation. |pixel_width| and |pixel_height| are the representation
    # size in pixel coordinates. Returns true (1) on success.
    get_representation_info*: proc(self: ptr cef_image,
      scale_factor: cfloat, actual_scale_factor: var cfloat, pixel_width: var cint,
      pixel_height: var cint): cint {.cef_callback.}

    # Returns the bitmap representation that most closely matches |scale_factor|.
    # Only 32-bit RGBA/BGRA formats are supported. |color_type| and |alpha_type|
    # values specify the desired output pixel format. |pixel_width| and
    # |pixel_height| are the output representation size in pixel coordinates.
    # Returns a cef_binary_value_t containing the pixel data on success or NULL
    # on failure.
    get_as_bitmap*: proc(self: ptr cef_image, scale_factor: cfloat,
      color_type: cef_color_type, alpha_type: cef_alpha_type,
      pixel_width: var cint, pixel_height: var cint): ptr cef_binary_value {.cef_callback.}

    # Returns the PNG representation that most closely matches |scale_factor|. If
    # |with_transparency| is true (1) any alpha transparency in the image will be
    # represented in the resulting PNG data. |pixel_width| and |pixel_height| are
    # the output representation size in pixel coordinates. Returns a
    # cef_binary_value_t containing the PNG image data on success or NULL on
    # failure.
    get_as_png*: proc(self: ptr cef_image, scale_factor: cfloat, with_transparency: cint,
      pixel_width: var cint, pixel_height: var cint): ptr cef_binary_value {.cef_callback.}

    # Returns the JPEG representation that most closely matches |scale_factor|.
    # |quality| determines the compression level with 0 == lowest and 100 ==
    # highest. The JPEG format does not support alpha transparency and the alpha
    # channel, if any, will be discarded. |pixel_width| and |pixel_height| are
    # the output representation size in pixel coordinates. Returns a
    # cef_binary_value_t containing the JPEG image data on success or NULL on
    # failure.
    get_as_jpeg*: proc(self: ptr cef_image, scale_factor: cfloat, quality: cint,
      pixel_width: var cint, pixel_height: var cint): ptr cef_binary_value {.cef_callback.}

# Create a new cef_image_t. It will initially be NULL. Use the Add*() functions
# to add representations at different scale factors.

proc cef_image_create(): ptr cef_image {.cef_import.}
