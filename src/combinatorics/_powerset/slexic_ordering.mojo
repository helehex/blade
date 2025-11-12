# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Defines size-first-lexicographic-second powerset ordering."""

from bit import pop_count, count_trailing_zeros
from blade.bit import PopIter, reverse_bits


# +----------------------------------------------------------------------------------------------+ #
# | Powerset Ordering: Size, Lexicographic
# +----------------------------------------------------------------------------------------------+ #
#
struct SlexicOrdering(Ordering):
    """Sorted by size first, then lexicographic.

    Example:
    `{ {}, {1}, {2}, {3}, {4} {1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, ...}`.
    """

    # +------( powerset )------+ #
    #
    @staticmethod
    @always_inline
    fn powerset(n: Int, out result: List[List[Int]]):
        """Returns the power set with size-lexic sorting."""
        result = List[List[Int]](capacity=2**n)
        for k in range(n + 1):
            result.extend(Self.combinations(n, k))

    @staticmethod
    @always_inline
    fn powerset_bin(n: Int, out result: List[Int]):
        """Returns the power set with size-lexic sorting."""
        result = List[Int](capacity=2**n)
        for k in range(n + 1):
            result.extend(Self.combinations_bin(n, k))

    @staticmethod
    @always_inline
    fn power_rank(n: Int, comb: List[Int], out result: Int):
        # iterate through pascals triangle,
        # moving down until hitting an element, then summing and moving right.
        # this has less time complexity than calculating each nCr separately.

        if len(comb) < 2:
            result = 0 if len(comb) == 0 else comb[0]
            return

        var last = len(comb) - 1
        var end: Int = n - comb[0]
        var _r = 1
        var _n: Int
        var current: Int
        result = n
        var psum = n

        if comb[last] == n:
            while _r == n - comb[last - _r]:
                _r += 1
                psum = (psum * (n - _r + 1)) // _r
                result += psum
            _n = n - comb[last - _r + 1] + 1
            current = 1
        else:
            _n = n - comb[last]
            current = _n
            result -= _n

        while _n < end:
            if _n + 1 == n - comb[last - _r]:
                _n += 1
                _r += 1
                current = (current * _n) // _r
                psum = (psum * (n - _r + 1)) // _r
                result += psum - current
            else:
                _n += 1
                current = (current * _n) // (_n - _r)

    @staticmethod
    @always_inline
    fn power_rank_bin(n: Int, comb: Int, out result: Int):
        r = pop_count(comb)
        result = pascal_sum(n, r) - 1
        for bit_idx in PopIter(comb):
            result -= pascal(n - (bit_idx + 1), r)
            r -= 1

    @staticmethod
    @always_inline
    fn power_unrank(n: Int, var idx: Int, out result: List[Int]):
        var r = pascal_degrade(n, idx)
        result = Self.unrank(n, r, idx)

    @staticmethod
    @always_inline
    fn power_unrank_bin(n: Int, var idx: Int, out result: Int):
        var r = pascal_degrade(n, idx)
        result = Self.unrank_bin(n, r, idx)

    @staticmethod
    @always_inline
    fn grade(n: Int, idx: Int) -> Int:
        var _idx = idx
        return pascal_degrade(n, _idx)

    # +------( combinations )------+ #
    #
    @staticmethod
    @always_inline
    fn rank(n: Int, comb: List[Int], out result: Int):
        # iterate through pascals triangle,
        # moving down until hitting an element, then summing and moving right.
        # this has less time complexity than calculating each nCr separately.

        if len(comb) < 2:
            result = 0 if len(comb) == 0 else comb[0]
            return

        var last = len(comb) - 1
        var end: Int = n - comb[0]
        var _r = 1
        var _n: Int
        var current: Int
        result = n

        if comb[last] == n:
            while _r == n - comb[last - _r]:
                _r += 1
            _n = n - comb[last - _r + 1] + 1
            current = 1
        else:
            _n = n - comb[last]
            current = _n
            result -= _n

        while _n < end:
            if _n + 1 == n - comb[last - _r]:
                _n += 1
                _r += 1
                current = (current * _n) // _r
                result -= current
            else:
                _n += 1
                current = (current * _n) // (_n - _r)

    @staticmethod
    @always_inline
    fn rank_bin(n: Int, comb: Int, out result: Int):
        r = pop_count(comb)
        result = pascal(n, r) - 1
        for bit_idx in PopIter(comb):
            result -= pascal(n - (bit_idx + 1), r)
            r -= 1

    @staticmethod
    @always_inline
    fn unrank(n: Int, var r: Int, var idx: Int, out result: List[Int]):
        result = List[Int](capacity=8)
        var element = n

        while r > 0:
            element -= 1
            r -= 1
            var sub = pascal(element, r)
            while idx - sub >= 0:
                idx -= sub
                element -= 1
                sub = pascal(element, r)
            result.append(n - element)

    @staticmethod
    @always_inline
    fn unrank_bin(n: Int, var r: Int, var idx: Int, out result: Int):
        result = 0
        var element = n

        while r > 0:
            element -= 1
            r -= 1
            var sub = pascal(element, r)
            while idx - sub >= 0:
                idx -= sub
                element -= 1
                sub = pascal(element, r)
            result |= 1 << (n - element - 1)

    # +------( iteration )------+ #
    #
    @staticmethod
    @always_inline
    fn next_bin(n: Int, comb: Int, out next_comb: Int):
        # TODO: create better algorithm for this sorting
        next_comb = reverse_bits(~comb, n)
        var t = next_comb | (next_comb - 1)
        # TODO: remove min() when mojo #3613 is resolved
        next_comb = (t + 1) | (
            ((~t & -~t) - 1) >> min(count_trailing_zeros(next_comb) + 1, 31)
        )
        next_comb = reverse_bits(~next_comb, n)
