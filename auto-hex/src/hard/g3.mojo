# x----------------------------------------------------------------------------------------------x #
# | MIT License
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Defines a G3 Multivector, and it's subspaces.

Cl(3,0,0) ⇔ Mat2x2(C)

`x*x = y*y = z*z = 1`

`x*y = i`

`x*z = j`

`y*z = k`

`i*i = j*j = k*k = a*a = -1`
"""


# +----------------------------------------------------------------------------------------------+ #
# | G3 Multivector
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Multivector[type: DType = DType.float64, size: Int = 1](
    StringableCollectionElement, Writable, EqualityComparable
):
    """A G3 Multivector."""

    # +------[ Alias ]------+ #
    #
    alias Lane = Multivector[type, 1]

    alias Rotor = Rotor[type, size]
    alias Coef = SIMD[type, size]
    alias Vect = Vector[type, size]
    alias Bive = Bivector[type, size]
    alias Anti = Antiox[type, size]

    # +------< Data >------+ #
    #
    var s: Self.Coef
    var v: Self.Vect
    var b: Self.Bive
    var a: Self.Anti

    # +------( Initialize )------+ #
    #
    @implicit
    fn __init__(out self, none: None = None):
        self.s = 0
        self.v = None
        self.b = None
        self.a = None

    @implicit
    fn __init__(out self, scalar: Self.Coef):
        self.s = scalar
        self.v = None
        self.b = None
        self.a = None

    fn __init__(
        out self,
        s: Self.Coef,
        x: Self.Coef,
        y: Self.Coef,
        z: Self.Coef,
        i: Self.Coef,
        j: Self.Coef,
        k: Self.Coef,
        a: Self.Coef,
    ):
        self.s = s
        self.v = Self.Vect(x, y, z)
        self.b = Self.Bive(i, j, k)
        self.a = a

    fn __init__(out self, s: Self.Coef, v: Self.Vect, b: Self.Bive, a: Self.Anti):
        self.s = s
        self.v = v
        self.b = b
        self.a = a

    # +------( Subscript )------+ #
    #
    @always_inline
    fn get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(
            self.s[idx],
            self.v.x[idx],
            self.v.y[idx],
            self.v.z[idx],
            self.b.i[idx],
            self.b.j[idx],
            self.b.k[idx],
            self.a.a[idx],
        )

    @always_inline
    fn set_lane(mut self, idx: Int, value: Self.Lane):
        self.s[idx] = value.s
        self.v.x[idx] = value.v.x
        self.v.y[idx] = value.v.y
        self.v.z[idx] = value.v.z
        self.b.i[idx] = value.b.i
        self.b.j[idx] = value.b.j
        self.b.k[idx] = value.b.k
        self.a.a[idx] = value.a.a

    # +------( Cast )------+ #
    #
    @always_inline
    fn is_zero(self) -> SIMD[DType.bool, size]:
        return (self.s == 0) & self.v.is_zero() & self.b.is_zero() & self.a.is_zero()

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    fn write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        @parameter
        if size == 1:
            writer.write(
                self.s,
                " + ",
                self.v.x,
                "x + ",
                self.v.y,
                "y + ",
                self.v.z,
                "z + ",
                self.b.i,
                "i + ",
                self.b.j,
                "j + ",
                self.b.k,
                "k + ",
                self.a.a,
                "a",
            )
        else:

            @parameter
            for lane in range(size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    fn __eq__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.s == other.s) & (self.v == other.v) & (self.b == other.b) & (self.a == other.a)

    fn __eq__(self, other: Self.Rotor) -> SIMD[DType.bool, size]:
        return (
            (self.s == other.s)
            & (self.v == Self.Vect())
            & (self.b == other.b)
            & (self.a == Self.Anti())
        )

    fn __eq__(self, other: Self.Coef) -> SIMD[DType.bool, size]:
        return (
            (self.s == other)
            & (self.v == Self.Vect())
            & (self.b == Self.Bive())
            & (self.a == Self.Anti())
        )

    fn __eq__(self, other: Self.Vect) -> SIMD[DType.bool, size]:
        return (self.s == 0) & (self.v == other) & (self.b == Self.Bive()) & (self.a == Self.Anti())

    fn __eq__(self, other: Self.Bive) -> SIMD[DType.bool, size]:
        return (self.s == 0) & (self.v == Self.Vect()) & (self.b == other) & (self.a == Self.Anti())

    fn __eq__(self, other: Self.Anti) -> SIMD[DType.bool, size]:
        return (self.s == 0) & (self.v == Self.Vect()) & (self.b == Self.Bive()) & (self.a == other)

    fn __eq__[__: None = None](self, other: Self) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Rotor) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Coef) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Vect) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Bive) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Anti) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __ne__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.s != other.s) | (self.v != other.v) | (self.b != other.b) | (self.a != other.a)

    fn __ne__(self, other: Self.Rotor) -> SIMD[DType.bool, size]:
        return (
            (self.s != other.s)
            | (self.v != Self.Vect())
            | (self.b != other.b)
            | (self.a != Self.Anti())
        )

    fn __ne__(self, other: Self.Coef) -> SIMD[DType.bool, size]:
        return (
            (self.s != other)
            | (self.v != Self.Vect())
            | (self.b != Self.Bive())
            | (self.a != Self.Anti())
        )

    fn __ne__(self, other: Self.Vect) -> SIMD[DType.bool, size]:
        return (self.s != 0) | (self.v != other) | (self.b != Self.Bive()) | (self.a != Self.Anti())

    fn __ne__(self, other: Self.Bive) -> SIMD[DType.bool, size]:
        return (self.s != 0) | (self.v != Self.Vect()) | (self.b != other) | (self.a != Self.Anti())

    fn __ne__(self, other: Self.Anti) -> SIMD[DType.bool, size]:
        return (self.s != 0) | (self.v != Self.Vect()) | (self.b != Self.Bive()) | (self.a != other)

    fn __ne__[__: None = None](self, other: Self) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Rotor) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Coef) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Vect) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Bive) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Anti) -> Bool:
        return self.__ne__(other).reduce_or()

    # +------( Operations )------+ #
    #
    fn __neg__(self) -> Self:
        return Self(-self.s, -self.v, -self.b, -self.a)

    # +------( Arithmetic )------+ #
    #
    fn __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.v + other.v, self.b + other.b, self.a + other.a)

    fn __add__(self, other: Self.Rotor) -> Self:
        return Self(self.s + other.s, self.v, self.b + other.b, self.a)

    fn __add__(self, other: Self.Coef) -> Self:
        return Self(self.s + other, self.v, self.b, self.a)

    fn __add__(self, other: Self.Vect) -> Self:
        return Self(self.s, self.v + other, self.b, self.a)

    fn __add__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.v, self.b + other, self.a)

    fn __add__(self, other: Self.Anti) -> Self:
        return Self(self.s, self.v, self.b, self.a + other)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.s - other.s, self.v - other.v, self.b - other.b, self.a - other.a)

    fn __sub__(self, other: Self.Rotor) -> Self:
        return Self(self.s - other.s, self.v, self.b - other.b, self.a)

    fn __sub__(self, other: Self.Coef) -> Self:
        return Self(self.s - other, self.v, self.b, self.a)

    fn __sub__(self, other: Self.Vect) -> Self:
        return Self(self.s, self.v - other, self.b, self.a)

    fn __sub__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.v, self.b - other, self.a)

    fn __sub__(self, other: Self.Anti) -> Self:
        return Self(self.s, self.v, self.b, self.a - other)

    fn __mul__(self, other: Self) -> Self:
        return (
            +self.s * other.s
            + self.s * other.v
            + self.s * other.b
            + self.s * other.a
            + self.v * other.s
            + self.v * other.v
            + self.v * other.b
            + self.v * other.a
            + self.b * other.s
            + self.b * other.v
            + self.b * other.b
            + self.b * other.a
            + self.a * other.s
            + self.a * other.v
            + self.a * other.b
            + self.a * other.a
        )

    fn __mul__(self, other: Self.Rotor) -> Self:
        return (
            +self.s * other.s
            + self.s * other.b
            + self.v * other.s
            + self.v * other.b
            + self.b * other.s
            + self.b * other.b
            + self.a * other.s
            + self.a * other.b
        )

    fn __mul__(self, other: Self.Coef) -> Self:
        return Self(self.s * other, self.v * other, self.b * other, self.a * other)

    fn __mul__(self, other: Self.Vect) -> Self:
        return +self.s * other + self.v * other + self.b * other + self.a * other

    fn __mul__(self, other: Self.Bive) -> Self:
        return +self.s * other + self.v * other + self.b * other + self.a * other

    fn __mul__(self, other: Self.Anti) -> Self:
        return Self(self.a * other, self.b * other, self.v * other, self.s * other)

    # +------( Reverse Arithmetic )------+ #
    #
    fn __radd__(self, other: Self.Coef) -> Self:
        return Self(other + self.s, self.v, self.b, self.a)

    fn __rsub__(self, other: Self.Coef) -> Self:
        return Self(other - self.s, self.v, self.b, self.a)

    fn __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.s, other * self.v, other * self.b, other * self.a)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Rotor
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Rotor[type: DType = DType.float64, size: Int = 1](
    StringableCollectionElement, Writable, EqualityComparable
):
    """A G3 Rotor. The even sub-algebra of G3. Isomorphic with Quaternions."""

    # +------[ Alias ]------+ #
    #
    alias Lane = Rotor[type, 1]

    alias Multi = Multivector[type, size]
    alias Coef = SIMD[type, size]
    alias Vect = Vector[type, size]
    alias Bive = Bivector[type, size]
    alias Anti = Antiox[type, size]

    # +------< Data >------+ #
    #
    var s: Self.Coef
    var b: Self.Bive

    # +------( Initialize )------+ #
    #
    @implicit
    fn __init__(out self, none: None = None):
        self.s = 0
        self.b = None

    @implicit
    fn __init__(out self, scalar: Self.Coef):
        self.s = scalar
        self.b = None

    fn __init__(out self, s: Self.Coef, i: Self.Coef, j: Self.Coef, k: Self.Coef):
        self.s = s
        self.b = Self.Bive(i, j, k)

    fn __init__(out self, s: Self.Coef, b: Self.Bive):
        self.s = s
        self.b = b

    # +------( Subscript )------+ #
    #
    @always_inline
    fn get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.s[idx], self.b.i[idx], self.b.j[idx], self.b.k[idx])

    @always_inline
    fn set_lane(mut self, idx: Int, value: Self.Lane):
        self.s[idx] = value.s
        self.b.i[idx] = value.b.i
        self.b.j[idx] = value.b.j
        self.b.k[idx] = value.b.k

    # +------( Cast )------+ #
    #
    @always_inline
    fn is_zero(self) -> SIMD[DType.bool, size]:
        return (self.s == 0) & self.b.is_zero()

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    fn write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        @parameter
        if size == 1:
            writer.write(self.s, " + ", self.b.i, "i + ", self.b.j, "j + ", self.b.k, "k")
        else:

            @parameter
            for lane in range(size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    fn __eq__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other == self

    fn __eq__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.s == other.s) & (self.b == other.b)

    fn __eq__(self, other: Self.Coef) -> SIMD[DType.bool, size]:
        return (self.s == other) & (self.b == Self.Bive())

    fn __eq__(self, other: Self.Bive) -> SIMD[DType.bool, size]:
        return (self.s == 0) & (self.b == other)

    fn __eq__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Coef) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Bive) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __ne__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other != self

    fn __ne__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.s != other.s) | (self.b != other.b)

    fn __ne__(self, other: Self.Coef) -> SIMD[DType.bool, size]:
        return (self.s != other) | (self.b != Self.Bive())

    fn __ne__(self, other: Self.Bive) -> SIMD[DType.bool, size]:
        return (self.s != 0) | (self.b != other)

    fn __ne__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Coef) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Bive) -> Bool:
        return self.__ne__(other).reduce_or()

    # +------( Operations )------+ #
    #
    fn __neg__(self) -> Self:
        return Self(-self.s, -self.b)

    # +------( Arithmetic )------+ #
    #
    fn __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self.s + other.s, other.v, self.b + other.b, other.a)

    fn __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.b + other.b)

    fn __add__(self, other: Self.Coef) -> Self:
        return Self(self.s + other, self.b)

    fn __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(self.s, other, self.b, None)

    fn __add__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.b + other)

    fn __add__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(self.s, None, self.b, other)

    fn __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self.s - other.s, -other.v, self.b - other.b, -other.a)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.s - other.s, self.b - other.b)

    fn __sub__(self, other: Self.Coef) -> Self:
        return Self(self.s - other, self.b)

    fn __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(self.s, -other, self.b, None)

    fn __sub__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.b - other)

    fn __sub__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(self.s, None, self.b, -other)

    fn __mul__(self, other: Self.Multi) -> Self.Multi:
        return self.s * other + self.b * other

    fn __mul__(self, other: Self) -> Self:
        return self.s * other + self.b * other

    fn __mul__(self, other: Self.Vect) -> Self.Multi:
        return self.s * other + self.b * other

    fn __mul__(self, other: Self.Bive) -> Self:
        return self.s * other + self.b * other

    fn __mul__(self, other: Self.Anti) -> Self.Multi:
        return self.s * other + self.b * other

    fn __mul__(self, other: Self.Coef) -> Self:
        return Self(self.s * other, self.b * other)

    # +------( Reverse Arithmetic )------+ #
    #
    fn __radd__(self, other: Self.Coef) -> Self:
        return Self(other + self.s, self.b)

    fn __rsub__(self, other: Self.Coef) -> Self:
        return Self(other - self.s, self.b)

    fn __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.s, other * self.b)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Vector
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Vector[type: DType = DType.float64, size: Int = 1](
    StringableCollectionElement, Writable, EqualityComparable
):
    """A G3 Vector."""

    # +------[ Alias ]------+ #
    #
    alias Lane = Vector[type, 1]

    alias Multi = Multivector[type, size]
    alias Rotor = Rotor[type, size]
    alias Coef = SIMD[type, size]
    alias Bive = Bivector[type, size]
    alias Anti = Antiox[type, size]

    # +------< Data >------+ #
    #
    var x: Self.Coef
    var y: Self.Coef
    var z: Self.Coef

    # +------( Initialize )------+ #
    #
    @implicit
    fn __init__(out self, none: None = None):
        self.x = 0
        self.y = 0
        self.z = 0

    fn __init__(out self, x: Self.Coef, y: Self.Coef, z: Self.Coef):
        self.x = x
        self.y = y
        self.z = z

    # +------( Subscript )------+ #
    #
    @always_inline
    fn get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.x[idx], self.y[idx], self.z[idx])

    @always_inline
    fn set_lane(mut self, idx: Int, value: Self.Lane):
        self.x[idx] = value.x
        self.y[idx] = value.y
        self.z[idx] = value.z

    # +------( Cast )------+ #
    #
    @always_inline
    fn is_zero(self) -> SIMD[DType.bool, size]:
        return (self.x == 0) & (self.y == 0) & (self.z == 0)

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    fn write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        @parameter
        if size == 1:
            writer.write(self.x, "x + ", self.y, "y + ", self.z, "z")
        else:

            @parameter
            for lane in range(size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    fn __eq__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other == self

    fn __eq__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.x == other.x) & (self.y == other.y) & (self.z == other.z)

    fn __eq__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __ne__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other != self

    fn __ne__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.x != other.x) | (self.y != other.y) | (self.z != other.z)

    fn __ne__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self) -> Bool:
        return self.__ne__(other).reduce_or()

    # +------( Operations )------+ #
    #
    fn __neg__(self) -> Self:
        return Self(-self.x, -self.y, -self.z)

    # +------( Arithmetic )------+ #
    #
    fn __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, self + other.v, other.b, other.a)

    fn __add__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(other.s, self, other.b, None)

    fn __add__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, self, None, None)

    fn __add__(self, other: Self) -> Self:
        return Self(self.x + other.x, self.y + other.y, self.z + other.z)

    fn __add__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, self, other, None)

    fn __add__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, self, None, other)

    fn __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, self - other.v, -other.b, -other.a)

    fn __sub__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(-other.s, self, -other.b, None)

    fn __sub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(-other, self, None, None)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.x - other.x, self.y - other.y, self.z - other.z)

    fn __sub__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, self, -other, None)

    fn __sub__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, self, None, -other)

    fn __mul__(self, other: Self.Multi) -> Self.Multi:
        return self * other.s + self * other.v + self * other.b + self * other.a

    fn __mul__(self, other: Self.Rotor) -> Self.Multi:
        return self * other.s + self * other.b

    fn __mul__(self, other: Self.Coef) -> Self:
        return Self(self.x * other, self.y * other, self.z * other)

    fn __mul__(self, other: Self) -> Self.Rotor:
        return Self.Rotor(
            self.x * other.x + self.y * other.y + self.z * other.z,
            self.x * other.y - self.y * other.x,
            self.x * other.z - self.z * other.x,
            self.y * other.z - self.z * other.y,
        )

    fn __mul__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(
            0,
            Self(
                -self.y * other.i - self.z * other.j,
                +self.x * other.i - self.z * other.k,
                +self.x * other.j + self.y * other.k,
            ),
            None,
            self.x * other.k - self.y * other.j + self.z * other.i,
        )

    fn __mul__(self, other: Self.Anti) -> Self.Bive:
        return Self.Bive(self.z * other.a, -self.y * other.a, self.x * other.a)

    # +------( Reverse Arithmetic )------+ #
    #
    fn __radd__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, self, None, None)

    fn __rsub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, -self, None, None)

    fn __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.x, other * self.y, other * self.z)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Bivector
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Bivector[type: DType = DType.float64, size: Int = 1](
    StringableCollectionElement, Writable, EqualityComparable
):
    """A G3 Bivector."""

    # +------[ Alias ]------+ #
    #
    alias Lane = Bivector[type, 1]

    alias Multi = Multivector[type, size]
    alias Rotor = Rotor[type, size]
    alias Coef = SIMD[type, size]
    alias Vect = Vector[type, size]
    alias Anti = Antiox[type, size]

    # +------< Data >------+ #
    #
    var i: Self.Coef
    var j: Self.Coef
    var k: Self.Coef

    # +------( Initialize )------+ #
    #
    @implicit
    fn __init__(out self, none: None = None):
        self.i = 0
        self.j = 0
        self.k = 0

    fn __init__(out self, i: Self.Coef, j: Self.Coef, k: Self.Coef):
        self.i = i
        self.j = j
        self.k = k

    # +------( Subscript )------+ #
    #
    @always_inline
    fn get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.i[idx], self.j[idx], self.k[idx])

    @always_inline
    fn set_lane(mut self, idx: Int, value: Self.Lane):
        self.i[idx] = value.i
        self.j[idx] = value.j
        self.k[idx] = value.k

    # +------( Cast )------+ #
    #
    @always_inline
    fn is_zero(self) -> SIMD[DType.bool, size]:
        return (self.i == 0) & (self.j == 0) & (self.k == 0)

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    fn write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        @parameter
        if size == 1:
            writer.write(self.i, "i + ", self.j, "j + ", self.k, "k + ")
        else:

            @parameter
            for lane in range(size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    fn __eq__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other == self

    fn __eq__(self, other: Self.Rotor) -> SIMD[DType.bool, size]:
        return other == self

    fn __eq__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.i == other.i) & (self.j == other.j) & (self.k == other.k)

    fn __eq__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self.Rotor) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __ne__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other != self

    fn __ne__(self, other: Self.Rotor) -> SIMD[DType.bool, size]:
        return other != self

    fn __ne__(self, other: Self) -> SIMD[DType.bool, size]:
        return (self.i != other.i) | (self.j != other.j) | (self.k != other.k)

    fn __ne__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self.Rotor) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self) -> Bool:
        return self.__ne__(other).reduce_or()

    # +------( Operations )------+ #
    #
    fn __neg__(self) -> Self:
        return Self(-self.i, -self.j, -self.k)

    # +------( Arithmetic )------+ #
    #
    fn __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, other.v, self + other.b, other.a)

    fn __add__(self, other: Self.Rotor) -> Self.Rotor:
        return Self.Rotor(other.s, self + other.b)

    fn __add__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(other, self)

    fn __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, other, self, None)

    fn __add__(self, other: Self) -> Self:
        return Self(self.i + other.i, self.j + other.j, self.k + other.k)

    fn __add__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, None, self, other)

    fn __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, -other.v, self - other.b, -other.a)

    fn __sub__(self, other: Self.Rotor) -> Self.Rotor:
        return Self.Rotor(-other.s, self - other.b)

    fn __sub__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(-other, self)

    fn __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, -other, self, None)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.i - other.i, self.j - other.j, self.k - other.k)

    fn __sub__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, None, self, -other)

    fn __mul__(self, other: Self.Multi) -> Self.Multi:
        return self * other.s + self * other.v + self * other.b + self * other.a

    fn __mul__(self, other: Self.Rotor) -> Self.Rotor:
        return self * other.s + self * other.b

    fn __mul__(self, other: Self.Coef) -> Self:
        return Self(self.i * other, self.j * other, self.k * other)

    fn __mul__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(
            0,
            Self.Vect(
                self.i * other.y + self.j * other.z,
                -self.i * other.x + self.k * other.z,
                -self.j * other.x - self.k * other.y,
            ),
            None,
            self.i * other.z - self.j * other.y + self.k * other.x,
        )

    fn __mul__(self, other: Self) -> Self.Rotor:
        return Self.Rotor(
            -self.i * other.i - self.j * other.j - self.k * other.k,
            +self.k * other.j - self.j * other.k,
            +self.i * other.k - self.k * other.i,
            +self.j * other.i - self.i * other.j,
        )

    fn __mul__(self, other: Self.Anti) -> Self.Vect:
        return Self.Vect(-self.k * other.a, self.j * other.a, -self.i * other.a)

    # +------( Reverse Arithmetic )------+ #
    #
    fn __radd__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(other, self)

    fn __rsub__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(other, -self)

    fn __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.i, other * self.j, other * self.k)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Antiox
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Antiox[type: DType = DType.float64, size: Int = 1](
    StringableCollectionElement, Writable, EqualityComparable
):
    """A G3 Antiox."""

    # +------[ Alias ]------+ #
    #
    alias Lane = Antiox[type, 1]

    alias Multi = Multivector[type, size]
    alias Rotor = Rotor[type, size]
    alias Coef = SIMD[type, size]
    alias Vect = Vector[type, size]
    alias Bive = Bivector[type, size]

    # +------< Data >------+ #
    #
    var a: Self.Coef

    # +------( Initialize )------+ #
    #
    @implicit
    fn __init__(out self, none: None = None):
        self.a = 0

    @implicit
    fn __init__(out self, a: Self.Coef):
        self.a = a

    # fn __init__(out self, a: Tuple[Self.Coef]):
    #     self.a = a.get[0, Self.Coef]()

    # +------( Subscript )------+ #
    #
    @always_inline
    fn get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.a[idx])

    @always_inline
    fn set_lane(mut self, idx: Int, value: Self.Lane):
        self.a[idx] = value.a

    # +------( Cast )------+ #
    #
    @always_inline
    fn is_zero(self) -> SIMD[DType.bool, size]:
        return self.a == 0

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    fn write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        @parameter
        if size == 1:
            writer.write(self.a, "a")
        else:

            @parameter
            for lane in range(size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    fn __eq__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other == self

    fn __eq__(self, other: Self) -> SIMD[DType.bool, size]:
        return self.a == other.a

    fn __eq__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __eq__[__: None = None](self, other: Self) -> Bool:
        return self.__eq__(other).reduce_and()

    fn __ne__(self, other: Self.Multi) -> SIMD[DType.bool, size]:
        return other != self

    fn __ne__(self, other: Self) -> SIMD[DType.bool, size]:
        return self.a != other.a

    fn __ne__[__: None = None](self, other: Self.Multi) -> Bool:
        return self.__ne__(other).reduce_or()

    fn __ne__[__: None = None](self, other: Self) -> Bool:
        return self.__ne__(other).reduce_or()

    # +------( Operations )------+ #
    #
    fn __neg__(self) -> Self:
        return Self(-self.a)

    # +------( Arithmetic )------+ #
    #
    fn __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, other.v, other.b, self + other.a)

    fn __add__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(other.s, None, other.b, self)

    fn __add__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, None, None, self)

    fn __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, other, None, self)

    fn __add__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, None, other, self)

    fn __add__(self, other: Self) -> Self:
        return Self(self.a + other.a)

    fn __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, -other.v, -other.b, self - other.a)

    fn __sub__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(-other.s, None, -other.b, self)

    fn __sub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(-other, None, None, self)

    fn __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, -other, None, self)

    fn __sub__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, None, -other, self)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.a - other.a)

    fn __mul__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self * other.a, self * other.b, self * other.v, self * other.s)

    fn __mul__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(0, self * other.b, None, self * other.s)

    fn __mul__(self, other: Self.Coef) -> Self:
        return Self(self.a * other)

    fn __mul__(self, other: Self.Vect) -> Self.Bive:
        return Self.Bive(self.a * other.z, self.a * -other.y, self.a * other.x)

    fn __mul__(self, other: Self.Bive) -> Self.Vect:
        return Self.Vect(self.a * -other.k, self.a * other.j, self.a * -other.i)

    fn __mul__(self, other: Self) -> Self.Coef:
        return -self.a * other.a

    # +------( Reverse Arithmetic )------+ #
    #
    fn __radd__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, None, None, self)

    fn __rsub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, None, None, -self)

    fn __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.a)
