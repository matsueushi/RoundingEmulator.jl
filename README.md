RoundingEmulation.jl
====================
[![Build Status](https://travis-ci.org/matsueushi/RoundingEmulation.jl.svg?branch=master)](https://travis-ci.org/matsueushi/RoundingEmulation.jl)

Emulate directed rounding using only the default rounding mode.

## Use

This package provides
* add_up, add_down - Addition
* sub_up, sub_down - Subtraction
* mul_up, mul_down - Multiprication
* div_up, div_down - Division
* sqrt_up, sqrt_down - Square root

`up`: Round up
`down`: Round down

```julia
julia> using RoundingEmulation

julia> add_up(0.1, 0.2)
0.30000000000000004

julia> bitstring(add_up(0.1, 0.2))
"0011111111010011001100110011001100110011001100110011001100110100"

julia> add_down(0.1, 0.2)
0.3

julia> bitstring(add_down(0.1, 0.2))
"0011111111010011001100110011001100110011001100110011001100110011"

julia> sub_up(-0.1, 0.2)
-0.3

julia> bitstring(sub_up(-0.1, 0.2))
"1011111111010011001100110011001100110011001100110011001100110011"

julia> sub_down(-0.1, 0.2)
-0.30000000000000004

julia> bitstring(sub_down(-0.1, 0.2))
"1011111111010011001100110011001100110011001100110011001100110100"

julia> mul_up(0.1, 0.2)
0.020000000000000004

julia> bitstring(mul_up(0.1, 0.2))
"0011111110010100011110101110000101000111101011100001010001111100"

julia> mul_down(0.1, 0.2)
0.02

julia> bitstring(mul_down(0.1, 0.2))
"0011111110010100011110101110000101000111101011100001010001111011"

julia> sqrt_up(2.0)
1.4142135623730951

julia> bitstring(sqrt_up(2.0))
"0011111111110110101000001001111001100110011111110011101111001101"

julia> sqrt_down(2.0)
1.414213562373095

julia> bitstring(sqrt_down(2.0))
"0011111111110110101000001001111001100110011111110011101111001100"
```

## Signed zero
```julia
julia> add_down(-1.0, 1.0)
-0.0

julia> add_down(-0.0, 0.0)
-0.0

julia> add_down(0.0, 0.0)
0.0
```

## References
M. Kashiwagi, *Saikinten ni yoru houkou tsuki marume no emulate* [Emulation of Rounded Arithmeticin Rounding to Nearest], http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf, (2014.06)  
M. Kashiwagi, Error Free Transformation (EFT) is NOT error-free, http://verifiedby.me/adiary/09, (2014.01)

## Link
[kv - a C++ Library for Verified Numerical Computation](https://github.com/mskashi/kv)  
[FastRounding.jl](https://github.com/JeffreySarnoff/FastRounding.jl)