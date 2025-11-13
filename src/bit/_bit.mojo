# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Bit utilities."""

from sys import bit_width_of
from bit import bit_reverse


# +--------------------------------------------------------------------------+ #
# | Bit Manipulate Int
# +--------------------------------------------------------------------------+ #
#
@always_inline("builtin")
fn get_bit(value: Int, place: Int) -> Bool:
    return ((value >> place) & 1) != 0


@always_inline("builtin")
fn set_bit(value: Int, place: Int) -> Int:
    return value | (1 << place)


@always_inline("builtin")
fn set_bit(value: Int, place: Int, bit: Bool) -> Int:
    var mask = 1 << place
    # TODO: -bool, or builtin Int()?
    return (value & ~mask) | (-bit.__int__() & mask)


@always_inline("builtin")
fn clr_bit(value: Int, place: Int) -> Int:
    return value & ~(1 << place)


@always_inline("builtin")
fn flp_bit(value: Int, place: Int) -> Int:
    return value ^ (1 << place)


@always_inline
fn reverse_bits(bin: Int) -> Int:
    return bit_reverse(bin)


@always_inline
fn reverse_bits(bin: Int, width: Int) -> Int:
    return bit_reverse(Int((Int64(bin) << (64 - width))))


# +--------------------------------------------------------------------------+ #
# | Bit Sign
# +--------------------------------------------------------------------------+ #
#
@always_inline("builtin")
fn bsign(bool: Bool) -> Int:
    return -(~bool).__int__() | bool.__int__()


@always_inline("builtin")
fn rsign(bool: Bool) -> Int:
    return -(bool).__int__() | (~bool).__int__()


# @always_inline
# fn reverse_bits(bin: UInt, width: UInt) -> Int:
#     # cant constant fold bit_reverse in mojo 25.1, wait for new version.
#     return bit_reverse(bin << (bit_width_of[Int]() - width))


# @always_inline
# fn idx_of_nth_set(value: Int, n: Int) -> Int:
