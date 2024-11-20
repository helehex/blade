# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from os import abort
from collections import Optional
from ..utils import ThickVector
from .mask import *


# +----------------------------------------------------------------------------------------------+ #
# | Multivector
# +----------------------------------------------------------------------------------------------+ #
#
@value
struct Multivector[sig: Signature, mask: BasisMask, type: DType = DType.float64, size: Int = 1](
    Writable, Stringable
):
    """Multivector."""

    # +------[ Alias ]------+ #
    #
    alias DataType = ThickVector[type, Self.mask.entry_count, size]

    # +------< Data >------+ #
    #
    var _data: Self.DataType

    # +------( Initialize )------+ #
    #
    @always_inline
    fn __init__[init: Bool = True](out self):
        self._data.__init__[init]()

    @always_inline
    fn __init__(out self: Multivector[sig, sig.full_mask(), type, size]):
        self._data.__init__[True]()

    @implicit
    @always_inline
    fn __init__(out self: Multivector[sig, sig.scalar_mask(), type, size], s: SIMD[type, size]):
        self.__init__[False]()
        self._data[0] = s

        @parameter
        for entry in range(1, Self.mask.entry_count):
            self._data[entry] = 0

    @always_inline
    fn __init__(out self, owned *coefs: SIMD[type, size]):
        self = Self(coefs^)

    @always_inline
    fn __init__(out self, owned coefs: VariadicListMem[SIMD[type, size]]):
        self.__init__[False]()
        if len(coefs) != Self.mask.entry_count:
            abort("incorrect number of coefficient passed to masked multivector")
        self._data.__init__(coefs^)

    @always_inline
    fn __init__(out self, owned **coefs: SIMD[type, size]):
        self.__init__[True]()

        @parameter
        fn _set_basis[basis: Int](value: SIMD[type, size]):
            @parameter
            if basis > sig.vecs:
                abort("basis is not a member of signature")
            elif mask.basis2entry[basis] > -1:
                self._data[mask.basis2entry[basis]] = value
            else:
                abort("basis is not a member of mask")

        for entry in coefs.items():
            if entry[].key == "s":
                _set_basis[0](entry[].value)
            elif entry[].key == "e1":
                _set_basis[1](entry[].value)
            elif entry[].key == "e2":
                _set_basis[2](entry[].value)
            elif entry[].key == "e3":
                _set_basis[3](entry[].value)
            elif entry[].key == "e4":
                _set_basis[4](entry[].value)
            else:
                abort("unknown basis: " + entry[].key)

    # +------( Subscript )------+ #
    #
    @always_inline
    fn __getattr__[key: StringLiteral](ref self) -> SIMD[type, size]:
        @parameter
        fn _get_basis[basis: Int]() -> SIMD[type, size]:
            @parameter
            if basis > sig.vecs:
                abort(key + " is not a member of signature")
            elif mask.basis2entry[basis] != -1:
                return self._data[mask.basis2entry[basis]]
            return 0

        @parameter
        if key == "s":
            return _get_basis[0]()
        elif key == "e1":
            return _get_basis[1]()
        elif key == "e2":
            return _get_basis[2]()
        elif key == "e3":
            return _get_basis[3]()
        elif key == "e4":
            return _get_basis[4]()
        else:
            abort("multivector attribute " + key + " does not exist")
            return 0

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, inout writer: WriterType):
        @parameter
        if self.mask.entry_count == 0:
            writer.write("0")
            return

        alias len = self.mask.entry_count - 1
        writer.write("-" if self._data[0] < 0 else "+")

        @parameter
        for entry in range(len):
            writer.write(abs(self._data[entry]), " [", self.mask.entry2basis[entry])
            if self._data[entry + 1] < 0:
                writer.write("] - ")
            else:
                writer.write("] + ")
        writer.write(abs(self._data[len]), " [", self.mask.entry2basis[len], "]")

    # +------( Comparison )------+ #
    #
    @always_inline
    fn __eq__(self, other: Multivector[sig, _, type, size]) -> Bool:
        @parameter
        for basis in range(sig.dims):
            alias self_entry = self.mask.basis2entry[basis]
            alias other_entry = other.mask.basis2entry[basis]

            @parameter
            if (self_entry != -1) and (other_entry != -1):
                if self._data[self_entry] != other._data[other_entry]:
                    return False
            elif self_entry != -1:
                if self._data[self_entry] != 0:
                    return False
            elif other_entry != -1:
                if other._data[other_entry] != 0:
                    return False

        return True

    @always_inline
    fn __ne__(self, other: Multivector[sig, _, type, size]) -> Bool:
        @parameter
        for basis in range(sig.dims):
            alias self_entry = self.mask.basis2entry[basis]
            alias other_entry = other.mask.basis2entry[basis]

            @parameter
            if (self_entry != -1) and (other_entry != -1):
                if self._data[self_entry] != other._data[other_entry]:
                    return True
            elif self_entry != -1:
                if self._data[self_entry] != 0:
                    return True
            elif other_entry != -1:
                if other._data[other_entry] != 0:
                    return True

        return False

    # +------( Unary )------+ #
    #
    @always_inline
    fn __neg__(self) -> Self:
        var result: Multivector[sig, mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            result._data[entry] = -self._data[entry]

        return result

    @always_inline
    fn __invert__(self) -> Self:
        return self.__rev__()

    @always_inline
    fn __rev__(self) -> Self:
        """Reversion operator, reverses the subscript of each basis element."""
        var result: Multivector[sig, mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            alias sign = (1 - (((sig.grade_of[self.mask.entry2basis[entry]] // 2) % 2) * 2))
            result._data[entry] = self._data[entry] * sign

        return result

    @always_inline
    fn __invo__(self) -> Self:
        """Involution operator."""
        var result: Multivector[sig, mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            alias sign = (((sig.grade_of[self.mask.entry2basis[entry]] % 2) * 2) - 1)
            result._data[entry] = self._data[entry] * sign

        return result

    @always_inline
    fn __conj__(self) -> Self:
        """Conjugate operator."""
        var result: Multivector[sig, mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            alias sign = (((((sig.grade_of[self.mask.entry2basis[entry]] + 3) // 2) % 2) * 2) - 1)
            result._data[entry] = self._data[entry] * sign

        return result

    @always_inline
    fn __dual__(self) -> Self:
        """Dualization operator, currently just reverses coefficients."""
        var result: Multivector[sig, mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            result._data[entry] = self._data[(result.mask.entry_count - 1) - entry]

        return result

    @always_inline
    fn norm(self) -> SIMD[type, size]:
        return sqrt(abs((self * self.__conj__()).s))

    @always_inline
    fn normalized(self) -> Multivector[sig, mask.mul(sig.scalar_mask(), sig), type, size]:
        return self * (1 / self.norm())

    # +------( Arithmetic )------+ #
    #
    @always_inline
    fn __add__(
        self, other: Multivector[sig, _, type, size]
    ) -> Multivector[sig, mask | other.mask, type, size]:
        var result: Multivector[sig, mask | other.mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            alias result_basis = result.mask.entry2basis[entry]
            alias self_entry = self.mask.basis2entry[result_basis]
            alias other_entry = other.mask.basis2entry[result_basis]

            @parameter
            if (self_entry != -1) and (other_entry != -1):
                result._data[entry] = self._data[self_entry] + other._data[other_entry]
            elif self_entry != -1:
                result._data[entry] = self._data[self_entry]
            elif other_entry != -1:
                result._data[entry] = other._data[other_entry]

        return result

    @always_inline
    fn __sub__(
        self, other: Multivector[sig, _, type, size]
    ) -> Multivector[sig, mask | other.mask, type, size]:
        var result: Multivector[sig, mask | other.mask, type, size]
        result.__init__[False]()

        @parameter
        for entry in range(result.mask.entry_count):
            alias result_basis = result.mask.entry2basis[entry]
            alias self_entry = self.mask.basis2entry[result_basis]
            alias other_entry = other.mask.basis2entry[result_basis]

            @parameter
            if (self_entry != -1) and (other_entry != -1):
                result._data[entry] = self._data[self_entry] - other._data[other_entry]
            elif self_entry != -1:
                result._data[entry] = self._data[self_entry]
            elif other_entry != -1:
                result._data[entry] = -other._data[other_entry]

        return result

    @always_inline
    fn __mul__(
        lhs, rhs: Multivector[sig, _, type, size]
    ) -> Multivector[sig, mask.mul(rhs.mask, sig), type, size]:
        var result: Multivector[sig, mask.mul(rhs.mask, sig), type, size]
        result.__init__[True]()

        @parameter
        for lhs_entry in range(lhs.mask.entry_count):
            alias lhs_basis = lhs.mask.entry2basis[lhs_entry]

            @parameter
            for rhs_entry in range(rhs.mask.entry_count):
                alias rhs_basis = rhs.mask.entry2basis[rhs_entry]
                alias signed_basis = sig.mult[lhs_basis, rhs_basis]
                alias entry = result.mask.basis2entry[signed_basis.basis]

                @parameter
                if entry >= 0:
                    result._data[entry] += (
                        signed_basis.sign * lhs._data[lhs_entry] * rhs._data[rhs_entry]
                    )

        return result

    @always_inline
    fn __call__(
        versor, operand: Multivector[sig, _, type, size]
    ) -> Multivector[sig, versor.mask.mul(operand.mask, sig).mul(versor.mask, sig), type, size]:
        """Shorthand for the sandwich operator."""
        return versor * operand * ~versor
