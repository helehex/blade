# +----------------------------------------------------------------------------------------------+ #
# | MIT License
# | Copyright (c) 2023-2025 Helehex
# +----------------------------------------------------------------------------------------------+ #
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
struct Multivector[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """A G3 Multivector."""

    # +------[ Alias ]------+ #
    #
    comptime Lane = Multivector[Self.type, 1]

    comptime Rotor = Rotor[Self.type, Self.size]
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Vect = Vector[Self.type, Self.size]
    comptime Bive = Bivector[Self.type, Self.size]
    comptime Anti = Antiox[Self.type, Self.size]

    # +------< Data >------+ #
    #
    var s: Self.Coef
    var v: Self.Vect
    var b: Self.Bive
    var a: Self.Anti

    # +------( Initialize )------+ #
    #
    @implicit
    def __init__(out self, none: None = None):
        self.s = 0
        self.v = None
        self.b = None
        self.a = None

    @implicit
    def __init__(out self, scalar: Self.Coef):
        self.s = scalar
        self.v = None
        self.b = None
        self.a = None

    def __init__(
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

    def __init__(out self, s: Self.Coef, v: Self.Vect, b: Self.Bive, a: Self.Anti):
        self.s = s
        self.v = v
        self.b = b
        self.a = a

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, idx: Int) -> Self.Lane:
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
    def set_lane(mut self, idx: Int, value: Self.Lane):
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
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.s == 0) & self.v.is_zero() & self.b.is_zero() & self.a.is_zero()

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.s, " + ", self.v.x, "x + ", self.v.y, "y + ", self.v.z, "z + ", self.b.i, "i + ", self.b.j, "j + ", self.b.k, "k + ", self.a.a, "a")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other.s)) & (self.v.eq(other.v)) & (self.b.eq(other.b)) & (self.a.eq(other.a))

    def eq(self, other: Self.Rotor) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other.s)) & (self.v.eq(Self.Vect())) & (self.b.eq(other.b)) & (self.a.eq(Self.Anti()))

    def eq(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other)) & (self.v.eq(Self.Vect())) & (self.b.eq(Self.Bive())) & (self.a.eq(Self.Anti()))

    def eq(self, other: Self.Vect) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(0)) & (self.v.eq(other)) & (self.b.eq(Self.Bive())) & (self.a.eq(Self.Anti()))

    def eq(self, other: Self.Bive) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(0)) & (self.v.eq(Self.Vect())) & (self.b.eq(other)) & (self.a.eq(Self.Anti()))

    def eq(self, other: Self.Anti) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(0)) & (self.v.eq(Self.Vect())) & (self.b.eq(Self.Bive())) & (self.a.eq(other))

    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Rotor) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Coef) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Vect) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Bive) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Anti) -> Bool:
        return all(self.eq(other))

    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other.s)) | (self.v.ne(other.v)) | (self.b.ne(other.b)) | (self.a.ne(other.a))

    def ne(self, other: Self.Rotor) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other.s)) | (self.v.ne(Self.Vect())) | (self.b.ne(other.b)) | (self.a.ne(Self.Anti()))

    def ne(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other)) | (self.v.ne(Self.Vect())) | (self.b.ne(Self.Bive())) | (self.a.ne(Self.Anti()))

    def ne(self, other: Self.Vect) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(0)) | (self.v.ne(other)) | (self.b.ne(Self.Bive())) | (self.a.ne(Self.Anti()))

    def ne(self, other: Self.Bive) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(0)) | (self.v.ne(Self.Vect())) | (self.b.ne(other)) | (self.a.ne(Self.Anti()))

    def ne(self, other: Self.Anti) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(0)) | (self.v.ne(Self.Vect())) | (self.b.ne(Self.Bive())) | (self.a.ne(other))

    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Rotor) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Coef) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Vect) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Bive) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Anti) -> Bool:
        return any(self.ne(other))

    # +------( Operations )------+ #
    #
    def __neg__(self) -> Self:
        return Self(-self.s, -self.v, -self.b, -self.a)

    # +------( Arithmetic )------+ #
    #
    def __add__(self, other: Self) -> Self:
        return Self(
            self.s + other.s,
            self.v + other.v,
            self.b + other.b,
            self.a + other.a,
        )

    def __add__(self, other: Self.Rotor) -> Self:
        return Self(self.s + other.s, self.v, self.b + other.b, self.a)

    def __add__(self, other: Self.Coef) -> Self:
        return Self(self.s + other, self.v, self.b, self.a)

    def __add__(self, other: Self.Vect) -> Self:
        return Self(self.s, self.v + other, self.b, self.a)

    def __add__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.v, self.b + other, self.a)

    def __add__(self, other: Self.Anti) -> Self:
        return Self(self.s, self.v, self.b, self.a + other)

    def __sub__(self, other: Self) -> Self:
        return Self(
            self.s - other.s,
            self.v - other.v,
            self.b - other.b,
            self.a - other.a,
        )

    def __sub__(self, other: Self.Rotor) -> Self:
        return Self(self.s - other.s, self.v, self.b - other.b, self.a)

    def __sub__(self, other: Self.Coef) -> Self:
        return Self(self.s - other, self.v, self.b, self.a)

    def __sub__(self, other: Self.Vect) -> Self:
        return Self(self.s, self.v - other, self.b, self.a)

    def __sub__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.v, self.b - other, self.a)

    def __sub__(self, other: Self.Anti) -> Self:
        return Self(self.s, self.v, self.b, self.a - other)

    def __mul__(self, other: Self) -> Self:
        return +self.s * other.s + self.s * other.v + self.s * other.b + self.s * other.a + self.v * other.s + self.v * other.v + self.v * other.b + self.v * other.a + self.b * other.s + self.b * other.v + self.b * other.b + self.b * other.a + self.a * other.s + self.a * other.v + self.a * other.b + self.a * other.a

    def __mul__(self, other: Self.Rotor) -> Self:
        return +self.s * other.s + self.s * other.b + self.v * other.s + self.v * other.b + self.b * other.s + self.b * other.b + self.a * other.s + self.a * other.b

    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.s * other, self.v * other, self.b * other, self.a * other)

    def __mul__(self, other: Self.Vect) -> Self:
        return +self.s * other + self.v * other + self.b * other + self.a * other

    def __mul__(self, other: Self.Bive) -> Self:
        return +self.s * other + self.v * other + self.b * other + self.a * other

    def __mul__(self, other: Self.Anti) -> Self:
        return Self(self.a * other, self.b * other, self.v * other, self.s * other)

    # +------( Reverse Arithmetic )------+ #
    #
    def __radd__(self, other: Self.Coef) -> Self:
        return Self(other + self.s, self.v, self.b, self.a)

    def __rsub__(self, other: Self.Coef) -> Self:
        return Self(other - self.s, self.v, self.b, self.a)

    def __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.s, other * self.v, other * self.b, other * self.a)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Rotor
# +----------------------------------------------------------------------------------------------+ #
#
struct Rotor[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """A G3 Rotor. The even sub-algebra of G3. Isomorphic with Quaternions."""

    # +------[ Alias ]------+ #
    #
    comptime Lane = Rotor[Self.type, 1]

    comptime Multi = Multivector[Self.type, Self.size]
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Vect = Vector[Self.type, Self.size]
    comptime Bive = Bivector[Self.type, Self.size]
    comptime Anti = Antiox[Self.type, Self.size]

    # +------< Data >------+ #
    #
    var s: Self.Coef
    var b: Self.Bive

    # +------( Initialize )------+ #
    #
    @implicit
    def __init__(out self, none: None = None):
        self.s = 0
        self.b = None

    @implicit
    def __init__(out self, scalar: Self.Coef):
        self.s = scalar
        self.b = None

    def __init__(out self, s: Self.Coef, i: Self.Coef, j: Self.Coef, k: Self.Coef):
        self.s = s
        self.b = Self.Bive(i, j, k)

    def __init__(out self, s: Self.Coef, b: Self.Bive):
        self.s = s
        self.b = b

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.s[idx], self.b.i[idx], self.b.j[idx], self.b.k[idx])

    @always_inline
    def set_lane(mut self, idx: Int, value: Self.Lane):
        self.s[idx] = value.s
        self.b.i[idx] = value.b.i
        self.b.j[idx] = value.b.j
        self.b.k[idx] = value.b.k

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
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.s == 0) & self.b.is_zero()

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.s, " + ", self.b.i, "i + ", self.b.j, "j + ", self.b.k, "k")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    def eq(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other.s)) & (self.b.eq(other.b))

    def eq(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(other)) & (self.b.eq(Self.Bive()))

    def eq(self, other: Self.Bive) -> SIMD[DType.bool, Self.size]:
        return (self.s.eq(0)) & (self.b.eq(other))

    def __eq__(self, other: Self.Multi) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Coef) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Bive) -> Bool:
        return all(self.eq(other))

    def ne(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other.s)) | (self.b.ne(other.b))

    def ne(self, other: Self.Coef) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(other)) | (self.b.ne(Self.Bive()))

    def ne(self, other: Self.Bive) -> SIMD[DType.bool, Self.size]:
        return (self.s.ne(0)) | (self.b.ne(other))

    def __ne__(self, other: Self.Multi) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Coef) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Bive) -> Bool:
        return any(self.ne(other))

    # +------( Operations )------+ #
    #
    def __neg__(self) -> Self:
        return Self(-self.s, -self.b)

    # +------( Arithmetic )------+ #
    #
    def __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self.s + other.s, other.v, self.b + other.b, other.a)

    def __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.b + other.b)

    def __add__(self, other: Self.Coef) -> Self:
        return Self(self.s + other, self.b)

    def __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(self.s, other, self.b, None)

    def __add__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.b + other)

    def __add__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(self.s, None, self.b, other)

    def __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self.s - other.s, -other.v, self.b - other.b, -other.a)

    def __sub__(self, other: Self) -> Self:
        return Self(self.s - other.s, self.b - other.b)

    def __sub__(self, other: Self.Coef) -> Self:
        return Self(self.s - other, self.b)

    def __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(self.s, -other, self.b, None)

    def __sub__(self, other: Self.Bive) -> Self:
        return Self(self.s, self.b - other)

    def __sub__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(self.s, None, self.b, -other)

    def __mul__(self, other: Self.Multi) -> Self.Multi:
        return self.s * other + self.b * other

    def __mul__(self, other: Self) -> Self:
        return self.s * other + self.b * other

    def __mul__(self, other: Self.Vect) -> Self.Multi:
        return self.s * other + self.b * other

    def __mul__(self, other: Self.Bive) -> Self:
        return self.s * other + self.b * other

    def __mul__(self, other: Self.Anti) -> Self.Multi:
        return self.s * other + self.b * other

    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.s * other, self.b * other)

    # +------( Reverse Arithmetic )------+ #
    #
    def __radd__(self, other: Self.Coef) -> Self:
        return Self(other + self.s, self.b)

    def __rsub__(self, other: Self.Coef) -> Self:
        return Self(other - self.s, self.b)

    def __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.s, other * self.b)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Vector
# +----------------------------------------------------------------------------------------------+ #
#
struct Vector[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """A G3 Vector."""

    # +------[ Alias ]------+ #
    #
    comptime Lane = Vector[Self.type, 1]

    comptime Multi = Multivector[Self.type, Self.size]
    comptime Rotor = Rotor[Self.type, Self.size]
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Bive = Bivector[Self.type, Self.size]
    comptime Anti = Antiox[Self.type, Self.size]

    # +------< Data >------+ #
    #
    var x: Self.Coef
    var y: Self.Coef
    var z: Self.Coef

    # +------( Initialize )------+ #
    #
    @implicit
    def __init__(out self, none: None = None):
        self.x = 0
        self.y = 0
        self.z = 0

    def __init__(out self, x: Self.Coef, y: Self.Coef, z: Self.Coef):
        self.x = x
        self.y = y
        self.z = z

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.x[idx], self.y[idx], self.z[idx])

    @always_inline
    def set_lane(mut self, idx: Int, value: Self.Lane):
        self.x[idx] = value.x
        self.y[idx] = value.y
        self.z[idx] = value.z

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
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.x == 0) & (self.y == 0) & (self.z == 0)

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.x, "x + ", self.y, "y + ", self.z, "z")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    def eq(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.x.eq(other.x)) & (self.y.eq(other.y)) & (self.z.eq(other.z))

    def __eq__(self, other: Self.Multi) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    def ne(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.x.ne(other.x)) | (self.y.ne(other.y)) | (self.z.ne(other.z))

    def __ne__(self, other: Self.Multi) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    # +------( Operations )------+ #
    #
    def __neg__(self) -> Self:
        return Self(-self.x, -self.y, -self.z)

    # +------( Arithmetic )------+ #
    #
    def __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, self + other.v, other.b, other.a)

    def __add__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(other.s, self, other.b, None)

    def __add__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, self, None, None)

    def __add__(self, other: Self) -> Self:
        return Self(self.x + other.x, self.y + other.y, self.z + other.z)

    def __add__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, self, other, None)

    def __add__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, self, None, other)

    def __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, self - other.v, -other.b, -other.a)

    def __sub__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(-other.s, self, -other.b, None)

    def __sub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(-other, self, None, None)

    def __sub__(self, other: Self) -> Self:
        return Self(self.x - other.x, self.y - other.y, self.z - other.z)

    def __sub__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, self, -other, None)

    def __sub__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, self, None, -other)

    def __mul__(self, other: Self.Multi) -> Self.Multi:
        return self * other.s + self * other.v + self * other.b + self * other.a

    def __mul__(self, other: Self.Rotor) -> Self.Multi:
        return self * other.s + self * other.b

    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.x * other, self.y * other, self.z * other)

    def __mul__(self, other: Self) -> Self.Rotor:
        return Self.Rotor(
            self.x * other.x + self.y * other.y + self.z * other.z,
            self.x * other.y - self.y * other.x,
            self.x * other.z - self.z * other.x,
            self.y * other.z - self.z * other.y,
        )

    def __mul__(self, other: Self.Bive) -> Self.Multi:
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

    def __mul__(self, other: Self.Anti) -> Self.Bive:
        return Self.Bive(self.z * other.a, -self.y * other.a, self.x * other.a)

    # +------( Reverse Arithmetic )------+ #
    #
    def __radd__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, self, None, None)

    def __rsub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, -self, None, None)

    def __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.x, other * self.y, other * self.z)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Bivector
# +----------------------------------------------------------------------------------------------+ #
#
struct Bivector[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """A G3 Bivector."""

    # +------[ Alias ]------+ #
    #
    comptime Lane = Bivector[Self.type, 1]

    comptime Multi = Multivector[Self.type, Self.size]
    comptime Rotor = Rotor[Self.type, Self.size]
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Vect = Vector[Self.type, Self.size]
    comptime Anti = Antiox[Self.type, Self.size]

    # +------< Data >------+ #
    #
    var i: Self.Coef
    var j: Self.Coef
    var k: Self.Coef

    # +------( Initialize )------+ #
    #
    @implicit
    def __init__(out self, none: None = None):
        self.i = 0
        self.j = 0
        self.k = 0

    def __init__(out self, i: Self.Coef, j: Self.Coef, k: Self.Coef):
        self.i = i
        self.j = j
        self.k = k

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.i[idx], self.j[idx], self.k[idx])

    @always_inline
    def set_lane(mut self, idx: Int, value: Self.Lane):
        self.i[idx] = value.i
        self.j[idx] = value.j
        self.k[idx] = value.k

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
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return (self.i == 0) & (self.j == 0) & (self.k == 0)

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.i, "i + ", self.j, "j + ", self.k, "k + ")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    def eq(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    def eq(self, other: Self.Rotor) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.i.eq(other.i)) & (self.j.eq(other.j)) & (self.k.eq(other.k))

    def __eq__(self, other: Self.Multi) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self.Rotor) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    def ne(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    def ne(self, other: Self.Rotor) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return (self.i.ne(other.i)) | (self.j.ne(other.j)) | (self.k.ne(other.k))

    def __ne__(self, other: Self.Multi) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self.Rotor) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    # +------( Operations )------+ #
    #
    def __neg__(self) -> Self:
        return Self(-self.i, -self.j, -self.k)

    # +------( Arithmetic )------+ #
    #
    def __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, other.v, self + other.b, other.a)

    def __add__(self, other: Self.Rotor) -> Self.Rotor:
        return Self.Rotor(other.s, self + other.b)

    def __add__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(other, self)

    def __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, other, self, None)

    def __add__(self, other: Self) -> Self:
        return Self(self.i + other.i, self.j + other.j, self.k + other.k)

    def __add__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, None, self, other)

    def __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, -other.v, self - other.b, -other.a)

    def __sub__(self, other: Self.Rotor) -> Self.Rotor:
        return Self.Rotor(-other.s, self - other.b)

    def __sub__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(-other, self)

    def __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, -other, self, None)

    def __sub__(self, other: Self) -> Self:
        return Self(self.i - other.i, self.j - other.j, self.k - other.k)

    def __sub__(self, other: Self.Anti) -> Self.Multi:
        return Self.Multi(0, None, self, -other)

    def __mul__(self, other: Self.Multi) -> Self.Multi:
        return self * other.s + self * other.v + self * other.b + self * other.a

    def __mul__(self, other: Self.Rotor) -> Self.Rotor:
        return self * other.s + self * other.b

    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.i * other, self.j * other, self.k * other)

    def __mul__(self, other: Self.Vect) -> Self.Multi:
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

    def __mul__(self, other: Self) -> Self.Rotor:
        return Self.Rotor(
            -self.i * other.i - self.j * other.j - self.k * other.k,
            +self.k * other.j - self.j * other.k,
            +self.i * other.k - self.k * other.i,
            +self.j * other.i - self.i * other.j,
        )

    def __mul__(self, other: Self.Anti) -> Self.Vect:
        return Self.Vect(-self.k * other.a, self.j * other.a, -self.i * other.a)

    # +------( Reverse Arithmetic )------+ #
    #
    def __radd__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(other, self)

    def __rsub__(self, other: Self.Coef) -> Self.Rotor:
        return Self.Rotor(other, -self)

    def __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.i, other * self.j, other * self.k)


# +----------------------------------------------------------------------------------------------+ #
# | G3 Antiox
# +----------------------------------------------------------------------------------------------+ #
#
struct Antiox[type: DType = DType.float64, size: Int = 1](Equatable, Movable, TrivialRegisterPassable, Writable):
    """A G3 Antiox."""

    # +------[ Alias ]------+ #
    #
    comptime Lane = Antiox[Self.type, 1]

    comptime Multi = Multivector[Self.type, Self.size]
    comptime Rotor = Rotor[Self.type, Self.size]
    comptime Coef = SIMD[Self.type, Self.size]
    comptime Vect = Vector[Self.type, Self.size]
    comptime Bive = Bivector[Self.type, Self.size]

    # +------< Data >------+ #
    #
    var a: Self.Coef

    # +------( Initialize )------+ #
    #
    @implicit
    def __init__(out self, none: None = None):
        self.a = 0

    @implicit
    def __init__(out self, a: Self.Coef):
        self.a = a

    # def __init__(out self, a: Tuple[Self.Coef]):
    #     self.a = a.get[0, Self.Coef]()

    # +------( Subscript )------+ #
    #
    @always_inline
    def get_lane(self, idx: Int) -> Self.Lane:
        return Self.Lane(self.a[idx])

    @always_inline
    def set_lane(mut self, idx: Int, value: Self.Lane):
        self.a[idx] = value.a

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
    def is_zero(self) -> SIMD[DType.bool, Self.size]:
        return self.a == 0

    # +------( Format )------+ #
    #
    @no_inline
    def __str__(self) -> String:
        return String(self)

    @no_inline
    def write_to[WriterType: Writer, //](self, mut writer: WriterType):
        self.write_to[sep="\n"](writer)

    @no_inline
    def write_to[WriterType: Writer, //, sep: StringLiteral](self, mut writer: WriterType):
        comptime if Self.size == 1:
            writer.write(self.a, "a")
        else:
            comptime for lane in range(Self.size - 1):
                self.get_lane(lane).write_to(writer)
                writer.write(sep)
            self.get_lane(Self.size - 1).write_to(writer)

    # +------( Comparison )------+ #
    #
    def eq(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.eq(self)

    def eq(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return self.a.eq(other.a)

    def __eq__(self, other: Self.Multi) -> Bool:
        return all(self.eq(other))

    def __eq__(self, other: Self) -> Bool:
        return all(self.eq(other))

    def ne(self, other: Self.Multi) -> SIMD[DType.bool, Self.size]:
        return other.ne(self)

    def ne(self, other: Self) -> SIMD[DType.bool, Self.size]:
        return self.a.ne(other.a)

    def __ne__(self, other: Self.Multi) -> Bool:
        return any(self.ne(other))

    def __ne__(self, other: Self) -> Bool:
        return any(self.ne(other))

    # +------( Operations )------+ #
    #
    def __neg__(self) -> Self:
        return Self(-self.a)

    # +------( Arithmetic )------+ #
    #
    def __add__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(other.s, other.v, other.b, self + other.a)

    def __add__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(other.s, None, other.b, self)

    def __add__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, None, None, self)

    def __add__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, other, None, self)

    def __add__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, None, other, self)

    def __add__(self, other: Self) -> Self:
        return Self(self.a + other.a)

    def __sub__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(-other.s, -other.v, -other.b, self - other.a)

    def __sub__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(-other.s, None, -other.b, self)

    def __sub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(-other, None, None, self)

    def __sub__(self, other: Self.Vect) -> Self.Multi:
        return Self.Multi(0, -other, None, self)

    def __sub__(self, other: Self.Bive) -> Self.Multi:
        return Self.Multi(0, None, -other, self)

    def __sub__(self, other: Self) -> Self:
        return Self(self.a - other.a)

    def __mul__(self, other: Self.Multi) -> Self.Multi:
        return Self.Multi(self * other.a, self * other.b, self * other.v, self * other.s)

    def __mul__(self, other: Self.Rotor) -> Self.Multi:
        return Self.Multi(0, self * other.b, None, self * other.s)

    def __mul__(self, other: Self.Coef) -> Self:
        return Self(self.a * other)

    def __mul__(self, other: Self.Vect) -> Self.Bive:
        return Self.Bive(self.a * other.z, self.a * -other.y, self.a * other.x)

    def __mul__(self, other: Self.Bive) -> Self.Vect:
        return Self.Vect(self.a * -other.k, self.a * other.j, self.a * -other.i)

    def __mul__(self, other: Self) -> Self.Coef:
        return -self.a * other.a

    # +------( Reverse Arithmetic )------+ #
    #
    def __radd__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, None, None, self)

    def __rsub__(self, other: Self.Coef) -> Self.Multi:
        return Self.Multi(other, None, None, -self)

    def __rmul__(self, other: Self.Coef) -> Self:
        return Self(other * self.a)
