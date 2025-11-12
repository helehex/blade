# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.combinatorics import *

alias Ls = List[String]
alias Li = List[Int]


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
    _assert_equal(BinaryOrdering.combinations(0, 0), List(Li()))

    _assert_equal(BinaryOrdering.combinations(1, 0), List(Li()))
    _assert_equal(BinaryOrdering.combinations(1, 1), List(Li(1)))

    _assert_equal(BinaryOrdering.combinations(2, 0), List(Li()))
    _assert_equal(BinaryOrdering.combinations(2, 1), List(Li(1), Li(2)))
    _assert_equal(BinaryOrdering.combinations(2, 2), List(Li(1, 2)))

    _assert_equal(BinaryOrdering.combinations(3, 0), List(Li()))
    _assert_equal(BinaryOrdering.combinations(3, 1), List(Li(1), Li(2), Li(3)))
    _assert_equal(
        BinaryOrdering.combinations(3, 2), List(Li(1, 2), Li(1, 3), Li(2, 3))
    )
    _assert_equal(BinaryOrdering.combinations(3, 3), List(Li(1, 2, 3)))

    _assert_equal(BinaryOrdering.combinations(4, 0), List(Li()))
    _assert_equal(
        BinaryOrdering.combinations(4, 1), List(Li(1), Li(2), Li(3), Li(4))
    )
    _assert_equal(
        BinaryOrdering.combinations(4, 2),
        List(Li(1, 2), Li(1, 3), Li(2, 3), Li(1, 4), Li(2, 4), Li(3, 4)),
    )
    _assert_equal(
        BinaryOrdering.combinations(4, 3),
        List(Li(1, 2, 3), Li(1, 2, 4), Li(1, 3, 4), Li(2, 3, 4)),
    )
    _assert_equal(BinaryOrdering.combinations(4, 4), List(Li(1, 2, 3, 4)))

    _assert_equal(BinaryOrdering.combinations(5, 0), List(Li()))
    _assert_equal(
        BinaryOrdering.combinations(5, 1),
        List(Li(1), Li(2), Li(3), Li(4), Li(5)),
    )
    _assert_equal(
        BinaryOrdering.combinations(5, 2),
        List(
            Li(1, 2),
            Li(1, 3),
            Li(2, 3),
            Li(1, 4),
            Li(2, 4),
            Li(3, 4),
            Li(1, 5),
            Li(2, 5),
            Li(3, 5),
            Li(4, 5),
        ),
    )
    _assert_equal(
        BinaryOrdering.combinations(5, 3),
        List(
            Li(1, 2, 3),
            Li(1, 2, 4),
            Li(1, 3, 4),
            Li(2, 3, 4),
            Li(1, 2, 5),
            Li(1, 3, 5),
            Li(2, 3, 5),
            Li(1, 4, 5),
            Li(2, 4, 5),
            Li(3, 4, 5),
        ),
    )
    _assert_equal(
        BinaryOrdering.combinations(5, 4),
        List(
            Li(1, 2, 3, 4),
            Li(1, 2, 3, 5),
            Li(1, 2, 4, 5),
            Li(1, 3, 4, 5),
            Li(2, 3, 4, 5),
        ),
    )
    _assert_equal(BinaryOrdering.combinations(5, 5), List(Li(1, 2, 3, 4, 5)))

    _assert_equal(combinations[SlexicOrdering](0, 0), List(Li()))

    _assert_equal(combinations[SlexicOrdering](1, 0), List(Li()))
    _assert_equal(combinations[SlexicOrdering](1, 1), List(Li(1)))

    _assert_equal(combinations[SlexicOrdering](2, 0), List(Li()))
    _assert_equal(combinations[SlexicOrdering](2, 1), List(Li(1), Li(2)))
    _assert_equal(combinations[SlexicOrdering](2, 2), List(Li(1, 2)))

    _assert_equal(combinations[SlexicOrdering](3, 0), List(Li()))
    _assert_equal(combinations[SlexicOrdering](3, 1), List(Li(1), Li(2), Li(3)))
    _assert_equal(
        combinations[SlexicOrdering](3, 2), List(Li(1, 2), Li(1, 3), Li(2, 3))
    )
    _assert_equal(combinations[SlexicOrdering](3, 3), List(Li(1, 2, 3)))

    _assert_equal(combinations[SlexicOrdering](4, 0), List(Li()))
    _assert_equal(
        combinations[SlexicOrdering](4, 1), List(Li(1), Li(2), Li(3), Li(4))
    )
    _assert_equal(
        combinations[SlexicOrdering](4, 2),
        List(Li(1, 2), Li(1, 3), Li(1, 4), Li(2, 3), Li(2, 4), Li(3, 4)),
    )
    _assert_equal(
        combinations[SlexicOrdering](4, 3),
        List(Li(1, 2, 3), Li(1, 2, 4), Li(1, 3, 4), Li(2, 3, 4)),
    )
    _assert_equal(combinations[SlexicOrdering](4, 4), List(Li(1, 2, 3, 4)))

    _assert_equal(combinations[SlexicOrdering](5, 0), List(Li()))
    _assert_equal(
        combinations[SlexicOrdering](5, 1),
        List(Li(1), Li(2), Li(3), Li(4), Li(5)),
    )
    _assert_equal(
        combinations[SlexicOrdering](5, 2),
        List(
            Li(1, 2),
            Li(1, 3),
            Li(1, 4),
            Li(1, 5),
            Li(2, 3),
            Li(2, 4),
            Li(2, 5),
            Li(3, 4),
            Li(3, 5),
            Li(4, 5),
        ),
    )
    _assert_equal(
        combinations[SlexicOrdering](5, 3),
        List(
            Li(1, 2, 3),
            Li(1, 2, 4),
            Li(1, 2, 5),
            Li(1, 3, 4),
            Li(1, 3, 5),
            Li(1, 4, 5),
            Li(2, 3, 4),
            Li(2, 3, 5),
            Li(2, 4, 5),
            Li(3, 4, 5),
        ),
    )
    _assert_equal(
        combinations[SlexicOrdering](5, 4),
        List(
            Li(1, 2, 3, 4),
            Li(1, 2, 3, 5),
            Li(1, 2, 4, 5),
            Li(1, 3, 4, 5),
            Li(2, 3, 4, 5),
        ),
    )
    _assert_equal(combinations[SlexicOrdering](5, 5), List(Li(1, 2, 3, 4, 5)))


def test_combinations_bin():
    _assert_equal(combinations_bin[BinaryOrdering](0, 0), Li(0))

    _assert_equal(combinations_bin[BinaryOrdering](1, 0), Li(0b0))
    _assert_equal(combinations_bin[BinaryOrdering](1, 1), Li(0b1))

    _assert_equal(combinations_bin[BinaryOrdering](2, 0), Li(0b00))
    _assert_equal(combinations_bin[BinaryOrdering](2, 1), Li(0b01, 0b10))
    _assert_equal(combinations_bin[BinaryOrdering](2, 2), Li(0b11))

    _assert_equal(combinations_bin[BinaryOrdering](3, 0), Li(0b000))
    _assert_equal(
        combinations_bin[BinaryOrdering](3, 1), Li(0b001, 0b010, 0b100)
    )
    _assert_equal(
        combinations_bin[BinaryOrdering](3, 2), Li(0b011, 0b101, 0b110)
    )
    _assert_equal(combinations_bin[BinaryOrdering](3, 3), Li(0b111))

    _assert_equal(combinations_bin[BinaryOrdering](4, 0), Li(0b0000))
    _assert_equal(
        combinations_bin[BinaryOrdering](4, 1),
        Li(0b0001, 0b0010, 0b0100, 0b1000),
    )
    _assert_equal(
        combinations_bin[BinaryOrdering](4, 2),
        Li(0b0011, 0b0101, 0b0110, 0b1001, 0b1010, 0b1100),
    )
    _assert_equal(
        combinations_bin[BinaryOrdering](4, 3),
        Li(0b0111, 0b1011, 0b1101, 0b1110),
    )
    _assert_equal(combinations_bin[BinaryOrdering](4, 4), Li(0b1111))

    _assert_equal(combinations_bin[BinaryOrdering](5, 0), Li(0b00000))
    _assert_equal(
        combinations_bin[BinaryOrdering](5, 1),
        Li(0b00001, 0b00010, 0b00100, 0b01000, 0b10000),
    )
    _assert_equal(
        combinations_bin[BinaryOrdering](5, 2),
        Li(
            0b00011,
            0b00101,
            0b00110,
            0b01001,
            0b01010,
            0b01100,
            0b10001,
            0b10010,
            0b10100,
            0b11000,
        ),
    )
    _assert_equal(
        combinations_bin[BinaryOrdering](5, 3),
        Li(
            0b00111,
            0b01011,
            0b01101,
            0b01110,
            0b10011,
            0b10101,
            0b10110,
            0b11001,
            0b11010,
            0b11100,
        ),
    )
    _assert_equal(
        combinations_bin[BinaryOrdering](5, 4),
        Li(0b01111, 0b10111, 0b11011, 0b11101, 0b11110),
    )
    _assert_equal(combinations_bin[BinaryOrdering](5, 5), Li(0b11111))

    _assert_equal(combinations_bin[SlexicOrdering](0, 0), Li(0))

    _assert_equal(combinations_bin[SlexicOrdering](1, 0), Li(0b0))
    _assert_equal(combinations_bin[SlexicOrdering](1, 1), Li(0b1))

    _assert_equal(combinations_bin[SlexicOrdering](2, 0), Li(0b00))
    _assert_equal(combinations_bin[SlexicOrdering](2, 1), Li(0b01, 0b10))
    _assert_equal(combinations_bin[SlexicOrdering](2, 2), Li(0b11))

    _assert_equal(combinations_bin[SlexicOrdering](3, 0), Li(0b000))
    _assert_equal(
        combinations_bin[SlexicOrdering](3, 1), Li(0b001, 0b010, 0b100)
    )
    _assert_equal(
        combinations_bin[SlexicOrdering](3, 2), Li(0b011, 0b101, 0b110)
    )
    _assert_equal(combinations_bin[SlexicOrdering](3, 3), Li(0b111))

    _assert_equal(combinations_bin[SlexicOrdering](4, 0), Li(0b0000))
    _assert_equal(
        combinations_bin[SlexicOrdering](4, 1),
        Li(0b0001, 0b0010, 0b0100, 0b1000),
    )
    _assert_equal(
        combinations_bin[SlexicOrdering](4, 2),
        Li(0b0011, 0b0101, 0b1001, 0b0110, 0b1010, 0b1100),
    )
    _assert_equal(
        combinations_bin[SlexicOrdering](4, 3),
        Li(0b0111, 0b1011, 0b1101, 0b1110),
    )
    _assert_equal(combinations_bin[SlexicOrdering](4, 4), Li(0b1111))

    _assert_equal(combinations_bin[SlexicOrdering](5, 0), Li(0b00000))
    _assert_equal(
        combinations_bin[SlexicOrdering](5, 1),
        Li(0b00001, 0b00010, 0b00100, 0b01000, 0b10000),
    )
    _assert_equal(
        combinations_bin[SlexicOrdering](5, 2),
        Li(
            0b00011,
            0b00101,
            0b01001,
            0b10001,
            0b00110,
            0b01010,
            0b10010,
            0b01100,
            0b10100,
            0b11000,
        ),
    )
    _assert_equal(
        combinations_bin[SlexicOrdering](5, 3),
        Li(
            0b00111,
            0b01011,
            0b10011,
            0b01101,
            0b10101,
            0b11001,
            0b01110,
            0b10110,
            0b11010,
            0b11100,
        ),
    )
    _assert_equal(
        combinations_bin[SlexicOrdering](5, 4),
        Li(0b01111, 0b10111, 0b11011, 0b11101, 0b11110),
    )
    _assert_equal(combinations_bin[SlexicOrdering](5, 5), Li(0b11111))


def test_powerset():
    # _assert_equal(powerset(Ls()), List(Ls()))
    # _assert_equal(powerset(Ls("a")), List(Ls(), Ls("a")))
    # _assert_equal(
    #     powerset(Ls("a", "b")), List(Ls(), Ls("a"), Ls("b"), Ls("a", "b"))
    # )
    # _assert_equal(
    #     powerset(Ls("a", "b", "c")),
    #     List(
    #         Ls(),
    #         Ls("a"),
    #         Ls("b"),
    #         Ls("a", "b"),
    #         Ls("c"),
    #         Ls("a", "c"),
    #         Ls("b", "c"),
    #         Ls("a", "b", "c"),
    #     ),
    # )
    # _assert_equal(
    #     powerset(Ls("a", "b", "c", "d")),
    #     List(
    #         Ls(),
    #         Ls("a"),
    #         Ls("b"),
    #         Ls("a", "b"),
    #         Ls("c"),
    #         Ls("a", "c"),
    #         Ls("b", "c"),
    #         Ls("a", "b", "c"),
    #         Ls("d"),
    #         Ls("a", "d"),
    #         Ls("b", "d"),
    #         Ls("a", "b", "d"),
    #         Ls("c", "d"),
    #         Ls("a", "c", "d"),
    #         Ls("b", "c", "d"),
    #         Ls("a", "b", "c", "d"),
    #     ),
    # )

    _assert_equal(powerset[BinaryOrdering](0), List(Li()))
    _assert_equal(powerset[BinaryOrdering](1), List(Li(), Li(1)))
    _assert_equal(
        powerset[BinaryOrdering](2), List(Li(), Li(1), Li(2), Li(1, 2))
    )
    _assert_equal(
        powerset[BinaryOrdering](3),
        List(
            Li(), Li(1), Li(2), Li(1, 2), Li(3), Li(1, 3), Li(2, 3), Li(1, 2, 3)
        ),
    )
    _assert_equal(
        powerset[BinaryOrdering](4),
        List(
            Li(),
            Li(1),
            Li(2),
            Li(1, 2),
            Li(3),
            Li(1, 3),
            Li(2, 3),
            Li(1, 2, 3),
            Li(4),
            Li(1, 4),
            Li(2, 4),
            Li(1, 2, 4),
            Li(3, 4),
            Li(1, 3, 4),
            Li(2, 3, 4),
            Li(1, 2, 3, 4),
        ),
    )

    _assert_equal(powerset[SlexicOrdering](0), List(Li()))
    _assert_equal(powerset[SlexicOrdering](1), List(Li(), Li(1)))
    _assert_equal(
        powerset[SlexicOrdering](2), List(Li(), Li(1), Li(2), Li(1, 2))
    )
    _assert_equal(
        powerset[SlexicOrdering](3),
        List(
            Li(), Li(1), Li(2), Li(3), Li(1, 2), Li(1, 3), Li(2, 3), Li(1, 2, 3)
        ),
    )
    _assert_equal(
        powerset[SlexicOrdering](4),
        List(
            Li(),
            Li(1),
            Li(2),
            Li(3),
            Li(4),
            Li(1, 2),
            Li(1, 3),
            Li(1, 4),
            Li(2, 3),
            Li(2, 4),
            Li(3, 4),
            Li(1, 2, 3),
            Li(1, 2, 4),
            Li(1, 3, 4),
            Li(2, 3, 4),
            Li(1, 2, 3, 4),
        ),
    )


def test_powerset_bin():
    _assert_equal(powerset_bin[BinaryOrdering](0), Li(0b0))
    _assert_equal(powerset_bin[BinaryOrdering](1), Li(0b0, 0b1))
    _assert_equal(powerset_bin[BinaryOrdering](2), Li(0b00, 0b01, 0b10, 0b11))
    _assert_equal(
        powerset_bin[BinaryOrdering](3),
        Li(0b000, 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111),
    )
    _assert_equal(
        powerset_bin[BinaryOrdering](4),
        Li(
            0b0000,
            0b0001,
            0b0010,
            0b0011,
            0b0100,
            0b0101,
            0b0110,
            0b0111,
            0b1000,
            0b1001,
            0b1010,
            0b1011,
            0b1100,
            0b1101,
            0b1110,
            0b1111,
        ),
    )

    _assert_equal(powerset_bin[SlexicOrdering](0), Li(0b0))
    _assert_equal(powerset_bin[SlexicOrdering](1), Li(0b0, 0b1))
    _assert_equal(powerset_bin[SlexicOrdering](2), Li(0b00, 0b01, 0b10, 0b11))
    _assert_equal(
        powerset_bin[SlexicOrdering](3),
        Li(0b000, 0b001, 0b010, 0b100, 0b011, 0b101, 0b110, 0b111),
    )
    _assert_equal(
        powerset_bin[SlexicOrdering](4),
        Li(
            0b0000,
            0b0001,
            0b0010,
            0b0100,
            0b1000,
            0b0011,
            0b0101,
            0b1001,
            0b0110,
            0b1010,
            0b1100,
            0b0111,
            0b1011,
            0b1101,
            0b1110,
            0b1111,
        ),
    )


def test_power_unrank():
    # x--- Binary
    _assert_equal(power_unrank[BinaryOrdering](0, 0), Li())

    _assert_equal(power_unrank[BinaryOrdering](1, 0), Li())
    _assert_equal(power_unrank[BinaryOrdering](1, 1), Li(1))

    _assert_equal(power_unrank[BinaryOrdering](2, 0), Li())
    _assert_equal(power_unrank[BinaryOrdering](2, 1), Li(1))
    _assert_equal(power_unrank[BinaryOrdering](2, 2), Li(2))
    _assert_equal(power_unrank[BinaryOrdering](2, 3), Li(1, 2))

    _assert_equal(power_unrank[BinaryOrdering](3, 0), Li())
    _assert_equal(power_unrank[BinaryOrdering](3, 1), Li(1))
    _assert_equal(power_unrank[BinaryOrdering](3, 2), Li(2))
    _assert_equal(power_unrank[BinaryOrdering](3, 3), Li(1, 2))
    _assert_equal(power_unrank[BinaryOrdering](3, 4), Li(3))
    _assert_equal(power_unrank[BinaryOrdering](3, 5), Li(1, 3))
    _assert_equal(power_unrank[BinaryOrdering](3, 6), Li(2, 3))
    _assert_equal(power_unrank[BinaryOrdering](3, 7), Li(1, 2, 3))

    _assert_equal(power_unrank[BinaryOrdering](4, 0), Li())
    _assert_equal(power_unrank[BinaryOrdering](4, 1), Li(1))
    _assert_equal(power_unrank[BinaryOrdering](4, 2), Li(2))
    _assert_equal(power_unrank[BinaryOrdering](4, 3), Li(1, 2))
    _assert_equal(power_unrank[BinaryOrdering](4, 4), Li(3))
    _assert_equal(power_unrank[BinaryOrdering](4, 5), Li(1, 3))
    _assert_equal(power_unrank[BinaryOrdering](4, 6), Li(2, 3))
    _assert_equal(power_unrank[BinaryOrdering](4, 7), Li(1, 2, 3))
    _assert_equal(power_unrank[BinaryOrdering](4, 8), Li(4))
    _assert_equal(power_unrank[BinaryOrdering](4, 9), Li(1, 4))
    _assert_equal(power_unrank[BinaryOrdering](4, 10), Li(2, 4))
    _assert_equal(power_unrank[BinaryOrdering](4, 11), Li(1, 2, 4))
    _assert_equal(power_unrank[BinaryOrdering](4, 12), Li(3, 4))
    _assert_equal(power_unrank[BinaryOrdering](4, 13), Li(1, 3, 4))
    _assert_equal(power_unrank[BinaryOrdering](4, 14), Li(2, 3, 4))
    _assert_equal(power_unrank[BinaryOrdering](4, 15), Li(1, 2, 3, 4))

    # x--- Slexic
    _assert_equal(power_unrank[SlexicOrdering](0, 0), Li())

    _assert_equal(power_unrank[SlexicOrdering](1, 0), Li())
    _assert_equal(power_unrank[SlexicOrdering](1, 1), Li(1))

    _assert_equal(power_unrank[SlexicOrdering](2, 0), Li())
    _assert_equal(power_unrank[SlexicOrdering](2, 1), Li(1))
    _assert_equal(power_unrank[SlexicOrdering](2, 2), Li(2))
    _assert_equal(power_unrank[SlexicOrdering](2, 3), Li(1, 2))

    _assert_equal(power_unrank[SlexicOrdering](3, 0), Li())
    _assert_equal(power_unrank[SlexicOrdering](3, 1), Li(1))
    _assert_equal(power_unrank[SlexicOrdering](3, 2), Li(2))
    _assert_equal(power_unrank[SlexicOrdering](3, 3), Li(3))
    _assert_equal(power_unrank[SlexicOrdering](3, 4), Li(1, 2))
    _assert_equal(power_unrank[SlexicOrdering](3, 5), Li(1, 3))
    _assert_equal(power_unrank[SlexicOrdering](3, 6), Li(2, 3))
    _assert_equal(power_unrank[SlexicOrdering](3, 7), Li(1, 2, 3))

    _assert_equal(power_unrank[SlexicOrdering](4, 0), Li())
    _assert_equal(power_unrank[SlexicOrdering](4, 1), Li(1))
    _assert_equal(power_unrank[SlexicOrdering](4, 2), Li(2))
    _assert_equal(power_unrank[SlexicOrdering](4, 3), Li(3))
    _assert_equal(power_unrank[SlexicOrdering](4, 4), Li(4))
    _assert_equal(power_unrank[SlexicOrdering](4, 5), Li(1, 2))
    _assert_equal(power_unrank[SlexicOrdering](4, 6), Li(1, 3))
    _assert_equal(power_unrank[SlexicOrdering](4, 7), Li(1, 4))
    _assert_equal(power_unrank[SlexicOrdering](4, 8), Li(2, 3))
    _assert_equal(power_unrank[SlexicOrdering](4, 9), Li(2, 4))
    _assert_equal(power_unrank[SlexicOrdering](4, 10), Li(3, 4))
    _assert_equal(power_unrank[SlexicOrdering](4, 11), Li(1, 2, 3))
    _assert_equal(power_unrank[SlexicOrdering](4, 12), Li(1, 2, 4))
    _assert_equal(power_unrank[SlexicOrdering](4, 13), Li(1, 3, 4))
    _assert_equal(power_unrank[SlexicOrdering](4, 14), Li(2, 3, 4))
    _assert_equal(power_unrank[SlexicOrdering](4, 15), Li(1, 2, 3, 4))


def test_power_unrank_bin():
    # x--- Binary
    assert_equal(power_unrank_bin[BinaryOrdering](0, 0), 0b0)

    assert_equal(power_unrank_bin[BinaryOrdering](1, 0), 0b0)
    assert_equal(power_unrank_bin[BinaryOrdering](1, 1), 0b1)

    assert_equal(power_unrank_bin[BinaryOrdering](2, 0), 0b00)
    assert_equal(power_unrank_bin[BinaryOrdering](2, 1), 0b01)
    assert_equal(power_unrank_bin[BinaryOrdering](2, 2), 0b10)
    assert_equal(power_unrank_bin[BinaryOrdering](2, 3), 0b11)

    assert_equal(power_unrank_bin[BinaryOrdering](3, 0), 0b000)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 1), 0b001)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 2), 0b010)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 3), 0b011)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 4), 0b100)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 5), 0b101)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 6), 0b110)
    assert_equal(power_unrank_bin[BinaryOrdering](3, 7), 0b111)

    assert_equal(power_unrank_bin[BinaryOrdering](4, 0), 0b0000)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 1), 0b0001)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 2), 0b0010)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 3), 0b0011)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 4), 0b0100)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 5), 0b0101)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 6), 0b0110)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 7), 0b0111)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 8), 0b1000)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 9), 0b1001)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 10), 0b1010)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 11), 0b1011)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 12), 0b1100)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 13), 0b1101)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 14), 0b1110)
    assert_equal(power_unrank_bin[BinaryOrdering](4, 15), 0b1111)

    # x--- Slexic
    assert_equal(power_unrank_bin[SlexicOrdering](0, 0), 0b0)

    assert_equal(power_unrank_bin[SlexicOrdering](1, 0), 0b0)
    assert_equal(power_unrank_bin[SlexicOrdering](1, 1), 0b1)

    assert_equal(power_unrank_bin[SlexicOrdering](2, 0), 0b00)
    assert_equal(power_unrank_bin[SlexicOrdering](2, 1), 0b01)
    assert_equal(power_unrank_bin[SlexicOrdering](2, 2), 0b10)
    assert_equal(power_unrank_bin[SlexicOrdering](2, 3), 0b11)

    assert_equal(power_unrank_bin[SlexicOrdering](3, 0), 0b000)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 1), 0b001)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 2), 0b010)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 3), 0b100)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 4), 0b011)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 5), 0b101)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 6), 0b110)
    assert_equal(power_unrank_bin[SlexicOrdering](3, 7), 0b111)

    assert_equal(power_unrank_bin[SlexicOrdering](4, 0), 0b0000)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 1), 0b0001)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 2), 0b0010)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 3), 0b0100)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 4), 0b1000)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 5), 0b0011)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 6), 0b0101)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 7), 0b1001)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 8), 0b0110)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 9), 0b1010)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 10), 0b1100)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 11), 0b0111)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 12), 0b1011)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 13), 0b1101)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 14), 0b1110)
    assert_equal(power_unrank_bin[SlexicOrdering](4, 15), 0b1111)


def test_power_rank():
    pass


def test_power_rank_bin():
    pass
