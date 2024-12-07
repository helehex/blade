# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from ..utils import Table


# +----------------------------------------------------------------------------------------------+ #
# | Signature
# +----------------------------------------------------------------------------------------------+ #
#
struct Signature:
    """Signature."""

    # +------< Data >------+ #
    #
    var po: Int
    var ne: Int
    var ze: Int

    # +------< Cache >------+ #
    #
    var vecs: Int
    var dims: Int
    var grds: Int
    var vec_sqrs: List[Int]
    var grade_dims: List[Int]
    var grade_of: List[Int]
    var index_in_grade: List[Int]
    var combs: List[List[Int]]
    var mult: Table[SignedBasis]

    # +------( Initialize )------+ #
    #
    fn __init__(out self, po: Int, ne: Int = 0, ze: Int = 0, *, flip_ze: Bool = True):
        self.po = po
        self.ne = ne
        self.ze = ze

        self.vecs = self.po + self.ne + self.ze
        self.dims = 2 ** (self.vecs)
        self.grds = self.vecs + 1

        self.vec_sqrs = List[Int](capacity=self.vecs)
        self.grade_dims = List[Int](capacity=self.grds)
        self.grade_of = List[Int](capacity=self.dims)
        self.index_in_grade = List[Int](capacity=self.dims)
        self.combs = powerset_ord(self.vecs)
        self.mult.__init__[False](self.dims, self.dims)

        if flip_ze:
            for _ in range(ze):
                self.vec_sqrs += 0

        for _ in range(po):
            self.vec_sqrs += 1

        for _ in range(ne):
            self.vec_sqrs += -1

        if not flip_ze:
            for _ in range(ze):
                self.vec_sqrs += 0

        for grade in range(self.grds):
            self.grade_dims += pascal(self.vecs, grade)

        for grade in range(self.grds):
            for basis in range(self.grade_dims[grade]):
                self.grade_of += grade
                self.index_in_grade += basis

        self.generate_product_table()

    # +------( Masks )------+ #
    #
    fn empty_mask(self) -> BasisMask:
        var result = List[Bool](capacity=self.dims)
        for _ in range(self.dims):
            result += False
        return BasisMask(result)

    fn full_mask(self) -> BasisMask:
        var result = List[Bool](capacity=self.dims)
        for _ in range(self.dims):
            result += True
        return BasisMask(result)

    fn grade_mask(self, grade: Int) -> BasisMask:
        var result = List[Bool](capacity=self.dims)
        for basis in range(self.dims):
            result += self.grade_of[basis] == grade
        return BasisMask(result)

    @always_inline
    fn even_mask(self) -> BasisMask:
        var result = List[Bool](capacity=self.dims)
        for basis in range(self.dims):
            result += (self.grade_of[basis] % 2) == 0
        return BasisMask(result)

    @always_inline
    fn scalar_mask(self) -> BasisMask:
        return self.grade_mask(0)

    @always_inline
    fn vector_mask(self) -> BasisMask:
        return self.grade_mask(1)

    @always_inline
    fn bivector_mask(self) -> BasisMask:
        return self.grade_mask(2)

    @always_inline
    fn trivector_mask(self) -> BasisMask:
        return self.grade_mask(3)

    @always_inline
    fn quadvector_mask(self) -> BasisMask:
        return self.grade_mask(4)

    @always_inline
    fn antiscalar_mask(self) -> BasisMask:
        return self.grade_mask(self.grds - 1)

    # +------( Basis )------+ #
    #
    @always_inline
    fn squash_basis(self, mut basis: List[Int], mut sign: Int):
        var result = List[Int](capacity=len(basis))
        var i = 1
        var j = 0
        while i < len(basis):
            if basis[i] != basis[i - 1]:
                result += basis[i - 1]
                i += 1
                j += 1
            else:
                sign *= self.vec_sqrs[basis[i] - 1]
                i += 2

        if i == len(basis):
            result += basis[len(basis) - 1]

        basis = result^

    @always_inline
    fn reduce_basis(self, owned basis: List[Int]) -> SignedBasis:
        if len(basis) == 0:
            return SignedBasis(1, 0)
        elif len(basis) == 1:
            return SignedBasis(1, basis[0])
        else:
            var sign: Int = 1 - ((signed_sort(basis) % 2) * 2)
            self.squash_basis(basis, sign)
            return SignedBasis(sign, self.order_basis(basis))

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
                sign = -sign
        basis.insert(0, vec)

    @always_inline
    fn reduce_basis(self, owned basis1: List[Int], basis2: List[Int]) -> SignedBasis:
        var sign: Int = 1
        for vec in basis2:
            self.squash_vec(basis1, vec[], sign)
        return SignedBasis(sign, self.order_basis(basis1))

    @always_inline
    fn order_basis(self, basis: List[Int]) -> Int:
        var result = self.grade_dims[len(basis)]

        for i in range(len(basis)):
            result += self.grade_dims[i]
            var n = self.vecs - basis[i]
            var k = len(basis) - i
            if n >= k:
                result -= pascal(n, k)

        return result - 1

    # +------( Generate )------+ #
    #
    fn generate_product_table(mut self):
        for x in range(self.dims):
            for y in range(self.dims):
                self.mult[x, y] = self.reduce_basis(self.combs[x], self.combs[y])

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_basis_to[WriterType: Writer, //](self, mut writer: WriterType, basis: SignedBasis):
        var align = len(str(self.dims)) + 1
        var str_basis: String = ""
        if basis.sign < 0:
            str_basis = str(basis)
            writer.write(Color.grey, Color.bg_colors[(self.grade_of[basis.basis] % 6) + 1])
        elif basis.sign > 0:
            str_basis = str(basis)
            writer.write(Color.white, Color.bg_colors[(self.grade_of[basis.basis] % 6) + 1])
        else:
            writer.write(Color.clear)
        for _ in range(align - len(str_basis)):
            writer.write(" ")
        writer.write(str_basis, " ")

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        for x in range(self.mult._cols):
            for y in range(self.mult._rows):
                self.write_basis_to(writer, self.mult[x, y])
            writer.write(Color.clear, "\n")
