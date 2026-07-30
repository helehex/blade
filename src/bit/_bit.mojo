# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Bit utilities."""

from std.sys import bit_width_of
from std.bit import bit_reverse


# +----------------------------------------------------------------------------------------------+ #
# | Bit Manipulate Int
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline("builtin")
def get_bit(value: Int, place: Int) -> Bool:
    return ((value >> place) & 1) != 0


@always_inline("builtin")
def set_bit(value: Int, place: Int) -> Int:
    return value | (1 << place)


@always_inline("builtin")
def set_bit(value: Int, place: Int, bit: Bool) -> Int:
    var mask = 1 << place
    # TODO: -bool, or builtin Int()?
    return (value & ~mask) | (-bit.__int__() & mask)


@always_inline("builtin")
def clr_bit(value: Int, place: Int) -> Int:
    return value & ~(1 << place)


@always_inline("builtin")
def flp_bit(value: Int, place: Int) -> Int:
    return value ^ (1 << place)


@always_inline
def reverse_bits(bin: Int) -> Int:
    return bit_reverse(bin)


@always_inline
def reverse_bits(bin: Int, width: Int) -> Int:
    return bit_reverse(bin << bit_width_of[Int]() - width)


# +----------------------------------------------------------------------------------------------+ #
# | Bit Sign
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline("builtin")
def bsign(bool: Bool) -> Int:
    return -(~bool).__int__() | bool.__int__()


@always_inline("builtin")
def rsign(bool: Bool) -> Int:
    return -(bool).__int__() | (~bool).__int__()
