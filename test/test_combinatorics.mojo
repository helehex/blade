# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.combinatorics import *


def main():
    test_pascal()
    test_factorial()
    test_combinations()
    test_combinations_bin()
    test_powerset()
    test_powerset_bin()
    test_power_unrank()
    test_power_unrank_bin()
    test_power_rank()
    test_power_rank_bin()


def test_pascal():
    assert_equal(pascal(0, -1), 0)
    assert_equal(pascal(0, 0), 1)
    assert_equal(pascal(0, 1), 0)

    assert_equal(pascal(1, -1), 0)
    assert_equal(pascal(1, 0), 1)
    assert_equal(pascal(1, 1), 1)
    assert_equal(pascal(1, 2), 0)

    assert_equal(pascal(2, -1), 0)
    assert_equal(pascal(2, 0), 1)
    assert_equal(pascal(2, 1), 2)
    assert_equal(pascal(2, 2), 1)
    assert_equal(pascal(2, 3), 0)

    assert_equal(pascal(3, -1), 0)
    assert_equal(pascal(3, 0), 1)
    assert_equal(pascal(3, 1), 3)
    assert_equal(pascal(3, 2), 3)
    assert_equal(pascal(3, 3), 1)
    assert_equal(pascal(3, 4), 0)

    assert_equal(pascal(4, -1), 0)
    assert_equal(pascal(4, 0), 1)
    assert_equal(pascal(4, 1), 4)
    assert_equal(pascal(4, 2), 6)
    assert_equal(pascal(4, 3), 4)
    assert_equal(pascal(4, 4), 1)
    assert_equal(pascal(4, 5), 0)

    assert_equal(pascal(5, -1), 0)
    assert_equal(pascal(5, 0), 1)
    assert_equal(pascal(5, 1), 5)
    assert_equal(pascal(5, 2), 10)
    assert_equal(pascal(5, 3), 10)
    assert_equal(pascal(5, 4), 5)
    assert_equal(pascal(5, 5), 1)
    assert_equal(pascal(5, 6), 0)


def test_factorial():
    assert_equal(factorial(0), 1)
    assert_equal(factorial(1), 1)
    assert_equal(factorial(2), 2)
    assert_equal(factorial(3), 6)
    assert_equal(factorial(4), 24)
    assert_equal(factorial(5), 120)
    assert_equal(factorial(6), 720)


def test_combinations():
    _assert_equal(BinaryOrdering.combinations(0, 0), [[]])

    _assert_equal(BinaryOrdering.combinations(1, 0), [[]])
    _assert_equal(BinaryOrdering.combinations(1, 1), [[1]])

    _assert_equal(BinaryOrdering.combinations(2, 0), [[]])
    _assert_equal(BinaryOrdering.combinations(2, 1), [[1], [2]])
    _assert_equal(BinaryOrdering.combinations(2, 2), [[1, 2]])

    _assert_equal(BinaryOrdering.combinations(3, 0), [[]])
    _assert_equal(BinaryOrdering.combinations(3, 1), [[1], [2], [3]])
    _assert_equal(BinaryOrdering.combinations(3, 2), [[1, 2], [1, 3], [2, 3]])
    _assert_equal(BinaryOrdering.combinations(3, 3), [[1, 2, 3]])

    _assert_equal(BinaryOrdering.combinations(4, 0), [[]])
    _assert_equal(BinaryOrdering.combinations(4, 1), [[1], [2], [3], [4]])
    _assert_equal(BinaryOrdering.combinations(4, 2), [[1, 2], [1, 3], [2, 3], [1, 4], [2, 4], [3, 4]])
    _assert_equal(BinaryOrdering.combinations(4, 3), [[1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]])
    _assert_equal(BinaryOrdering.combinations(4, 4), [[1, 2, 3, 4]])

    _assert_equal(BinaryOrdering.combinations(5, 0), [[]])
    _assert_equal(BinaryOrdering.combinations(5, 1), [[1], [2], [3], [4], [5]])
    _assert_equal(BinaryOrdering.combinations(5, 2), [[1, 2], [1, 3], [2, 3], [1, 4], [2, 4], [3, 4], [1, 5], [2, 5], [3, 5], [4, 5]])
    _assert_equal(BinaryOrdering.combinations(5, 3), [[1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4], [1, 2, 5], [1, 3, 5], [2, 3, 5], [1, 4, 5], [2, 4, 5], [3, 4, 5]])
    _assert_equal(BinaryOrdering.combinations(5, 4), [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]])
    _assert_equal(BinaryOrdering.combinations(5, 5), [[1, 2, 3, 4, 5]])

    _assert_equal(SlexicOrdering.combinations(0, 0), [[]])

    _assert_equal(SlexicOrdering.combinations(1, 0), [[]])
    _assert_equal(SlexicOrdering.combinations(1, 1), [[1]])

    _assert_equal(SlexicOrdering.combinations(2, 0), [[]])
    _assert_equal(SlexicOrdering.combinations(2, 1), [[1], [2]])
    _assert_equal(SlexicOrdering.combinations(2, 2), [[1, 2]])

    _assert_equal(SlexicOrdering.combinations(3, 0), [[]])
    _assert_equal(SlexicOrdering.combinations(3, 1), [[1], [2], [3]])
    _assert_equal(SlexicOrdering.combinations(3, 2), [[1, 2], [1, 3], [2, 3]])
    _assert_equal(SlexicOrdering.combinations(3, 3), [[1, 2, 3]])

    _assert_equal(SlexicOrdering.combinations(4, 0), [[]])
    _assert_equal(SlexicOrdering.combinations(4, 1), [[1], [2], [3], [4]])
    _assert_equal(SlexicOrdering.combinations(4, 2), [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]])
    _assert_equal(SlexicOrdering.combinations(4, 3), [[1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]])
    _assert_equal(SlexicOrdering.combinations(4, 4), [[1, 2, 3, 4]])

    _assert_equal(SlexicOrdering.combinations(5, 0), [[]])
    _assert_equal(SlexicOrdering.combinations(5, 1), [[1], [2], [3], [4], [5]])
    _assert_equal(SlexicOrdering.combinations(5, 2), [[1, 2], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]])
    _assert_equal(SlexicOrdering.combinations(5, 3), [[1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 3, 4], [1, 3, 5], [1, 4, 5], [2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5]])
    _assert_equal(SlexicOrdering.combinations(5, 4), [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]])
    _assert_equal(SlexicOrdering.combinations(5, 5), [[1, 2, 3, 4, 5]])


def test_combinations_bin():
    _assert_equal(BinaryOrdering.combinations_bin(0, 0), [0])

    _assert_equal(BinaryOrdering.combinations_bin(1, 0), [0b0])
    _assert_equal(BinaryOrdering.combinations_bin(1, 1), [0b1])

    _assert_equal(BinaryOrdering.combinations_bin(2, 0), [0b00])
    _assert_equal(BinaryOrdering.combinations_bin(2, 1), [0b01, 0b10])
    _assert_equal(BinaryOrdering.combinations_bin(2, 2), [0b11])

    _assert_equal(BinaryOrdering.combinations_bin(3, 0), [0b000])
    _assert_equal(BinaryOrdering.combinations_bin(3, 1), [0b001, 0b010, 0b100])
    _assert_equal(BinaryOrdering.combinations_bin(3, 2), [0b011, 0b101, 0b110])
    _assert_equal(BinaryOrdering.combinations_bin(3, 3), [0b111])

    _assert_equal(BinaryOrdering.combinations_bin(4, 0), [0b0000])
    _assert_equal(BinaryOrdering.combinations_bin(4, 1), [0b0001, 0b0010, 0b0100, 0b1000])
    _assert_equal(BinaryOrdering.combinations_bin(4, 2), [0b0011, 0b0101, 0b0110, 0b1001, 0b1010, 0b1100])
    _assert_equal(BinaryOrdering.combinations_bin(4, 3), [0b0111, 0b1011, 0b1101, 0b1110])
    _assert_equal(BinaryOrdering.combinations_bin(4, 4), [0b1111])

    _assert_equal(BinaryOrdering.combinations_bin(5, 0), [0b00000])
    _assert_equal(BinaryOrdering.combinations_bin(5, 1), [0b00001, 0b00010, 0b00100, 0b01000, 0b10000])
    _assert_equal(BinaryOrdering.combinations_bin(5, 2), [0b00011, 0b00101, 0b00110, 0b01001, 0b01010, 0b01100, 0b10001, 0b10010, 0b10100, 0b11000])
    _assert_equal(BinaryOrdering.combinations_bin(5, 3), [0b00111, 0b01011, 0b01101, 0b01110, 0b10011, 0b10101, 0b10110, 0b11001, 0b11010, 0b11100])
    _assert_equal(BinaryOrdering.combinations_bin(5, 4), [0b01111, 0b10111, 0b11011, 0b11101, 0b11110])
    _assert_equal(BinaryOrdering.combinations_bin(5, 5), [0b11111])

    _assert_equal(SlexicOrdering.combinations_bin(0, 0), [0])

    _assert_equal(SlexicOrdering.combinations_bin(1, 0), [0b0])
    _assert_equal(SlexicOrdering.combinations_bin(1, 1), [0b1])

    _assert_equal(SlexicOrdering.combinations_bin(2, 0), [0b00])
    _assert_equal(SlexicOrdering.combinations_bin(2, 1), [0b01, 0b10])
    _assert_equal(SlexicOrdering.combinations_bin(2, 2), [0b11])

    _assert_equal(SlexicOrdering.combinations_bin(3, 0), [0b000])
    _assert_equal(SlexicOrdering.combinations_bin(3, 1), [0b001, 0b010, 0b100])
    _assert_equal(SlexicOrdering.combinations_bin(3, 2), [0b011, 0b101, 0b110])
    _assert_equal(SlexicOrdering.combinations_bin(3, 3), [0b111])

    _assert_equal(SlexicOrdering.combinations_bin(4, 0), [0b0000])
    _assert_equal(SlexicOrdering.combinations_bin(4, 1), [0b0001, 0b0010, 0b0100, 0b1000])
    _assert_equal(SlexicOrdering.combinations_bin(4, 2), [0b0011, 0b0101, 0b1001, 0b0110, 0b1010, 0b1100])
    _assert_equal(SlexicOrdering.combinations_bin(4, 3), [0b0111, 0b1011, 0b1101, 0b1110])
    _assert_equal(SlexicOrdering.combinations_bin(4, 4), [0b1111])

    _assert_equal(SlexicOrdering.combinations_bin(5, 0), [0b00000])
    _assert_equal(SlexicOrdering.combinations_bin(5, 1), [0b00001, 0b00010, 0b00100, 0b01000, 0b10000])
    _assert_equal(SlexicOrdering.combinations_bin(5, 2), [0b00011, 0b00101, 0b01001, 0b10001, 0b00110, 0b01010, 0b10010, 0b01100, 0b10100, 0b11000])
    _assert_equal(SlexicOrdering.combinations_bin(5, 3), [0b00111, 0b01011, 0b10011, 0b01101, 0b10101, 0b11001, 0b01110, 0b10110, 0b11010, 0b11100])
    _assert_equal(SlexicOrdering.combinations_bin(5, 4), [0b01111, 0b10111, 0b11011, 0b11101, 0b11110])
    _assert_equal(SlexicOrdering.combinations_bin(5, 5), [0b11111])


def test_powerset():
    # _assert_equal(powerset([]), [[]])
    # _assert_equal(powerset(["a"]), [[], ["a"]])
    # _assert_equal(powerset(["a", "b"]), [[], ["a"], ["b"], ["a", "b"]])
    # _assert_equal(powerset(["a", "b", "c"]), [[], ["a"], ["b"], ["a", "b"], ["c"], ["a", "c"], ["b", "c"], ["a", "b", "c"]])
    # _assert_equal(powerset(["a", "b", "c", "d"]), [[], ["a"], ["b"], ["a", "b"], ["c"], ["a", "c"], ["b", "c"], ["a", "b", "c"], ["d"], ["a", "d"], ["b", "d"], ["a", "b", "d"], ["c", "d"], ["a", "c", "d"], ["b", "c", "d"], ["a", "b", "c", "d"]])

    _assert_equal(BinaryOrdering.powerset(0), [[]])
    _assert_equal(BinaryOrdering.powerset(1), [[], [1]])
    _assert_equal(BinaryOrdering.powerset(2), [[], [1], [2], [1, 2]])
    _assert_equal(BinaryOrdering.powerset(3), [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]])
    _assert_equal(BinaryOrdering.powerset(4), [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3], [4], [1, 4], [2, 4], [1, 2, 4], [3, 4], [1, 3, 4], [2, 3, 4], [1, 2, 3, 4]])

    _assert_equal(SlexicOrdering.powerset(0), [[]])
    _assert_equal(SlexicOrdering.powerset(1), [[], [1]])
    _assert_equal(SlexicOrdering.powerset(2), [[], [1], [2], [1, 2]])
    _assert_equal(SlexicOrdering.powerset(3), [[], [1], [2], [3], [1, 2], [1, 3], [2, 3], [1, 2, 3]])
    _assert_equal(SlexicOrdering.powerset(4), [[], [1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4], [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4], [1, 2, 3, 4]])


def test_powerset_bin():
    _assert_equal(BinaryOrdering.powerset_bin(0), [0b0])
    _assert_equal(BinaryOrdering.powerset_bin(1), [0b0, 0b1])
    _assert_equal(BinaryOrdering.powerset_bin(2), [0b00, 0b01, 0b10, 0b11])
    _assert_equal(BinaryOrdering.powerset_bin(3), [0b000, 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111])
    _assert_equal(BinaryOrdering.powerset_bin(4), [0b0000, 0b0001, 0b0010, 0b0011, 0b0100, 0b0101, 0b0110, 0b0111, 0b1000, 0b1001, 0b1010, 0b1011, 0b1100, 0b1101, 0b1110, 0b1111])

    _assert_equal(SlexicOrdering.powerset_bin(0), [0b0])
    _assert_equal(SlexicOrdering.powerset_bin(1), [0b0, 0b1])
    _assert_equal(SlexicOrdering.powerset_bin(2), [0b00, 0b01, 0b10, 0b11])
    _assert_equal(SlexicOrdering.powerset_bin(3), [0b000, 0b001, 0b010, 0b100, 0b011, 0b101, 0b110, 0b111])
    _assert_equal(SlexicOrdering.powerset_bin(4), [0b0000, 0b0001, 0b0010, 0b0100, 0b1000, 0b0011, 0b0101, 0b1001, 0b0110, 0b1010, 0b1100, 0b0111, 0b1011, 0b1101, 0b1110, 0b1111])


def test_power_unrank():
    # x--- Binary
    _assert_equal(BinaryOrdering.power_unrank(0, 0), [])

    _assert_equal(BinaryOrdering.power_unrank(1, 0), [])
    _assert_equal(BinaryOrdering.power_unrank(1, 1), [1])

    _assert_equal(BinaryOrdering.power_unrank(2, 0), [])
    _assert_equal(BinaryOrdering.power_unrank(2, 1), [1])
    _assert_equal(BinaryOrdering.power_unrank(2, 2), [2])
    _assert_equal(BinaryOrdering.power_unrank(2, 3), [1, 2])

    _assert_equal(BinaryOrdering.power_unrank(3, 0), [])
    _assert_equal(BinaryOrdering.power_unrank(3, 1), [1])
    _assert_equal(BinaryOrdering.power_unrank(3, 2), [2])
    _assert_equal(BinaryOrdering.power_unrank(3, 3), [1, 2])
    _assert_equal(BinaryOrdering.power_unrank(3, 4), [3])
    _assert_equal(BinaryOrdering.power_unrank(3, 5), [1, 3])
    _assert_equal(BinaryOrdering.power_unrank(3, 6), [2, 3])
    _assert_equal(BinaryOrdering.power_unrank(3, 7), [1, 2, 3])

    _assert_equal(BinaryOrdering.power_unrank(4, 0), [])
    _assert_equal(BinaryOrdering.power_unrank(4, 1), [1])
    _assert_equal(BinaryOrdering.power_unrank(4, 2), [2])
    _assert_equal(BinaryOrdering.power_unrank(4, 3), [1, 2])
    _assert_equal(BinaryOrdering.power_unrank(4, 4), [3])
    _assert_equal(BinaryOrdering.power_unrank(4, 5), [1, 3])
    _assert_equal(BinaryOrdering.power_unrank(4, 6), [2, 3])
    _assert_equal(BinaryOrdering.power_unrank(4, 7), [1, 2, 3])
    _assert_equal(BinaryOrdering.power_unrank(4, 8), [4])
    _assert_equal(BinaryOrdering.power_unrank(4, 9), [1, 4])
    _assert_equal(BinaryOrdering.power_unrank(4, 10), [2, 4])
    _assert_equal(BinaryOrdering.power_unrank(4, 11), [1, 2, 4])
    _assert_equal(BinaryOrdering.power_unrank(4, 12), [3, 4])
    _assert_equal(BinaryOrdering.power_unrank(4, 13), [1, 3, 4])
    _assert_equal(BinaryOrdering.power_unrank(4, 14), [2, 3, 4])
    _assert_equal(BinaryOrdering.power_unrank(4, 15), [1, 2, 3, 4])

    # x--- Slexic
    _assert_equal(SlexicOrdering.power_unrank(0, 0), [])

    _assert_equal(SlexicOrdering.power_unrank(1, 0), [])
    _assert_equal(SlexicOrdering.power_unrank(1, 1), [1])

    _assert_equal(SlexicOrdering.power_unrank(2, 0), [])
    _assert_equal(SlexicOrdering.power_unrank(2, 1), [1])
    _assert_equal(SlexicOrdering.power_unrank(2, 2), [2])
    _assert_equal(SlexicOrdering.power_unrank(2, 3), [1, 2])

    _assert_equal(SlexicOrdering.power_unrank(3, 0), [])
    _assert_equal(SlexicOrdering.power_unrank(3, 1), [1])
    _assert_equal(SlexicOrdering.power_unrank(3, 2), [2])
    _assert_equal(SlexicOrdering.power_unrank(3, 3), [3])
    _assert_equal(SlexicOrdering.power_unrank(3, 4), [1, 2])
    _assert_equal(SlexicOrdering.power_unrank(3, 5), [1, 3])
    _assert_equal(SlexicOrdering.power_unrank(3, 6), [2, 3])
    _assert_equal(SlexicOrdering.power_unrank(3, 7), [1, 2, 3])

    _assert_equal(SlexicOrdering.power_unrank(4, 0), [])
    _assert_equal(SlexicOrdering.power_unrank(4, 1), [1])
    _assert_equal(SlexicOrdering.power_unrank(4, 2), [2])
    _assert_equal(SlexicOrdering.power_unrank(4, 3), [3])
    _assert_equal(SlexicOrdering.power_unrank(4, 4), [4])
    _assert_equal(SlexicOrdering.power_unrank(4, 5), [1, 2])
    _assert_equal(SlexicOrdering.power_unrank(4, 6), [1, 3])
    _assert_equal(SlexicOrdering.power_unrank(4, 7), [1, 4])
    _assert_equal(SlexicOrdering.power_unrank(4, 8), [2, 3])
    _assert_equal(SlexicOrdering.power_unrank(4, 9), [2, 4])
    _assert_equal(SlexicOrdering.power_unrank(4, 10), [3, 4])
    _assert_equal(SlexicOrdering.power_unrank(4, 11), [1, 2, 3])
    _assert_equal(SlexicOrdering.power_unrank(4, 12), [1, 2, 4])
    _assert_equal(SlexicOrdering.power_unrank(4, 13), [1, 3, 4])
    _assert_equal(SlexicOrdering.power_unrank(4, 14), [2, 3, 4])
    _assert_equal(SlexicOrdering.power_unrank(4, 15), [1, 2, 3, 4])


def test_power_unrank_bin():
    # x--- Binary
    assert_equal(BinaryOrdering.power_unrank_bin(0, 0), 0b0)

    assert_equal(BinaryOrdering.power_unrank_bin(1, 0), 0b0)
    assert_equal(BinaryOrdering.power_unrank_bin(1, 1), 0b1)

    assert_equal(BinaryOrdering.power_unrank_bin(2, 0), 0b00)
    assert_equal(BinaryOrdering.power_unrank_bin(2, 1), 0b01)
    assert_equal(BinaryOrdering.power_unrank_bin(2, 2), 0b10)
    assert_equal(BinaryOrdering.power_unrank_bin(2, 3), 0b11)

    assert_equal(BinaryOrdering.power_unrank_bin(3, 0), 0b000)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 1), 0b001)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 2), 0b010)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 3), 0b011)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 4), 0b100)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 5), 0b101)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 6), 0b110)
    assert_equal(BinaryOrdering.power_unrank_bin(3, 7), 0b111)

    assert_equal(BinaryOrdering.power_unrank_bin(4, 0), 0b0000)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 1), 0b0001)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 2), 0b0010)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 3), 0b0011)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 4), 0b0100)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 5), 0b0101)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 6), 0b0110)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 7), 0b0111)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 8), 0b1000)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 9), 0b1001)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 10), 0b1010)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 11), 0b1011)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 12), 0b1100)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 13), 0b1101)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 14), 0b1110)
    assert_equal(BinaryOrdering.power_unrank_bin(4, 15), 0b1111)

    # x--- Slexic
    assert_equal(SlexicOrdering.power_unrank_bin(0, 0), 0b0)

    assert_equal(SlexicOrdering.power_unrank_bin(1, 0), 0b0)
    assert_equal(SlexicOrdering.power_unrank_bin(1, 1), 0b1)

    assert_equal(SlexicOrdering.power_unrank_bin(2, 0), 0b00)
    assert_equal(SlexicOrdering.power_unrank_bin(2, 1), 0b01)
    assert_equal(SlexicOrdering.power_unrank_bin(2, 2), 0b10)
    assert_equal(SlexicOrdering.power_unrank_bin(2, 3), 0b11)

    assert_equal(SlexicOrdering.power_unrank_bin(3, 0), 0b000)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 1), 0b001)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 2), 0b010)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 3), 0b100)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 4), 0b011)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 5), 0b101)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 6), 0b110)
    assert_equal(SlexicOrdering.power_unrank_bin(3, 7), 0b111)

    assert_equal(SlexicOrdering.power_unrank_bin(4, 0), 0b0000)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 1), 0b0001)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 2), 0b0010)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 3), 0b0100)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 4), 0b1000)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 5), 0b0011)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 6), 0b0101)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 7), 0b1001)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 8), 0b0110)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 9), 0b1010)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 10), 0b1100)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 11), 0b0111)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 12), 0b1011)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 13), 0b1101)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 14), 0b1110)
    assert_equal(SlexicOrdering.power_unrank_bin(4, 15), 0b1111)


def test_power_rank():
    pass


def test_power_rank_bin():
    pass
