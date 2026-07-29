# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #

from std.testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.algebra.mask import *


def main() raises:
    test_basis_mask()


def test_basis_mask() raises:
    var mask: BasisMask

    mask = BasisMask()
    assert_equal(len(mask), 0)
    _assert_equal(mask.entries, List[Basis]())
    assert_equal(mask.get_entry(Basis(bin=0b0)), -1)

    mask = BasisMask(Basis(bin=0b0))
    assert_equal(len(mask), 1)
    _assert_equal(mask.entries, [Basis(bin=0b0)])
    assert_equal(mask.get_basis(0), Basis(bin=0b0))
    assert_equal(mask.get_entry(Basis(bin=0b0)), 0)
    assert_equal(mask.get_entry(Basis(bin=0b1)), -1)

    mask = BasisMask(Basis(bin=0b1))
    assert_equal(len(mask), 1)
    _assert_equal(mask.entries, [Basis(bin=0b1)])
    assert_equal(mask.get_basis(0), Basis(bin=0b1))
    assert_equal(mask.get_entry(Basis(bin=0b0)), -1)
    assert_equal(mask.get_entry(Basis(bin=0b1)), 0)

    mask = BasisMask(Basis(bin=0b1), Basis(bin=0b0))
    assert_equal(len(mask), 2)
    _assert_equal(mask.entries, [Basis(bin=0b0), Basis(bin=0b1)])
    assert_equal(mask.get_basis(0), Basis(bin=0b0))
    assert_equal(mask.get_basis(1), Basis(bin=0b1))
    assert_equal(mask.get_entry(Basis(bin=0b0)), 0)
    assert_equal(mask.get_entry(Basis(bin=0b1)), 1)
    assert_equal(mask.get_entry(Basis(bin=0b10)), -1)

    mask = BasisMask(Basis(bin=0b100), Basis(bin=0b010))
    assert_equal(len(mask), 2)
    _assert_equal(mask.entries, [Basis(bin=0b010), Basis(bin=0b100)])
    assert_equal(mask.get_basis(0), Basis(bin=0b010))
    assert_equal(mask.get_basis(1), Basis(bin=0b100))
    assert_equal(mask.get_entry(Basis(bin=0b000)), -1)
    assert_equal(mask.get_entry(Basis(bin=0b001)), -1)
    assert_equal(mask.get_entry(Basis(bin=0b010)), 0)
    assert_equal(mask.get_entry(Basis(bin=0b100)), 1)
    assert_equal(mask.get_entry(Basis(bin=0b110)), -1)
