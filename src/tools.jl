if VERSION >= v"1.4"
    using Base: exponent_bias, exponent_max
else
    # The following definitions of exponent_bias and exopnent_max are taken from julia, base/float.jl. 
    # License is MIT: https://julialang.org/license
    for T in (Float32, Float64)
        @eval exponent_bias(::Type{$T}) = $(Int(Base.exponent_one(T) >> Base.significand_bits(T)))
        @eval exponent_max(::Type{$T}) = $(Int(Base.exponent_mask(T) >> Base.significand_bits(T)) - exponent_bias(T))
    end
end

for T in (Float32, Float64)
    @eval log2u(::Type{$T}) = $(2 - exponent_bias(T) - precision(T))
end

# Sum

function fast_twosum(a, b)
    x = a + b
    tmp = x - a
    x, b - tmp
end

twosum(a, b) = ifelse(abs(a) > abs(b), fast_twosum(a, b), fast_twosum(b, a))

# Product
function twoprod(a, b)
    x = a * b
    x, fma(a, b, -x)
end
