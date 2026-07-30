# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Bitmap encoder."""

from std.pathlib import Path
from std.sys import size_of
from std.math import align_up


# +----------------------------------------------------------------------------------------------+ #
# | Color
# +----------------------------------------------------------------------------------------------+ #
#
@fieldwise_init
struct ColorBGR888(TrivialRegisterPassable):
    var b: UInt8
    var g: UInt8
    var r: UInt8

    def __init__(out self, *, hsv: Tuple[Float64, Float64, Float64]):
        h6 = hsv[0] * 6.0
        h6_rem = h6 % 1.0
        a = hsv[2] * (1.0 - hsv[1])
        b = hsv[2] * (1.0 - (h6_rem * hsv[1]))
        c = hsv[2] * (1.0 - ((1.0 - h6_rem) * hsv[1]))
        if h6 < 1.0:
            rgb = (hsv[2], c, a)
        elif h6 < 2.0:
            rgb = (b, hsv[2], a)
        elif h6 < 3.0:
            rgb = (a, hsv[2], c)
        elif h6 < 4.0:
            rgb = (a, b, hsv[2])
        elif h6 < 5.0:
            rgb = (c, a, hsv[2])
        else:
            rgb = (hsv[2], a, b)
        self.r = UInt8(rgb[0] * 255)
        self.g = UInt8(rgb[1] * 255)
        self.b = UInt8(rgb[2] * 255)


# +----------------------------------------------------------------------------------------------+ #
# | Encoder
# +----------------------------------------------------------------------------------------------+ #
#
comptime _UInt16 = InlineArray[UInt8, size_of[UInt16]()]
"""Used to avoid padding to the highest multiple of the highest sized field."""

comptime _UInt32 = InlineArray[UInt8, size_of[UInt32]()]
"""Used to avoid padding to the highest multiple of the highest sized field."""


def to_bytes[T: AnyType](ref object: T) -> Span[UInt8, origin_of(object)]:
    var byte_ptr = UnsafePointer(to=object).bitcast[UInt8]()
    return Span(unsafe_ptr=byte_ptr, length=size_of[T]())


@fieldwise_init
struct BitmapFileHeader(Copyable):
    """This block of bytes is at the start of the file and is used to identify
    the file. A typical application reads this block first to ensure that the
    file is actually a BMP file and that it is not damaged.

    see: https://wikipedia.org/wiki/BMP_file_format"""

    var signature: _UInt16
    """The header field used to identify the BMP and DIB file is `0x4D42`
    in hexadecimal, same as 'BM' in ASCII."""

    var file_size: _UInt32
    """The size of the BMP file in bytes."""

    var reserved1: _UInt16
    """Reserved; actual value depends on the application that creates the
    image, if created manually can be `0`."""

    var reserved2: _UInt16
    """Reserved; actual value depends on the application that creates the
    image, if created manually can be `0`."""

    var offset_to_pixels: _UInt32
    """The offset, i.e. starting address, of the byte where the bitmap image
    data (pixel array) can be found."""

    def __init__(
        out self,
        signature: UInt16,
        file_size: UInt32,
        reserved1: UInt16,
        reserved2: UInt16,
        offset_to_pixels: UInt32,
    ):
        self.signature = signature.as_bytes()
        self.file_size = file_size.as_bytes()
        self.reserved1 = reserved1.as_bytes()
        self.reserved2 = reserved2.as_bytes()
        self.offset_to_pixels = offset_to_pixels.as_bytes()


@fieldwise_init
struct BitmapInfoHeader(Copyable):
    """This block of bytes tells the application detailed information about
    the image, which will be used to display the image on the screen.

    see: https://wikipedia.org/wiki/BMP_file_format"""

    var info_size: _UInt32
    """The size of this header, in bytes (`40`)."""

    var width: _UInt32
    """The bitmap width in pixels (signed integer)."""

    var height: _UInt32
    """The bitmap height in pixels (signed integer)."""

    var planes: _UInt16
    """The number of color planes (must be `1`)."""

    var bits_per_pixel: _UInt16
    """The number of bits per pixel, which is the color depth of the image.
    Typical values are `1`, `4`, `8`, `16`, `24` and `32`."""

    var compression: _UInt32
    """The compression method being used.
    See the next table for a list of possible values."""

    var img_size: _UInt32
    """The image size. This is the size of the raw bitmap data;
    a dummy `0` can be given for BI_RGB bitmaps."""

    var h_res: _UInt32
    """The horizontal resolution of the image.
    (pixel per metre, signed integer)."""

    var v_res: _UInt32
    """The vertical resolution of the image.
    (pixel per metre, signed integer)."""

    var palette_size: _UInt32
    """The number of colors in the color palette,
    or `0` to default to `2**n`."""

    var icc: _UInt32
    """The number of important colors used, or 0 when every color is important; generally ignored."""

    def __init__(
        out self,
        info_size: UInt32,
        width: UInt32,
        height: UInt32,
        planes: UInt16,
        bits_per_pixel: UInt16,
        compression: UInt32,
        img_size: UInt32,
        h_res: UInt32,
        v_res: UInt32,
        palette_size: UInt32,
        icc: UInt32,
    ):
        self.info_size = info_size.as_bytes()
        self.width = width.as_bytes()
        self.height = height.as_bytes()
        self.planes = planes.as_bytes()
        self.bits_per_pixel = bits_per_pixel.as_bytes()
        self.compression = compression.as_bytes()
        self.img_size = img_size.as_bytes()
        self.h_res = h_res.as_bytes()
        self.v_res = v_res.as_bytes()
        self.palette_size = palette_size.as_bytes()
        self.icc = icc.as_bytes()


comptime fn_sampler = def(x: Int, y: Int) capturing[_] -> ColorBGR888


def write_bmp[sampler: fn_sampler](path: Path, width: Int, height: Int) raises:
    bytes_per_pixel = 3
    bits_per_pixel = bytes_per_pixel * 8

    row_size = align_up(width * bytes_per_pixel, 4)
    img_size = row_size * height

    var file_header = BitmapFileHeader(
        0x4D42,
        UInt32(size_of[BitmapFileHeader]() + size_of[BitmapInfoHeader]() + img_size),
        0,
        0,
        UInt32(size_of[BitmapFileHeader]() + size_of[BitmapInfoHeader]()),
    )

    var info_header = BitmapInfoHeader.__init__(
        UInt32(size_of[BitmapInfoHeader]()),
        UInt32(width),
        UInt32(height),
        1,
        UInt16(bits_per_pixel),
        0,
        UInt32(img_size),
        2**100,
        2**100,
        0,
        0,
    )

    rem = List[UInt8](length=row_size - (width * bytes_per_pixel), fill=0)

    with open(path, "w") as bmp_out:
        bmp_out.write_bytes(to_bytes(file_header))
        bmp_out.write_bytes(to_bytes(info_header))
        for y in range(height):
            for x in range(width):
                bmp_out.write_bytes(to_bytes(sampler(x, y)))
            bmp_out.write_bytes(Span[UInt8](rem))
