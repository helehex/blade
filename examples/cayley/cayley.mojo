# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #
"""Cayley table image generator."""

from pathlib import Path
from sys import size_of
from math import align_up
from sys import argv

from blade import Signature


# +--------------------------------------------------------------------------+ #
# | Entry Point
# +--------------------------------------------------------------------------+ #
#
# This writes the multiplication table to a bmp file `img.bmp`
# Takes three arguments for the `+`, `-`, and `0` basis vectors respectively
#
# TODO: you currently have to add the blade.mojopkg to this directory manually
#
def main():
    # Set args
    var args = [3, 3, 3]
    for idx in range(1, len(argv())):
        args[idx] = Int(argv()[idx])

    # Define the signature
    var sig = Signature(args[0], args[1], args[2])

    # Define the pixel function
    @parameter
    fn _sample(x: Int, y: Int) -> ColorBGR888:
        m = sig.mul(x, y)
        c = m.sign
        v = (m.idx * 255) // sig.dims
        return ColorBGR888(v * Int(c == -1), v * Int(c == 0), v * Int(c == 1))

    # Write the image to a bitmap file
    write_bmp[_sample](Path("./img.bmp"), sig.dims, sig.dims)


# +--------------------------------------------------------------------------+ #
# | Bitmap encoder
# +--------------------------------------------------------------------------+ #
#
@fieldwise_init
@register_passable("trivial")
struct ColorBGR888:
    var b: UInt8
    var g: UInt8
    var r: UInt8


alias _UInt16 = InlineArray[UInt8, size_of[UInt16]()]
"""Used to avoid padding to the highest multiple of the highest sized field."""

alias _UInt32 = InlineArray[UInt8, size_of[UInt32]()]
"""Used to avoid padding to the highest multiple of the highest sized field."""


fn to_bytes[T: AnyType](ref object: T) -> Span[UInt8, origin_of(object)]:
    var byte_ptr = UnsafePointer(to=object).bitcast[UInt8]()
    return Span(ptr=byte_ptr, length=size_of[T]())


@fieldwise_init
struct BitmapFileHeader(Copyable & Movable):
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

    fn __init__(
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
struct BitmapInfoHeader(Copyable & Movable):
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

    fn __init__(
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


alias fn_sampler = fn (x: Int, y: Int) capturing [_] -> ColorBGR888


def write_bmp[sampler: fn_sampler](path: Path, width: Int, height: Int):
    bytes_per_pixel = 3
    bits_per_pixel = bytes_per_pixel * 8

    row_size = align_up(width * bytes_per_pixel, 4)
    img_size = row_size * height

    var file_header = BitmapFileHeader(
        0x4D42,
        size_of[BitmapFileHeader]() + size_of[BitmapInfoHeader]() + img_size,
        0,
        0,
        size_of[BitmapFileHeader]() + size_of[BitmapInfoHeader](),
    )

    var info_header = BitmapInfoHeader(
        size_of[BitmapInfoHeader](),
        width,
        height,
        1,
        bits_per_pixel,
        0,
        img_size,
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
