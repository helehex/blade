# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import assert_equal_, assert_not_equal_

from blade.math.combinatorics import *


def main():
    test_pascal()
    test_factorial()
    test_combinations_bin()
    test_powerset()
    test_powerset_bin()
    test_powerset_ord()


def test_pascal():
    assert_equal(pascal(0, 0), 1)

    assert_equal(pascal(1, 0), 1)
    assert_equal(pascal(1, 1), 1)

    assert_equal(pascal(2, 0), 1)
    assert_equal(pascal(2, 1), 2)
    assert_equal(pascal(2, 2), 1)

    assert_equal(pascal(3, 0), 1)
    assert_equal(pascal(3, 1), 3)
    assert_equal(pascal(3, 2), 3)
    assert_equal(pascal(3, 3), 1)

    assert_equal(pascal(4, 0), 1)
    assert_equal(pascal(4, 1), 4)
    assert_equal(pascal(4, 2), 6)
    assert_equal(pascal(4, 3), 4)
    assert_equal(pascal(4, 4), 1)


def test_factorial():
    assert_equal(factorial(0), 1)
    assert_equal(factorial(1), 1)
    assert_equal(factorial(2), 2)
    assert_equal(factorial(3), 6)
    assert_equal(factorial(4), 24)
    assert_equal(factorial(5), 120)
    assert_equal(factorial(6), 720)


def test_combinations_bin():
    assert_equal_(combinations_bin(0, 0), List(List[Int]()))
    assert_equal_(combinations_bin(1, 0), List(List[Int]()))
    assert_equal_(combinations_bin(1, 1), List(List[Int](1)))
    assert_equal_(combinations_bin(2, 0), List(List[Int]()))
    assert_equal_(combinations_bin(2, 1), List(List[Int](1), List[Int](2)))
    assert_equal_(combinations_bin(2, 2), List(List[Int](1, 2)))
    assert_equal_(combinations_bin(3, 2), List(List[Int](1, 2), List[Int](1, 3), List[Int](2, 3)))


def test_powerset():
    assert_equal_(powerset(List[String]()), List(List[String]()))
    assert_equal_(powerset(List[String]('a')), List(List[String](), List[String]('a')))
    assert_equal_(powerset(List[String]('a', 'b')), List(List[String](), List[String]('a'), List[String]('b'), List[String]('a', 'b')))
    assert_equal_(powerset(List[String]('a', 'b', 'c')), List(List[String](), List[String]('a'), List[String]('b'), List[String]('a', 'b'), List[String]('c'), List[String]('a', 'c'), List[String]('b', 'c'), List[String]('a', 'b', 'c')))


def test_powerset_bin():
    assert_equal_(powerset_bin(0), List(List[Int]()))
    assert_equal_(powerset_bin(1), List(List[Int](), List[Int](1)))
    assert_equal_(powerset_bin(2), List(List[Int](), List[Int](1), List[Int](2), List[Int](1, 2)))
    assert_equal_(powerset_bin(3), List(List[Int](), List[Int](1), List[Int](2), List[Int](1, 2), List[Int](3), List[Int](1, 3), List[Int](2, 3), List[Int](1, 2, 3)))


def test_powerset_ord():
    assert_equal_(powerset_ord(0), List[List[Int]](List[Int]()))
    assert_equal_(powerset_ord(1), List[List[Int]](List[Int](), List[Int](1)))
    assert_equal_(powerset_ord(2), List[List[Int]](List[Int](), List[Int](1), List[Int](2), List[Int](1, 2)))
    assert_equal_(powerset_ord(3), List[List[Int]](List[Int](), List[Int](1), List[Int](2), List[Int](3), List[Int](1, 2), List[Int](1, 3), List[Int](2, 3), List[Int](1, 2, 3)))