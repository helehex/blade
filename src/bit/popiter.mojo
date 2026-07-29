# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Defines the bit pop iterator."""
from std.sys import bit_width_of
from std.bit import count_trailing_zeros, count_leading_zeros


# +----------------------------------------------------------------------------------------------+ #
# | PopIter
# +----------------------------------------------------------------------------------------------+ #
#
# A better name might be: IndicesOfSetBitsIter.
#
struct PopIter[reversed: Bool = False](ImplicitlyCopyable):
    """Bit pop iterator.
    Iterates through the offsets of each 1-bit, skipping 0 bits."""

    var bin: Int
    var idx: Int

    @always_inline("nodebug")
    def __init__(out self, bin: Int):
        self.bin = bin

        comptime if Self.reversed:
            self.idx = bit_width_of[Int]() - count_leading_zeros(bin) - 1
        else:
            self.idx = count_trailing_zeros(bin)

    @always_inline("nodebug")
    def __iter__(self) -> Self:
        return self

    @always_inline("nodebug")
    def __reversed__(self) -> PopIter[~Self.reversed]:
        return PopIter[~Self.reversed](self.bin)

    @always_inline("nodebug")
    def __next__(mut self, out result: Int):
        result = self.idx

        comptime if Self.reversed:
            self._backward()
        else:
            self._forward()

    @always_inline("nodebug")
    def _forward(mut self):
        self.idx = count_trailing_zeros(self.bin & (~1 << self.idx))

    @always_inline("nodebug")
    def _backward(mut self):
        self.idx = bit_width_of[Int]() - count_leading_zeros(self.bin & ~(-1 << self.idx)) - 1

    @always_inline("nodebug")
    def __has_next__(self) -> Bool:
        comptime if Self.reversed:
            return self.idx >= 0
        else:
            return self.idx < bit_width_of[Int]()
