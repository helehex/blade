# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Defines the binary powerset ordering."""

from blade.bit import PopIter
from bit import pop_count, count_trailing_zeros


# +--------------------------------------------------------------------------+ #
# | Powerset Ordering: Binary
# +--------------------------------------------------------------------------+ #
#
struct BinaryOrdering(Ordering):
    """Sorted by size first, then lexicographic.

    Example:
    `{ {}, {1}, {2}, {1, 2}, {3}, {1, 3}, {2, 3}, {1, 2, 3}, {4}, ... }`
    """

    # +------( powerset )------+ #
    #
    @staticmethod
    @always_inline
    fn powerset(n: Int, out result: List[List[Int]]):
        """Returns the power set with binary sorting."""
        result = List[List[Int]](capacity=2**n)
        for i in range(2**n):
            var l = List[Int](capacity=pop_count(i))
            for j in range(i):
                if (i >> j) & 1:
                    l.append(j + 1)
            result.append(l^)

    @staticmethod
    @always_inline
    fn powerset_bin(n: Int, out result: List[Int]):
        """Returns the power set with binary sorting."""
        result = List[Int](capacity=2**n)
        for i in range(2**n):
            result.append(i)

    @staticmethod
    @always_inline
    fn power_rank(n: Int, subset: List[Int], out result: Int):
        result = 0
        for element in subset:
            result |= 1 << (element - 1)

    @staticmethod
    @always_inline
    fn power_rank_bin(n: Int, subset: Int) -> Int:
        return subset

    @staticmethod
    @always_inline
    fn power_unrank(n: Int, var idx: Int, out result: List[Int]):
        result = List[Int](capacity=8)
        for bit_idx in PopIter(idx):
            result.append(bit_idx + 1)

    @staticmethod
    @always_inline
    fn power_unrank_bin(n: Int, var idx: Int) -> Int:
        return idx

    @staticmethod
    @always_inline
    fn grade(n: Int, idx: Int) -> Int:
        return pop_count(idx)

    # +------( combinations )------+ #
    #
    @staticmethod
    @always_inline
    fn rank(n: Int, comb: List[Int]) -> Int:
        return Self.power_rank(n, comb) - pascal_sum(n, len(comb))

    @staticmethod
    @always_inline
    fn rank_bin(n: Int, comb: Int) -> Int:
        return comb - pascal_sum(n, pop_count(comb))

    @staticmethod
    @always_inline
    fn unrank(n: Int, var r: Int, var idx: Int, out result: List[Int]):
        result = Self.power_unrank(n, idx + pascal_sum(n, r))

    @staticmethod
    @always_inline
    fn unrank_bin(n: Int, var r: Int, var idx: Int) -> Int:
        return idx + pascal_sum(n, r)

    # +------( iteration )------+ #
    #
    @staticmethod
    @always_inline
    fn next_bin(n: Int, comb: Int, out next_comb: Int):
        var t = comb | (comb - 1)
        next_comb = (t + 1) | (
            ((~t & -~t) - 1) >> (count_trailing_zeros(comb) + 1)
        )
