# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""
Geometric Algebra.

This contains the main interface of blade.
"""

from os import abort

from .algebra.basis import BasisLiteral, Basis
from .algebra.mask import BasisMask
from .algebra.multivector import Multivector
from .algebra.signature import Signature


# +----------------------------------------------------------------------------------------------+ #
# | Flavor Aliases
# +----------------------------------------------------------------------------------------------+ #
#
alias Split = ga(1)
"""Split Numbers."""

alias Complex = ga(0, 1)
"""Complex Numbers."""

alias Dual = ga(0, 0, 1)
"""Dual Numbers."""

alias G2 = ga(2)
"""2D Vector Algebra."""

alias G3 = ga(3)
"""3D Vector Algebra."""

alias PG2 = ga(2, 0, 1)
"""2D Projective Algebra."""

alias PG3 = ga(3, 0, 1)
"""3D Projective Algebra."""

alias CG2 = ga(3, 1)
"""2D Conformal Algebra."""

alias CG3 = ga(4, 1)
"""3D Conformal Algebra."""

alias SG2 = ga(1, 2)
"""2D Spacetime Algebra."""

alias SG3 = ga(1, 3)
"""3D Spacetime Algebra."""


# +----------------------------------------------------------------------------------------------+ #
# | Geometric Algebra
# +----------------------------------------------------------------------------------------------+ #
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
    alias Multivector = Multivector[sig, dtype=_, size=_, mask=_]
    alias Vector = Multivector[sig,]
    alias i = Multivector[sig, Self.antiscalar_mask, _, _](1)

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
    alias empty_mask = sig.empty_mask()
    alias full_mask = sig.full_mask()
    alias even_mask = sig.even_mask()

    alias scalar_mask = sig.scalar_mask()
    alias vector_mask = sig.vector_mask()
    alias bivector_mask = sig.bivector_mask()
    alias trivector_mask = sig.trivector_mask()
    alias quadvector_mask = sig.quadvector_mask()

    alias antiscalar_mask = sig.antiscalar_mask()
    alias antivector_mask = sig.antivector_mask()
    alias antibivector_mask = sig.antibivector_mask()
    alias antitrivector_mask = sig.antitrivector_mask()
    alias antiquadvector_mask = sig.antiquadvector_mask()
