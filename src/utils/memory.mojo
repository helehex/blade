# +--------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +--------------------------------------------------------------------------+ #
"""Memory."""

from memory import UnsafePointer
from algorithm import vectorize
from sys import size_of, simd_width_of

# from sys import simd_width_of, size_of


@always_inline
fn memclr[
    type: DType, //
](ptr: UnsafePointer[Scalar[type], MutAnyOrigin], count: Int):
    memset(ptr, 0, count)


@always_inline
fn memclr[
    T: AnyTrivialRegType, //
](ptr: UnsafePointer[T, MutAnyOrigin], count: Int):
    memclr(ptr.bitcast[UInt8](), count * size_of[T]())


@always_inline
fn memset[
    type: DType, //
](
    ptr: UnsafePointer[Scalar[type], MutAnyOrigin],
    value: Scalar[type],
    count: Int,
):
    @parameter
    fn _set[width: Int](offset: Int):
        simd_store[width](ptr, offset, value)

    vectorize[_set, simd_width_of[type]()](count)


@always_inline
fn memset[
    T: AnyTrivialRegType, //
](ptr: UnsafePointer[T, MutAnyOrigin], value: T, count: Int):
    for idx in range(count):
        (ptr + idx)[] = value


@always_inline
fn memcpy[
    type: DType, //
](
    dst: UnsafePointer[Scalar[type], *_],
    src: UnsafePointer[Scalar[type], *_],
    count: Int,
):
    @parameter
    fn _cpy[width: Int](offset: Int):
        simd_store[width](dst, offset, simd_load[width](src, offset))

    vectorize[_cpy, simd_width_of[type]()](count)


@always_inline
fn memcpy[
    T: AnyTrivialRegType, //
](dst: UnsafePointer[T, *_], src: UnsafePointer[T, *_], count: Int):
    memcpy(dst.bitcast[UInt8](), src.bitcast[UInt8](), count * size_of[T]())


@always_inline
fn simd_load[
    type: DType, //, width: Int, /, *, alignment: Int = 1
](ptr: UnsafePointer[Scalar[type], *_], offset: Int) -> SIMD[type, width]:
    @parameter
    if type is DType.bool:
        return __mlir_op.`pop.load`[alignment = alignment._mlir_value](
            (ptr + offset).bitcast[SIMD[DType.uint8, width]]().address
        ).cast[type]()
    else:
        return __mlir_op.`pop.load`[alignment = alignment._mlir_value](
            (ptr + offset).bitcast[SIMD[type, width]]().address
        )


@always_inline
fn simd_store[
    type: DType, //, width: Int, /, *, alignment: Int = 1
](ptr: UnsafePointer[Scalar[type], *_], offset: Int, value: SIMD[type, width]):
    @parameter
    if type is DType.bool:
        __mlir_op.`pop.store`[alignment = alignment._mlir_value](
            value.cast[DType.uint8](),
            (ptr + offset).bitcast[SIMD[DType.uint8, width]]().address,
        )
    else:
        __mlir_op.`pop.store`[alignment = alignment._mlir_value](
            value, (ptr + offset).bitcast[SIMD[type, width]]().address
        )
