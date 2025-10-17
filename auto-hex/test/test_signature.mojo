# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import assert_equal_, assert_not_equal_

from blade.algebra import *


def main():
    test_signed_sort()
    test_squash_basis()
    test_count_odd()


def test_signed_sort():
    var l = List(1)
    assert_equal(signed_sort(l), 0)
    assert_equal_(l, List(1))

    l = List(1, 1)
    assert_equal(signed_sort(l), 0)
    assert_equal_(l, List(1, 1))

    l = List(2, 1, 3, 1)
    assert_equal(signed_sort(l), 3)
    assert_equal_(l, List(1, 1, 2, 3))

    l = List(5, 5, 4, 5, 1, 1)
    assert_equal(signed_sort(l), 10)
    assert_equal_(l, List(1, 1, 4, 5, 5, 5))


def test_squash_basis():
    var sig = Signature(1)
    var basis = List(1, 1)
    var sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 1)
    assert_equal_(basis, List[Int]())
    basis = List(1, 1, 2)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 1)
    assert_equal_(basis, List[Int](2))

    sig = Signature(0, 1)
    basis = List(1, 1)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, -1)
    assert_equal_(basis, List[Int]())
    basis = List(1, 1, 2)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, -1)
    assert_equal_(basis, List[Int](2))

    sig = Signature(0, 0, 1)
    basis = List(1, 1)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 0)
    assert_equal_(basis, List[Int]())
    basis = List(1, 1, 2)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 0)
    assert_equal_(basis, List[Int](2))
    


def test_count_odd():
    assert_equal(count_odd(List(1)), 1)
    assert_equal(count_odd(List(2)), 1)
    assert_equal(count_odd(List(3)), 1)
    assert_equal(count_odd(List(1, 1)), 0)
    assert_equal(count_odd(List(1, 2)), 2)
    assert_equal(count_odd(List(2, 2)), 0)
    assert_equal(count_odd(List(1, 1, 1)), 1)
    assert_equal(count_odd(List(1, 1, 2)), 1)
    assert_equal(count_odd(List(1, 2, 2)), 1)
    assert_equal(count_odd(List(1, 2, 3)), 3)
    assert_equal(count_odd(List(1, 1, 1, 1)), 0)
    assert_equal(count_odd(List(1, 1, 1, 2)), 2)
    assert_equal(count_odd(List(1, 1, 2, 2)), 0)
    assert_equal(count_odd(List(1, 2, 2, 2)), 2)
    assert_equal(count_odd(List(1, 1, 1, 1, 1)), 1)
    assert_equal(count_odd(List(1, 1, 2, 2, 3)), 1)
    assert_equal(count_odd(List(1, 2, 2, 2, 3)), 3)