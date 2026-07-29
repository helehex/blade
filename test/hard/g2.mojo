# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
"""Defines a G2 Multivector, and it's subspaces.

Cl(2,0,0) ⇔ Mat2x2

`x*x = y*y = 1`

`x*y = i`

`y*x = -i`

`i*i = -1`
"""

from std.math import sqrt, cos, sin, atan2

# from collections import Optional


# +----------------------------------------------------------------------------------------------+ #
# | G2 Multivector
# +----------------------------------------------------------------------------------------------+ #
#
struct Multivector[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """A G2 Multivector."""

    # +------[ Alias ]------+ #
    #
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Vect = Vector[Self.type, Self.size]
    comptime Roto = Rotor[Self.type, Self.size]
    comptime Lane = Multivector[Self.type, 1]

    # +------< Data >------+ #
    #
    var s: Self.Coef
    """The scalar component."""

    var v: Self.Vect
    """The vector component."""

    var i: Self.Coef
    """The bivector component."""

    # +------( Initialize )------+ #
    #
    @always_inline
    def __init__(out self):
        self.s = 0
        self.v = None
        self.i = 0

    @implicit
    @always_inline
    def __init__(out self, none: None):
        self = Self.__init__()

    @always_inline
    def __init__(out self, s: Self.Coef, x: Self.Coef, y: Self.Coef, i: Self.Coef):
        self.s = s
        self.v = Self.Vect(x, y)
        self.i = i

    @always_inline
    def __init__(out self, s: Self.Coef, v: Self.Vect = None, i: Self.Coef = 0):
        self.s = s
        self.v = v
        self.i = i

    @always_inline
    def __init__(out self, v: Self.Vect, r: Self.Roto = None):
        self.s = r.s
        self.v = v
        self.i = r.i

    @implicit
    @always_inline
    def __init__(out self, r: Self.Roto):
        self.s = r.s
        self.v = None
        self.i = r.i

    @implicit
    @always_inline
    def __init__(out self, m: Self.Lane):
        self.s = m.s
        self.v = m.v
        self.i = m.i

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, index: Int) -> Self.Lane:
        return Self.Lane(self.s[index], self.v.x[index], self.v.y[index], self.i[index])

    @always_inline
    def set_lane(mut self, index: Int, value: Self.Lane):
        self.s[index] = value.s
        self.v.x[index] = value.v.x
        self.v.y[index] = value.v.y
        self.i[index] = value.i

    @always_inline
    def vector(self) -> Self.Vect:
        return Self.Vect(self.v.x, self.v.y)

    @always_inline
    def rotor(self) -> Self.Roto:
        return Self.Roto(self.s, self.i)

    # +------( Cast )------+ #
    #
    @always_inline
    def __all__(self) -> Bool:
        return self.__simd_bool__().reduce_and()

    @always_inline
    def __any__(self) -> Bool:
        return self.__simd_bool__().reduce_or()

    @always_inline
    def __bool__(self) -> Bool:
        return self.__simd_bool__().__bool__()

    @always_inline
    def __simd_bool__(self) -> SIMD[DType.bool, Self.size]:
        return self.is_zero()

    @always_inline
    def is_null(self) -> SIMD[DType.bool, Self.size]:
        return self.nom() == 0

    @always_inline
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.s == 0) & self.v.is_zero() & (self.i == 0)

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String.write(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.s, " + ", self.v.x, "x + ", self.v.y, "y + ", self.i, "i")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    @always_inline
    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other.s)) & (self.v.eq(other.v)) & (self.i.eq(other.i))

    @always_inline
    def eq(self, other: Self.Roto) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other.s)) & (self.v.eq(Self.Vect())) & (self.i.eq(other.i))

    @always_inline
    def eq(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other)) & (self.v.eq(Self.Vect())) & (self.i.eq(0))

    @always_inline
    def eq(self, other: Self.Vect) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(0)) & (self.v.eq(other)) & (self.i.eq(0))

    @always_inline
    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    @always_inline
    def __eq__(self, other: Self.Roto) -> Bool:
        return all(self.eq(other))

    @always_inline
    def __eq__(self, other: Self.Coef) -> Bool:
        return all(self.eq(other))

    @always_inline
    def __eq__(self, other: Self.Vect) -> Bool:
        return all(self.eq(other))

    @always_inline
    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other.s)) | (self.v.ne(other.v)) | (self.i.ne(other.i))

    @always_inline
    def ne(self, other: Self.Roto) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other.s)) | (self.v.ne(Self.Vect())) | (self.i.ne(other.i))

    @always_inline
    def ne(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other)) | (self.v.ne(Self.Vect())) | (self.i.ne(0))

    @always_inline
    def ne(self, other: Self.Vect) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(0)) | (self.v.ne(other)) | (self.i.ne(0))

    @always_inline
    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    @always_inline
    def __ne__(self, other: Self.Roto) -> Bool:
        return any(self.ne(other))

    @always_inline
    def __ne__(self, other: Self.Coef) -> Bool:
        return any(self.ne(other))

    @always_inline
    def __ne__(self, other: Self.Vect) -> Bool:
        return any(self.ne(other))

    # +------( Unary )------+ #
    #
    @always_inline
    def __neg__(self) -> Self:
        return Self(-self.s, -self.v, -self.i)

    @always_inline
    def __invert__(self) -> Self:
        return self.coj() / self.den()

    @always_inline
    def rev(self) -> Self:
        return Self(self.s, self.v.x, self.v.y, -self.i)

    @always_inline
    def inv(self) -> Self:
        return Self(self.s, -self.v.x, -self.v.y, self.i)

    @always_inline
    def coj(self) -> Self:
        return Self(self.s, -self.v.x, -self.v.y, -self.i)

    @always_inline
    def det(self) -> Self.Coef:
        return (self.s * self.i) - (self.v.x * self.v.y)

    @always_inline
    def den(self) -> Self.Coef:
        return (self.s * self.s) - (self.v.x * self.v.x) - (self.v.y * self.v.y) + (self.i * self.i)

    @always_inline
    def inn(self) -> Self.Coef:
        return (self.s * self.s) + (self.v.x * self.v.x) + (self.v.y * self.v.y) + (self.i * self.i)

    @always_inline
    def nom(self) -> Self.Coef:
        return sqrt(self.inn())

    @always_inline
    def normalized[degen: Optional[Self] = None](self) -> Self:
        comptime if degen:
            if self.is_zero():
                return degen.unsafe_value()
        return self / self.nom()

    @always_inline
    def trans(self, other: Self) -> Self:
        return (self.v + other.v) + (self.rotor() * other.rotor())

    # +------( Arithmetic )------+ #
    #
    @always_inline
    def __add__(self, other: Self.Coef) -> Self:
        return Self(self.s + other, self.v, self.i)

    @always_inline
    def __add__(self, other: Self.Vect) -> Self:
        return Self(self.s, self.v + other, self.i)

    @always_inline
    def __add__(self, other: Self.Roto) -> Self:
        return Self(self.s + other.s, self.v, self.i + other.i)

    @always_inline
    def __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.v + other.v, self.i + other.i)

    @always_inline
    def __sub__(self, other: Self.Coef) -> Self:
        return Self(self.s - other, self.v, self.i)

    @always_inline
    def __sub__(self, other: Self.Vect) -> Self:
        return Self(self.s, self.v - other, self.i)

    @always_inline
    def __sub__(self, other: Self.Roto) -> Self:
        return Self(self.s - other.s, self.v, self.i - other.i)

    @always_inline
    def __sub__(self, other: Self) -> Self:
        return Self(self.s - other.s, self.v - other.v, self.i - other.i)

    @always_inline
    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.s * other, self.v * other, self.i * other)

    @always_inline
    def __mul__(self, other: Self.Vect) -> Self:
        return Self(
            self.v.x * other.x + self.v.y * other.y,
            self.s * other.x + self.i * other.y,
            self.s * other.y - self.i * other.x,
            self.v.x * other.y - self.v.y * other.x,
        )

    @always_inline
    def __mul__(self, other: Self.Roto) -> Self:
        return Self(
            self.s * other.s - self.i * other.i,
            self.v.x * other.s - self.v.y * other.i,
            self.v.y * other.s + self.v.x * other.i,
            self.s * other.i + self.i * other.s,
        )

    @always_inline
    def __mul__(self, other: Self) -> Self:
        return Self(
            self.s * other.s + self.v.x * other.v.x + self.v.y * other.v.y - self.i * other.i,
            self.s * other.v.x + self.v.x * other.s + self.i * other.v.y - self.v.y * other.i,
            self.s * other.v.y + self.v.y * other.s - self.i * other.v.x + self.v.x * other.i,
            self.s * other.i + self.i * other.s + self.v.x * other.v.y - self.v.y * other.v.x,
        )

    @always_inline
    def __truediv__(self, other: Self.Coef) -> Self:
        return Self(self.s / other, self.v.x / other, self.v.y / other, self.i / other)

    @always_inline
    def __truediv__(self, other: Self.Vect) -> Self:
        return self * ~other

    @always_inline
    def __truediv__(self, other: Self.Roto) -> Self:
        return self * ~other

    @always_inline
    def __truediv__(self, other: Self) -> Self:
        return self * ~other

    # +------( Reverse Arithmetic )------+ #
    #
    @always_inline
    def __radd__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs + rhs.s, rhs.v, rhs.i)

    @always_inline
    def __rsub__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs - rhs.s, -rhs.v, -rhs.i)

    @always_inline
    def __rmul__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs * rhs.s, lhs * rhs.v, lhs * rhs.i)

    @always_inline
    def __rtruediv__(rhs, lhs: Self.Coef) -> Self:
        return (lhs * rhs.coj()) / rhs.den()

    # +------( In-place Arithmetic )------+ #
    #
    @always_inline
    def __iadd__(mut self, other: Self.Coef):
        self = self + other

    @always_inline
    def __iadd__(mut self, other: Self.Vect):
        self = self + other

    @always_inline
    def __iadd__(mut self, other: Self.Roto):
        self = self + other

    @always_inline
    def __iadd__(mut self, other: Self):
        self = self + other

    @always_inline
    def __isub__(mut self, other: Self.Coef):
        self = self - other

    @always_inline
    def __isub__(mut self, other: Self.Vect):
        self = self - other

    @always_inline
    def __isub__(mut self, other: Self.Roto):
        self = self - other

    @always_inline
    def __isub__(mut self, other: Self):
        self = self - other

    @always_inline
    def __imul__(mut self, other: Self.Coef):
        self = self * other

    @always_inline
    def __imul__(mut self, other: Self.Vect):
        self = self * other

    @always_inline
    def __imul__(mut self, other: Self.Roto):
        self = self * other

    @always_inline
    def __imul__(mut self, other: Self):
        self = self * other

    @always_inline
    def __itruediv__(mut self, other: Self.Coef):
        self = self / other

    @always_inline
    def __itruediv__(mut self, other: Self.Vect):
        self = self / other

    @always_inline
    def __itruediv__(mut self, other: Self.Roto):
        self = self / other

    @always_inline
    def __itruediv__(mut self, other: Self):
        self = self / other

    # +------( Min / Max )------+ #
    #
    @always_inline
    def __max__(self, other: Self) -> Self:
        return Self(
            max(self.s, other.s),
            max(self.v.x, other.v.x),
            max(self.v.y, other.v.y),
            max(self.i, other.i),
        )

    @always_inline
    def __min__(self, other: Self) -> Self:
        return Self(
            min(self.s, other.s),
            min(self.v.x, other.v.x),
            min(self.v.y, other.v.y),
            min(self.i, other.i),
        )

    @always_inline
    def max_coef(self) -> SIMD[Self.type, Self.size]:
        return max(max(max(self.s, self.v.x), self.v.y), self.i)

    @always_inline
    def min_coef(self) -> SIMD[Self.type, Self.size]:
        return min(min(min(self.s, self.v.x), self.v.y), self.i)

    @always_inline
    def reduce_max_coef(self) -> Scalar[Self.type]:
        """Reduces across every coefficient present within this structure."""
        return max(
            max(self.s.reduce_max(), self.v.x.reduce_max()),
            max(self.v.y.reduce_max(), self.i.reduce_max()),
        )

    @always_inline
    def reduce_min_coef(self) -> Scalar[Self.type]:
        """Reduces across every coefficient present within this structure."""
        return min(
            min(self.s.reduce_min(), self.v.x.reduce_min()),
            min(self.v.y.reduce_min(), self.i.reduce_min()),
        )

    @always_inline
    def reduce_max_compose(self) -> Self.Lane:
        """Treats each basis channel independently, then uses those to constuct a new multivector."""
        return Self.Lane(
            self.s.reduce_max(),
            self.v.x.reduce_max(),
            self.v.y.reduce_max(),
            self.i.reduce_max(),
        )

    @always_inline
    def reduce_min_compose(self) -> Self.Lane:
        """Treats each basis channel independently, then uses those to constuct a new multivector."""
        return Self.Lane(
            self.s.reduce_min(),
            self.v.x.reduce_min(),
            self.v.y.reduce_min(),
            self.i.reduce_min(),
        )


# +----------------------------------------------------------------------------------------------+ #
# | G2 Rotor
# +----------------------------------------------------------------------------------------------+ #
#
struct Rotor[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """The real and anti parts of a Multivector G2. Useful for rotating vectors."""

    # +------[ Alias ]------+ #
    #
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Vect = Vector[Self.type, Self.size]
    comptime Multi = Multivector[Self.type, Self.size]
    comptime Lane = Rotor[Self.type, 1]

    # +------< Data >------+ #
    #
    var s: Self.Coef
    """The scalar part."""

    var i: Self.Coef
    """The antiox part."""

    # +------( Initialization )------+ #
    #
    @implicit
    @always_inline
    def __init__(out self, none: None = None):
        self.s = 0
        self.i = 0

    @always_inline
    def __init__(out self, s: Self.Coef, i: Self.Coef = 0):
        self.s = s
        self.i = i

    @always_inline
    def __init__(out self, v: Self.Lane):
        self.s = v.s
        self.i = v.i

    @always_inline
    def __init__(out self, *, angle: Self.Coef) where Self.type.is_floating_point():
        self.s = cos(angle)
        self.i = sin(angle)

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, i: Int) -> Self.Lane:
        return Self.Lane(self.s[i], self.i[i])

    @always_inline
    def set_lane(mut self, i: Int, item: Self.Lane):
        self.s[i] = item.s
        self.i[i] = item.i

    # +------( Cast )------+ #
    #
    @always_inline
    def __all__(self) -> Bool:
        return self.__simd_bool__().reduce_and()

    @always_inline
    def __any__(self) -> Bool:
        return self.__simd_bool__().reduce_or()

    @always_inline
    def __bool__(self) -> Bool:
        return self.__simd_bool__().__bool__()

    @always_inline
    def __simd_bool__(self) -> SIMD[DType.bool, Self.size]:
        return self.is_null()

    @always_inline
    def is_null(self) -> SIMD[DType.bool, Self.size]:
        return self.nom() == 0

    @always_inline
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.s == 0) & (self.i == 0)

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String.write(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.s, " + ", self.i, "i")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    @always_inline
    def eq(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    @always_inline
    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other.s)) & (self.i.eq(other.i))

    @always_inline
    def eq(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other)) & (self.i.eq(0))

    @always_inline
    def __eq__(self, other: Self.Multi) -> Bool:
        return all(self.eq(other))

    @always_inline
    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    @always_inline
    def __eq__(self, other: Self.Coef) -> Bool:
        return all(self.eq(other))

    @always_inline
    def ne(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    @always_inline
    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other.s)) | (self.i.ne(other.i))

    @always_inline
    def ne(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other)) | (self.i.ne(0))

    @always_inline
    def __ne__(self, other: Self.Multi) -> Bool:
        return any(self.ne(other))

    @always_inline
    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    @always_inline
    def __ne__(self, other: Self.Coef) -> Bool:
        return any(self.ne(other))

    # +------( Unary )------+ #
    #
    @always_inline
    def __neg__(self) -> Self:
        return Self(-self.s, -self.i)

    @always_inline
    def __invert__(self) -> Self:
        return self.coj() / self.den()

    @always_inline
    def rev(self) -> Self:
        return Self(self.s, -self.i)

    @always_inline
    def inv(self) -> Self:
        return Self(self.s, self.i)

    @always_inline
    def coj(self) -> Self:
        return Self(self.s, -self.i)

    @always_inline
    def det(self) -> Self.Coef:
        return self.s * self.i

    @always_inline
    def den(self) -> Self.Coef:
        return (self.s * self.s) + (self.i * self.i)

    @always_inline
    def inn(self) -> Self.Coef:
        return (self.s * self.s) + (self.i * self.i)

    @always_inline
    def nom(self) -> Self.Coef:
        return sqrt(self.inn())

    @always_inline
    def arg(self) -> Self.Coef where Self.type.is_floating_point():
        return atan2(self.i, self.s)

    @always_inline
    def normalized[degen: Optional[Self] = None](self) -> Self:
        comptime if degen:
            if self.is_zero():
                return degen.unsafe_value()
        return self / self.nom()

    # +------( Operations )------+ #
    #
    @always_inline
    def __add__(self, other: Self.Coef) -> Self:
        return Self(self.s + other, self.i)

    @always_inline
    def __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(self.s, other.x, other.y, self.i)

    @always_inline
    def __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.i + other.i)

    @always_inline
    def __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self.s + other.s, other.v.x, other.v.y, self.i + other.i)

    @always_inline
    def __sub__(self, other: Self.Coef) -> Self:
        return Self(self.s - other, self.i)

    @always_inline
    def __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(self.s, -other.x, -other.y, self.i)

    @always_inline
    def __sub__(self, other: Self) -> Self:
        return Self(self.s - other.s, self.i - other.i)

    @always_inline
    def __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self.s - other.s, -other.v.x, -other.v.y, self.i - other.i)

    @always_inline
    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.s * other, self.i * other)

    @always_inline
    def __mul__(self, other: Self.Vect) -> Self.Vect:
        return Self.Vect(
            self.s * other.x + self.i * other.y,
            self.s * other.y - self.i * other.x,
        )

    @always_inline
    def __mul__(self, other: Self) -> Self:
        return Self(
            self.s * other.s - self.i * other.i,
            self.s * other.i + self.i * other.s,
        )

    @always_inline
    def __mul__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(
            self.s * other.s - self.i * other.i,
            self.s * other.v.x + self.i * other.v.y,
            self.s * other.v.y - self.i * other.v.x,
            self.s * other.i + self.i * other.s,
        )

    @always_inline
    def __truediv__(self, other: Self.Coef) -> Self:
        return Self(self.s / other, self.i / other)

    @always_inline
    def __truediv__(self, other: Self.Vect) -> Self.Vect:
        return self * ~other

    @always_inline
    def __truediv__(self, other: Self) -> Self:
        return self * ~other

    @always_inline
    def __truediv__(self, other: Self.Multi) -> Self.Multi:
        return self * ~other

    # +------( Reverse Arithmetic )------+ #
    #
    @always_inline
    def __radd__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs + rhs.s, rhs.i)

    @always_inline
    def __rsub__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs - rhs.s, -rhs.i)

    @always_inline
    def __rmul__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs * rhs.s, lhs * rhs.i)

    @always_inline
    def __rtruediv__(rhs, lhs: Self.Coef) -> Self:
        return (lhs * rhs.coj()) / rhs.den()

    # +------( In-place Arithmetic )------+ #
    #
    @always_inline
    def __iadd__(mut self, other: Self.Coef):
        self = self + other

    @always_inline
    def __iadd__(mut self, other: Self):
        self = self + other

    @always_inline
    def __isub__(mut self, other: Self.Coef):
        self = self - other

    @always_inline
    def __isub__(mut self, other: Self):
        self = self - other

    @always_inline
    def __imul__(mut self, other: Self.Coef):
        self = self * other

    @always_inline
    def __imul__(mut self, other: Self):
        self = self * other

    @always_inline
    def __itruediv__(mut self, other: Self.Coef):
        self = self / other

    @always_inline
    def __itruediv__(mut self, other: Self):
        self = self / other


# +----------------------------------------------------------------------------------------------+ #
# | G2 Vector
# +----------------------------------------------------------------------------------------------+ #
#
struct Vector[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    # +------[ Alias ]------+ #
    #
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Roto = Rotor[Self.type, Self.size]
    comptime Multi = Multivector[Self.type, Self.size]
    comptime Lane = Vector[Self.type, 1]

    # +------< Data >------+ #
    #
    var x: Self.Coef
    """The x component."""

    var y: Self.Coef
    """The y component."""

    # +------( initialize )------+ #
    #
    @implicit
    @always_inline
    def __init__(out self, none: None = None):
        self.x = 0
        self.y = 0

    @always_inline
    def __init__(out self, x: Self.Coef, y: Self.Coef):
        self.x = x
        self.y = y

    @implicit
    @always_inline
    def __init__(out self, v: Self.Lane):
        self.x = v.x
        self.y = v.y

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, i: Int) -> Self.Lane:
        return Self.Lane(self.x[i], self.y[i])

    @always_inline
    def set_lane(mut self, i: Int, item: Self.Lane):
        self.x[i] = item.x
        self.y[i] = item.y

    # +------( Cast )------+ #
    #
    @always_inline
    def __all__(self) -> Bool:
        return self.__simd_bool__().reduce_and()

    @always_inline
    def __any__(self) -> Bool:
        return self.__simd_bool__().reduce_or()

    @always_inline
    def __bool__(self) -> Bool:
        return self.__simd_bool__().__bool__()

    @always_inline
    def __simd_bool__(self) -> SIMD[DType.bool, Self.size]:
        return self.is_null()

    @always_inline
    def is_null(self) -> SIMD[DType.bool, Self.size]:
        return self.nom() == 0

    @always_inline
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.x == 0) & (self.y == 0)

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String.write(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.x, "x + ", self.y, "y")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    @always_inline
    def eq(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    @always_inline
    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.x.eq(other.x)) & (self.y.eq(other.y))

    @always_inline
    def __eq__(self, other: Self.Multi) -> Bool:
        return all(self.eq(other))

    @always_inline
    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    @always_inline
    def ne(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    @always_inline
    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.x.ne(other.x)) | (self.y.ne(other.y))

    @always_inline
    def __ne__(self, other: Self.Multi) -> Bool:
        return any(self.ne(other))

    @always_inline
    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    # +------( Unary )------+ #
    #
    @always_inline
    def __neg__(self) -> Self:
        return Self(-self.x, -self.y)

    @always_inline
    def __invert__(self) -> Self:
        return self.coj() / self.den()

    @always_inline
    def rev(self) -> Self:
        return Self(self.x, self.y)

    @always_inline
    def inv(self) -> Self:
        return Self(-self.x, -self.y)

    @always_inline
    def coj(self) -> Self:
        return Self(-self.x, -self.y)

    @always_inline
    def det(self) -> Self.Coef:
        return -(self.x * self.y)

    @always_inline
    def den(self) -> Self.Coef:
        return -(self.x * self.x) - (self.y * self.y)

    @always_inline
    def inn(self) -> Self.Coef:
        return (self.x * self.x) + (self.y * self.y)

    @always_inline
    def nom(self) -> Self.Coef:
        return sqrt(self.inn())

    @always_inline
    def arg(self) -> Self.Coef where Self.type.is_floating_point():
        return atan2(self.y, self.x)

    @always_inline
    def nrm(self) -> Self:
        return Self(self.y, -self.x)

    @always_inline
    def normalized[degen: Optional[Self] = None](self) -> Self:
        comptime if degen:
            if self.is_zero():
                return degen.unsafe_value()
        return self / self.nom()

    # +------( Products )------+ #
    #
    @always_inline
    def inner(self, other: Self) -> Self.Coef:
        return self.x * other.x + self.y * other.y

    @always_inline
    def outer(self, other: Self) -> Self.Coef:
        # TODO: should return a bivector
        return self.x * other.y - self.y * other.x

    @always_inline
    def reger(self, other: Self) -> Self.Coef:
        return self.y * other.x - self.x * other.y

    # +------( Arithmetic )------+ #
    #
    @always_inline
    def __add__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, self.x, self.y, 0)

    @always_inline
    def __add__(self, other: Self) -> Self:
        return Self(self.x + other.x, self.y + other.y)

    @always_inline
    def __add__(self, other: Self.Roto) -> Self.Multi:
        return Self.Multi(other.s, self.x, self.y, other.i)

    @always_inline
    def __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, self.x + other.v.x, self.y + other.v.y, other.i)

    @always_inline
    def __sub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(-other, self.x, self.y, 0)

    @always_inline
    def __sub__(self, other: Self) -> Self:
        return Self(self.x - other.x, self.y - other.y)

    @always_inline
    def __sub__(self, other: Self.Roto) -> Self.Multi:
        return Self.Multi(-other.s, self.x, self.y, -other.i)

    @always_inline
    def __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, self.x - other.v.x, self.y - other.v.y, -other.i)

    @always_inline
    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.x * other, self.y * other)

    @always_inline
    def __mul__(self, other: Self) -> Self.Roto:
        return Self.Roto(
            self.x * other.x + self.y * other.y,
            self.x * other.y - self.y * other.x,
        )

    @always_inline
    def __mul__(self, other: Self.Roto) -> Self:
        return Self(
            self.x * other.s - self.y * other.i,
            self.y * other.s + self.x * other.i,
        )

    @always_inline
    def __mul__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(
            self.x * other.v.x + self.y * other.v.y,
            self.x * other.s - self.y * other.i,
            self.y * other.s + self.x * other.i,
            self.x * other.v.y - self.y * other.v.x,
        )

    @always_inline
    def __truediv__(self, other: Self.Coef) -> Self:
        return Self(self.x / other, self.y / other)

    @always_inline
    def __truediv__(self, other: Self.Roto) -> Self:
        return self * ~other

    @always_inline
    def __truediv__(self, other: Self) -> Self.Roto:
        return self * ~other

    @always_inline
    def __truediv__(self, other: Self.Multi) -> Self.Multi:
        return self * ~other

    # +------( Reverse Arithmetic )------+ #
    #
    @always_inline
    def __radd__(rhs, lhs: Self.Coef) -> Self.Multi:
        return Self.Multi(lhs, rhs, 0)

    @always_inline
    def __rsub__(rhs, lhs: Self.Coef) -> Self.Multi:
        return Self.Multi(lhs, -rhs, 0)

    @always_inline
    def __rmul__(rhs, lhs: Self.Coef) -> Self:
        return Self(lhs * rhs.x, lhs * rhs.y)

    @always_inline
    def __rtruediv__(rhs, lhs: Self.Coef) -> Self:
        return (lhs * rhs.coj()) / rhs.den()

    # +------( In-place Arithmetic )------+ #
    #
    @always_inline
    def __iadd__(mut self, other: Self):
        self = self + other

    @always_inline
    def __isub__(mut self, other: Self):
        self = self - other

    @always_inline
    def __imul__(mut self, other: Self.Coef):
        self = self * other

    @always_inline
    def __imul__(mut self, other: Self.Roto):
        self = self * other

    @always_inline
    def __itruediv__(mut self, other: Self.Coef):
        self = self / other

    @always_inline
    def __itruediv__(mut self, other: Self.Roto):
        self = self / other
