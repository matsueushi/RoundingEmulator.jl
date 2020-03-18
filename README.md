RoundingEmulation.jl
====================
Emulate directed rounding using only the default rounding mode. 

[![Build Status](https://travis-ci.org/matsueushi/RoundingEmulation.jl.svg?branch=master)](https://travis-ci.org/matsueushi/RoundingEmulation.jl)

This package is meant to produce the exact same results of `Rounding.setrounding` ([deprecated](https://github.com/JuliaLang/julia/pull/27166)) without switching rounding moddes.

## Requirements 
 - Julia 1.3 or higher
 - `Base.Rounding.get_zero_subnormals() == true`. (See [Base.Rounding.get_zero_subnormals](https://docs.julialang.org/en/v1/base/numbers/#Base.Rounding.get_zero_subnormals))

## Use

This package provides
* add_up, add_down - Addition
* sub_up, sub_down - Subtraction
* mul_up, mul_down - Multiplication
* div_up, div_down - Division
* sqrt_up, sqrt_down - Square root

`up`: Round up,
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

julia> div_up(1.0, 3.0)
0.33333333333333337

julia> bitstring(div_up(1.0, 3.0))
"0011111111010101010101010101010101010101010101010101010101010110"

julia> div_down(1.0, 3.0)
0.3333333333333333

julia> bitstring(div_down(1.0, 3.0))
"0011111111010101010101010101010101010101010101010101010101010101"

julia> sqrt_up(2.0)
1.4142135623730951

julia> bitstring(sqrt_up(2.0))
"0011111111110110101000001001111001100110011111110011101111001101"

julia> sqrt_down(2.0)
1.414213562373095

julia> bitstring(sqrt_down(2.0))
"0011111111110110101000001001111001100110011111110011101111001100"
```

## Corner cases
```julia
julia> u = nextfloat(zero(Float64))
5.0e-324

julia> v = floatmax(Float64)
1.7976931348623157e308

julia> v + v
Inf

julia> add_up(v, v)
Inf

julia> add_down(v, v)
1.7976931348623157e308

julia> u * u
0.0

julia> mul_up(u, u)
5.0e-324

julia> mul_down(u, u)
0.0

julia> 1.0 / u
Inf

julia> div_up(1.0, u)
Inf

julia> div_down(1.0, u)
1.7976931348623157e308
```

## Signed zero
```julia
julia> add_up(-1.0, 1.0)
0.0

julia> add_down(-1.0, 1.0)
-0.0

julia> add_up(-0.0, 0.0)
0.0

julia> add_down(-0.0, 0.0)
-0.0

julia> add_up(0.0, 0.0)
0.0

julia> add_down(0.0, 0.0)
0.0

julia> sqrt_up(-0.0)
-0.0

julia> sqrt_down(-0.0)
-0.0
```

## References
M. Kashiwagi, *Saikinten ni yoru houkou tsuki marume no emulate* [Emulation of Rounded Arithmeticin Rounding to Nearest], http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf, (2014.06)  
M. Kashiwagi, Error Free Transformation (EFT) is NOT error-free, http://verifiedby.me/adiary/09, (2014.01)

## Link
[kv - a C++ Library for Verified Numerical Computation](https://github.com/mskashi/kv)  
[FastRounding.jl](https://github.com/JeffreySarnoff/FastRounding.jl)