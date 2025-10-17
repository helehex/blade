# Blade ![Static Badge](https://img.shields.io/badge/build-0.1.0-orange) ![Static Badge](https://img.shields.io/badge/mojo-25.7.0.dev2025101605-red)
**Blade** is a geometric algebra library for Mojo 🔥

## Geometric Algebra
Geometric algebra is a mathematical abstraction over geometry. 
At it's core, blade uses something called a 'Multivector'. 
Multivectors are numeric types that represent geometric objects and transformations. 

With blade, you can generate the geometric product table for an arbitrary signature.

Multivectors are also parameterized on a basis masks, to avoid unnecessary overhead.

Example:

alias sig = Signature(2, 0, 1)
var m = Multivector[sig, sig.vector_mask()](0.0, 1.0, 2.0)
print(m * m)
blade has no dependecies other than max.

Developers can use blade as a mathematical abstraction over geometry (projective, conformal, spacetime, dimension-agnostic, etc.)

## Temporary Notes
Typically, the highest grade element is called the 'pseudoscalar'. I dont like typing or spelling that word.
I've called it the 'antiox' for now, but i'm open to something better. Maybe antireal or something.

## Contributing
I'm accepting contributions, but haven't made a contributors guide yet.

Some issues and areas of work include:

performance improvements, signature generation could use bitwise operations
examples and benchmarks

If you want to reach out, you can email me at helehex@gmail.com, or message me on discord (my alias is ghostfire)
