# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from blade.ga import *
from blade.algebra.multivector import *


def main():
    test_eq()
    test_ne()
    test_subspace_constructor()
    test_getattr()
    test_normalized()
    test_add()
    test_sub()
    test_mul()
    test_sandwich()


def test_eq():
    assert_true(G3.Multivector[G3.empty_mask]().__eq__(Float64(0)))
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__eq__(
            G3.Multivector[G3.vector_mask](1, 2, 3)
        )
    )
    assert_false(
        G3.Multivector[G3.vector_mask](1, 2, 3).__eq__(
            G3.Multivector[G3.vector_mask](1, 4, 3)
        )
    )
    assert_false(G3.Multivector[G3.vector_mask](1, 2, 3).__eq__(Float64(1)))


def test_ne():
    assert_false(G3.Multivector[G3.empty_mask]().__ne__(Float64(0)))
    assert_false(
        G3.Multivector[G3.vector_mask](1, 2, 3).__ne__(
            G3.Multivector[G3.vector_mask](1, 2, 3)
        )
    )
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__ne__(
            G3.Multivector[G3.vector_mask](1, 4, 3)
        )
    )
    assert_true(G3.Multivector[G3.vector_mask](1, 2, 3).__ne__(Float64(1)))


def test_subspace_constructor():
    assert_true(G3.vector(1, 2, 3) == G3.Multivector[G3.vector_mask](1, 2, 3))
    assert_true(G3.vector(1, 0, 3) != G3.Multivector[G3.vector_mask](1, 2, 3))

    assert_true(
        G3.bivector(4, 5, 6) == G3.Multivector[G3.bivector_mask](4, 5, 6)
    )
    assert_true(
        G3.bivector(4, 0, 6) != G3.Multivector[G3.bivector_mask](4, 5, 6)
    )

    # assert_true(i[G3](6) == G3.Multivector[G3.antiscalar_mask](6))
    # assert_true(i[G3](0) != G3.Multivector[G3.antiscalar_mask](6))


def test_getattr():
    alias g3 = Signature(3, 0, 0)
    assert_equal(Multivector[g3](6).s, Float64(6))
    assert_equal(G3.Multivector[G3.vector_mask](7, 8, 9).s, Float64(0))
    assert_equal(
        G3.Multivector[G3.scalar_mask | G3.vector_mask](6, 7, 8, 9).s,
        Float64(6),
    )


def test_normalized():
    alias g3 = Signature(3, 0, 0)
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).normalized()
        == G3.Multivector[G3.vector_mask](
            0.2672612419124244, 0.53452248382484879, 0.80178372573727319
        )
    )
    assert_true(
        G3.Multivector[G3.bivector_mask](1, 2, 3).normalized()
        == G3.Multivector[G3.bivector_mask](
            0.2672612419124244, 0.53452248382484879, 0.80178372573727319
        )
    )


def test_add():
    alias g3 = Signature(3, 0, 0)
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__add__(
            G3.Multivector[G3.vector_mask](1, 2, 3)
        )
        == G3.Multivector[G3.vector_mask](2, 4, 6)
    )
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__add__(Float64(1))
        == G3.Multivector[G3.scalar_mask | G3.vector_mask](1, 1, 2, 3)
    )


def test_sub():
    alias g3 = Signature(3, 0, 0)
    assert_true(
        G3.Multivector[G3.vector_mask](2, 4, 6).__sub__(
            G3.Multivector[G3.vector_mask](1, 2, 3)
        )
        == G3.Multivector[G3.vector_mask](1, 2, 3)
    )
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__sub__(Float64(1))
        == G3.Multivector[G3.scalar_mask | G3.vector_mask](-1, 1, 2, 3)
    )


def test_mul():
    alias g3 = Signature(3, 0, 0)
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__mul__(Float64(2))
        == G3.Multivector[G3.vector_mask](2, 4, 6)
    )
    assert_true(
        G3.Multivector[G3.vector_mask](1, 2, 3).__mul__(
            G3.Multivector[G3.antiscalar_mask](1)
        )
        == G3.Multivector[G3.bivector_mask](3, -2, 1)
    )

    alias ug3 = Signature(1, 1, 1, flip_ze=False)
    alias v1_mask = BasisMask(Basis(bin=0b001))
    assert_true(
        Multivector[ug3, v1_mask](2).__mul__(Multivector[ug3, v1_mask](2))
        == Float64(4)
    )
    alias v2_mask = BasisMask(Basis(bin=0b010))
    assert_true(
        Multivector[ug3, v2_mask](2).__mul__(Multivector[ug3, v2_mask](2))
        == Float64(-4)
    )
    alias v3_mask = BasisMask(Basis(bin=0b100))
    assert_true(
        Multivector[ug3, v3_mask](2).__mul__(Multivector[ug3, v3_mask](2))
        == Float64(0)
    )

    alias niltrivector_mask = BasisMask(
        Basis(bin=0b0111), Basis(bin=0b1011), Basis(bin=0b1101)
    )
    assert_true(
        PG3.Multivector[PG3.vector_mask](1, 2, 3, 4).__mul__(Float64(2))
        == PG3.Multivector[PG3.vector_mask](2, 4, 6, 8)
    )
    assert_true(
        PG3.Multivector[PG3.vector_mask](1, 2, 3, 4).__mul__(
            PG3.Multivector[PG3.antiscalar_mask](1)
        )
        == PG3.Multivector[niltrivector_mask](-4, 3, -2)
    )


def test_sandwich():
    alias g3 = Signature(3, 0, 0)
    assert_true(
        G3.Multivector[G3.even_mask](0, 1, 0, 0)(
            G3.Multivector[G3.vector_mask](1, 2, 3)
        )
        == G3.Multivector[G3.vector_mask](-1, -2, 3)
    )
