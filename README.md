# Blade 

![Static Badge](https://img.shields.io/badge/build-0.1.0-orange)
![Static Badge](https://img.shields.io/badge/mojo-1.0.0b3.dev2026080400-red)

**Blade** is a geometric algebra library for **Mojo** 🔥.

It generates efficient geometric algebras from arbitrary signatures, enabling expressive, type-safe representations of geometry in any dimension.


## What is Geometric Algebra?

Geometric algebra (GA) is a mathematical framework that unifies vectors, complex numbers, quaternions, rotations, reflections, and many other geometric concepts into a single algebraic system.

The fundamental type in GA is the **multivector**, which can represent:

- Scalars
- Vectors
- Lines and planes
- Rotations and reflections
- Higher-dimensional geometric objects

Blade generates the **geometric product** from a given signature, allowing the same API to work across Euclidean, projective, conformal, spacetime, and custom algebras.


## Signatures

A geometric algebra is defined by its **signature**:

```mojo
ga(p, n, z)
```

where:

- `p` = number of basis vectors that square to `+1`
- `n` = number of basis vectors that square to `-1`
- `z` = number of basis vectors that square to `0`


For example, blade contains `Complex`, which is an alias of the signature `ga(0, 1, 0)`:

```mojo
from blade import Complex

var z = 1 + Complex.i
print(z * z)

# prints: 0 + 2e1
```

Here, `e1` is the algebra's only basis vector, acting as the imaginary unit `i`.


## Multivectors

Every multivector is parameterized by both:

- its algebra signature
- a compile-time basis mask

The basis mask allows Blade to eliminate unnecessary storage and arithmetic, producing smaller and more efficient operations.

```mojo
comptime sig = Signature(2, 0, 1)
comptime Vector = Multivector[sig, sig.vector_mask()]

var v = Vector(1.0, 2.0, 1.0)

print(v * v)
```

You can also import `ga`, which makes multivector construction implicit, allowing things like:

```mojo
comptime GA = ga(3, 0, 0)

var v = 2*GA.e1 + 5*GA.e2 + 3*GA.e3
var b = 2*GA.e12 + 2*GA.e13 + 2*GA.e23
```

## Contributing

Contributions are welcome!

If you find a bug, have an idea, or want to discuss geometric algebra or Blade, feel free to open an issue or email:

**helehex@gmail.com**
