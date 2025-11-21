# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Defines the bit pop iterator."""
from sys import bit_width_of
from bit import count_trailing_zeros, count_leading_zeros


# +--------------------------------------------------------------------------+ #
# | PopIter
# +--------------------------------------------------------------------------+ #
#
# A better name might be: IndicesOfSetBitsIter.
#
@register_passable("trivial")
struct PopIter[reversed: Bool = False]:
    """Bit pop iterator.
    Iterates through the offsets of each 1-bit, skipping 0 bits."""

    var bin: Int
    var idx: Int

    @always_inline("nodebug")
    fn __init__(out self, bin: Int):
        self.bin = bin

        @parameter
        if Self.reversed:
            self.idx = Int.BITWIDTH - count_leading_zeros(bin) - 1
        else:
            self.idx = count_trailing_zeros(bin)

    @always_inline("nodebug")
    fn __iter__(self) -> Self:
        return self

    @always_inline("nodebug")
    fn __reversed__(self) -> PopIter[~Self.reversed]:
        return PopIter[~Self.reversed](self.bin)

    @always_inline("nodebug")
    fn __next__(mut self, out result: Int):
        result = self.idx

        @parameter
        if Self.reversed:
            self._backward()
        else:
            self._forward()

    @always_inline("nodebug")
    fn _forward(mut self):
        self.idx = count_trailing_zeros(self.bin & (~1 << self.idx))

    @always_inline("nodebug")
    fn _backward(mut self):
        self.idx = (
            Int.BITWIDTH - count_leading_zeros(self.bin & ~(-1 << self.idx)) - 1
        )

    @always_inline("nodebug")
    fn __has_next__(self) -> Bool:
        @parameter
        if Self.reversed:
            return self.idx >= 0
        else:
            return self.idx < Int.BITWIDTH
