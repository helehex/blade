# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #

from bit import pop_count
from blade.utils.format import ctoi, stoi, write_sign
from blade.bit import PopIter, reverse_bits


# +----------------------------------------------------------------------------------------------+ #
# | Basis Literal
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct BasisLiteral[sig: Signature, basis: SignedBasis](
    Copyable, Defaultable, EqualityComparable, Movable, Writable
):
    @always_inline("builtin")
    fn __init__(out self):
        pass

    @always_inline
    fn __add__(
        lhs,
        rhs: BasisLiteral[sig, _],
        out result: Multivector[
            sig, sig.basis_mask(lhs.basis) | sig.basis_mask(rhs.basis)
        ],
    ):
        result = result.__init__[False]()
        var lhs_entry = result.mask.get_entry(Basis(bin=lhs.basis.bin))
        result._data[lhs_entry] = lhs.basis.sign
        result._data[1 - lhs_entry] = rhs.basis.sign

    @always_inline
    fn __sub__(
        lhs,
        rhs: BasisLiteral[sig, _],
        out result: Multivector[
            sig, sig.basis_mask(lhs.basis) | sig.basis_mask(-rhs.basis)
        ],
    ):
        result = lhs + -rhs

    @always_inline("builtin")
    fn __mul__(
        lhs,
        rhs: BasisLiteral[sig, _],
        out result: BasisLiteral[sig, sig.mul(lhs.basis, rhs.basis)],
    ):
        result = result.__init__()

    @always_inline
    fn __mul__(
        lhs,
        rhs: SIMD,
        out result: Multivector[
            sig, sig.basis_mask(basis), rhs.dtype, rhs.size
        ],
    ):
        result = result.__init__[False]()
        result._data[0] = rhs

    @always_inline
    fn __rmul__(
        rhs,
        lhs: SIMD,
        out result: Multivector[
            sig, sig.basis_mask(basis), lhs.dtype, lhs.size
        ],
    ):
        result = rhs * lhs

    @always_inline("builtin")
    fn __neg__(self, out result: BasisLiteral[sig, -basis]):
        result = result.__init__()

    @always_inline("builtin")
    fn __eq__(lhs, rhs: Self) -> Bool:
        return True

    @always_inline("builtin")
    fn __eq__(lhs, rhs: BasisLiteral[sig, _]) -> Bool:
        return lhs.basis == rhs.basis

    @always_inline("builtin")
    fn __ne__(lhs, rhs: Self) -> Bool:
        return False

    @always_inline("builtin")
    fn __ne__(lhs, rhs: BasisLiteral[sig, _]) -> Bool:
        return lhs.basis != rhs.basis

    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer](self, mut writer: WriterType):
        writer.write(self.basis)


# +----------------------------------------------------------------------------------------------+ #
# | Basis
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Basis(
    Copyable,
    Defaultable,
    EqualityComparable,
    Movable,
    Representable,
    Stringable,
    Writable,
):
    var bin: Int

    @always_inline("builtin")
    fn __init__(out self):
        self.bin = 0

    @always_inline("builtin")
    fn __init__(out self, *, bin: Int):
        self.bin = bin

    @always_inline("builtin")
    fn __neg__(self) -> SignedBasis:
        return SignedBasis(-1, bin=self.bin)

    @always_inline("builtin")
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.bin == rhs.bin

    @always_inline("builtin")
    fn __ne__(lhs, rhs: Self) -> Bool:
        return lhs.bin != rhs.bin

    fn __lt__(lhs, rhs: Self) -> Bool:
        var lhs_vecs = pop_count(lhs.bin)
        var rhs_vecs = pop_count(rhs.bin)
        return (lhs_vecs < rhs_vecs) | (
            (lhs_vecs == rhs_vecs)
            & (UInt(reverse_bits(lhs.bin)) > UInt(reverse_bits(rhs.bin)))
        )

    fn __gt__(lhs, rhs: Self) -> Bool:
        var lhs_vecs = pop_count(lhs.bin)
        var rhs_vecs = pop_count(rhs.bin)
        return (lhs_vecs > rhs_vecs) | (
            (lhs_vecs == rhs_vecs)
            & (UInt(reverse_bits(lhs.bin)) < UInt(reverse_bits(rhs.bin)))
        )

    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn __repr__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer](self, mut writer: WriterType):
        if self.bin == 0:
            writer.write("1")
        else:
            for vec in PopIter(self.bin):
                writer.write("e", vec + 1)


# +----------------------------------------------------------------------------------------------+ #
# | Signed Basis
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct SignedBasis(
    Copyable, Defaultable, EqualityComparable, Movable, Stringable, Writable
):
    var sign: Int
    var bin: Int

    @always_inline("builtin")
    fn __init__(out self):
        self.sign = 1
        self.bin = 0

    @implicit
    @always_inline("builtin")
    fn __init__(out self, basis: Basis):
        self.sign = 1
        self.bin = basis.bin

    @always_inline("builtin")
    fn __init__(out self, sign: Int, *, bin: Int):
        self.sign = sign
        self.bin = bin

    @always_inline("builtin")
    fn __init__(out self, sign: Int, basis: Basis):
        self.sign = sign
        self.bin = basis.bin

    @always_inline("builtin")
    fn __neg__(self) -> Self:
        return Self(-self.sign, bin=self.bin)

    @always_inline("builtin")
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.bin == rhs.bin

    @always_inline("builtin")
    fn __ne__(lhs, rhs: Self) -> Bool:
        return lhs.bin != rhs.bin

    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer](self, mut writer: WriterType):
        write_sign(writer, self.sign)
        writer.write(Basis(bin=self.bin))


# +----------------------------------------------------------------------------------------------+ #
# | Scaled Basis
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct ScaledBasis[dtype: DType, width: Int](
    Defaultable, EqualityComparable, Writable
):
    var scale: SIMD[dtype, width]
    var bin: Int

    # TODO: should be inline builtin
    @always_inline("nodebug")
    fn __init__(out self):
        self.scale = 1
        self.bin = 0

    @implicit
    # TODO: should be inline builtin
    @always_inline("nodebug")
    fn __init__(out self, basis: Basis):
        self.scale = 1
        self.bin = basis.bin

    @implicit
    @always_inline
    fn __init__(out self, basis: SignedBasis):
        self.scale = basis.sign
        self.bin = basis.bin

    @always_inline("builtin")
    fn __init__(out self, scale: SIMD[dtype, width], *, bin: Int):
        self.scale = scale
        self.bin = bin

    @always_inline("builtin")
    fn __init__(out self, scale: SIMD[dtype, width], basis: Basis):
        self.scale = scale
        self.bin = basis.bin

    @always_inline
    fn __neg__(self) -> Self:
        return Self(-self.scale, bin=self.bin)

    @always_inline
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.scale.eq(rhs.scale).reduce_and() and lhs.bin == rhs.bin

    @always_inline
    fn __ne__(lhs, rhs: Self) -> Bool:
        return lhs.scale.ne(rhs.scale).reduce_or() or lhs.bin != rhs.bin

    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer](self, mut writer: WriterType):
        @parameter
        if width == 1:
            writer.write(self.scale, self.bin)
        else:
            writer.write("[")

            @parameter
            for lane in range(width - 1):
                writer.write(
                    ScaledBasis[dtype, 1](self.scale[lane], bin=self.bin), ", "
                )
            writer.write(
                ScaledBasis[dtype, 1](self.scale[width - 1], bin=self.bin), "]"
            )


# +----------------------------------------------------------------------------------------------+ #
# | Basis Index
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct BasisIndex(Copyable, EqualityComparable, Intable, Stringable, Writable):
    var idx: Int

    @implicit
    @always_inline("builtin")
    fn __init__(out self, idx: Int):
        self.idx = idx

    @always_inline("builtin")
    fn __int__(self) -> Int:
        return self.idx

    @always_inline("builtin")
    fn __neg__(self) -> SignedBasisIndex:
        return SignedBasisIndex(-1, self.idx)

    @always_inline("builtin")
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.idx == rhs.idx

    @always_inline("builtin")
    fn __ne__(lhs, rhs: Self) -> Bool:
        return lhs.idx != rhs.idx

    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        writer.write(self.idx)


# +----------------------------------------------------------------------------------------------+ #
# | Signed Basis Index
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct SignedBasisIndex(
    Copyable, EqualityComparable, Movable, Stringable, Writable
):
    var sign: Int
    var idx: Int

    @implicit
    @always_inline("builtin")
    fn __init__(out self, idx: Int):
        self.sign = 1
        self.idx = idx

    @implicit
    @always_inline("builtin")
    fn __init__(out self, idx: BasisIndex):
        self.sign = 1
        self.idx = idx.idx

    @always_inline("builtin")
    fn __init__(out self, sign: Int, idx: Int):
        self.sign = sign
        self.idx = idx

    @always_inline("builtin")
    fn __neg__(self) -> Self:
        return Self(-self.sign, self.idx)

    @always_inline("builtin")
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.sign == rhs.sign and lhs.idx == rhs.idx

    @always_inline("builtin")
    fn __ne__(lhs, rhs: Self) -> Bool:
        return lhs.sign != rhs.sign or lhs.idx != rhs.idx

    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        write_sign(writer, self.sign)
        writer.write(self.idx)
