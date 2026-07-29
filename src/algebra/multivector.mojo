# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Multivector."""

from std.os import abort
from std.math import sqrt

from src.utils.thick_vector import ThickVector

from .basis import Basis, SignedBasis, ScaledBasis, BasisLiteral
from .mask import BasisMask
from .signature import Signature


# +----------------------------------------------------------------------------------------------+ #
# | Multivector
# +----------------------------------------------------------------------------------------------+ #
#
struct Multivector[
    sig: Signature, mask: BasisMask, dtype: DType = DType.float64, size: Int = 1
](Movable, TrivialRegisterPassable, Writable):
    """Multivector."""

    # +------[ Alias ]------+ #
    #
    comptime DataType = ThickVector[Self.dtype, len(Self.mask), Self.size]
    comptime Coef = SIMD[Self.dtype, Self.size]
    comptime Lane = Multivector[Self.sig, Self.mask, Self.dtype, 1]
    # TODO: rename to something less misleading
    comptime Mask = Multivector[Self.sig, _, Self.dtype, Self.size]

    # +------< Data >------+ #
    #
    var _data: Self.DataType
    """The internal data of this multivector."""

    # +------( Initialize )------+ #
    #
    @always_inline("builtin")
    def __init__(out self, _data: Self.DataType):
        self._data = _data

    @always_inline
    def __init__[
        init: Bool = True, *, _mask: BasisMask = Self.sig.empty_mask()
    ](out self: Self.Mask[_mask]):
        self._data = self._data.__init__[init]()

    # TODO: Uses precedence hacking to get default signature for implicit conversion from simd
    @implicit
    @always_inline
    def __init__[
        __: None = None
    ](out self: Self.Mask[Self.sig.scalar_mask()], scalar: Self.Coef):
        self = self.__init__[False]()
        self._data[0] = scalar

    @implicit
    @always_inline
    def __init__[
        basis: SignedBasis, //, __: None = None
    ](
        out self: Self.Mask[Self.sig.basis_mask(basis)],
        scalar: BasisLiteral[Self.sig, basis],
    ):
        self = self.__init__[False]()
        self._data[0] = Self.Coef(basis.sign)

    @implicit
    @always_inline
    def __init__[
        __: None = None
    ](out self: Self.Mask[Self.sig.scalar_mask()], scalar: Int):
        self = Self.Coef(scalar)

    @always_inline
    def __init__(out self, coef: Self.Coef):
        self = self.__init__[False]()

        comptime if len(Self.mask) != 1:
            abort(
                "incorrect number of coefficient passed to masked multivector"
            )
        self._data = self._data.__init__()
        self._data[0] = coef

    @always_inline
    def __init__(out self, coef: Int):
        self = Self(Self.Coef(coef))

    @always_inline
    def __init__(out self, var *coefs: Self.Coef):
        self = Self(coefs^)

    @always_inline
    def __init__(out self, var coefs: VariadicList[Self.Coef, is_owned=True]):
        self = self.__init__[False]()
        if len(coefs) != len(materialize[Self.mask]()):
            abort(
                "incorrect number of coefficient passed to masked multivector"
            )
        self._data = self._data.__init__(coefs^)

    @always_inline
    def __init__(out self, var **coefs: Self.Coef):
        self = self.__init__[True]()
        for item in coefs.items():
            var entry = materialize[Self.mask]().get_entry(
                materialize[Self.sig]().basis(item.key)
            )
            if entry == -1:
                abort("basis is not a member of mask")
            self._data[entry] = item.value

    # +------( Subscript )------+ #
    #
    @always_inline
    def __getattr__(ref self, _key: StringLiteral) -> Self.Coef:
        comptime key = type_of(_key)()
        comptime entry = Self.mask.get_entry(Self.sig.basis(key))

        comptime if entry == -1:
            return 0
        return self._data[entry]

    @always_inline
    def get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self._data.get_lane(idx))

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String.write(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        comptime if Self.size == 1:
            comptime if len(Self.mask) == 0:
                writer.write("0")
                return

            comptime length = len(Self.mask) - 1
            if self._data[0] < 0:
                writer.write("-")

            comptime for entry in range(length):
                # TODO: reduce verbosity with ScaledBasisIndex
                var element = ScaledBasis(
                    abs(self._data[entry]),
                    materialize[self.mask]().get_basis(entry),
                )
                materialize[Self.sig]().write_basis_to(writer, element)
                writer.write(" - " if self._data[entry + 1] < 0 else " + ")
            var element = ScaledBasis(
                abs(self._data[length]),
                materialize[self.mask]().get_basis(length),
            )
            materialize[Self.sig]().write_basis_to(writer, element)
        else:
            for lane_idx in range(Self.size - 1):
                self.get_lane(lane_idx).write_to(writer)
                writer.write("\n")
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    @always_inline
    def __eq__(
        lhs, rhs: Multivector[Self.sig, _, Self.dtype, Self.size]
    ) -> Bool:
        # TODO: this doesnt have to unroll every element in the algebra
        comptime for basis in range(Self.sig.dims):
            comptime lhs_entry = lhs.mask.get_entry(Basis(bin=basis))
            comptime rhs_entry = rhs.mask.get_entry(Basis(bin=basis))

            comptime if (lhs_entry != -1) and (rhs_entry != -1):
                if lhs._data[lhs_entry] != rhs._data[rhs_entry]:
                    return False
            elif lhs_entry != -1:
                if lhs._data[lhs_entry] != 0:
                    return False
            elif rhs_entry != -1:
                if rhs._data[rhs_entry] != 0:
                    return False

        return True

    @always_inline
    def __ne__(
        lhs, rhs: Multivector[Self.sig, _, Self.dtype, Self.size]
    ) -> Bool:
        # TODO: this doesnt have to unroll every element in the algebra
        comptime for basis in range(Self.sig.dims):
            comptime lhs_entry = lhs.mask.get_entry(Basis(bin=basis))
            comptime rhs_entry = rhs.mask.get_entry(Basis(bin=basis))

            comptime if (lhs_entry != -1) and (rhs_entry != -1):
                if lhs._data[lhs_entry] != rhs._data[rhs_entry]:
                    return True
            elif lhs_entry != -1:
                if lhs._data[lhs_entry] != 0:
                    return True
            elif rhs_entry != -1:
                if rhs._data[rhs_entry] != 0:
                    return True

        return False

    # +------( Unary )------+ #
    #
    @always_inline
    def __neg__(self) -> Self:
        var result = Multivector[
            Self.sig, Self.mask, Self.dtype, Self.size
        ].__init__[False]()

        comptime for entry in range(len(result.mask)):
            result._data[entry] = -self._data[entry]

        return result

    @always_inline
    def __invert__(self) -> Self:
        return self.__rev__()

    @always_inline
    def __rev__(self) -> Self:
        """Reverse operator, reverses the subscript of each basis element."""
        var result = Multivector[
            Self.sig, Self.mask, Self.dtype, Self.size
        ].__init__[False]()

        comptime for entry in range(len(result.mask)):
            comptime sign = 1 - (Self.sig.grade(self.mask.get_basis(entry)) & 2)
            result._data[entry] = self._data[entry] * Self.Coef(sign)

        return result

    @always_inline
    def __invo__(self) -> Self:
        """Involute operator."""
        var result = Multivector[
            Self.sig, Self.mask, Self.dtype, Self.size
        ].__init__[False]()

        comptime for entry in range(len(result.mask)):
            comptime sign = (
                (Self.sig.grade(self.mask.get_basis(entry)) & 1) << 1
            ) - 1
            result._data[entry] = self._data[entry] * Self.Coef(sign)

        return result

    @always_inline
    def __conj__(self) -> Self:
        """Conjugate operator."""
        var result = Multivector[
            Self.sig, Self.mask, Self.dtype, Self.size
        ].__init__[False]()

        comptime for entry in range(len(result.mask)):
            comptime sign = 1 - (
                (Self.sig.grade(self.mask.get_basis(entry)) + 1) & 2
            )
            result._data[entry] = self._data[entry] * Self.Coef(sign)

        return result

    @always_inline
    def __dual__(self) -> Self:
        """Dual operator, currently just reverses coefficients."""
        var result = Multivector[
            Self.sig, Self.mask, Self.dtype, Self.size
        ].__init__[False]()

        comptime for entry in range(len(result.mask)):
            result._data[entry] = self._data[
                (len(materialize[result.mask]()) - 1) - entry
            ]

        return result

    @always_inline
    def norm(self) -> Self.Coef:
        return sqrt(abs((self * self.__conj__()).s))

    @always_inline
    def normalized(
        self,
    ) -> Multivector[
        Self.sig,
        Self.sig.mul(Self.mask, Self.sig.scalar_mask()),
        Self.dtype,
        Self.size,
    ]:
        return self * (1 / self.norm())

    # +------( Arithmetic )------+ #
    #
    @always_inline
    def __add__(
        lhs, rhs: Self.Mask, out result: Self.Mask[lhs.mask | rhs.mask]
    ):
        result = result.__init__[False]()

        comptime for entry in range(len(result.mask)):
            comptime result_basis = result.mask.get_basis(entry)
            comptime self_entry = lhs.mask.get_entry(result_basis)
            comptime other_entry = rhs.mask.get_entry(result_basis)

            comptime if (self_entry != -1) and (other_entry != -1):
                result._data[entry] = (
                    lhs._data[self_entry] + rhs._data[other_entry]
                )
            elif self_entry != -1:
                result._data[entry] = lhs._data[self_entry]
            elif other_entry != -1:
                result._data[entry] = rhs._data[other_entry]

    @always_inline
    def __radd__(rhs, lhs: Self.Mask) -> Self.Mask[lhs.mask | rhs.mask]:
        return lhs + rhs

    @always_inline
    def __sub__(
        lhs, rhs: Self.Mask, out result: Self.Mask[lhs.mask | rhs.mask]
    ):
        result = result.__init__[False]()

        comptime for entry in range(len(result.mask)):
            comptime result_basis = result.mask.get_basis(entry)
            comptime lhs_entry = lhs.mask.get_entry(result_basis)
            comptime rhs_entry = rhs.mask.get_entry(result_basis)

            comptime if (lhs_entry != -1) and (rhs_entry != -1):
                result._data[entry] = (
                    lhs._data[lhs_entry] - rhs._data[rhs_entry]
                )
            elif lhs_entry != -1:
                result._data[entry] = lhs._data[lhs_entry]
            elif rhs_entry != -1:
                result._data[entry] = -rhs._data[rhs_entry]

    @always_inline
    def __rsub__(rhs, lhs: Self.Mask) -> Self.Mask[lhs.mask | rhs.mask]:
        return lhs - rhs

    @always_inline
    def __mul__(
        lhs,
        rhs: Self.Mask,
        out result: Self.Mask[Self.sig.mul(lhs.mask, rhs.mask)],
    ):
        result = result.__init__[True]()

        comptime for lhs_entry in range(len(lhs.mask)):
            comptime lhs_basis = lhs.mask.get_basis(lhs_entry)

            comptime for rhs_entry in range(len(rhs.mask)):
                comptime rhs_basis = rhs.mask.get_basis(rhs_entry)
                comptime res_basis = Self.sig.mul(lhs_basis, rhs_basis)
                comptime entry = result.mask.get_entry(Basis(bin=res_basis.bin))

                comptime if entry >= 0:
                    result._data[entry] += (
                        Self.Coef(res_basis.sign)
                        * lhs._data[lhs_entry]
                        * rhs._data[rhs_entry]
                    )

    # @always_inline
    # def __mul__[
    #     origin: ImmOrigin, //
    # ](
    #     ref [origin]lhs,
    #     ref [origin]rhs: Self,
    #     out result: Self.Mask[Self.sig.sqr(rhs.mask)],
    # ):
    #     print("squared")
    #     result = lhs**2

    @always_inline
    def __rmul__(
        rhs, lhs: Self.Mask
    ) -> Self.Mask[Self.sig.mul(lhs.mask, rhs.mask)]:
        return lhs * rhs

    @always_inline
    def __pow__(
        lhs,
        rhs: IntLiteral[(2).value],
        out result: Self.Mask[Self.sig.sqr(lhs.mask)],
    ):
        result = result.__init__[True]()

        comptime for lhs_entry in range(len(lhs.mask)):
            comptime lhs_basis = lhs.mask.get_basis(lhs_entry)

            comptime for rhs_entry in range(lhs_entry):
                comptime rhs_basis = lhs.mask.get_basis(rhs_entry)
                comptime res_basis = Self.sig.mul(lhs_basis, rhs_basis)
                comptime rev_basis = Self.sig.mul(rhs_basis, lhs_basis)
                comptime res_entry = result.mask.get_entry(
                    Basis(bin=res_basis.bin)
                )

                comptime if res_basis.sign != -rev_basis.sign:
                    result._data[res_entry] += (
                        Self.Coef(res_basis.sign)
                        * lhs._data[lhs_entry]
                        * lhs._data[rhs_entry]
                        * 2
                    )

            comptime res_basis = Self.sig.mul(lhs_basis, lhs_basis)
            comptime res_entry = result.mask.get_entry(Basis(bin=res_basis.bin))

            comptime if res_basis.sign != 0:
                result._data[res_entry] += (
                    Self.Coef(res_basis.sign)
                    * lhs._data[lhs_entry]
                    * lhs._data[lhs_entry]
                )

    @always_inline
    def __call__(
        versor, operand: Self.Mask
    ) -> Self.Mask[
        Self.sig.mul(Self.sig.mul(versor.mask, operand.mask), versor.mask)
    ]:
        """Shorthand for the sandwich operator."""
        return versor * operand * ~versor
