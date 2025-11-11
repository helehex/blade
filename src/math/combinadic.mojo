from sys import bit_width_of
from bit import pop_count, count_trailing_zeros, bit_reverse
from ..utils.bit import SetBitIter
from .combinatorics import (
    SetOrder,
    SetOrder_SizeLexic,
    power_rank_bin,
    power_unrank_bin,
)


@register_passable("trivial")
struct Combinadic[width: Int, sorting: SetOrder = SetOrder_SizeLexic](Intable):
    var _data: Int

    fn __init__(out self):
        self._data = 0

    fn __init__(out self, *, data: Int):
        self._data = data

    # Integer to Combinadic
    fn __init__(out self, var idx: Int):
        constrained[
            width <= bit_width_of[Int](), "width must be <= bit_width_of[Int]()"
        ]()
        idx %= 2**width
        self._data = power_unrank_bin[sorting](width, idx)

    # Combinadic to Integer
    fn __int__(self, out result: Int):
        result = power_rank_bin[sorting](width, self._data)

    fn __inc__(self, out result: Self):
        result = Self(data=self._data)
        result._data = sorting.next_bin(width, result._data)

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
        for bit_idx in SetBitIter(self._data):
            result.append(bit_idx)

    fn write_to[WriterType: Writer](self, mut writer: WriterType):
        writer.write("[")
        for bit_idx in SetBitIter(self._data):
            writer.write(bit_idx + 1)
            if self._data & (-2 << bit_idx):
                writer.write(", ")
        writer.write("]")
