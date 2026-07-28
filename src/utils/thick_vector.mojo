# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Thick Vector."""

from std.memory import UnsafePointer


@always_inline("builtin")
def _thick_vector_construction_checks[size: Int, width: Int]():
    comptime assert size >= 0 and width > 0, "number of elements in `SmallArray` must be >= 0"


# +--------------------------------------------------------------------------+ #
# | Thick Vector
# +--------------------------------------------------------------------------+ #
#
struct ThickVector[type: DType, size: SIMDLength, thickness: Int = 1](
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
    def __getitem__(ref self, var idx: Int) -> Self.Coef:
        return (self.unsafe_ptr() + idx)[]

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
