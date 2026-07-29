# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #

from std.testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.utils.algorithm import *


def main() raises:
    test_counted_sort()
    test_count_odd()


def test_counted_sort() raises:
    var l = [1]
    assert_equal(counted_sort(l), 0)
    _assert_equal(l, [1])

    l = [1, 1]
    assert_equal(counted_sort(l), 0)
    _assert_equal(l, [1, 1])

    l = [2, 1, 3, 1]
    assert_equal(counted_sort(l), 3)
    _assert_equal(l, [1, 1, 2, 3])

    l = [5, 5, 4, 5, 1, 1]
    assert_equal(counted_sort(l), 10)
    _assert_equal(l, [1, 1, 4, 5, 5, 5])


def test_count_odd() raises:
    assert_equal(count_odd([1]), 1)
    assert_equal(count_odd([2]), 1)
    assert_equal(count_odd([3]), 1)
    assert_equal(count_odd([1, 1]), 0)
    assert_equal(count_odd([1, 2]), 2)
    assert_equal(count_odd([2, 2]), 0)
    assert_equal(count_odd([1, 1, 1]), 1)
    assert_equal(count_odd([1, 1, 2]), 1)
    assert_equal(count_odd([1, 2, 2]), 1)
    assert_equal(count_odd([1, 2, 3]), 3)
    assert_equal(count_odd([1, 1, 1, 1]), 0)
    assert_equal(count_odd([1, 1, 1, 2]), 2)
    assert_equal(count_odd([1, 1, 2, 2]), 0)
    assert_equal(count_odd([1, 2, 2, 2]), 2)
    assert_equal(count_odd([1, 1, 1, 1, 1]), 1)
    assert_equal(count_odd([1, 1, 2, 2, 3]), 1)
    assert_equal(count_odd([1, 2, 2, 2, 3]), 3)
