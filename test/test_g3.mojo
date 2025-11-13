# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from hard.g3 import *


def main():
    simd_run[DType.float64, 1]()
    simd_run[DType.float64, 2]()
    simd_run[DType.float64, 4]()

    simd_run[DType.float32, 1]()
    simd_run[DType.float32, 2]()
    simd_run[DType.float32, 4]()

    simd_run[DType.int, 1]()
    simd_run[DType.int, 2]()
    simd_run[DType.int, 4]()


def simd_run[type: DType, size: Int]():
    test_eq[type, size]()
    test_ne[type, size]()
    test_add[type, size]()
    test_sub[type, size]()
    test_mul[type, size]()


def test_eq[type: DType, size: Int]():
    # +--- Multivector
    assert_true(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8).__eq__(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8)))
    assert_false(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8).__eq__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    assert_true(Multivector[type, size](1, 0, 0, 0, 5, 6, 7, 0).__eq__(Rotor[type, size](1, 5, 6, 7)))
    assert_false(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__eq__(Rotor[type, size](8, 4, 3, 2)))

    assert_true(Multivector[type, size](1, 0, 0, 0, 0, 0, 0, 0).__eq__(1))
    assert_false(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__eq__(8))

    assert_true(Multivector[type, size](0, 2, 3, 4, 0, 0, 0, 0).__eq__(Vector[type, size](2, 3, 4)))
    assert_false(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__eq__(Vector[type, size](7, 6, 5)))

    assert_true(Multivector[type, size](0, 0, 0, 0, 5, 6, 7, 0).__eq__(Bivector[type, size](5, 6, 7)))
    assert_false(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__eq__(Bivector[type, size](4, 3, 2)))

    assert_true(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 8).__eq__(Antiox[type, size](8)))
    assert_false(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__eq__(Multivector[type, size](1)))

    # +--- Rotor
    assert_true(Rotor[type, size](1, 5, 6, 7).__eq__(Multivector[type, size](1, 0, 0, 0, 5, 6, 7, 0)))
    assert_false(Rotor[type, size](1, 5, 6, 7).__eq__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    assert_true(Rotor[type, size](1, 5, 6, 7).__eq__(Rotor[type, size](1, 5, 6, 7)))
    assert_false(Rotor[type, size](1, 5, 6, 7).__eq__(Rotor[type, size](8, 4, 3, 2)))

    assert_true(Rotor[type, size](1, 0, 0, 0).__eq__(1))
    assert_false(Rotor[type, size](8, 4, 3, 2).__eq__(8))

    # (False)

    assert_true(Rotor[type, size](0, 5, 6, 7).__eq__(Bivector[type, size](5, 6, 7)))
    assert_false(Rotor[type, size](8, 4, 3, 2).__eq__(Bivector[type, size](4, 3, 2)))

    # (False)

    # +--- Vector
    assert_true(Vector[type, size](2, 3, 4).__eq__(Multivector[type, size](0, 2, 3, 4, 0, 0, 0, 0)))
    assert_false(Vector[type, size](2, 3, 4).__eq__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    # (False)

    # (False)

    assert_true(Vector[type, size](2, 3, 4).__eq__(Vector[type, size](2, 3, 4)))
    assert_false(Vector[type, size](2, 3, 4).__eq__(Vector[type, size](7, 6, 5)))

    # (False)

    # (False)

    # +--- Bivector
    assert_true(Bivector[type, size](5, 6, 7).__eq__(Multivector[type, size](0, 0, 0, 0, 5, 6, 7, 0)))
    assert_false(Bivector[type, size](5, 6, 7).__eq__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    assert_true(Bivector[type, size](5, 6, 7).__eq__(Rotor[type, size](0, 5, 6, 7)))
    assert_false(Bivector[type, size](5, 6, 7).__eq__(Rotor[type, size](8, 4, 3, 2)))

    # (False)

    # (False)

    assert_true(Bivector[type, size](5, 6, 7).__eq__(Bivector[type, size](5, 6, 7)))
    assert_false(Bivector[type, size](5, 6, 7).__eq__(Bivector[type, size](4, 3, 2)))

    # (False)

    # +--- Antiox
    assert_true(Antiox[type, size](8).__eq__(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 8)))
    assert_false(Antiox[type, size](8).__eq__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    # (False)

    # (False)

    # (False)

    # (False)

    assert_true(Antiox[type, size](8).__eq__(Antiox[type, size](8)))
    assert_false(Antiox[type, size](8).__eq__(Antiox[type, size](1)))


def test_ne[type: DType, size: Int]():
    # +--- Multivector
    assert_false(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8).__ne__(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8)))
    assert_true(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8).__ne__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    assert_false(Multivector[type, size](1, 0, 0, 0, 5, 6, 7, 0).__ne__(Rotor[type, size](1, 5, 6, 7)))
    assert_true(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__ne__(Rotor[type, size](8, 4, 3, 2)))

    assert_false(Multivector[type, size](1, 0, 0, 0, 0, 0, 0, 0).__ne__(1))
    assert_true(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__ne__(8))

    assert_false(Multivector[type, size](0, 2, 3, 4, 0, 0, 0, 0).__ne__(Vector[type, size](2, 3, 4)))
    assert_true(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__ne__(Vector[type, size](7, 6, 5)))

    assert_false(Multivector[type, size](0, 0, 0, 0, 5, 6, 7, 0).__ne__(Bivector[type, size](5, 6, 7)))
    assert_true(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__ne__(Bivector[type, size](4, 3, 2)))

    assert_false(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 8).__ne__(Antiox[type, size](8)))
    assert_true(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1).__ne__(Multivector[type, size](1)))

    # +--- Rotor
    assert_false(Rotor[type, size](1, 5, 6, 7).__ne__(Multivector[type, size](1, 0, 0, 0, 5, 6, 7, 0)))
    assert_true(Rotor[type, size](1, 5, 6, 7).__ne__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    assert_false(Rotor[type, size](1, 5, 6, 7).__ne__(Rotor[type, size](1, 5, 6, 7)))
    assert_true(Rotor[type, size](1, 5, 6, 7).__ne__(Rotor[type, size](8, 4, 3, 2)))

    assert_false(Rotor[type, size](1, 0, 0, 0).__ne__(1))
    assert_true(Rotor[type, size](8, 4, 3, 2).__ne__(8))

    # (False)

    assert_false(Rotor[type, size](0, 5, 6, 7).__ne__(Bivector[type, size](5, 6, 7)))
    assert_true(Rotor[type, size](8, 4, 3, 2).__ne__(Bivector[type, size](4, 3, 2)))

    # (False)

    # +--- Vector
    assert_false(Vector[type, size](2, 3, 4).__ne__(Multivector[type, size](0, 2, 3, 4, 0, 0, 0, 0)))
    assert_true(Vector[type, size](2, 3, 4).__ne__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    # (False)

    # (False)

    assert_false(Vector[type, size](2, 3, 4).__ne__(Vector[type, size](2, 3, 4)))
    assert_true(Vector[type, size](2, 3, 4).__ne__(Vector[type, size](7, 6, 5)))

    # (False)

    # (False)

    # +--- Bivector
    assert_false(Bivector[type, size](5, 6, 7).__ne__(Multivector[type, size](0, 0, 0, 0, 5, 6, 7, 0)))
    assert_true(Bivector[type, size](5, 6, 7).__ne__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    assert_false(Bivector[type, size](5, 6, 7).__ne__(Rotor[type, size](0, 5, 6, 7)))
    assert_true(Bivector[type, size](5, 6, 7).__ne__(Rotor[type, size](8, 4, 3, 2)))

    # (False)

    # (False)

    assert_false(Bivector[type, size](5, 6, 7).__ne__(Bivector[type, size](5, 6, 7)))
    assert_true(Bivector[type, size](5, 6, 7).__ne__(Bivector[type, size](4, 3, 2)))

    # (False)

    # +--- Antiox
    assert_false(Antiox[type, size](8).__ne__(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 8)))
    assert_true(Antiox[type, size](8).__ne__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)))

    # (False)

    # (False)

    # (False)

    # (False)

    assert_false(Antiox[type, size](8).__ne__(Antiox[type, size](8)))
    assert_true(Antiox[type, size](8).__ne__(Antiox[type, size](1)))


def test_add[type: DType, size: Int]():
    assert_equal(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8).__add__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)), Multivector[type, size](9, 9, 9, 9, 9, 9, 9, 9))
    assert_equal(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 0).__add__(Rotor[type, size](1, 5, 6, 7)), Multivector[type, size](1, 0, 0, 0, 5, 6, 7, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 0).__add__(SIMD[type, size](1)), Multivector[type, size](1, 0, 0, 0, 0, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 0).__add__(Vector[type, size](2, 3, 4)), Multivector[type, size](0, 2, 3, 4, 0, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 0).__add__(Bivector[type, size](5, 6, 7)), Multivector[type, size](0, 0, 0, 0, 5, 6, 7, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 0).__add__(Antiox[type, size](8)), Multivector[type, size](0, 0, 0, 0, 0, 0, 0, 8))

    assert_equal(Rotor[type, size](1, 5, 6, 7).__add__(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8)), Multivector[type, size](2, 2, 3, 4, 10, 12, 14, 8))
    assert_equal(Rotor[type, size](1, 5, 6, 7).__add__(Rotor[type, size](8, 4, 3, 2)), Rotor[type, size](9, 9, 9, 9))
    assert_equal(Rotor[type, size](1, 2, 3, 4).__add__(SIMD[type, size](8)), Rotor[type, size](9, 2, 3, 4))
    assert_equal(Rotor[type, size](1, 5, 6, 7).__add__(Vector[type, size](2, 3, 4)), Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 0))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__add__(Bivector[type, size](1, 1, 1)), Rotor[type, size](1, 2, 2, 2))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__add__(Antiox[type, size](1)), Multivector[type, size](1, 0, 0, 0, 1, 1, 1, 1))

    assert_equal(Vector[type, size](1, 1, 1).__add__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](1, 2, 2, 2, 1, 1, 1, 1))
    assert_equal(Vector[type, size](1, 1, 1).__add__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 0))
    assert_equal(Vector[type, size](1, 1, 1).__add__(SIMD[type, size](1)), Multivector[type, size](1, 1, 1, 1, 0, 0, 0, 0))
    assert_equal(Vector[type, size](2, 3, 4).__add__(Vector[type, size](7, 6, 5)), Vector[type, size](9, 9, 9))
    assert_equal(Vector[type, size](1, 1, 1).__add__(Bivector[type, size](1, 1, 1)), Multivector[type, size](0, 1, 1, 1, 1, 1, 1, 0))
    assert_equal(Vector[type, size](1, 1, 1).__add__(Antiox[type, size](1)), Multivector[type, size](0, 1, 1, 1, 0, 0, 0, 1))

    assert_equal(Bivector[type, size](1, 1, 1).__add__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](1, 1, 1, 1, 2, 2, 2, 1))
    assert_equal(Bivector[type, size](1, 1, 1).__add__(Rotor[type, size](1, 1, 1, 1)), Rotor[type, size](1, 2, 2, 2))
    assert_equal(Bivector[type, size](1, 1, 1).__add__(SIMD[type, size](1)), Rotor[type, size](1, 1, 1, 1))
    assert_equal(Bivector[type, size](1, 1, 1).__add__(Vector[type, size](1, 1, 1)), Multivector[type, size](0, 1, 1, 1, 1, 1, 1, 0))
    assert_equal(Bivector[type, size](5, 6, 7).__add__(Bivector[type, size](4, 3, 2)), Bivector[type, size](9, 9, 9))
    assert_equal(Bivector[type, size](1, 1, 1).__add__(Antiox[type, size](1)), Multivector[type, size](0, 0, 0, 0, 1, 1, 1, 1))

    assert_equal(Antiox[type, size](1).__add__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 2))
    assert_equal(Antiox[type, size](1).__add__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](1, 0, 0, 0, 1, 1, 1, 1))
    assert_equal(Antiox[type, size](1).__add__(SIMD[type, size](1)), Multivector[type, size](1, 0, 0, 0, 0, 0, 0, 1))
    assert_equal(Antiox[type, size](1).__add__(Vector[type, size](1, 1, 1)), Multivector[type, size](0, 1, 1, 1, 0, 0, 0, 1))
    assert_equal(Antiox[type, size](1).__add__(Bivector[type, size](1, 1, 1)), Multivector[type, size](0, 0, 0, 0, 1, 1, 1, 1))
    assert_equal(Antiox[type, size](8).__add__(Antiox[type, size](1)), Antiox[type, size](9))


def test_sub[type: DType, size: Int]():
    assert_equal(Multivector[type, size](9, 9, 9, 9, 9, 9, 9, 9).__sub__(Multivector[type, size](8, 7, 6, 5, 4, 3, 2, 1)), Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__sub__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](0, 1, 1, 1, 0, 0, 0, 1))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__sub__(SIMD[type, size](1)), Multivector[type, size](0, 1, 1, 1, 1, 1, 1, 1))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__sub__(Vector[type, size](1, 1, 1)), Multivector[type, size](1, 0, 0, 0, 1, 1, 1, 1))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__sub__(Bivector[type, size](1, 1, 1)), Multivector[type, size](1, 1, 1, 1, 0, 0, 0, 1))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__sub__(Antiox[type, size](1)), Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 0))

    assert_equal(Rotor[type, size](1, 1, 1, 1).__sub__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](0, -1, -1, -1, 0, 0, 0, -1))
    assert_equal(Rotor[type, size](9, 9, 9, 9).__sub__(Rotor[type, size](8, 4, 3, 2)), Rotor[type, size](1, 5, 6, 7))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__sub__(SIMD[type, size](1)), Rotor[type, size](0, 1, 1, 1))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__sub__(Vector[type, size](1, 1, 1)), Multivector[type, size](1, -1, -1, -1, 1, 1, 1, 0))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__sub__(Bivector[type, size](1, 1, 1)), Rotor[type, size](1, 0, 0, 0))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__sub__(Antiox[type, size](1)), Multivector[type, size](1, 0, 0, 0, 1, 1, 1, -1))

    assert_equal(Vector[type, size](1, 1, 1).__sub__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](-1, 0, 0, 0, -1, -1, -1, -1))
    assert_equal(Vector[type, size](1, 1, 1).__sub__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](-1, 1, 1, 1, -1, -1, -1, 0))
    assert_equal(Vector[type, size](1, 1, 1).__sub__(SIMD[type, size](1)), Multivector[type, size](-1, 1, 1, 1, 0, 0, 0, 0))
    assert_equal(Vector[type, size](9, 9, 9).__sub__(Vector[type, size](7, 6, 5)), Vector[type, size](2, 3, 4))
    assert_equal(Vector[type, size](1, 1, 1).__sub__(Bivector[type, size](1, 1, 1)), Multivector[type, size](0, 1, 1, 1, -1, -1, -1, 0))
    assert_equal(Vector[type, size](1, 1, 1).__sub__(Antiox[type, size](1)), Multivector[type, size](0, 1, 1, 1, 0, 0, 0, -1))

    assert_equal(Bivector[type, size](1, 1, 1).__sub__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](-1, -1, -1, -1, 0, 0, 0, -1))
    assert_equal(Bivector[type, size](1, 1, 1).__sub__(Rotor[type, size](1, 1, 1, 1)), Rotor[type, size](-1, 0, 0, 0))
    assert_equal(Bivector[type, size](1, 1, 1).__sub__(SIMD[type, size](1)), Rotor[type, size](-1, 1, 1, 1))
    assert_equal(Bivector[type, size](1, 1, 1).__sub__(Vector[type, size](1, 1, 1)), Multivector[type, size](0, -1, -1, -1, 1, 1, 1, 0))
    assert_equal(Bivector[type, size](9, 9, 9).__sub__(Bivector[type, size](4, 3, 2)), Bivector[type, size](5, 6, 7))
    assert_equal(Bivector[type, size](1, 1, 1).__sub__(Antiox[type, size](1)), Multivector[type, size](0, 0, 0, 0, 1, 1, 1, -1))

    assert_equal(Antiox[type, size](1).__sub__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](-1, -1, -1, -1, -1, -1, -1, 0))
    assert_equal(Antiox[type, size](1).__sub__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](-1, 0, 0, 0, -1, -1, -1, 1))
    assert_equal(Antiox[type, size](1).__sub__(SIMD[type, size](1)), Multivector[type, size](-1, 0, 0, 0, 0, 0, 0, 1))
    assert_equal(Antiox[type, size](1).__sub__(Vector[type, size](1, 1, 1)), Multivector[type, size](0, -1, -1, -1, 0, 0, 0, 1))
    assert_equal(Antiox[type, size](1).__sub__(Bivector[type, size](1, 1, 1)), Multivector[type, size](0, 0, 0, 0, -1, -1, -1, 1))
    assert_equal(Antiox[type, size](9).__sub__(Antiox[type, size](1)), Antiox[type, size](8))


def test_mul[type: DType, size: Int]():
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__mul__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](0, 0, 4, 0, 4, 0, 4, 4))
    assert_equal(Multivector[type, size](1, 3, 5, 2, 4, 6, 8, 7).__mul__(Multivector[type, size](1, 2, 4, 3, 5, 7, 6, 8)), Multivector[type, size](-133, -106, 125, -55, 68, -66, 61, 12))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__mul__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](-2, -2, 2, 2, 2, 2, 2, 2))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__mul__(SIMD[type, size](2)), Multivector[type, size](2, 2, 2, 2, 2, 2, 2, 2))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__mul__(Vector[type, size](1, 1, 1)), Multivector[type, size](3, 3, 1, -1, 1, -1, 1, 1))
    assert_equal(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1).__mul__(Bivector[type, size](1, 1, 1)), Multivector[type, size](-3, -3, 1, 1, 1, 1, 1, 1))
    assert_equal(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8).__mul__(Antiox[type, size](1)), Multivector[type, size](-8, -7, 6, -5, 4, -3, 2, 1))

    assert_equal(Rotor[type, size](1, 1, 1, 1).__mul__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](-2, 2, 2, -2, 2, 2, 2, 2))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__mul__(Rotor[type, size](1, 1, 1, 1)), Rotor[type, size](-2, 2, 2, 2))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__mul__(SIMD[type, size](2)), Rotor[type, size](2, 2, 2, 2))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__mul__(Vector[type, size](1, 1, 1)), Multivector[type, size](0, 3, 1, -1, 0, 0, 0, 1))
    assert_equal(Rotor[type, size](1, 1, 1, 1).__mul__(Bivector[type, size](1, 1, 1)), Rotor[type, size](-3, 1, 1, 1))
    assert_equal(Rotor[type, size](1, 5, 6, 7).__mul__(Antiox[type, size](1)), Multivector[type, size](0, -7, 6, -5, 0, 0, 0, 1))

    assert_equal(Vector[type, size](1, 1, 1).__mul__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](3, -1, 1, 3, 1, -1, 1, 1))
    assert_equal(Vector[type, size](1, 1, 1).__mul__(Rotor[type, size](1, 1, 1, 1)), Multivector[type, size](0, -1, 1, 3, 0, 0, 0, 1))
    assert_equal(Vector[type, size](1, 1, 1).__mul__(Vector[type, size](1, 1, 1)), SIMD[type, size](3))
    assert_equal(Vector[type, size](1, 1, 1).__mul__(Bivector[type, size](1, 1, 1)), Multivector[type, size](0, -2, 0, 2, 0, 0, 0, 1))
    assert_equal(Vector[type, size](2, 3, 4).__mul__(Antiox[type, size](1)), Bivector[type, size](4, -3, 2))

    assert_equal(Bivector[type, size](1, 1, 1).__mul__(Multivector[type, size](1, 1, 1, 1, 1, 1, 1, 1)), Multivector[type, size](-3, 1, 1, -3, 1, 1, 1, 1))
    assert_equal(Bivector[type, size](1, 1, 1).__mul__(Rotor[type, size](1, 1, 1, 1)), Rotor[type, size](-3, 1, 1, 1))
    assert_equal(Bivector[type, size](1, 1, 1).__mul__(Vector[type, size](1, 1, 1)), Multivector[type, size](0, 2, 0, -2, 0, 0, 0, 1))
    assert_equal(Bivector[type, size](1, 1, 1).__mul__(Bivector[type, size](1, 1, 1)), SIMD[type, size](-3))
    assert_equal(Bivector[type, size](5, 6, 7).__mul__(Antiox[type, size](1)), Vector[type, size](-7, 6, -5))

    assert_equal(Antiox[type, size](1).__mul__(Multivector[type, size](1, 2, 3, 4, 5, 6, 7, 8)), Multivector[type, size](-8, -7, 6, -5, 4, -3, 2, 1))
    assert_equal(Antiox[type, size](1).__mul__(Rotor[type, size](1, 5, 6, 7)), Multivector[type, size](0, -7, 6, -5, 0, 0, 0, 1))
    assert_equal(Antiox[type, size](1).__mul__(SIMD[type, size](2)), Antiox[type, size](2))
    assert_equal(Antiox[type, size](1).__mul__(Vector[type, size](2, 3, 4)), Bivector[type, size](4, -3, 2))
    assert_equal(Antiox[type, size](1).__mul__(Bivector[type, size](5, 6, 7)), Vector[type, size](-7, 6, -5))
    assert_equal(Antiox[type, size](1).__mul__(Antiox[type, size](1)), SIMD[type, size](-1))
