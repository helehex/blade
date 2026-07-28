# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #
"""Cayley table image generator."""

from std.pathlib import Path, _dir_of_current_file
from std.sys import argv

from bmp import *
from blade import Signature
from blade.combinatorics import Ordering, BinaryOrdering, SlexicOrdering


# +--------------------------------------------------------------------------+ #
# | Cayley
# +--------------------------------------------------------------------------+ #
#
# This uses the generated algebra to create a bmp file `img.bmp`
# Takes three arguments for the `+`, `-`, and `0` basis vectors respectively
# Currently displays a map of anti-commutation
#
def main() raises:
    # Set args
    var args = [3, 3, 3] if len(argv()) == 1 else [0, 0, 0]
    for idx in range(1, len(argv())):
        args[idx - 1] = Int(argv()[idx])

    # Define the signature
    var sig = Signature[BinaryOrdering](args[0], args[1], args[2])

    # Define the pixel function
    @parameter
    def _sample(x: Int, y: Int) -> ColorBGR888:
        m = sig.mul(x, y)
        # c = m.sign
        # v = (m.idx * 255) // sig.dims
        # return ColorBGR888(v * Int(c == -1), v * Int(c == 0), v * Int(c == 1))
        v = Float64(m.idx / sig.dims)
        return ColorBGR888(
            hsv=(v, 0.0, Float64(sig.mul(x, y).sign == sig.mul(y, x).sign))
        )

    # Write the image to a bitmap file
    write_bmp[_sample](
        _dir_of_current_file() / Path(".img.bmp"), sig.dims, sig.dims
    )
