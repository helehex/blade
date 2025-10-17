# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Bit utilities."""

from sys import bit_width_of
from bit import count_trailing_zeros, count_leading_zeros, bit_reverse


# +----------------------------------------------------------------------------------------------+ #
# | Bit Manipulate Int
# +----------------------------------------------------------------------------------------------+ #
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
fn reverse_bits(bin: Int, width: Int) -> Int:
    return bit_reverse(Int((Int64(bin) << (64 - width))))


# +----------------------------------------------------------------------------------------------+ #
# | Bit Sign
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline("builtin")
fn bsign(bool: Bool) -> Int:
    return -(~bool).__int__() | bool.__int__()


@always_inline("builtin")
fn rsign(bool: Bool) -> Int:
    return -(bool).__int__() | (~bool).__int__()


# +----------------------------------------------------------------------------------------------+ #
# | Bit Iteration
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct SetBitIter[reversed: Bool = False]:
    var binary: Int
    var bit_idx: Int

    @always_inline("nodebug")
    fn __init__(out self, binary: Int):
        self.binary = binary

        @parameter
        if reversed:
            self.bit_idx = bit_width_of[Int]() - count_leading_zeros(binary) - 1
        else:
            self.bit_idx = count_trailing_zeros(binary)

    @always_inline("nodebug")
    fn __iter__(self) -> Self:
        return self

    @always_inline("nodebug")
    fn __reversed__(self) -> SetBitIter[~reversed]:
        return SetBitIter[~reversed](self.binary)

    @always_inline("nodebug")
    fn __next__(mut self, out result: Int):
        result = self.bit_idx

        @parameter
        if reversed:
            self.bit_idx = (
                bit_width_of[Int]() - count_leading_zeros(self.binary & ~(-1 << (self.bit_idx))) - 1
            )
        else:
            self.bit_idx = count_trailing_zeros(self.binary & (-1 << (self.bit_idx + 1)))

    @always_inline("nodebug")
    fn __has_next__(self) -> Bool:
        @parameter
        if reversed:
            return self.bit_idx >= 0
        else:
            return self.bit_idx < bit_width_of[Int]()


# @always_inline
# fn reverse_bits(bin: UInt, width: UInt) -> Int:
#     # cant constant fold bit_reverse in mojo 25.1, wait for new version.
#     return bit_reverse(bin << (bit_width_of[Int]() - width))


# @always_inline
# fn idx_of_nth_set(value: Int, n: Int) -> Int:
