# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Combinatorics functions."""

from math import sqrt, log, exp, gamma, lgamma
from bit import pop_count


# +----------------------------------------------------------------------------------------------+ #
# | gamma
# +----------------------------------------------------------------------------------------------+ #
#
# Computes the gamma function of x.
# A domain error or pole error may occur if x is a negative integer or zero.
# A range error occurs if the magnitude of x is too large and may occur if the magnitude of x is too small.


# +----------------------------------------------------------------------------------------------+ #
# | lgamma
# +----------------------------------------------------------------------------------------------+ #
#
# The lgamma function computes the natural logarithm of the absolute value of gamma of x.
# A range error occurs if x is too large.
# A pole error may occur if x is a negative integer or zero.


# +----------------------------------------------------------------------------------------------+ #
# | Powerset
# +----------------------------------------------------------------------------------------------+ #
#
fn powerset[T: CollectionElement, //](list: List[T]) -> List[List[T]]:
    # maybe faster to use powerset_bin to generate this as well
    if len(list) == 0:
        return List[List[T]](List[T]())
    var cs = List[List[T]]()
    for c in powerset(list[1:]):
        cs += c[]
        cs += List(list[0]) + c[]
    return cs


@always_inline
fn powerset_bin(n: Int) -> List[List[Int]]:
    var result = List[List[Int]](capacity=2**n)
    for i in range(2**n):
        var j = 0
        var l = List[Int](capacity=pop_count(i))
        while j < i:
            if (i >> j) & 1:
                l += j + 1
            j += 1
        result += l
    return result


@always_inline
fn powerset_ord(n: Int) -> List[List[Int]]:
    var result = List[List[Int]](capacity=2**n)
    for k in range(n + 1):
        result += combinations_ord(n, k)
    return result^


# fn powerset_dan13(n: Int) -> List[List[Int]]:
#     var result = List[List[Int]](capacity=2**n)
#     var head = 0
#     queue.append(List())
#     tail += 1
#     while(head < queue.size()):
#         var current = queue[head]
#         if current.size() == n:
#             break
#         head += 1
#         for i in range(n):
#             if i in current:
#             continue
#             var next_set = current + i
#             queue.append(next_set)
#     return result


# +----------------------------------------------------------------------------------------------+ #
# | Combination
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline
fn increment_combination[offset: Int = 1](n: Int, mut l: List[Int]) -> Bool:
    var first_gap: Int = -1
    var first_val: Int = -1
    for i in range(1, len(l) + 1):
        if (l[len(l) - i]) < ((n + offset) - i):
            first_gap = len(l) - i
            first_val = l[first_gap]
            break
    if first_gap == -1:
        return False
    for i in range(first_gap, len(l)):
        l[i] = first_val + (i - first_gap) + 1
    return True


@always_inline
fn combinations_ord[offset: Int = 1](n: Int, k: Int) -> List[List[Int]]:
    var result = List[List[Int]](capacity=2**n)
    var idxs = List[Int](capacity=k)
    for i in range(k):
        idxs += i + offset
    result += idxs
    while increment_combination(n, idxs):
        result += idxs
    return result^


@always_inline
fn combinations_bin(n: Int, k: Int) -> List[List[Int]]:
    var result = List[List[Int]](capacity=2**n)
    for i in range(2**n):
        var bits = pop_count(i)
        if bits != k:
            continue
        var j = 0
        var l = List[Int](capacity=bits)
        while j < i:
            if (i >> j) & 1:
                l += j + 1
            j += 1
        result += l
    return result


@always_inline
fn order_of_comb(n: Int, comb: List[Int]) -> Int:
    var result = pascal(n, len(comb))

    for i in range(len(comb)):
        var _n = n - comb[i]
        var _k = len(comb) - i
        if _n >= _k:
            result -= pascal(_n, _k)

    return result - 1


@always_inline
fn order_of_scomb(n: Int, comb: List[Int]) -> Int:
    var result = pascal(n, len(comb))

    for i in range(len(comb)):
        result += pascal(n, i)
        var _n = n - comb[i]
        var _k = len(comb) - i
        if _n >= _k:
            result -= pascal(_n, _k)

    return result - 1


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
fn factorial(n: IntLiteral) -> IntLiteral:
    return multifactorial[1](n)


@always_inline
fn factorial(n: Int) -> Int:
    return multifactorial[1](n)


# +----------------------------------------------------------------------------------------------+ #
# | Multifactorial
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline
fn double_factorial(n: IntLiteral) -> IntLiteral:
    return multifactorial[2](n)


@always_inline
fn double_factorial(n: Int) -> Int:
    return multifactorial[2](n)


@always_inline
fn multifactorial[step: IntLiteral](n: IntLiteral) -> IntLiteral:
    constrained[step > 0, "factorial step must be greater than 0"]()
    var result: IntLiteral = 1
    var i: IntLiteral = n
    while i > 1:
        result *= i
        i -= step
    return result


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
alias nPr: fn (Int, Int) -> Int = permutial


@always_inline
fn permutial(n: IntLiteral, r: IntLiteral) -> IntLiteral:
    var i: IntLiteral = n - r + 1
    var end: IntLiteral = n + 1
    var result: IntLiteral = 1
    while i < end:
        result *= i
        i += 1
    return result


@always_inline
fn permutial[r: Int](n: Int) -> Int:
    alias start: Int = 1 - r
    alias end: Int = 1
    var result: Int = 1

    @parameter
    for i in range(start, end):
        result *= n + i
    return result


@always_inline
fn permutial(n: Int, r: Int) -> Int:
    var start: Int = n - r + 1
    var end: Int = n + 1
    var result: Int = 1
    for i in range(start, end):
        result *= i
    return result


# +----------------------------------------------------------------------------------------------+ #
# | Supertial
# +----------------------------------------------------------------------------------------------+ #
#
# (d+n)! / n!
#
@always_inline
fn supertial(d: IntLiteral, n: IntLiteral) -> IntLiteral:
    var i: IntLiteral = n + 1
    var end: IntLiteral = n + d + 1
    var result: IntLiteral = 1
    while i < end:
        result *= i
        i += 1
    return result


@always_inline
fn supertial[d: Int](n: Int) -> Int:
    alias start: Int = 1
    alias end: Int = d + 1
    var result: Int = 1

    @parameter
    for i in range(start, end):
        result *= n + i
    return result


@always_inline
fn supertial(d: Int, n: Int) -> Int:
    var start: Int = n + 1
    var end: Int = n + d + 1
    var result: Int = 1
    for i in range(start, end):
        result *= i
    return result


# +----------------------------------------------------------------------------------------------+ #
# | Pascal
# +----------------------------------------------------------------------------------------------+ #
#
# n! / (n-r)!r!
#
alias nCr: fn (Int, Int) -> Int = pascal


@always_inline
fn pascal(n: IntLiteral, r: IntLiteral) -> IntLiteral:
    return permutial(n, r) // factorial(r)


@always_inline
fn pascal[n: Int](r: Int) -> Int:
    return permutial[n](r) // factorial(r)


@always_inline
fn pascal(n: Int, r: Int) -> Int:
    return permutial(n, r) // factorial(r)


# +----------------------------------------------------------------------------------------------+ #
# | Simplicial
# +----------------------------------------------------------------------------------------------+ #
#
# justified pascal
# (d+n)! / d!n!
#
alias ntri = simplicial[Int(2)]
# alias ntet = simplicial[3]


@always_inline
fn simplicial(d: IntLiteral, n: IntLiteral) -> IntLiteral:
    return supertial(d, n) // factorial(d)


@always_inline
fn simplicial[d: Int](n: Int) -> Int:
    return supertial[d](n) // factorial(d)


@always_inline
fn simplicial(d: Int, n: Int) -> Int:
    return supertial(d, n) // factorial(d)
