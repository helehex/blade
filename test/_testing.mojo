from std.collections import Optional
from std.testing.testing import isclose, _assert_error, _assert_cmp_error
from std.reflection import SourceLocation, source_location, call_location

@always_inline
def _str[T: Copyable & Writable & Equatable](l: List[List[T]]) -> String:
    var result: String = "["
    for idx in range(len(l) - 1):
        result += String(l[idx]) + ", "
    if len(l) > 0:
        result += String(l[len(l) - 1])
    return result + "]"


@always_inline
def _assert_equal[T: Copyable & Writable & Equatable](lhs: List[T], rhs: List[T], msg: String = "", *, location: Optional[SourceLocation] = None) raises:
    var eq = len(lhs) == len(rhs)

    if eq:
        for idx in range(len(lhs)):
            if lhs[idx] != rhs[idx]:
                eq = False
                break

    if not eq:
        raise _assert_cmp_error["`left == right` comparison"](
            String(lhs),
            String(rhs),
            msg=msg,
            loc=location.or_else(call_location()),
        )


@always_inline
def _assert_not_equal[T: Copyable & Writable & Equatable](lhs: List[T], rhs: List[T], msg: String = "", *, location: Optional[SourceLocation] = None) raises:
    var ne = len(lhs) != len(rhs)

    if not ne:
        for idx in range(len(lhs)):
            if lhs[idx] != rhs[idx]:
                ne = True
                break

    if not ne:
        raise _assert_cmp_error["`left != right` comparison"](
            String(lhs),
            String(rhs),
            msg=msg,
            loc=location.or_else(call_location()),
        )


# @always_inline
# def _assert_equal[T: Copyable & Writable & Equatable](lhs: List[List[T]], rhs: List[List[T]], msg: String = "", *, location: Optional[SourceLocation] = None,) raises:
#     var eq = len(lhs) == len(rhs)

#     if eq:
#         for idx in range(len(lhs)):
#             if lhs[idx] != rhs[idx]:
#                 eq = False
#                 break

#     if not eq:
#         raise _assert_cmp_error["`left == right` comparison"](
#             _str(lhs),
#             _str(rhs),
#             msg=msg,
#             loc=location.or_else(call_location()),
#         )


# @always_inline
# def _assert_not_equal[T: Copyable & Writable & Equatable](lhs: List[List[T]], rhs: List[List[T]], msg: String = "", *, location: Optional[SourceLocation] = None,) raises:
#     var ne = len(lhs) != len(rhs)

#     if not ne:
#         for idx in range(len(lhs)):
#             if lhs[idx] != rhs[idx]:
#                 ne = True
#                 break

#     if not ne:
#         raise _assert_cmp_error["`left != right` comparison"](
#             _str(lhs),
#             _str(rhs),
#             msg=msg,
#             loc=location.or_else(call_location()),
#         )
