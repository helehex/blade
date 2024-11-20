# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Thick Vector."""

from .memory import UnsafePointer, memclr, simd_load, simd_store


fn _thick_vector_construction_checks[size: Int, width: Int]():
    constrained[size >= 0 and width > 0, "number of elements in `SmallArray` must be >= 0"]()


# +----------------------------------------------------------------------------------------------+ #
# | Thick Vector
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct ThickVector[type: DType, size: Int, thickness: Int = 1]:
    """A thick vector."""

    # +------< Data >------+ #
    #
    alias Data = __mlir_type[`!pop.array<`, size.value, `, `, SIMD[type, thickness], `>`]
    var _data: Self.Data

    # +------( Initialize )------+ #
    #
    @always_inline
    fn __init__[clear: Bool = True](inout self):
        _thick_vector_construction_checks[size, thickness]()
        self._data = __mlir_op.`kgen.param.constant`[
            _type = Self.Data, value = __mlir_attr[`#kgen.unknown : `, Self.Data]
        ]()

        @parameter
        if clear:
            for idx in range(size):
                self[idx] = 0

    @always_inline
    fn __init__[clear: Bool = True](inout self, owned values: VariadicListMem[Int]):
        self.__init__[False]()
        for idx in range(size):
            self[idx] = values[idx]

    @always_inline
    fn __init__[
        clear: Bool = True
    ](inout self, owned values: VariadicListMem[SIMD[type, thickness]]):
        self.__init__[False]()
        for idx in range(size):
            self[idx] = values[idx]

    # +------( Subscript )------+ #
    #
    @always_inline
    fn __getitem__[
        width: Int
    ](ref [_]self: ThickVector[type, size, 1], owned idx: Int) -> SIMD[type, width]:
        return simd_load[width](self.unsafe_ptr(), idx)

    @always_inline
    fn __getitem__(ref [_]self, owned idx: Int) -> SIMD[type, thickness]:
        return (self.unsafe_ptr() + idx)[]

    @always_inline
    fn __setitem__[
        lif: MutableOrigin, //, width: Int
    ](ref [lif]self: ThickVector[type, size, 1], owned idx: Int, value: SIMD[type, width]):
        simd_store[width](self.unsafe_ptr(), idx, value)

    @always_inline
    fn __setitem__[
        lif: MutableOrigin, //
    ](ref [lif]self, owned idx: Int, owned value: SIMD[type, thickness]):
        (self.unsafe_ptr() + idx)[] = value

    @always_inline
    fn unsafe_ptr[
        spc: __mlir_type.`index`
    ](ref [_, spc]self) -> UnsafePointer[SIMD[type, thickness], AddressSpace(spc)]:
        return UnsafePointer.address_of(self._data).bitcast[
            SIMD[type, thickness], address_space = AddressSpace(spc)
        ]()

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
        return UnsafePointer.address_of(self) == UnsafePointer.address_of(rhs)

    @always_inline
    fn __isnot__(ref [_]self, ref [_]rhs: Self) -> Bool:
        return UnsafePointer.address_of(self) != UnsafePointer.address_of(rhs)

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

    #     return vectorize_stoping[_check, simdwidthof[type]()](size)

    # @always_inline
    # fn __all__(self) -> Bool:
    #     @parameter
    #     @always_inline
    #     fn _check[width: Int](offset: Int) -> Bool:
    #         return any(self.__getitem__[width](offset) == 0)

    #     return not vectorize_stoping[_check, simdwidthof[type]()](size)
