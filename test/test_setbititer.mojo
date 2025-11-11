# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.utils.bit import SetBitIter


def main():
    var iter = SetBitIter(0b0000)
    assert_false(iter.__has_next__())

    iter = SetBitIter(0b0001)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 0)
    assert_false(iter.__has_next__())

    iter = SetBitIter(0b0010)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 1)
    assert_false(iter.__has_next__())

    iter = SetBitIter(0b0011)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 0)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 1)
    assert_false(iter.__has_next__())

    iter = SetBitIter(0b000010001001)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 0)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 3)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 7)
    assert_false(iter.__has_next__())

    iter = SetBitIter(0b01000000)
    assert_true(iter.__has_next__())
    assert_equal(iter.__next__(), 6)
    assert_false(iter.__has_next__())

    var riter = SetBitIter(0b0000).__reversed__()
    assert_false(riter.__has_next__())

    riter = SetBitIter(0b0001).__reversed__()
    assert_true(riter.__has_next__())
    assert_equal(riter.__next__(), 0)
    assert_false(riter.__has_next__())

    riter = SetBitIter(0b0010).__reversed__()
    assert_true(riter.__has_next__())
    assert_equal(riter.__next__(), 1)
    assert_false(riter.__has_next__())

    riter = SetBitIter(0b0011).__reversed__()
    assert_true(riter.__has_next__())
    assert_equal(riter.__next__(), 1)
    assert_true(riter.__has_next__())
    assert_equal(riter.__next__(), 0)
    assert_false(riter.__has_next__())

    riter = SetBitIter(0b01000000).__reversed__()
    assert_true(riter.__has_next__())
    assert_equal(riter.__next__(), 6)
    assert_false(riter.__has_next__())
