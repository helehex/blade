# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.utils.combinadic import *


def main():
    pass
    # test_init()
    # test_inc()
    # test_int()


def test_init():
    assert_equal(Combinadic[4](0)._data, 0b0000)
    assert_equal(Combinadic[4](1)._data, 0b0001)
    assert_equal(Combinadic[4](2)._data, 0b0010)
    assert_equal(Combinadic[4](3)._data, 0b0100)
    assert_equal(Combinadic[4](4)._data, 0b1000)