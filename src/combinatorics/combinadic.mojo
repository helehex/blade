# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Defines a combinadic type."""

from std.sys import bit_width_of
from src.bit import PopIter
from ._powerset import *


struct Combinadic[width: Int, Order: Ordering = DefaultOrder](Intable):
    """A combinadic type. Represents an integer,
    but uses a combinatorial base system instead of binary."""

    var _data: Int

    def __init__(out self):
        self._data = 0

    def __init__(out self, *, data: Int):
        self._data = data

    # Integer to Combinadic
    def __init__(out self, var idx: Int):
        comptime assert Self.width <= bit_width_of[Int](), "width must be <= Int.BITWIDTH"
        idx %= 2**Self.width
        self._data = power_unrank_bin[Self.Order](Self.width, idx)

    # Combinadic to Integer
    def __int__(self, out result: Int):
        result = power_rank_bin[Self.Order](Self.width, self._data)

    def __inc__(self, out result: Self):
        result = Self(data=self._data)
        result._data = Self.Order.next_bin(Self.width, result._data)

    def __invert__(self) -> Self:
        return Self(data=~self._data)

    def __or__(lhs, rhs: Self) -> Self:
        return Self(data=lhs._data | rhs._data)

    def __and__(lhs, rhs: Self) -> Self:
        return Self(data=lhs._data & rhs._data)

    def __xor__(lhs, rhs: Self) -> Self:
        return Self(data=lhs._data ^ rhs._data)

    def expand(self, out result: List[Int]):
        result = List[Int](capacity=8)
        for bit_idx in PopIter(self._data):
            result.append(bit_idx)

    def write_to[WriterType: Writer](self, mut writer: WriterType):
        writer.write("[")
        for bit_idx in PopIter(self._data):
            writer.write(bit_idx + 1)
            if self._data & (-2 << bit_idx):
                writer.write(", ")
        writer.write("]")
