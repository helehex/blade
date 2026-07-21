# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #

from std.bit import pop_count

from src.utils.format import ctoi, stoi, write_sign
from src.bit import PopIter, reverse_bits

from .multivector import Multivector
from .signature import Signature

# +--------------------------------------------------------------------------+ #
# | Basis Literal
# +--------------------------------------------------------------------------+ #
#
struct BasisLiteral[sig: Signature, basis: SignedBasis](
    TrivialRegisterPassable, Defaultable, Equatable, Movable, Writable
):
    @always_inline("builtin")
    def __init__(out self):
        pass

    @always_inline
    def __add__(
        lhs,
        rhs: BasisLiteral[Self.sig, _],
        out result: Multivector[
            Self.sig,
            Self.sig.basis_mask(lhs.basis) | Self.sig.basis_mask(rhs.basis),
        ],
    ):
        result = result.__init__[False]()
        var lhs_entry = materialize[result.mask]().get_entry(Basis(bin=lhs.basis.bin))
        result._data[lhs_entry] = type_of(result).Coef(lhs.basis.sign)
        result._data[1 - lhs_entry] = type_of(result).Coef(rhs.basis.sign)

    @always_inline
    def __sub__(
        lhs,
        rhs: BasisLiteral[Self.sig, _],
        out result: Multivector[
            Self.sig,
            Self.sig.basis_mask(lhs.basis) | Self.sig.basis_mask(-rhs.basis),
        ],
    ):
        result = lhs + -rhs

    @always_inline("builtin")
    def __mul__(
        lhs,
        rhs: BasisLiteral[Self.sig, _],
        out result: BasisLiteral[Self.sig, Self.sig.mul(lhs.basis, rhs.basis)],
    ):
        result = result.__init__()

    @always_inline
    def __mul__(
        lhs,
        rhs: SIMD,
        out result: Multivector[
            Self.sig, Self.sig.basis_mask(Self.basis), rhs.dtype, rhs.size
        ],
    ):
        result = result.__init__[False]()
        result._data[0] = rhs

    @always_inline
    def __rmul__(
        rhs,
        lhs: SIMD,
        out result: Multivector[
            Self.sig, Self.sig.basis_mask(Self.basis), lhs.dtype, lhs.size
        ],
    ):
        result = rhs * lhs

    @always_inline("builtin")
    def __neg__(self, out result: BasisLiteral[Self.sig, -Self.basis]):
        result = result.__init__()

    @always_inline("builtin")
    def __eq__(lhs, rhs: Self) -> Bool:
        return True

    @always_inline("builtin")
    def __eq__(lhs, rhs: BasisLiteral[Self.sig, _]) -> Bool:
        return lhs.basis == rhs.basis

    @always_inline("builtin")
    def __ne__(lhs, rhs: Self) -> Bool:
        return False

    @always_inline("builtin")
    def __ne__(lhs, rhs: BasisLiteral[Self.sig, _]) -> Bool:
        return lhs.basis != rhs.basis

    @no_inline
    def write_to[WriterType: Writer](self, mut writer: WriterType):
        writer.write(self.basis)


# +--------------------------------------------------------------------------+ #
# | Basis
# +--------------------------------------------------------------------------+ #
#
struct Basis(
    TrivialRegisterPassable,
    Defaultable,
    Equatable,
    Movable,
    Writable,
):
    var bin: Int

    @always_inline("builtin")
    def __init__(out self):
        self.bin = 0

    @always_inline("builtin")
    def __init__(out self, *, bin: Int):
        self.bin = bin

    @always_inline("builtin")
    def __neg__(self) -> SignedBasis:
        return SignedBasis(-1, bin=self.bin)

    @always_inline("builtin")
    def __eq__(lhs, rhs: Self) -> Bool:
        return lhs.bin == rhs.bin

    @always_inline("builtin")
    def __ne__(lhs, rhs: Self) -> Bool:
        return lhs.bin != rhs.bin

    def __lt__(lhs, rhs: Self) -> Bool:
        var lhs_vecs = pop_count(lhs.bin)
        var rhs_vecs = pop_count(rhs.bin)
        return (lhs_vecs < rhs_vecs) | (
            (lhs_vecs == rhs_vecs)
            & (UInt(reverse_bits(lhs.bin)) > UInt(reverse_bits(rhs.bin)))
        )

    def __gt__(lhs, rhs: Self) -> Bool:
        var lhs_vecs = pop_count(lhs.bin)
        var rhs_vecs = pop_count(rhs.bin)
        return (lhs_vecs > rhs_vecs) | (
            (lhs_vecs == rhs_vecs)
            & (UInt(reverse_bits(lhs.bin)) < UInt(reverse_bits(rhs.bin)))
        )

    @no_inline
    def write_to[WriterType: Writer](self, mut writer: WriterType):
        if self.bin == 0:
            writer.write("1")
        else:
            for vec in PopIter(self.bin):
                writer.write("e", vec + 1)


# +--------------------------------------------------------------------------+ #
# | Signed Basis
# +--------------------------------------------------------------------------+ #
#
struct SignedBasis(
    TrivialRegisterPassable, Defaultable, Equatable, Movable, Writable
):
    var sign: Int
    var bin: Int

    @always_inline("builtin")
    def __init__(out self):
        self.sign = 1
        self.bin = 0

    @implicit
    @always_inline("builtin")
    def __init__(out self, basis: Basis):
        self.sign = 1
        self.bin = basis.bin

    @always_inline("builtin")
    def __init__(out self, sign: Int, *, bin: Int):
        self.sign = sign
        self.bin = bin

    @always_inline("builtin")
    def __init__(out self, sign: Int, basis: Basis):
        self.sign = sign
        self.bin = basis.bin

    @always_inline("builtin")
    def __neg__(self) -> Self:
        return Self(-self.sign, bin=self.bin)

    @always_inline("builtin")
    def __eq__(lhs, rhs: Self) -> Bool:
        return lhs.bin == rhs.bin

    @always_inline("builtin")
    def __ne__(lhs, rhs: Self) -> Bool:
        return lhs.bin != rhs.bin

    @no_inline
    def write_to[WriterType: Writer](self, mut writer: WriterType):
        write_sign(writer, self.sign)
        writer.write(Basis(bin=self.bin))


# +--------------------------------------------------------------------------+ #
# | Scaled Basis
# +--------------------------------------------------------------------------+ #
#
struct ScaledBasis[dtype: DType, width: Int](TrivialRegisterPassable, Defaultable, Equatable, Writable):
    var scale: SIMD[Self.dtype, Self.width]
    var bin: Int

    # TODO: should be inline builtin
    @always_inline("nodebug")
    def __init__(out self):
        self.scale = 1
        self.bin = 0

    @implicit
    # TODO: should be inline builtin
    @always_inline("nodebug")
    def __init__(out self, basis: Basis):
        self.scale = 1
        self.bin = basis.bin

    @implicit
    @always_inline
    def __init__(out self, basis: SignedBasis):
        self.scale = type_of(self.scale)(basis.sign)
        self.bin = basis.bin

    @always_inline("builtin")
    def __init__(out self, scale: SIMD[Self.dtype, Self.width], *, bin: Int):
        self.scale = scale
        self.bin = bin

    @always_inline("builtin")
    def __init__(out self, scale: SIMD[Self.dtype, Self.width], basis: Basis):
        self.scale = scale
        self.bin = basis.bin

    @always_inline
    def __neg__(self) -> Self:
        return Self(-self.scale, bin=self.bin)

    @always_inline
    def __eq__(lhs, rhs: Self) -> Bool:
        return lhs.scale.eq(rhs.scale).reduce_and() and lhs.bin == rhs.bin

    @always_inline
    def __ne__(lhs, rhs: Self) -> Bool:
        return lhs.scale.ne(rhs.scale).reduce_or() or lhs.bin != rhs.bin

    @no_inline
    def __str__(self) -> String:
        return String.write(self)

    @no_inline
    def write_to[WriterType: Writer](self, mut writer: WriterType):
        comptime if Self.width == 1:
            writer.write(self.scale, self.bin)
        else:
            writer.write("[")

            comptime for lane in range(Self.width - 1):
                writer.write(
                    ScaledBasis[Self.dtype, 1](self.scale[lane], bin=self.bin),
                    ", ",
                )
            writer.write(
                ScaledBasis[Self.dtype, 1](
                    self.scale[Self.width - 1], bin=self.bin
                ),
                "]",
            )


# +--------------------------------------------------------------------------+ #
# | Basis Index
# +--------------------------------------------------------------------------+ #
#
struct BasisIndex(TrivialRegisterPassable, Equatable, Intable, Writable):
    var idx: Int

    @implicit
    @always_inline("builtin")
    def __init__(out self, idx: Int):
        self.idx = idx

    @always_inline("builtin")
    def __int__(self) -> Int:
        return self.idx

    @always_inline("builtin")
    def __neg__(self) -> SignedBasisIndex:
        return SignedBasisIndex(-1, self.idx)

    @always_inline("builtin")
    def __eq__(lhs, rhs: Self) -> Bool:
        return lhs.idx == rhs.idx

    @always_inline("builtin")
    def __ne__(lhs, rhs: Self) -> Bool:
        return lhs.idx != rhs.idx

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        writer.write(self.idx)


# +--------------------------------------------------------------------------+ #
# | Signed Basis Index
# +--------------------------------------------------------------------------+ #
#
struct SignedBasisIndex(TrivialRegisterPassable, Equatable, Movable, Writable):
    var sign: Int
    var idx: Int

    @implicit
    @always_inline("builtin")
    def __init__(out self, idx: Int):
        self.sign = 1
        self.idx = idx

    @implicit
    @always_inline("builtin")
    def __init__(out self, idx: BasisIndex):
        self.sign = 1
        self.idx = idx.idx

    @always_inline("builtin")
    def __init__(out self, sign: Int, idx: Int):
        self.sign = sign
        self.idx = idx

    @always_inline("builtin")
    def __neg__(self) -> Self:
        return Self(-self.sign, self.idx)

    @always_inline("builtin")
    def __eq__(lhs, rhs: Self) -> Bool:
        return lhs.sign == rhs.sign and lhs.idx == rhs.idx

    @always_inline("builtin")
    def __ne__(lhs, rhs: Self) -> Bool:
        return lhs.sign != rhs.sign or lhs.idx != rhs.idx

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        write_sign(writer, self.sign)
        writer.write(self.idx)
