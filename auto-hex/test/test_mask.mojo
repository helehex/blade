# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import assert_equal_

from blade.algebra.mask import *


def main():
    test_basis_mask()


def test_basis_mask():
    var mask: BasisMask

    mask = BasisMask(List[Bool]())
    assert_equal(mask.entry_count, 0)
    assert_equal_(mask.basis2entry, List[Int]())
    assert_equal_(mask.entry2basis, List[Int]())

    mask = BasisMask(List(False))
    assert_equal(mask.entry_count, 0)
    assert_equal_(mask.basis2entry, List(-1))
    assert_equal_(mask.entry2basis, List[Int]())

    mask = BasisMask(List(True))
    assert_equal(mask.entry_count, 1)
    assert_equal_(mask.basis2entry, List(0))
    assert_equal_(mask.entry2basis, List(0))

    mask = BasisMask(List(False, True))
    assert_equal(mask.entry_count, 1)
    assert_equal_(mask.basis2entry, List(-1, 0))
    assert_equal_(mask.entry2basis, List(1))

    mask = BasisMask(List(False, False, True, False))
    assert_equal(mask.entry_count, 1)
    assert_equal_(mask.basis2entry, List(-1, -1, 0, -1))
    assert_equal_(mask.entry2basis, List(2))

    mask = BasisMask(List(False, True, True, False))
    assert_equal(mask.entry_count, 2)
    assert_equal_(mask.basis2entry, List(-1, 0, 1, -1))
    assert_equal_(mask.entry2basis, List(1, 2))