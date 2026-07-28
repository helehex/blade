# Blade ![Static Badge](https://img.shields.io/badge/build-0.1.0-orange) ![Static Badge](https://img.shields.io/badge/mojo-1.0.0b3.dev2026072706-red)
**Blade** is a geometric algebra library for Mojo 🔥

## Geometric Algebra
Geometric algebra is a mathematical abstraction over geometry.
At it's core, it uses something called a 'Multivector'.
A multivector represents geometric objects and transformations.

With blade, you can generate the geometric product table for an arbitrary signature,
Allowing geometric abstractions for arbitrary dimensions.

Multivectors are also parameterized on a basis masks, to avoid unnecessary operations.

Example:
```mojo
comptime sig = Signature(2, 0, 1)
var m = Multivector[sig, sig.vector_mask()](0.0, 1.0, 2.0)
print(m * m)

```
blade has no dependecies other than mojo.
Developers can use blade as a mathematical abstraction over geometry (projective, conformal, spacetime, dimension-agnostic, etc.)

## Contributing
I welcome contributions.

If you have any questions, or if you just want to talk, feel free to email me at helehex@gmail.com
