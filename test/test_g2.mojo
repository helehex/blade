# x--------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x--------------------------------------------------------------------------x #

from std.testing import assert_true, assert_false, assert_equal, assert_not_equal
from _testing import _assert_equal, _assert_not_equal

from hard.g2 import *


def main() raises:
    simd_run[DType.float64, 1]()
    simd_run[DType.float64, 2]()
    simd_run[DType.float64, 4]()

    simd_run[DType.float32, 1]()
    simd_run[DType.float32, 2]()
    simd_run[DType.float32, 4]()

    simd_run[DType.int, 1]()
    simd_run[DType.int, 2]()
    simd_run[DType.int, 4]()


def simd_run[type: DType, size: Int]() raises:
    test_eq[type, size]()
    test_ne[type, size]()
    test_add[type, size]()
    test_sub[type, size]()
    test_mul[type, size]()

    comptime if type.is_floating_point():
        test_truediv[type, size]()


def test_eq[type: DType, size: Int]() raises:
    # +--- Multivector
    assert_true(Multivector[type, size](1, 2, 3, 4).__eq__(Multivector[type, size](1, 2, 3, 4)))
    assert_false(Multivector[type, size](1, 2, 3, 4).__eq__(Multivector[type, size](4, 3, 2, 1)))

    assert_true(Multivector[type, size](0, 2, 3, 0).__eq__(Vector[type, size](2, 3)))
    assert_false(Multivector[type, size](1, 2, 3, 4).__eq__(Vector[type, size](2, 3)))

    assert_true(Multivector[type, size](1, 0, 0, 0).__eq__(SIMD[type, size](1)))
    assert_false(Multivector[type, size](1, 2, 3, 4).__eq__(SIMD[type, size](1)))

    assert_true(Multivector[type, size](1, 0, 0, 4).__eq__(Rotor[type, size](1, 4)))
    assert_false(Multivector[type, size](1, 2, 3, 4).__eq__(Rotor[type, size](1, 4)))

    # +--- Rotor
    assert_true(Rotor[type, size](1, 4).__eq__(Multivector[type, size](1, 0, 0, 4)))
    assert_false(Rotor[type, size](1, 4).__eq__(Multivector[type, size](1, 2, 3, 4)))

    assert_true(Rotor[type, size](1, 4).__eq__(Rotor[type, size](1, 4)))
    assert_false(Rotor[type, size](1, 4).__eq__(Rotor[type, size](4, 1)))

    assert_true(Rotor[type, size](1, 0).__eq__(SIMD[type, size](1)))
    assert_false(Rotor[type, size](1, 4).__eq__(SIMD[type, size](1)))

    # False

    # +--- Vector
    assert_true(Vector[type, size](2, 3).__eq__(Multivector[type, size](0, 2, 3, 0)))
    assert_false(Vector[type, size](2, 3).__eq__(Multivector[type, size](1, 2, 3, 4)))

    # False

    assert_true(Vector[type, size](2, 3).__eq__(Vector[type, size](2, 3)))
    assert_false(Vector[type, size](2, 3).__eq__(Vector[type, size](3, 2)))


def test_ne[type: DType, size: Int]() raises:
    # +--- Multivector
    assert_false(Multivector[type, size](1, 2, 3, 4).__ne__(Multivector[type, size](1, 2, 3, 4)))
    assert_true(Multivector[type, size](1, 2, 3, 4).__ne__(Multivector[type, size](4, 3, 2, 1)))

    assert_false(Multivector[type, size](0, 2, 3, 0).__ne__(Vector[type, size](2, 3)))
    assert_true(Multivector[type, size](1, 2, 3, 4).__ne__(Vector[type, size](2, 3)))

    assert_false(Multivector[type, size](1, 0, 0, 0).__ne__(SIMD[type, size](1)))
    assert_true(Multivector[type, size](1, 2, 3, 4).__ne__(SIMD[type, size](1)))

    assert_false(Multivector[type, size](1, 0, 0, 4).__ne__(Rotor[type, size](1, 4)))
    assert_true(Multivector[type, size](1, 2, 3, 4).__ne__(Rotor[type, size](1, 4)))

    # +--- Rotor
    assert_false(Rotor[type, size](1, 4).__ne__(Multivector[type, size](1, 0, 0, 4)))
    assert_true(Rotor[type, size](1, 4).__ne__(Multivector[type, size](1, 2, 3, 4)))

    assert_false(Rotor[type, size](1, 4).__ne__(Rotor[type, size](1, 4)))
    assert_true(Rotor[type, size](1, 4).__ne__(Rotor[type, size](4, 1)))

    assert_false(Rotor[type, size](1, 0).__ne__(SIMD[type, size](1)))
    assert_true(Rotor[type, size](1, 4).__ne__(SIMD[type, size](1)))

    # False

    # +--- Vector
    assert_false(Vector[type, size](2, 3).__ne__(Multivector[type, size](0, 2, 3, 0)))
    assert_true(Vector[type, size](2, 3).__ne__(Multivector[type, size](1, 2, 3, 4)))

    # False

    assert_false(Vector[type, size](2, 3).__ne__(Vector[type, size](2, 3)))
    assert_true(Vector[type, size](2, 3).__ne__(Vector[type, size](3, 2)))


def test_add[type: DType, size: Int]() raises:
    assert_equal(Multivector[type, size](1, 2, 3, 4).__add__(Multivector[type, size](5, 4, 3, 2)), Multivector[type, size](6, 6, 6, 6))
    assert_equal(Multivector[type, size](0, 0, 0, 0).__add__(Rotor[type, size](1, 4)), Multivector[type, size](1, 0, 0, 4))
    assert_equal(Multivector[type, size](0, 0, 0, 0).__add__(Vector[type, size](2, 3)), Multivector[type, size](0, 2, 3, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 0).__add__(SIMD[type, size](1)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Rotor[type, size](1, 4).__add__(Multivector[type, size](0, 2, 3, 0)), Multivector[type, size](1, 2, 3, 4))
    assert_equal(Rotor[type, size](1, 4).__add__(Rotor[type, size](5, 2)), Rotor[type, size](6, 6))
    assert_equal(Rotor[type, size](1, 4).__add__(Vector[type, size](2, 3)), Multivector[type, size](1, 2, 3, 4))
    assert_equal(Rotor[type, size](0, 4).__add__(SIMD[type, size](1)), Rotor[type, size](1, 4))

    assert_equal(Vector[type, size](2, 3).__add__(Multivector[type, size](1, 0, 0, 4)), Multivector[type, size](1, 2, 3, 4))
    assert_equal(Vector[type, size](2, 3).__add__(Rotor[type, size](1, 4)), Multivector[type, size](1, 2, 3, 4))
    assert_equal(Vector[type, size](2, 3).__add__(Vector[type, size](4, 3)), Vector[type, size](6, 6))
    assert_equal(Vector[type, size](2, 3).__add__(SIMD[type, size](1)), Multivector[type, size](1, 2, 3, 0))

    assert_equal(Multivector[type, size](0, 2, 3, 4).__radd__(SIMD[type, size](1)), Multivector[type, size](1, 2, 3, 4))
    assert_equal(Rotor[type, size](0, 4).__radd__(SIMD[type, size](1)), Rotor[type, size](1, 4))
    assert_equal(Vector[type, size](2, 3).__radd__(SIMD[type, size](1)), Multivector[type, size](1, 2, 3, 0))


def test_sub[type: DType, size: Int]() raises:
    assert_equal(Multivector[type, size](6, 6, 6, 6).__sub__(Multivector[type, size](5, 4, 3, 2)), Multivector[type, size](1, 2, 3, 4))
    assert_equal(Multivector[type, size](1, 0, 0, 4).__sub__(Rotor[type, size](1, 4)), Multivector[type, size](0, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 2, 3, 0).__sub__(Vector[type, size](2, 3)), Multivector[type, size](0, 0, 0, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__sub__(SIMD[type, size](1)), Multivector[type, size](0, 0, 0, 0))

    assert_equal(Rotor[type, size](1, 4).__sub__(Multivector[type, size](0, 2, 3, 0)), Multivector[type, size](1, -2, -3, 4))
    assert_equal(Rotor[type, size](6, 6).__sub__(Rotor[type, size](5, 2)), Rotor[type, size](1, 4))
    assert_equal(Rotor[type, size](1, 4).__sub__(Vector[type, size](2, 3)), Multivector[type, size](1, -2, -3, 4))
    assert_equal(Rotor[type, size](1, 4).__sub__(SIMD[type, size](1)), Rotor[type, size](0, 4))

    assert_equal(Vector[type, size](2, 3).__sub__(Multivector[type, size](1, 0, 0, 4)), Multivector[type, size](-1, 2, 3, -4))
    assert_equal(Vector[type, size](2, 3).__sub__(Rotor[type, size](1, 4)), Multivector[type, size](-1, 2, 3, -4))
    assert_equal(Vector[type, size](6, 6).__sub__(Vector[type, size](4, 3)), Vector[type, size](2, 3))
    assert_equal(Vector[type, size](2, 3).__sub__(SIMD[type, size](1)), Multivector[type, size](-1, 2, 3, 0))

    assert_equal(Multivector[type, size](1, 2, 3, 4).__rsub__(SIMD[type, size](1)), Multivector[type, size](0, -2, -3, -4))
    assert_equal(Rotor[type, size](1, 4).__rsub__(SIMD[type, size](1)), Rotor[type, size](0, -4))
    assert_equal(Vector[type, size](2, 3).__rsub__(SIMD[type, size](1)), Multivector[type, size](1, -2, -3, 0))


def test_mul[type: DType, size: Int]() raises:
    # +--- multivector * multivector
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 0, 1))

    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, 0, -1))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, -1, 0, 0))

    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, -1, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](-1, 0, 0, 0))

    # +--- multivector * vector
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Vector[type, size](1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Vector[type, size](0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Vector[type, size](1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Vector[type, size](0, 1)), Multivector[type, size](0, 0, 0, 1))

    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Vector[type, size](1, 0)), Multivector[type, size](0, 0, 0, -1))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Vector[type, size](0, 1)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Vector[type, size](1, 0)), Multivector[type, size](0, 0, -1, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Vector[type, size](0, 1)), Multivector[type, size](0, 1, 0, 0))

    # +--- multivector * rotor
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Rotor[type, size](1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(Rotor[type, size](0, 1)), Multivector[type, size](0, 0, 0, 1))

    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Rotor[type, size](1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(Rotor[type, size](0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Rotor[type, size](1, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(Rotor[type, size](0, 1)), Multivector[type, size](0, -1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Rotor[type, size](1, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(Rotor[type, size](0, 1)), Multivector[type, size](-1, 0, 0, 0))

    # +--- multivector * scalar
    assert_equal(Multivector[type, size](1, 0, 0, 0).__mul__(2), Multivector[type, size](2, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__mul__(2), Multivector[type, size](0, 2, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__mul__(2), Multivector[type, size](0, 0, 2, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__mul__(2), Multivector[type, size](0, 0, 0, 2))
    assert_equal(Multivector[type, size](1, 2, 3, 4).__mul__(2), Multivector[type, size](2, 4, 6, 8))

    # +--- vector * multivector
    assert_equal(Vector[type, size](1, 0).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Vector[type, size](1, 0).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Vector[type, size](1, 0).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Vector[type, size](1, 0).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Vector[type, size](0, 1).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Vector[type, size](0, 1).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, 0, -1))
    assert_equal(Vector[type, size](0, 1).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Vector[type, size](0, 1).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, -1, 0, 0))

    # +--- vector * vector
    assert_equal(Vector[type, size](1, 0).__mul__(Vector[type, size](1, 0)), Rotor[type, size](1, 0))
    assert_equal(Vector[type, size](1, 0).__mul__(Vector[type, size](0, 1)), Rotor[type, size](0, 1))

    assert_equal(Vector[type, size](0, 1).__mul__(Vector[type, size](1, 0)), Rotor[type, size](0, -1))
    assert_equal(Vector[type, size](0, 1).__mul__(Vector[type, size](0, 1)), Rotor[type, size](1, 0))

    # +--- vector * rotor
    assert_equal(Vector[type, size](1, 0).__mul__(Rotor[type, size](1, 0)), Vector[type, size](1, 0))
    assert_equal(Vector[type, size](1, 0).__mul__(Rotor[type, size](0, 1)), Vector[type, size](0, 1))

    assert_equal(Vector[type, size](0, 1).__mul__(Rotor[type, size](1, 0)), Vector[type, size](0, 1))
    assert_equal(Vector[type, size](0, 1).__mul__(Rotor[type, size](0, 1)), Vector[type, size](-1, 0))

    # +--- vector * scalar
    assert_equal(Vector[type, size](1, 0).__mul__(2), Vector[type, size](2, 0))
    assert_equal(Vector[type, size](0, 1).__mul__(2), Vector[type, size](0, 2))
    assert_equal(Vector[type, size](2, 3).__mul__(2), Vector[type, size](4, 6))

    # +--- rotor * multivector
    assert_equal(Rotor[type, size](1, 0).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Rotor[type, size](1, 0).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Rotor[type, size](1, 0).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Rotor[type, size](1, 0).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 0, 1))

    assert_equal(Rotor[type, size](0, 1).__mul__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Rotor[type, size](0, 1).__mul__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, -1, 0))
    assert_equal(Rotor[type, size](0, 1).__mul__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Rotor[type, size](0, 1).__mul__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](-1, 0, 0, 0))

    # +--- rotor * vector
    assert_equal(Rotor[type, size](1, 0).__mul__(Vector[type, size](1, 0)), Vector[type, size](1, 0))
    assert_equal(Rotor[type, size](1, 0).__mul__(Vector[type, size](0, 1)), Vector[type, size](0, 1))

    assert_equal(Rotor[type, size](0, 1).__mul__(Vector[type, size](1, 0)), Vector[type, size](0, -1))
    assert_equal(Rotor[type, size](0, 1).__mul__(Vector[type, size](0, 1)), Vector[type, size](1, 0))

    # +--- rotor * rotor
    assert_equal(Rotor[type, size](1, 0).__mul__(Rotor[type, size](1, 0)), Rotor[type, size](1, 0))
    assert_equal(Rotor[type, size](1, 0).__mul__(Rotor[type, size](0, 1)), Rotor[type, size](0, 1))

    assert_equal(Rotor[type, size](0, 1).__mul__(Rotor[type, size](1, 0)), Rotor[type, size](0, 1))
    assert_equal(Rotor[type, size](0, 1).__mul__(Rotor[type, size](0, 1)), Rotor[type, size](-1, 0))

    # +--- rotor * scalar
    assert_equal(Rotor[type, size](1, 0).__mul__(2), Rotor[type, size](2, 0))
    assert_equal(Rotor[type, size](0, 1).__mul__(2), Rotor[type, size](0, 2))
    assert_equal(Rotor[type, size](1, 4).__mul__(2), Rotor[type, size](2, 8))

    # +--- scalar * multivector
    assert_equal(Multivector[type, size](1, 0, 0, 0).__rmul__(2), Multivector[type, size](2, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__rmul__(2), Multivector[type, size](0, 2, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__rmul__(2), Multivector[type, size](0, 0, 2, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__rmul__(2), Multivector[type, size](0, 0, 0, 2))

    # +--- scalar * vector
    assert_equal(Vector[type, size](1, 0).__rmul__(2), Vector[type, size](2, 0))
    assert_equal(Vector[type, size](0, 1).__rmul__(2), Vector[type, size](0, 2))

    # +--- scalar * rotor
    assert_equal(Rotor[type, size](1, 0).__rmul__(2), Rotor[type, size](2, 0))
    assert_equal(Rotor[type, size](0, 1).__rmul__(2), Rotor[type, size](0, 2))


def test_truediv[type: DType, size: Int]() raises:
    # +--- multivector / multivector
    assert_equal(Multivector[type, size](1, 0, 0, 0).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Multivector[type, size](0, 1, 0, 0).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 1, 0, 0))

    assert_equal(Multivector[type, size](0, 0, 1, 0).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](0, 0, 0, -1).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](0, -1, 0, 0).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Multivector[type, size](0, 0, 0, 1).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](0, 0, -1, 0).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](-1, 0, 0, 0).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 0, 1))

    # +--- multivector / vector
    assert_equal(Multivector[type, size](0, 1, 0, 0).__truediv__(Vector[type, size](1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__truediv__(Vector[type, size](0, 1)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Multivector[type, size](1, 0, 0, 0).__truediv__(Vector[type, size](1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__truediv__(Vector[type, size](0, 1)), Multivector[type, size](0, 1, 0, 0))

    assert_equal(Multivector[type, size](0, 0, 0, -1).__truediv__(Vector[type, size](1, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](1, 0, 0, 0).__truediv__(Vector[type, size](0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Multivector[type, size](0, 0, -1, 0).__truediv__(Vector[type, size](1, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](0, 1, 0, 0).__truediv__(Vector[type, size](0, 1)), Multivector[type, size](0, 0, 0, 1))

    # +--- multivector / rotor
    assert_equal(Multivector[type, size](1, 0, 0, 0).__truediv__(Rotor[type, size](1, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 1).__truediv__(Rotor[type, size](0, 1)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Multivector[type, size](0, 1, 0, 0).__truediv__(Rotor[type, size](1, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 1, 0).__truediv__(Rotor[type, size](0, 1)), Multivector[type, size](0, 1, 0, 0))

    assert_equal(Multivector[type, size](0, 0, 1, 0).__truediv__(Rotor[type, size](1, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](0, -1, 0, 0).__truediv__(Rotor[type, size](0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Multivector[type, size](0, 0, 0, 1).__truediv__(Rotor[type, size](1, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](-1, 0, 0, 0).__truediv__(Rotor[type, size](0, 1)), Multivector[type, size](0, 0, 0, 1))

    # +--- multivector / scalar
    assert_equal(Multivector[type, size](2, 0, 0, 0).__truediv__(2), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Multivector[type, size](0, 2, 0, 0).__truediv__(2), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Multivector[type, size](0, 0, 2, 0).__truediv__(2), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Multivector[type, size](0, 0, 0, 2).__truediv__(2), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Multivector[type, size](2, 4, 6, 8).__truediv__(2), Multivector[type, size](1, 2, 3, 4))

    # +--- vector / multivector
    assert_equal(Vector[type, size](1, 0).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Vector[type, size](0, 1).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Vector[type, size](1, 0).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Vector[type, size](0, 1).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 1, 0, 0))

    assert_equal(Vector[type, size](0, 1).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Vector[type, size](-1, 0).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Vector[type, size](0, -1).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Vector[type, size](1, 0).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 0, 1))

    # +--- vector / vector
    assert_equal(Vector[type, size](1, 0).__truediv__(Vector[type, size](1, 0)), Rotor[type, size](1, 0))
    assert_equal(Vector[type, size](0, 1).__truediv__(Vector[type, size](0, 1)), Rotor[type, size](1, 0))

    assert_equal(Vector[type, size](0, -1).__truediv__(Vector[type, size](1, 0)), Rotor[type, size](0, 1))
    assert_equal(Vector[type, size](1, 0).__truediv__(Vector[type, size](0, 1)), Rotor[type, size](0, 1))

    # +--- vector / rotor
    assert_equal(Vector[type, size](1, 0).__truediv__(Rotor[type, size](1, 0)), Vector[type, size](1, 0))
    assert_equal(Vector[type, size](0, 1).__truediv__(Rotor[type, size](0, 1)), Vector[type, size](1, 0))

    assert_equal(Vector[type, size](0, 1).__truediv__(Rotor[type, size](1, 0)), Vector[type, size](0, 1))
    assert_equal(Vector[type, size](-1, 0).__truediv__(Rotor[type, size](0, 1)), Vector[type, size](0, 1))

    # +--- vector / scalar
    assert_equal(Vector[type, size](2, 0).__truediv__(2), Vector[type, size](1, 0))
    assert_equal(Vector[type, size](0, 2).__truediv__(2), Vector[type, size](0, 1))
    assert_equal(Vector[type, size](2, 4).__truediv__(2), Vector[type, size](1, 2))

    # +--- rotor / multivector
    assert_equal(Rotor[type, size](1, 0).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](1, 0, 0, 0))
    assert_equal(Rotor[type, size](0, 1).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](1, 0, 0, 0))

    assert_equal(Rotor[type, size](1, 0).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 1, 0, 0))
    assert_equal(Rotor[type, size](0, 1).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 1, 0, 0))

    assert_equal(Rotor[type, size](0, -1).__truediv__(Multivector[type, size](0, 1, 0, 0)), Multivector[type, size](0, 0, 1, 0))
    assert_equal(Rotor[type, size](1, 0).__truediv__(Multivector[type, size](0, 0, 1, 0)), Multivector[type, size](0, 0, 1, 0))

    assert_equal(Rotor[type, size](0, 1).__truediv__(Multivector[type, size](1, 0, 0, 0)), Multivector[type, size](0, 0, 0, 1))
    assert_equal(Rotor[type, size](-1, 0).__truediv__(Multivector[type, size](0, 0, 0, 1)), Multivector[type, size](0, 0, 0, 1))

    # +--- rotor / vector
    assert_equal(Rotor[type, size](1, 0).__truediv__(Vector[type, size](1, 0)), Vector[type, size](1, 0))
    assert_equal(Rotor[type, size](0, 1).__truediv__(Vector[type, size](0, 1)), Vector[type, size](1, 0))

    assert_equal(Rotor[type, size](0, -1).__truediv__(Vector[type, size](1, 0)), Vector[type, size](0, 1))
    assert_equal(Rotor[type, size](1, 0).__truediv__(Vector[type, size](0, 1)), Vector[type, size](0, 1))

    # +--- rotor / rotor
    assert_equal(Rotor[type, size](1, 0).__truediv__(Rotor[type, size](1, 0)), Rotor[type, size](1, 0))
    assert_equal(Rotor[type, size](0, 1).__truediv__(Rotor[type, size](0, 1)), Rotor[type, size](1, 0))

    # assert_equal(Rotor[type, size](1, 0).__truediv__(Rotor[type, size](0, 0)), Rotor[type, size](0, 0))
    # assert_equal(Rotor[type, size](0, 1).__truediv__(Rotor[type, size](0, 0)), Rotor[type, size](0, 0))

    # assert_equal(Rotor[type, size](0, -1).__truediv__(Rotor[type, size](0, 0)), Rotor[type, size](0, 0))
    # assert_equal(Rotor[type, size](1, 0).__truediv__(Rotor[type, size](0, 0)), Rotor[type, size](0, 0))

    assert_equal(Rotor[type, size](0, 1).__truediv__(Rotor[type, size](1, 0)), Rotor[type, size](0, 1))
    assert_equal(Rotor[type, size](-1, 0).__truediv__(Rotor[type, size](0, 1)), Rotor[type, size](0, 1))

    # +--- rotor / scalar
    assert_equal(Rotor[type, size](2, 0).__truediv__(2), Rotor[type, size](1, 0))
    assert_equal(Rotor[type, size](0, 2).__truediv__(2), Rotor[type, size](0, 1))
    assert_equal(Rotor[type, size](2, 8).__truediv__(2), Rotor[type, size](1, 4))

    # +--- scalar / multivector
    assert_equal(Multivector[type, size](1, 2, 3, 4).__rtruediv__(SIMD[type, size](2)), Multivector[type, size](0.5, -1, -1.5, -2))

    # +--- scalar / vector
    assert_equal(Vector[type, size](1, 1).__rtruediv__(SIMD[type, size](1)), Vector[type, size](0.5, 0.5))

    # +--- rotor / scalar
    assert_equal(Rotor[type, size](1, 1).__rtruediv__(SIMD[type, size](1)), Rotor[type, size](0.5, -0.5))
