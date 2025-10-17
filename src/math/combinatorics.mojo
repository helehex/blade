# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Combinatorics functions."""

from sys import bit_width_of
from math import sqrt, log, exp, gamma, lgamma
from bit import pop_count, count_trailing_zeros
from utils._select import _select_register_value
from ..utils.bit import SetBitIter, reverse_bits


# +----------------------------------------------------------------------------------------------+ #
# | SetOrder
# +----------------------------------------------------------------------------------------------+ #
#
trait SetOrder:
    # +------( powerset )------+ #
    #
    @staticmethod
    fn powerset(n: Int) -> List[List[Int]]:
        ...

    @staticmethod
    fn powerset_bin(n: Int) -> List[Int]:
        ...

    @staticmethod
    fn power_rank(n: Int, comb: List[Int]) -> Int:
        ...

    @staticmethod
    fn power_rank_bin(n: Int, comb: Int) -> Int:
        ...

    @staticmethod
    fn power_unrank(n: Int, var idx: Int) -> List[Int]:
        ...

    @staticmethod
    fn power_unrank_bin(n: Int, var idx: Int) -> Int:
        ...

    # +------( combinations )------+ #
    #
    @staticmethod
    fn combinations(n: Int, r: Int) -> List[List[Int]]:
        ...

    @staticmethod
    fn combinations_bin(n: Int, r: Int) -> List[Int]:
        ...

    @staticmethod
    fn rank(n: Int, comb: List[Int]) -> Int:
        ...

    @staticmethod
    fn rank_bin(n: Int, comb: Int) -> Int:
        ...

    @staticmethod
    fn unrank(n: Int, var r: Int, var idx: Int) -> List[Int]:
        ...

    @staticmethod
    fn unrank_bin(n: Int, var r: Int, var idx: Int) -> Int:
        ...

    # +------( iteration )------+ #
    #
    @staticmethod
    fn next_bin(n: Int, bin: Int, out next_comb: Int):
        ...


# +----------------------------------------------------------------------------------------------+ #
# | SetOrder: Binary
# +----------------------------------------------------------------------------------------------+ #
#
struct SetOrder_Binary(SetOrder):
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
        for bit_idx in SetBitIter(idx):
            result.append(bit_idx + 1)

    @staticmethod
    @always_inline
    fn power_unrank_bin(n: Int, var idx: Int) -> Int:
        return idx

    # +------( combinations )------+ #
    #
    @staticmethod
    @always_inline
    fn combinations(n: Int, r: Int, out result: List[List[Int]]):
        """Returns the combinations of `n` choose `r` with binary sorting."""
        result = _combinations[Self](n, r)

    @staticmethod
    @always_inline
    fn combinations_bin(n: Int, r: Int, out result: List[Int]):
        """Returns the combinations of `n` choose `r` with binary sorting."""
        result = _combinations_bin[Self](n, r)

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
        next_comb = (t + 1) | (((~t & -~t) - 1) >> (count_trailing_zeros(comb) + 1))


# +----------------------------------------------------------------------------------------------+ #
# | SetOrder: Size, Lexicographic
# +----------------------------------------------------------------------------------------------+ #
#
struct SetOrder_SizeLexic(SetOrder):
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
            result.extend(_combinations[Self](n, k))

    @staticmethod
    @always_inline
    fn powerset_bin(n: Int, out result: List[Int]):
        """Returns the power set with size-lexic sorting."""
        result = List[Int](capacity=2**n)
        for k in range(n + 1):
            result.extend(_combinations_bin[Self](n, k))

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
        for bit_idx in SetBitIter(comb):
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

    # +------( combinations )------+ #
    #
    @staticmethod
    @always_inline
    fn combinations(n: Int, r: Int, out result: List[List[Int]]):
        """Returns the combinations of `n` choose `r` with size-lexic sorting."""
        result = _combinations[Self](n, r)

    @staticmethod
    @always_inline
    fn combinations_bin(n: Int, r: Int, out result: List[Int]):
        """Returns the combinations of `n` choose `r` with size-lexic sorting."""
        result = _combinations_bin[Self](n, r)

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
        for bit_idx in SetBitIter(comb):
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
        next_comb = (t + 1) | (((~t & -~t) - 1) >> min(count_trailing_zeros(next_comb) + 1, 31))
        next_comb = reverse_bits(~next_comb, n)


# +----------------------------------------------------------------------------------------------+ #
# | Powerset
# +----------------------------------------------------------------------------------------------+ #
#
fn powerset[T: Copyable & Movable, //](list: List[T]) -> List[List[T]]:
    """Returns all possible subsets of the given set."""
    # maybe faster to use powerset_bin to generate this as well
    if len(list) == 0:
        return List(List[T]())
    var cs = List[List[T]]()
    for c in powerset(list[1:]):
        cs.append(c.copy())
        cs.append(List(list[0].copy()) + c.copy())
    return cs^


@always_inline
fn powerset[Sorting: SetOrder = SetOrder_SizeLexic](n: Int) -> List[List[Int]]:
    """Returns the power set with the provided ordering."""
    return Sorting.powerset(n)


@always_inline
fn powerset_bin[Sorting: SetOrder = SetOrder_SizeLexic](n: Int) -> List[Int]:
    """Returns the power set with the provided ordering."""
    return Sorting.powerset_bin(n)


@always_inline
fn power_rank[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, comb: List[Int]) -> Int:
    return Sorting.power_rank(n, comb)


@always_inline
fn power_rank_bin[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, comb: Int) -> Int:
    return Sorting.power_rank_bin(n, comb)


@always_inline
fn power_unrank[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, idx: Int) -> List[Int]:
    return Sorting.power_unrank(n, idx)


@always_inline
fn power_unrank_bin[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, idx: Int) -> Int:
    return Sorting.power_unrank_bin(n, idx)


@always_inline
fn grade_of(n: Int, var power_rank: Int) -> Int:
    return pascal_degrade(n, power_rank)


@always_inline
fn degrade(n: Int, var power_rank: Int) -> Int:
    _ = pascal_degrade(n, power_rank)
    return power_rank


# +----------------------------------------------------------------------------------------------+ #
# | Combination
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline
fn _combinations[Sorting: SetOrder](n: Int, r: Int, out result: List[List[Int]]):
    var num_combs = pascal(n, r)
    result = List[List[Int]](capacity=num_combs)
    var i = ~(-1 << r)
    while len(result) < num_combs:
        var l = List[Int](capacity=r)
        for bit_idx in SetBitIter(i):
            l.append(bit_idx + 1)
        result.append(l^)
        i = Sorting.next_bin(n, i)


@always_inline
fn combinations[
    Sorting: SetOrder = SetOrder_SizeLexic
](n: Int, r: Int, out result: List[List[Int]]):
    """Returns the combinations of `n` choose `r` with the provided ordering."""
    result = Sorting.combinations(n, r)


@always_inline
fn _combinations_bin[Sorting: SetOrder](n: Int, r: Int, out result: List[Int]):
    """Returns the combinations of `n` choose `r` with binary sorting."""
    var num_combs = pascal(n, r)
    result = List[Int](capacity=num_combs)
    var i = ~(-1 << r)
    while len(result) < num_combs:
        result.append(i)
        i = Sorting.next_bin(n, i)


@always_inline
fn combinations_bin[
    Sorting: SetOrder = SetOrder_SizeLexic
](n: Int, r: Int, out result: List[Int]):
    """Returns the combinations of `n` choose `r` with binary sorting."""
    result = Sorting.combinations_bin(n, r)


@always_inline
fn rank[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, comb: List[Int]) -> Int:
    return Sorting.rank(n, comb)


@always_inline
fn rank_bin[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, comb: Int) -> Int:
    return Sorting.rank_bin(n, comb)


@always_inline
fn unrank[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, r: Int, idx: Int) -> List[Int]:
    return Sorting.unrank(n, r, idx)


@always_inline
fn unrank_bin[Sorting: SetOrder = SetOrder_SizeLexic](n: Int, r: Int, idx: Int) -> Int:
    return Sorting.unrank_bin(n, r, idx)


# +----------------------------------------------------------------------------------------------+ #
# | Factorial
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline
fn factorial_slow(n: Int) -> Float64:
    var result: Float64 = 0
    for i in range(2, n + 1):
        result += log(Float64(i))
    return exp(result)


@always_inline
fn factorial_stirling(n: Float64) -> Float64:
    return sqrt(tau * n) * ((n / e) ** n)


@always_inline
fn factorial_gamma(n: Float64) -> Float64:
    return gamma(n + 1.0)


@always_inline
fn factorial(n: Int) -> Int:
    return multifactorial[1](n)


# +----------------------------------------------------------------------------------------------+ #
# | Multifactorial
# +----------------------------------------------------------------------------------------------+ #
#
alias double_factorial = multifactorial[2]


@always_inline
fn multifactorial[step: Int](n: Int) -> Int:
    constrained[step > 0, "factorial step must be greater than 0"]()
    var result: Int = 1
    var i: Int = n
    while i > 1:
        result *= i
        i -= step
    return result


# +----------------------------------------------------------------------------------------------+ #
# | Permutial
# +----------------------------------------------------------------------------------------------+ #
#
# n! / (n-r)!
#
#           r
#    ---------------
#   | 1  0  0  0  0
#   | 1  1  0  0  0
# n | 1  2  2  0  0
#   | 1  3  6  6  0
#   | 1  4 12 24 24

alias nPr: fn (Int, Int) -> Int = permutial


@always_inline
fn permutial[r: Int](n: Int, out result: Int):
    result = 1

    @parameter
    for i in range(1 - r, 1):
        result *= n + i


@always_inline
fn permutial(n: Int, r: Int, out result: Int):
    result = 1
    for i in range(n - r + 1, n + 1):
        result *= i


# +----------------------------------------------------------------------------------------------+ #
# | Supertial
# +----------------------------------------------------------------------------------------------+ #
#
# (n+r)! / r!
#
#                r
#    ------------------------
#   |  1    1    1    1    1
#   |  1    2    3    4    5
# n |  2    6   12   20   30
#   |  6   24   60  120  210
#   | 24  120  360  840 1680


@always_inline
fn supertial[n: Int](r: Int, out result: Int):
    result = 1

    @parameter
    for i in range(1, n + 1):
        result *= r + i


@always_inline
fn supertial(n: Int, r: Int, out result: Int):
    result = 1
    for i in range(r + 1, r + n + 1):
        result *= i


# +----------------------------------------------------------------------------------------------+ #
# | Pascal
# +----------------------------------------------------------------------------------------------+ #
#
# n! / (n-r)!r!
#
#           r
#    ---------------
#   | 1  0  0  0  0
#   | 1  1  0  0  0
# n | 1  2  1  0  0
#   | 1  3  3  1  0
#   | 1  4  6  4  1

alias nCr: fn (Int, var Int) -> Int = pascal


@always_inline
fn pascal[r: Int](n: Int, out result: Int):
    result = 1

    @parameter
    for i in range(1, r + 1):
        result = (result * (i + n - r)) // i


@always_inline
fn pascal(n: Int, var r: Int, out result: Int):
    """Returns `n choose r`, or `0` if `n >= r >= 0` is false."""
    result = n >= r >= 0
    r = min(r, n - r)  # * result # expects n to be positive
    for i in range(1, r + 1):
        result = (result * (i + n - r)) // i


@always_inline
fn pascal_sum(n: Int, var r: Int, out sum: Int):
    sum = r >= 0
    term = 1
    for i in range(1, r + 1):
        term = (term * (n - i + 1)) // i
        sum += term


@always_inline
fn pascal_degrade(n: Int, mut power_rank: Int, out grade: Int):
    term = 1
    grade = 0
    while power_rank - term >= 0:
        power_rank -= term
        grade += 1
        term = (term * (n - grade + 1)) // grade


@always_inline
fn next_pascal(mut n: Int, mut r: Int, mut current: Int, *, next_r: Bool):
    n += 1
    r += next_r
    current = ((current * n) // _select_register_value(next_r, r, n - r)) or Int(r <= n)


# +----------------------------------------------------------------------------------------------+ #
# | Simplicial
# +----------------------------------------------------------------------------------------------+ #
#
# justified pascal
# (n+r)! / n!r!
#
#           r
#    ---------------
#   | 1  1  1  1  1
#   | 1  2  3  4  5
# n | 1  3  6 10 15
#   | 1  4 10 20 35
#   | 1  5 15 35 70

alias ntri = simplicial[2]
alias ntet = simplicial[3]


@always_inline
fn simplicial[n: Int](r: Int, out result: Int):
    result = 1

    @parameter
    for i in range(1, n + 1):
        result = (result * (i + r)) // i


@always_inline
fn simplicial(var n: Int, var r: Int, out result: Int):
    result = 1
    n, r = min(n, r), max(n, r)
    for i in range(1, n + 1):
        result = (result * (i + r)) // i


@always_inline
fn next_simplicial(var n: Int, mut r: Int, mut current: Int):
    current = ((current * (r + n)) // r) or 1
    r += 1
