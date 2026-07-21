# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Memory."""

# from std.memory import UnsafePointer
# from std.algorithm import vectorize
# from std.sys import size_of, simd_width_of

# # from sys import simd_width_of, size_of


# @always_inline
# def memclr[
#     type: DType, //
# ](ptr: UnsafePointer[Scalar[type], MutAnyOrigin], count: Int):
#     memset(ptr, 0, count)


# @always_inline
# def memclr[
#     T: TrivialRegisterPassable, //
# ](ptr: UnsafePointer[T, MutAnyOrigin], count: Int):
#     memclr(ptr.bitcast[UInt8](), count * size_of[T]())


# @always_inline
# def memset[
#     type: DType, //
# ](
#     ptr: UnsafePointer[Scalar[type], MutAnyOrigin],
#     value: Scalar[type],
#     count: Int,
# ):
#     @parameter
#     def _set[width: Int](offset: Int):
#         simd_store[width](ptr, offset, value)

#     vectorize[_set, simd_width_of[type]()](count)


# @always_inline
# def memset[
#     T: TrivialRegisterPassable, //
# ](ptr: UnsafePointer[T, MutAnyOrigin], value: T, count: Int):
#     for idx in range(count):
#         (ptr + idx)[] = value


# @always_inline
# def memcpy[
#     type: DType, //
# ](
#     dst: UnsafePointer[Scalar[type], ...],
#     src: UnsafePointer[Scalar[type], ...],
#     count: Int,
# ):

#     def _cpy[width: Int](offset: Int):
#         simd_store[width](dst, offset, simd_load[width](src, offset))

#     vectorize[simd_width_of[type]()](count, _cpy)


# @always_inline
# def memcpy[
#     T: TrivialRegisterPassable, //
# ](dst: UnsafePointer[T, ...], src: UnsafePointer[T, ...], count: Int):
#     memcpy(dst.bitcast[UInt8](), src.bitcast[UInt8](), count * size_of[T]())


# @always_inline
# def simd_load[
#     type: DType, //, width: Int, /, *, alignment: Int = 1
# ](ptr: UnsafePointer[Scalar[type], ...], offset: Int) -> SIMD[type, width]:
#     comptime if type == DType.bool:
#         return __mlir_op.`pop.load`[alignment = alignment._mlir_value](
#             (ptr + offset).bitcast[SIMD[DType.uint8, width]]().address
#         ).cast[type]()
#     else:
#         return __mlir_op.`pop.load`[alignment = alignment._mlir_value](
#             (ptr + offset).bitcast[SIMD[type, width]]().address
#         )


# @always_inline
# def simd_store[
#     type: DType, //, width: Int, /, *, alignment: Int = 1
# ](ptr: UnsafePointer[Scalar[type], ...], offset: Int, value: SIMD[type, width]):
#     comptime if type == DType.bool:
#         __mlir_op.`pop.store`[alignment = alignment._mlir_value](
#             value.cast[DType.uint8](),
#             (ptr + offset).bitcast[SIMD[DType.uint8, width]]().address,
#         )
#     else:
#         __mlir_op.`pop.store`[alignment = alignment._mlir_value](
#             value, (ptr + offset).bitcast[SIMD[type, width]]().address
#         )
