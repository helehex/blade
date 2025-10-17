# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.algebra.signature import *


def main():
    test_squash_basis()
    test_mul()


def test_squash_basis():
    var sig = Signature(1)
    var basis = List[Int](1, 1)
    var sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 1)
    _assert_equal(basis, List[Int]())
    basis = List[Int](1, 1, 2)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 1)
    _assert_equal(basis, List[Int](2))

    sig = Signature(0, 1)
    basis = List[Int](1, 1)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, -1)
    _assert_equal(basis, List[Int]())
    basis = List[Int](1, 1, 2)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, -1)
    _assert_equal(basis, List[Int](2))

    sig = Signature(0, 0, 1)
    basis = List[Int](1, 1)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 0)
    _assert_equal(basis, List[Int]())
    basis = List[Int](1, 1, 2)
    sign = 1
    sig.squash_basis(basis, sign)
    assert_equal(sign, 0)
    _assert_equal(basis, List[Int](2))


def test_mul():
    var sig = Signature(2, 2)
    assert_equal(sig.mul(Basis(bin=0b0000), Basis(bin=0b0000)), SignedBasis(1, bin=0b0000))
    assert_equal(sig.mul(Basis(bin=0b0001), Basis(bin=0b0001)), SignedBasis(1, bin=0b0000))
    assert_equal(sig.mul(Basis(bin=0b0010), Basis(bin=0b0010)), SignedBasis(1, bin=0b0000))
    assert_equal(sig.mul(Basis(bin=0b0100), Basis(bin=0b0100)), SignedBasis(-1, bin=0b0000))
    assert_equal(sig.mul(Basis(bin=0b1000), Basis(bin=0b1000)), SignedBasis(-1, bin=0b0000))
    assert_equal(sig.mul(Basis(bin=0b0001), Basis(bin=0b0010)), SignedBasis(1, bin=0b0011))
    assert_equal(sig.mul(Basis(bin=0b0010), Basis(bin=0b0001)), SignedBasis(-1, bin=0b0011))
