# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Defines a combinadic type."""

from blade.bit import PopIter


@register_passable("trivial")
struct Combinadic[width: Int, Order: Ordering = DefaultOrder](Intable):
    """A combinadic type. Represents an integer,
    but uses a combinatorial base system instead of binary."""

    var _data: Int

    fn __init__(out self):
        self._data = 0

    fn __init__(out self, *, data: Int):
        self._data = data

    # Integer to Combinadic
    fn __init__(out self, var idx: Int):
        constrained[width <= Int.BITWIDTH, "width must be <= Int.BITWIDTH"]()
        idx %= 2**width
        self._data = power_unrank_bin[Order](width, idx)

    # Combinadic to Integer
    fn __int__(self, out result: Int):
        result = power_rank_bin[Order](width, self._data)

    fn __inc__(self, out result: Self):
        result = Self(data=self._data)
        result._data = Order.next_bin(width, result._data)

    fn __invert__(self) -> Self:
        return Self(data=~self._data)

    fn __or__(lhs, rhs: Self) -> Self:
        return Self(data=lhs._data | rhs._data)

    fn __and__(lhs, rhs: Self) -> Self:
        return Self(data=lhs._data & rhs._data)

    fn __xor__(lhs, rhs: Self) -> Self:
        return Self(data=lhs._data ^ rhs._data)

    fn expand(self, out result: List[Int]):
        result = List[Int](capacity=8)
        for bit_idx in PopIter(self._data):
            result.append(bit_idx)

    fn write_to[WriterType: Writer](self, mut writer: WriterType):
        writer.write("[")
        for bit_idx in PopIter(self._data):
            writer.write(bit_idx + 1)
            if self._data & (-2 << bit_idx):
                writer.write(", ")
        writer.write("]")
