# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Combinatorics functions."""

from utils._select import _select_register_value
from math import sqrt, log, exp, gamma, lgamma
from blade.math import tau, e


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
# | Supercial
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
fn supercial[n: Int](r: Int, out result: Int):
    result = 1

    @parameter
    for i in range(1, n + 1):
        result *= r + i


@always_inline
fn supercial(n: Int, r: Int, out result: Int):
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
    result = Int(n >= r >= 0)
    r = min(r, n - r)  # * result # expects n to be positive
    for i in range(1, r + 1):
        result = (result * (i + n - r)) // i


@always_inline
fn pascal_sum(n: Int, var r: Int, out sum: Int):
    sum = Int(r >= 0)
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
fn degrade(n: Int, var power_rank: Int) -> Int:
    _ = pascal_degrade(n, power_rank)
    return power_rank


@always_inline
fn next_pascal(mut n: Int, mut r: Int, mut current: Int, *, next_r: Bool):
    n += 1
    r += Int(next_r)
    current = (
        (current * n) // _select_register_value(next_r, r, n - r)
    ) or Int(r <= n)


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
