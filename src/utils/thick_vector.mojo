# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Thick Vector."""

from std.memory import UnsafePointer


@always_inline
def _thick_vector_construction_checks[size: Int, width: Int]():
    comptime assert size >= 0 and width > 0, "number of elements in `SmallArray` must be >= 0"


# +--------------------------------------------------------------------------+ #
# | Thick Vector
# +--------------------------------------------------------------------------+ #
#
struct ThickVector[type: DType, size: SIMDSize, thickness: Int = 1](
    TrivialRegisterPassable, Movable
):
    """A thick vector."""

    # +------[ Alias ]------+ #
    #
    comptime Coef = SIMD[Self.type, Self.thickness]
    comptime Lane = ThickVector[Self.type, Self.size, 1]
    comptime Data = __mlir_type[`!pop.array<`, Self.size._mlir_value, `, `, Self.Coef, `>`]

    # +------< Data >------+ #
    #
    var _data: Self.Data

    # +------( Initialize )------+ #
    #
    @always_inline
    def __init__[init: Bool = True](out self):
        _thick_vector_construction_checks[Self.size, Self.thickness]()
        __mlir_op.`lit.ownership.mark_initialized`(
            __get_mvalue_as_litref(self._data)
        )

        comptime if init:
            for idx in range(Self.size):
                self[idx] = 0

    # @always_inline
    # def __init__[clear: Bool = True](out self, var values: VariadicList[Int, is_owned = True]):
    #     self = self.__init__[False]()
    #     for idx in range(Self.size):
    #         self[idx] = values[idx]

    @always_inline
    def __init__[
        clear: Bool = True
    ](out self, var values: VariadicList[Self.Coef, is_owned = True]):
        self = self.__init__[False]()
        for idx in range(Self.size):
            self[idx] = values[idx]

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, idx: Int, out result: Self.Lane):
        result = result.__init__[False]()

        comptime for coef_idx in range(Self.size):
            result[coef_idx] = self[coef_idx][idx]

    @always_inline
    def __getitem__[
        width: Int
    ](ref self: Self.Lane, var idx: Int) -> SIMD[Self.type, width]:
        return self.unsafe_ptr().load[width](idx)

    @always_inline
    def __getitem__(ref self, var idx: Int) -> Self.Coef:
        return (self.unsafe_ptr() + idx)[]

    @always_inline
    def __setitem__[
        lif: MutOrigin, //, width: Int
    ](
        ref [lif]self: ThickVector[Self.type, Self.size, 1],
        var idx: Int,
        value: SIMD[Self.type, width],
    ):
        self.unsafe_ptr().store[width](idx, value)

    @always_inline
    def __setitem__[
        lif: MutOrigin, //
    ](ref [lif]self, var idx: Int, var value: Self.Coef):
        (self.unsafe_ptr() + idx)[] = value

    @always_inline
    def unsafe_ptr(
        ref self,
    ) -> UnsafePointer[Self.Coef, origin = origin_of(self._data)]:
        return UnsafePointer(to=self._data).bitcast[Self.Coef]()

    # @always_inline
    # def clear[lif: AnyLifetime[True].type, //](ref [lif]self):
    #     memclr(self.unsafe_ptr(), size)

    # @always_inline
    # def fill(self, value: Scalar[type]):
    #     memset(self.unsafe_ptr(), value, size)

    # +------( Operations )------+ #
    #
    @always_inline
    def __len__(self) -> Int:
        return Self.size

    @always_inline
    def __bool__(self) -> Bool:
        return True

    @always_inline
    def __is__(ref [_]self, ref [_]rhs: Self) -> Bool:
        return UnsafePointer(to=self) == UnsafePointer(to=rhs)

    @always_inline
    def __isnot__(ref [_]self, ref [_]rhs: Self) -> Bool:
        return UnsafePointer(to=self) != UnsafePointer(to=rhs)

    # @always_inline
    # def __eq__[size: Int = size](self, rhs: ThickVector[type, size]) -> Bool:
    #     return self[:] == rhs[:]

    # @always_inline
    # def __ne__[size: Int = size](self, rhs: ThickVector[type, size]) -> Bool:
    #     return self[:] != rhs[:]

    # @always_inline
    # def __any__(self) -> Bool:
    #     @parameter
    #     @always_inline
    #     def _check[width: Int](offset: Int) -> Bool:
    #         return any(self.__getitem__[width](offset) != 0)

    #     return vectorize_stoping[_check, simd_width_of[type]()](size)

    # @always_inline
    # def __all__(self) -> Bool:
    #     @parameter
    #     @always_inline
    #     def _check[width: Int](offset: Int) -> Bool:
    #         return any(self.__getitem__[width](offset) == 0)

    #     return not vectorize_stoping[_check, simd_width_of[type]()](size)
