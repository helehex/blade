# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #

from collections.string import StringSlice
from bit import pop_count
from utils._select import _select_register_value

from .basis import Basis, SignedBasis, ScaledBasis, BasisIndex, SignedBasisIndex
from ..utils import ansi
from ..utils.algorithm import counted_sort
from ..utils.control import _assert
from ..utils.format import ctoi, stoi, write_repeat
from ..utils.bit import SetBitIter, rsign
from ..math import (
    SetOrder,
    SetOrder_Slexic,
    pascal,
    # powerset,
    power_unrank,
    power_rank,
    power_unrank_bin,
    power_rank_bin,
    grade_of,
    # degrade,
)


# +----------------------------------------------------------------------------------------------+ #
# | Signature
# +----------------------------------------------------------------------------------------------+ #
#
@fieldwise_init
struct Signature[Sorting: SetOrder = SetOrder_Slexic](Writable):
    """Signature."""

    # +------< Data >------+ #
    #
    var po: Int
    var ne: Int
    var ze: Int

    # +------< Cache >------+ #
    #
    var vecs: Int
    """Number of basis vectors."""
    var dims: Int
    """Number of basis elements."""
    var grds: Int
    """Number of basis grades."""
    var vec_sqrs: List[Int]

    # +------( Initialize )------+ #
    #
    fn __init__(
        out self, po: Int, ne: Int = 0, ze: Int = 0, *, flip_ze: Bool = True
    ):
        self.po = po
        self.ne = ne
        self.ze = ze

        self.vecs = self.po + self.ne + self.ze
        self.dims = 2 ** (self.vecs)
        self.grds = self.vecs + 1

        self.vec_sqrs = List[Int](capacity=self.vecs)

        if flip_ze:
            for _ in range(ze):
                self.vec_sqrs.append(0)

        for _ in range(po):
            self.vec_sqrs.append(1)

        for _ in range(ne):
            self.vec_sqrs.append(-1)

        if not flip_ze:
            for _ in range(ze):
                self.vec_sqrs.append(0)

        # var grade_idx = 0
        # for grade in range(self.grds):
        # var grade_dims = pascal(self.vecs, grade)
        # self.grade_dims.append(grade_dims)
        # self.grade_idx.append(grade_idx)
        # grade_idx += grade_dims
        # for _ in range(grade_dims):
        #     self.grade_of.append(grade)

        # self.generate_product_table()

    # +------( Masks )------+ #
    #
    fn basis_mask(self, basis: Basis, out result: BasisMask):
        result = BasisMask(capacity=1)
        result.entries.append(basis)

    fn basis_mask(self, basis: SignedBasis, out result: BasisMask):
        result = BasisMask(capacity=1)
        result.entries.append(Basis(bin=basis.bin))

    fn basis_mask(self, string: StringSlice, out result: BasisMask):
        result = BasisMask()

        var start = 0
        var stop = 1
        while stop < len(string):
            stop = string.find("+", start=start)
            if stop == -1:
                stop = len(string)

            var slice = StringSlice(
                unsafe_from_utf8=string._slice[start:stop]
            ).strip(" ")
            var idx_of_e = slice.find("e")

            if idx_of_e == -1:
                basis = SignedBasis()
            else:
                # TODO: manualy set slice to avoid ctime raising problems
                basis = self.signed_basis(
                    StringSlice(
                        unsafe_from_utf8=slice._slice[idx_of_e : len(slice)]
                    )
                )

            if basis.sign != 0:
                result.unmask(Basis(bin=basis.bin))

            start = stop + 1

    @always_inline
    fn empty_mask(self, out mask: BasisMask):
        mask = BasisMask()

    @always_inline
    fn full_mask(self, out mask: BasisMask):
        mask = BasisMask(full=self.vecs)

    @always_inline
    fn grade_mask(self, grade: Int, out mask: BasisMask):
        elements = pascal(self.vecs, grade)
        mask = BasisMask(capacity=elements)
        var basis = ~(-1 << grade)
        for _ in range(elements):
            mask.entries.append(Basis(bin=basis))
            basis = Sorting.next_bin(self.vecs, basis)

    @always_inline
    fn even_mask(self, out mask: BasisMask):
        mask = BasisMask(capacity=self.dims // 2)
        for grade in range(0, self.grds, 2):
            var basis = ~(-1 << grade)
            for _ in range(pascal(self.vecs, grade)):
                mask.entries.append(Basis(bin=basis))
                basis = Sorting.next_bin(self.vecs, basis)

    @always_inline
    fn scalar_mask(self, out mask: BasisMask):
        mask = self.grade_mask(0)

    @always_inline
    fn vector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(1)

    @always_inline
    fn bivector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(2)

    @always_inline
    fn trivector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(3)

    @always_inline
    fn quadvector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(4)

    @always_inline
    fn antiscalar_mask(self, out mask: BasisMask):
        mask = self.grade_mask(self.grds - 1)

    @always_inline
    fn antivector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(self.grds - 2)

    @always_inline
    fn antibivector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(self.grds - 3)

    @always_inline
    fn antitrivector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(self.grds - 4)

    @always_inline
    fn antiquadvector_mask(self, out mask: BasisMask):
        mask = self.grade_mask(self.grds - 5)

    # +------( Basis )------+ #
    #
    fn basis(self, idx: BasisIndex) -> Basis:
        return Basis(bin=power_unrank_bin[Sorting](self.vecs, Int(idx)))

    fn basis(self, string: StringSlice, out result: Basis):
        result = Basis()

        if len(string) == 0 or (len(string) == 1 and string[0] == "s"):
            return

        var prev_vec = -1
        var vec_idx = 0

        @parameter
        fn account_vec(vec: Int):
            _assert(
                vec <= self.vecs,
                "basis vector 'e",
                vec,
                "' not present in algebra",
            )
            _assert(
                prev_vec < vec, "basis element '", string, "' is not sorted"
            )
            result.bin |= 1 << (vec - 1)
            prev_vec = vec
            vec_idx += 1

        if string[0] != "e":
            while vec_idx < len(string):
                account_vec(ctoi(string[vec_idx]))

        _assert(len(string) > 1, "'", string, "' is not a valid basis")

        if self.vecs < 10:
            # basis vectors can be 'e' separated
            var char_idx = 0
            while char_idx < len(string):
                if string[char_idx] != "e":
                    account_vec(ctoi(string[char_idx]))
                char_idx += 1
        else:
            # basis vectors must be 'e' separated
            start, stop = 1, 2
            while stop <= len(string):
                stop = string.find("e", start=start)
                stop = len(string) if stop == -1 else stop
                var slice_sep = StringSlice(
                    unsafe_from_utf8=string._slice[start:stop]
                )
                account_vec(stoi(slice_sep))
                start, stop = stop + 1, stop + 2

    # +------( SignedBasis )------+ #
    #
    @always_inline
    fn signed_basis(self, idx: SignedBasisIndex) -> SignedBasis:
        return SignedBasis(
            idx.sign, bin=power_unrank_bin[Sorting](self.vecs, idx.idx)
        )

    fn signed_basis(self, string: StringSlice, out result: SignedBasis):
        result = SignedBasis()

        if len(string) == 0:
            return

        _assert(
            string[0] == "e" and len(string) != 1,
            "'",
            string,
            "' is not a valid basis",
        )

        @parameter
        @always_inline
        fn _account_vec(vec: Int):
            _assert(
                vec <= self.vecs,
                "basis vector 'e",
                vec,
                "' not present in algebra",
            )
            self.squash_vec(result, vec)

        if self.vecs < 10:
            # basis vectors can be 'e' separated
            for idx in range(len(string)):
                if string[idx] != "e":
                    _account_vec(ctoi(string[idx]))
        else:
            # basis vectors must be 'e' separated
            start, stop = 1, 2
            while stop <= len(string):
                stop = string.find("e", start=start)
                stop = len(string) if stop == -1 else stop
                var slice_sep = StringSlice(
                    unsafe_from_utf8=string._slice[start:stop]
                )
                _account_vec(stoi(slice_sep))
                start, stop = stop + 1, stop + 2

    # +------( BasisIndex )------+ #
    #
    @always_inline
    fn basis_index(self, basis: Basis) -> BasisIndex:
        return power_rank_bin[Sorting](self.vecs, basis.bin)

    @always_inline
    fn basis_index(self, basis: SignedBasis) -> BasisIndex:
        return power_rank_bin[Sorting](self.vecs, basis.bin)

    @always_inline
    fn basis_index(self, string: StringSlice) -> BasisIndex:
        return power_rank_bin[Sorting](self.vecs, self.basis(string).bin)

    # +------( SignedBasisIndex )------+ #
    #
    @always_inline
    fn signed_basis_index(self, basis: SignedBasis) -> SignedBasisIndex:
        return SignedBasisIndex(basis.sign, Int(self.basis_index(basis)))

    @always_inline
    fn signed_basis_index(
        self, string: StringSlice, out result: SignedBasisIndex
    ):
        basis = self.signed_basis(string)
        return SignedBasisIndex(basis.sign, Int(self.basis_index(basis)))

    # +------( Grade Basis )------+ #
    #
    @always_inline
    fn grade(self, basis: Basis) -> Int:
        return pop_count(basis.bin)

    @always_inline
    fn grade(self, basis: SignedBasis) -> Int:
        return pop_count(basis.bin)

    @always_inline
    fn grade(self, basis: ScaledBasis) -> Int:
        return pop_count(basis.bin)

    @always_inline
    fn grade(self, idx: BasisIndex) -> Int:
        return grade_of[Sorting](self.vecs, Int(idx))

    @always_inline
    fn grade(self, idx: SignedBasisIndex) -> Int:
        return grade_of[Sorting](self.vecs, idx.idx)

    # +------( Product )------+ #
    #
    @always_inline
    fn squash_vec(self, mut basis: SignedBasis, vec: Int):
        var mask = 1 << (vec - 1)
        var crosses = pop_count(basis.bin & (-1 << vec))
        basis.sign *= _select_register_value(
            Bool(basis.bin & mask), self.vec_sqrs[vec - 1], 1
        ) * rsign(crosses & 1)
        basis.bin ^= mask

    @always_inline
    fn mul(self, lhs: Basis, rhs: Basis, out result: SignedBasis):
        result = lhs
        for vec in SetBitIter(rhs.bin):
            self.squash_vec(result, vec + 1)

    @always_inline
    fn mul(self, lhs: SignedBasis, rhs: SignedBasis, out result: SignedBasis):
        result = SignedBasis(lhs.sign * rhs.sign, bin=lhs.bin)
        for vec in SetBitIter(rhs.bin):
            self.squash_vec(result, vec + 1)

    @always_inline
    fn mul(
        self, lhs: BasisIndex, rhs: BasisIndex, out result: SignedBasisIndex
    ):
        result = self.signed_basis_index(
            self.mul(self.basis(lhs), self.basis(rhs))
        )

    @always_inline
    fn mul(self, lhs: BasisMask, rhs: BasisMask, out result: BasisMask):
        result = BasisMask()
        for lhs_basis in lhs.entries:
            for rhs_basis in rhs.entries:
                var res_basis = self.mul(lhs_basis, rhs_basis)
                if res_basis.sign != 0:
                    result.unmask(Basis(bin=res_basis.bin))

    @always_inline
    fn sqr(self, mask: BasisMask, out result: BasisMask):
        result = BasisMask()
        for lhs_basis in mask.entries:
            for rhs_basis in mask.entries:
                var res_basis = self.mul(lhs_basis, rhs_basis)
                var rev_basis = self.mul(rhs_basis, lhs_basis)
                if res_basis.sign != -rev_basis.sign:
                    result.unmask(Basis(bin=res_basis.bin))
                if rhs_basis == lhs_basis:
                    break

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn __repr__(self) -> String:
        return String.write(
            "Signature(", self.po, ", ", self.ne, ", ", self.ze, ")"
        )

    # TODO: add more formatting options, like coloring
    @no_inline
    fn write_basis_to[
        WriterType: Writer, //
    ](self, mut writer: WriterType, basis: Basis, *, expand: Bool = True):
        if not expand:
            self.write_basis_to(writer, self.basis_index(basis), expand=False)
            return

        if self.vecs < 10:
            if basis.bin != 0:
                writer.write("e")
            for vec in SetBitIter(basis.bin):
                writer.write(vec + 1)
            writer.write(ansi.clear)
        else:
            for vec in SetBitIter(basis.bin):
                writer.write("e", vec + 1)
            writer.write(ansi.clear)

    @no_inline
    fn write_basis_to[
        WriterType: Writer, //
    ](self, mut writer: WriterType, basis: SignedBasis, *, expand: Bool = True):
        if not expand:
            self.write_basis_to(
                writer, self.signed_basis_index(basis), expand=False
            )
            return

        writer.write(ansi.get_color(self.grade(basis)))
        if basis.sign > 0:
            writer.write("+")
        elif basis.sign > 0:
            writer.write("-")
        else:
            writer.write("o")
        self.write_basis_to(writer, Basis(bin=basis.bin))

    @no_inline
    fn write_basis_to[
        WriterType: Writer, //
    ](self, mut writer: WriterType, basis: ScaledBasis, *, expand: Bool = True):
        writer.write(ansi.get_color(self.grade(basis)), basis.scale)
        self.write_basis_to(writer, Basis(bin=basis.bin))

    @no_inline
    fn write_basis_to[
        WriterType: Writer, //
    ](self, mut writer: WriterType, basis: BasisIndex, *, expand: Bool = False):
        if expand:
            self.write_basis_to(writer, self.basis(basis), expand=True)
            return

        var align = len(String(self.dims)) + 1
        var str_basis = String(basis)
        writer.write(ansi.get_bg_color(self.grade(basis)))
        write_repeat(writer, align - len(str_basis))
        writer.write(str_basis, " ")

    @no_inline
    fn write_basis_to[
        WriterType: Writer, //
    ](
        self,
        mut writer: WriterType,
        basis: SignedBasisIndex,
        *,
        expand: Bool = False,
    ):
        if expand:
            self.write_basis_to(writer, self.signed_basis(basis), expand=True)
            return

        if basis.sign < 0:
            writer.write(ansi.grey)
            self.write_basis_to(writer, BasisIndex(basis.idx))
        elif basis.sign > 0:
            writer.write(ansi.white)
            self.write_basis_to(writer, BasisIndex(basis.idx))
        else:
            writer.write(ansi.clear)
            write_repeat(writer, len(String(self.dims)) + 2)

    # TODO: re-name to explicitly convey that this writes the geometric product table
    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        for x in range(self.dims):
            for y in range(self.dims):
                self.write_basis_to(writer, self.mul(x, y))
            writer.write(ansi.clear, "\n")

    # +------( Old Basis List )------+ #
    #
    @always_inline
    fn ibasis_to_ebasis(self, ibasis: Int) -> List[Int]:
        return power_unrank[Sorting](self.vecs, ibasis)

    @always_inline
    fn ebasis_to_ibasis(self, ebasis: List[Int]) -> Int:
        return power_rank[Sorting](self.vecs, ebasis)

    @always_inline
    fn squash_basis(self, mut basis: List[Int], mut sign: Int):
        var result = List[Int](capacity=len(basis))
        var i = 1
        var j = 0
        while i < len(basis):
            if basis[i] != basis[i - 1]:
                result.append(basis[i - 1])
                i += 1
                j += 1
            else:
                sign *= self.vec_sqrs[basis[i] - 1]
                i += 2

        if i == len(basis):
            result.append(basis[len(basis) - 1])

        basis = result^

    @always_inline
    fn reduce_basis(self, var basis: List[Int]) -> SignedBasisIndex:
        if len(basis) == 0:
            return SignedBasisIndex(1, 0)
        elif len(basis) == 1:
            return SignedBasisIndex(1, basis[0])
        else:
            var sign: Int = 1 - ((counted_sort(basis) % 2) * 2)
            self.squash_basis(basis, sign)
            return SignedBasisIndex(sign, self.ebasis_to_ibasis(basis))

    @always_inline
    fn squash_vec(self, mut basis: List[Int], vec: Int, mut sign: Int):
        for idx in reversed(range(len(basis))):
            if basis[idx] == vec:
                sign *= self.vec_sqrs[vec - 1]
                _ = basis.pop(idx)
                return
            elif basis[idx] < vec:
                basis.insert(idx + 1, vec)
                return
            else:
                # TODO: use modulo of idx instead
                sign = -sign
        basis.insert(0, vec)

    @always_inline
    fn reduce_basis(
        self, var basis1: List[Int], basis2: List[Int]
    ) -> SignedBasisIndex:
        var sign: Int = 1
        for vec in basis2:
            self.squash_vec(basis1, vec, sign)
        return SignedBasisIndex(sign, self.ebasis_to_ibasis(basis1))

    @no_inline
    fn __str__old(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to_old[WriterType: Writer, //](self, mut writer: WriterType):
        for x in range(self.dims):
            for y in range(self.dims):
                self.write_basis_to(
                    writer,
                    self.reduce_basis(
                        self.ibasis_to_ebasis(x), self.ibasis_to_ebasis(y)
                    ),
                )
            writer.write(ansi.clear, "\n")
