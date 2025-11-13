# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""
Geometric Algebra.

This contains the main interface of blade.
"""

from os import abort

from .algebra.basis import BasisLiteral, Basis
from .algebra.mask import BasisMask
from .algebra.multivector import Multivector
from .algebra.signature import Signature


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
fn ga[
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


@register_passable("trivial")
struct GA[sig: Signature]:
    """Statically generated geometric algebra."""

    # +------( Initialization Helper )------+ #
    #
    @always_inline("builtin")
    fn __init__(out self):
        pass

    # +------( Multivector Parsing )------+ #
    #
    fn __getitem__[
        string: String
    ](self, out result: Multivector[sig, sig.basis_mask(string)]):
        result = result.__init__()
        var start = 0
        var stop = 1

        while stop < len(string):
            stop = string.find("+", start=start)
            stop = len(string) if stop == -1 else stop
            var slice = string[start:stop].strip(" ")
            var idx_of_e = slice.find("e")
            idx_of_e = len(slice) if idx_of_e == -1 else idx_of_e
            try:
                var basis = materialize[sig]().signed_basis(slice[idx_of_e:])
                var entry = result.mask.get_entry(Basis(bin=basis.bin))
                var value = 1 if idx_of_e == start else result.Coef(
                    slice[:idx_of_e]
                )
                result._data[entry] = value * basis.sign
            except e:
                abort[prefix="failed to parse multivector: "](String(e))
            start = stop + 1

    @always_inline("builtin")
    fn __getattr__[
        attr: StringLiteral
    ](self, out result: BasisLiteral[sig, sig.signed_basis(attr)]):
        result = result.__init__()

    # +------( Subspace Constructors )------+ #
    #
    comptime Multivector = Multivector[sig, dtype=_, size=_, mask=_]
    comptime Vector = Multivector[sig,]
    comptime i = Multivector[sig, Self.antiscalar_mask, _, _](1)

    @staticmethod
    @always_inline
    fn vector[
        type: DType = DType.float64, size: Int = 1
    ](var *coefs: SIMD[type, size]) -> Multivector[
        sig, Self.vector_mask, type, size
    ]:
        return Multivector[sig, Self.vector_mask, type, size](coefs^)

    @staticmethod
    @always_inline
    fn bivector[
        type: DType = DType.float64, size: Int = 1
    ](var *coefs: SIMD[type, size]) -> Multivector[
        sig, Self.bivector_mask, type, size
    ]:
        return Multivector[sig, Self.bivector_mask, type, size](coefs^)

    # @staticmethod
    # @always_inline
    # fn i[type: DType = DType.float64, size: Int = 1](var coef: SIMD[type, size]) -> Multivector[sig, Self.antiscalar_mask, type, size]:
    #     return Multivector[sig, Self.antiscalar_mask, type, size](coef)

    # +------( Mask Aliases )------+ #
    #
    comptime empty_mask = sig.empty_mask()
    comptime full_mask = sig.full_mask()
    comptime even_mask = sig.even_mask()

    comptime scalar_mask = sig.scalar_mask()
    comptime vector_mask = sig.vector_mask()
    comptime bivector_mask = sig.bivector_mask()
    comptime trivector_mask = sig.trivector_mask()
    comptime quadvector_mask = sig.quadvector_mask()

    comptime antiscalar_mask = sig.antiscalar_mask()
    comptime antivector_mask = sig.antivector_mask()
    comptime antibivector_mask = sig.antibivector_mask()
    comptime antitrivector_mask = sig.antitrivector_mask()
    comptime antiquadvector_mask = sig.antiquadvector_mask()
