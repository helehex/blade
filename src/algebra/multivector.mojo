# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Multivector."""

from math import sqrt
from blade.utils.thick_vector import ThickVector
from .basis import Basis, SignedBasis, ScaledBasis


# +----------------------------------------------------------------------------------------------+ #
# | Multivector
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Multivector[
    sig: Signature, mask: BasisMask, dtype: DType = DType.float64, size: Int = 1
](Writable & Copyable & Movable):
    """Multivector."""

    # +------[ Alias ]------+ #
    #
    alias DataType = ThickVector[dtype, len(mask), size]
    alias Coef = SIMD[dtype, size]
    alias Lane = Multivector[sig, mask, dtype, 1]
    # TODO: rename to something less misleading
    alias Mask = Multivector[sig, _, dtype, size]

    # +------< Data >------+ #
    #
    var _data: Self.DataType
    """The internal data of this multivector."""

    # +------( Initialize )------+ #
    #
    @always_inline("builtin")
    fn __init__(out self, _data: Self.DataType):
        self._data = _data

    @always_inline
    fn __init__[
        init: Bool = True, *, _mask: BasisMask = sig.empty_mask()
    ](out self: Self.Mask[_mask]):
        self._data = self._data.__init__[init]()

    # TODO: Uses precedence hacking to get default signature for implicit conversion from simd
    @implicit
    @always_inline
    fn __init__[
        __: None = None
    ](out self: Self.Mask[sig.scalar_mask()], scalar: Self.Coef):
        self = self.__init__[False]()
        self._data[0] = scalar

    @implicit
    @always_inline
    fn __init__[
        basis: SignedBasis, //, __: None = None
    ](
        out self: Self.Mask[sig.basis_mask(basis)],
        scalar: BasisLiteral[sig, basis],
    ):
        self = self.__init__[False]()
        self._data[0] = basis.sign

    @implicit
    @always_inline
    fn __init__[
        __: None = None
    ](out self: Self.Mask[sig.scalar_mask()], scalar: Int):
        self = Self.Coef(scalar)

    @always_inline
    fn __init__(out self, coef: Self.Coef):
        self = self.__init__[False]()

        @parameter
        if len(mask) != 1:
            abort(
                "incorrect number of coefficient passed to masked multivector"
            )
        self._data = self._data.__init__()
        self._data[0] = coef

    @always_inline
    fn __init__(out self, coef: Int):
        self = Self(Self.Coef(coef))

    @always_inline
    fn __init__(out self, var *coefs: Self.Coef):
        self = Self(coefs^)

    @always_inline
    fn __init__(out self, var coefs: VariadicListMem[Self.Coef]):
        self = self.__init__[False]()
        if len(coefs) != len(mask):
            abort(
                "incorrect number of coefficient passed to masked multivector"
            )
        self._data = self._data.__init__(coefs^)

    @always_inline
    fn __init__(out self, var **coefs: Self.Coef):
        self = self.__init__[True]()
        for item in coefs.items():
            var entry = mask.get_entry(materialize[sig]().basis(item.key))
            if entry == -1:
                abort("basis is not a member of mask")
            self._data[entry] = item.value

    # +------( Subscript )------+ #
    #
    @always_inline
    fn __getattr__[key: String](ref self) -> Self.Coef:
        alias entry = mask.get_entry(sig.basis(key))

        @parameter
        if entry == -1:
            return 0
        return self._data[entry]

    @always_inline
    fn get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self._data.get_lane(idx))

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        @parameter
        if size == 1:

            @parameter
            if len(mask) == 0:
                writer.write("0")
                return

            alias length = len(mask) - 1
            if self._data[0] < 0:
                writer.write("-")

            @parameter
            for entry in range(length):
                # TODO: reduce verbosity with ScaledBasisIndex
                var element = ScaledBasis(
                    abs(self._data[entry]), self.mask.get_basis(entry)
                )
                materialize[sig]().write_basis_to(writer, element)
                writer.write(" - " if self._data[entry + 1] < 0 else " + ")
            var element = ScaledBasis(
                abs(self._data[length]), self.mask.get_basis(length)
            )
            materialize[sig]().write_basis_to(writer, element)
        else:
            for lane_idx in range(size - 1):
                self.get_lane(lane_idx).write_to(writer)
                writer.write("\n")
            self.get_lane(size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    @always_inline
    fn __eq__(lhs, rhs: Multivector[sig, _, dtype, size]) -> Bool:
        # TODO: this doesnt have to unroll every element in the algebra
        @parameter
        for basis in range(sig.dims):
            alias lhs_entry = lhs.mask.get_entry(Basis(bin=basis))
            alias rhs_entry = rhs.mask.get_entry(Basis(bin=basis))

            @parameter
            if (lhs_entry != -1) and (rhs_entry != -1):
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
    fn __ne__(lhs, rhs: Multivector[sig, _, dtype, size]) -> Bool:
        # TODO: this doesnt have to unroll every element in the algebra
        @parameter
        for basis in range(sig.dims):
            alias lhs_entry = lhs.mask.get_entry(Basis(bin=basis))
            alias rhs_entry = rhs.mask.get_entry(Basis(bin=basis))

            @parameter
            if (lhs_entry != -1) and (rhs_entry != -1):
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
    fn __neg__(self) -> Self:
        var result = Multivector[sig, mask, dtype, size].__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            result._data[entry] = -self._data[entry]

        return result

    @always_inline
    fn __invert__(self) -> Self:
        return self.__rev__()

    @always_inline
    fn __rev__(self) -> Self:
        """Reverse operator, reverses the subscript of each basis element."""
        var result = Multivector[sig, mask, dtype, size].__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            alias sign = 1 - (sig.grade(self.mask.get_basis(entry)) & 2)
            result._data[entry] = self._data[entry] * sign

        return result

    @always_inline
    fn __invo__(self) -> Self:
        """Involute operator."""
        var result = Multivector[sig, mask, dtype, size].__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            alias sign = ((sig.grade(self.mask.get_basis(entry)) & 1) << 1) - 1
            result._data[entry] = self._data[entry] * sign

        return result

    @always_inline
    fn __conj__(self) -> Self:
        """Conjugate operator."""
        var result = Multivector[sig, mask, dtype, size].__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            alias sign = 1 - ((sig.grade(self.mask.get_basis(entry)) + 1) & 2)
            result._data[entry] = self._data[entry] * sign

        return result

    @always_inline
    fn __dual__(self) -> Self:
        """Dual operator, currently just reverses coefficients."""
        var result = Multivector[sig, mask, dtype, size].__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            result._data[entry] = self._data[(len(result.mask) - 1) - entry]

        return result

    @always_inline
    fn norm(self) -> Self.Coef:
        return sqrt(abs((self * self.__conj__()).s))

    @always_inline
    fn normalized(
        self,
    ) -> Multivector[sig, sig.mul(mask, sig.scalar_mask()), dtype, size]:
        return self * (1 / self.norm())

    # +------( Arithmetic )------+ #
    #
    @always_inline
    fn __add__(lhs, rhs: Self.Mask, out result: Self.Mask[lhs.mask | rhs.mask]):
        result = result.__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            alias result_basis = result.mask.get_basis(entry)
            alias self_entry = lhs.mask.get_entry(result_basis)
            alias other_entry = rhs.mask.get_entry(result_basis)

            @parameter
            if (self_entry != -1) and (other_entry != -1):
                result._data[entry] = (
                    lhs._data[self_entry] + rhs._data[other_entry]
                )
            elif self_entry != -1:
                result._data[entry] = lhs._data[self_entry]
            elif other_entry != -1:
                result._data[entry] = rhs._data[other_entry]

    @always_inline
    fn __radd__(rhs, lhs: Self.Mask) -> Self.Mask[lhs.mask | rhs.mask]:
        return lhs + rhs

    @always_inline
    fn __sub__(lhs, rhs: Self.Mask, out result: Self.Mask[lhs.mask | rhs.mask]):
        result = result.__init__[False]()

        @parameter
        for entry in range(len(result.mask)):
            alias result_basis = result.mask.get_basis(entry)
            alias lhs_entry = lhs.mask.get_entry(result_basis)
            alias rhs_entry = rhs.mask.get_entry(result_basis)

            @parameter
            if (lhs_entry != -1) and (rhs_entry != -1):
                result._data[entry] = (
                    lhs._data[lhs_entry] - rhs._data[rhs_entry]
                )
            elif lhs_entry != -1:
                result._data[entry] = lhs._data[lhs_entry]
            elif rhs_entry != -1:
                result._data[entry] = -rhs._data[rhs_entry]

    @always_inline
    fn __rsub__(rhs, lhs: Self.Mask) -> Self.Mask[lhs.mask | rhs.mask]:
        return lhs - rhs

    @always_inline
    fn __mul__[
        lhs_origin: ImmutOrigin, rhs_origin: ImmutOrigin, //
    ](
        ref [lhs_origin]lhs,
        ref [rhs_origin]rhs: Self.Mask,
        out result: Self.Mask[sig.mul(lhs.mask, rhs.mask)],
    ):
        result = result.__init__[True]()

        @parameter
        for lhs_entry in range(len(lhs.mask)):
            alias lhs_basis = lhs.mask.get_basis(lhs_entry)

            @parameter
            for rhs_entry in range(len(rhs.mask)):
                alias rhs_basis = rhs.mask.get_basis(rhs_entry)
                alias res_basis = sig.mul(lhs_basis, rhs_basis)
                alias entry = result.mask.get_entry(Basis(bin=res_basis.bin))

                @parameter
                if entry >= 0:
                    result._data[entry] += (
                        res_basis.sign
                        * lhs._data[lhs_entry]
                        * rhs._data[rhs_entry]
                    )

    @always_inline
    fn __mul__[
        origin: ImmutOrigin, //
    ](
        ref [origin]lhs,
        ref [origin]rhs: Self,
        out result: Self.Mask[sig.sqr(rhs.mask)],
    ):
        result = lhs**2

    @always_inline
    fn __rmul__(rhs, lhs: Self.Mask) -> Self.Mask[sig.mul(lhs.mask, rhs.mask)]:
        return lhs * rhs

    @always_inline
    fn __pow__(
        lhs,
        rhs: IntLiteral[(2).value],
        out result: Self.Mask[sig.sqr(lhs.mask)],
    ):
        result = result.__init__[True]()

        @parameter
        for lhs_entry in range(len(lhs.mask)):
            alias lhs_basis = lhs.mask.get_basis(lhs_entry)

            @parameter
            for rhs_entry in range(lhs_entry):
                alias rhs_basis = lhs.mask.get_basis(rhs_entry)
                alias res_basis = sig.mul(lhs_basis, rhs_basis)
                alias rev_basis = sig.mul(rhs_basis, lhs_basis)
                alias res_entry = result.mask.get_entry(
                    Basis(bin=res_basis.bin)
                )

                @parameter
                if res_basis.sign != -rev_basis.sign:
                    result._data[res_entry] += (
                        res_basis.sign
                        * lhs._data[lhs_entry]
                        * lhs._data[rhs_entry]
                        * 2
                    )

            alias res_basis = sig.mul(lhs_basis, lhs_basis)
            alias res_entry = result.mask.get_entry(Basis(bin=res_basis.bin))

            @parameter
            if res_basis.sign != 0:
                result._data[res_entry] += (
                    res_basis.sign * lhs._data[lhs_entry] * lhs._data[lhs_entry]
                )

    @always_inline
    fn __call__(
        versor, operand: Self.Mask
    ) -> Self.Mask[sig.mul(sig.mul(versor.mask, operand.mask), versor.mask)]:
        """Shorthand for the sandwich operator."""
        return versor * operand * ~versor
