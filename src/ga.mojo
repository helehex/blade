# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""
Geometric Algebra.

This contains the main interface of blade.
"""

from std.os import abort

from .algebra.basis import BasisLiteral, Basis
from .algebra.mask import BasisMask
from .algebra.multivector import Multivector
from .algebra.signature import Signature
from .utils.length import len

# +--------------------------------------------------------------------------+ #
# | Flavor Aliases
# +--------------------------------------------------------------------------+ #
#
comptime Split = ga(1)
"""Split Numbers."""

comptime Complex = ga(0, 1)
"""Complex Numbers."""

comptime Dual = ga(0, 0, 1)
"""Dual Numbers."""

comptime G2 = ga(2)
"""2D Vector Algebra."""

comptime G3 = ga(3)
"""3D Vector Algebra."""

comptime PG2 = ga(2, 0, 1)
"""2D Projective Algebra."""

comptime PG3 = ga(3, 0, 1)
"""3D Projective Algebra."""

comptime CG2 = ga(3, 1)
"""2D Conformal Algebra."""

comptime CG3 = ga(4, 1)
"""3D Conformal Algebra."""

comptime SG2 = ga(1, 2)
"""2D Spacetime Algebra."""

comptime SG3 = ga(1, 3)
"""3D Spacetime Algebra."""


# +--------------------------------------------------------------------------+ #
# | Geometric Algebra
# +--------------------------------------------------------------------------+ #
#
# This is the general wrapper for static signature parsing and generation.
#
# +------( Initialization Helper )------+ #
#
@always_inline("builtin")
def ga[
    _po: __mlir_type.`!pop.int_literal`,
    _ne: __mlir_type.`!pop.int_literal` = __mlir_attr.`#pop.int_literal<0>: !pop.int_literal`,
    _ze: __mlir_type.`!pop.int_literal` = __mlir_attr.`#pop.int_literal<0>: !pop.int_literal`,
](
    out self: GA[
        Signature(IntLiteral[_po](), IntLiteral[_ne](), IntLiteral[_ze]())
    ],
    po: IntLiteral[_po],
    ne: IntLiteral[_ne] = IntLiteral[_ne](),
    ze: IntLiteral[_ze] = IntLiteral[_ze](),
):
    return type_of(self)()


struct GA[sig: Signature](TrivialRegisterPassable):
    """Statically generated geometric algebra."""

    # +------( Initialization Helper )------+ #
    #
    @always_inline("builtin")
    def __init__(out self):
        pass

    # +------( Multivector Parsing )------+ #
    #
    def __getitem__[
        string: String
    ](self, out result: Multivector[Self.sig, Self.sig.basis_mask(string)]):
        result = result.__init__()
        var start = 0
        var stop = 1

        while stop < len(string):
            stop = string.find("+", start=start)
            stop = len(string) if stop == -1 else stop
            var slice = string[byte=start:stop].strip(" ")
            var idx_of_e = slice.find("e")
            idx_of_e = len(slice) if idx_of_e == -1 else idx_of_e
            try:
                var basis = materialize[Self.sig]().signed_basis(slice[byte=idx_of_e:])
                var entry = materialize[result.mask]().get_entry(Basis(bin=basis.bin))
                var value = 1 if idx_of_e == start else result.Coef(
                    slice[byte=:idx_of_e]
                )
                result._data[entry] = value * Float64(basis.sign)
            except e:
                abort[prefix="failed to parse multivector: "](String(e))
            start = stop + 1

    @always_inline("builtin")
    def __getattr__[
        attr: StringLiteral
    ](self, out result: BasisLiteral[Self.sig, Self.sig.signed_basis(attr)]):
        result = result.__init__()

    # +------( Subspace Constructors )------+ #
    #
    comptime Multivector = Multivector[Self.sig, dtype=_, size=_, mask=_]
    comptime Vector = Multivector[Self.sig, ...]
    comptime i = Multivector[Self.sig, Self.antiscalar_mask, ...](1)

    @staticmethod
    @always_inline
    def vector[
        type: DType = DType.float64, size: Int = 1
    ](var *coefs: SIMD[type, size]) -> Multivector[
        Self.sig, Self.vector_mask, type, size
    ]:
        return Multivector[Self.sig, Self.vector_mask, type, size](coefs^)

    @staticmethod
    @always_inline
    def bivector[
        type: DType = DType.float64, size: Int = 1
    ](var *coefs: SIMD[type, size]) -> Multivector[
        Self.sig, Self.bivector_mask, type, size
    ]:
        return Multivector[Self.sig, Self.bivector_mask, type, size](coefs^)

    # @staticmethod
    # @always_inline
    # def i[type: DType = DType.float64, size: Int = 1](var coef: SIMD[type, size]) -> Multivector[sig, Self.antiscalar_mask, type, size]:
    #     return Multivector[sig, Self.antiscalar_mask, type, size](coef)

    # +------( Mask Aliases )------+ #
    #
    comptime empty_mask = Self.sig.empty_mask()
    comptime full_mask = Self.sig.full_mask()
    comptime even_mask = Self.sig.even_mask()

    comptime scalar_mask = Self.sig.scalar_mask()
    comptime vector_mask = Self.sig.vector_mask()
    comptime bivector_mask = Self.sig.bivector_mask()
    comptime trivector_mask = Self.sig.trivector_mask()
    comptime quadvector_mask = Self.sig.quadvector_mask()

    comptime antiscalar_mask = Self.sig.antiscalar_mask()
    comptime antivector_mask = Self.sig.antivector_mask()
    comptime antibivector_mask = Self.sig.antibivector_mask()
    comptime antitrivector_mask = Self.sig.antitrivector_mask()
    comptime antiquadvector_mask = Self.sig.antiquadvector_mask()
