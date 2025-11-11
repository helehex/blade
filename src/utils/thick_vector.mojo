# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Thick Vector."""

from memory import UnsafePointer
from .memory import memclr, simd_load, simd_store


@always_inline
fn _thick_vector_construction_checks[size: Int, width: Int]():
    constrained[size >= 0 and width > 0, "number of elements in `SmallArray` must be >= 0"]()


# +----------------------------------------------------------------------------------------------+ #
# | Thick Vector
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct ThickVector[type: DType, size: Int, thickness: Int = 1](Copyable, Movable):
    """A thick vector."""

    # +------[ Alias ]------+ #
    #
    alias Coef = SIMD[type, thickness]
    alias Lane = ThickVector[type, size, 1]
    alias Data = __mlir_type[`!pop.array<`, size._mlir_value, `, `, Self.Coef, `>`]

    # +------< Data >------+ #
    #
    var _data: Self.Data

    # +------( Initialize )------+ #
    #
    @always_inline
    fn __init__[init: Bool = True](out self):
        _thick_vector_construction_checks[size, thickness]()
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(self._data))

        @parameter
        if init:
            for idx in range(size):
                self[idx] = 0

    @always_inline
    fn __init__[clear: Bool = True](out self, var values: VariadicListMem[Int]):
        self = self.__init__[False]()
        for idx in range(size):
            self[idx] = values[idx]

    @always_inline
    fn __init__[clear: Bool = True](out self, var values: VariadicListMem[Self.Coef]):
        self = self.__init__[False]()
        for idx in range(size):
            self[idx] = values[idx]

    # +------( Subscript )------+ #
    #
    @always_inline
    fn get_lane(self, idx: Int, out result: Self.Lane):
        result = result.__init__[False]()

        @parameter
        for coef_idx in range(size):
            result[coef_idx] = self[coef_idx][idx]

    @always_inline
    fn __getitem__[width: Int](ref self: Self.Lane, var idx: Int) -> SIMD[type, width]:
        return simd_load[width](self.unsafe_ptr(), idx)

    @always_inline
    fn __getitem__(ref self, var idx: Int) -> Self.Coef:
        return (self.unsafe_ptr() + idx)[]

    @always_inline
    fn __setitem__[
        lif: MutOrigin, //, width: Int
    ](ref [lif]self: ThickVector[type, size, 1], var idx: Int, value: SIMD[type, width]):
        simd_store[width](self.unsafe_ptr(), idx, value)

    @always_inline
    fn __setitem__[lif: MutOrigin, //](ref [lif]self, var idx: Int, var value: Self.Coef):
        (self.unsafe_ptr() + idx)[] = value

    @always_inline
    fn unsafe_ptr(
        ref self,
    ) -> UnsafePointer[
        Self.Coef,
        mut = Origin(origin_of(self)).mut,
        origin = origin_of(self),
    ]:
        return UnsafePointer(to=self._data).bitcast[Self.Coef]()

    # @always_inline
    # fn clear[lif: AnyLifetime[True].type, //](ref [lif]self):
    #     memclr(self.unsafe_ptr(), size)

    # @always_inline
    # fn fill(self, value: Scalar[type]):
    #     memset(self.unsafe_ptr(), value, size)

    # +------( Operations )------+ #
    #
    @always_inline
    fn __len__(self) -> Int:
        return size

    @always_inline
    fn __bool__(self) -> Bool:
        return True

    @always_inline
    fn __is__(ref [_]self, ref [_]rhs: Self) -> Bool:
        return UnsafePointer(to=self) == UnsafePointer(to=rhs)

    @always_inline
    fn __isnot__(ref [_]self, ref [_]rhs: Self) -> Bool:
        return UnsafePointer(to=self) != UnsafePointer(to=rhs)

    # @always_inline
    # fn __eq__[size: Int = size](self, rhs: ThickVector[type, size]) -> Bool:
    #     return self[:] == rhs[:]

    # @always_inline
    # fn __ne__[size: Int = size](self, rhs: ThickVector[type, size]) -> Bool:
    #     return self[:] != rhs[:]

    # @always_inline
    # fn __any__(self) -> Bool:
    #     @parameter
    #     @always_inline
    #     fn _check[width: Int](offset: Int) -> Bool:
    #         return any(self.__getitem__[width](offset) != 0)

    #     return vectorize_stoping[_check, simd_width_of[type]()](size)

    # @always_inline
    # fn __all__(self) -> Bool:
    #     @parameter
    #     @always_inline
    #     fn _check[width: Int](offset: Int) -> Bool:
    #         return any(self.__getitem__[width](offset) == 0)

    #     return not vectorize_stoping[_check, simd_width_of[type]()](size)
