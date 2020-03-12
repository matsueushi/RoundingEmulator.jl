module RoundingEmulation

export twosum, add_up, add_down
export sub_up, sub_down
export twoprod, mul_up, mul_down

using Base: IEEEFloat

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

# Sum

function fast_twosum(a, b)
    x = a + b
    tmp = x - a
    x, b - tmp
end

twosum(a, b) = abs(a) > abs(b) ? fast_twosum(a, b) : fast_twosum(b, a)

# Product
function twoprod(a, b)
    x = a * b
    x, fma(a, b, -x)
end

# Rounding

# Add
function add_up(a::T, b::T) where T <:Union{Float32, Float64}
    x, y = twosum(a, b)
    if isfinite(x)
        y > zero(T) ? nextfloat(x) : x
    else
        x == typemin(T) && isfinite(a) && isfinite(b) ? -floatmax(T) : x
    end
end

function add_down(a::T, b::T) where T <:Union{Float32, Float64}
    x, y = twosum(a, b)
    if isfinite(x)
        if y < zero(T)
            prevfloat(x)
        else
            # y = 0 -> x = a + b
            # 1) x ≂̸ 0 => x
            # 2) x = 0, a = -b ≂̸ 0 => -0.0
            # 3) x = 0, a = b = 0
            #    (a, b) = (0.0, 0.0) => 0.0
            #    (a, b) = (-0.0, 0.0) => -0.0
            #    (a, b) = (-0.0, -0.0) => -0.0
            x == zero(T) && (signbit(a) || signbit(b)) ? -zero(T) : x
        end
    else
        x == typemax(T) && isfinite(a) && isfinite(b) ? floatmax(T) : x
    end
end

# Sub
sub_up(a::T, b::T) where T <:Union{Float32, Float64} = add_up(a, -b)
sub_down(a::T, b::T) where T <:Union{Float32, Float64} = add_down(a, -b)

# Mul
# const
for T in (Float32, Float64)
    # (minimal exponent) - (significand bits) + 2 * (significand bits) - 1 ?
    @eval _mul_th1_exponent(::Type{$T}) = $((2 -exponent_max(T)) + (Base.significand_bits(T) + 2) - 1)
    @eval _mul_th1(::Type{$T}) = $(ldexp(one(T), _mul_th1_exponent(T)))
    @eval _mul_th2_exponent(::Type{$T}) = $(-1 + (exponent_max(T) + Base.significand_bits(T)) ÷ 2)
    @eval _mul_th2(::Type{$T}) = $(ldexp(one(T), _mul_th2_exponent(T)))
end

function mul_up(a::T, b::T) where T <:Union{Float32, Float64} 
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = twoprod(a, b)
    if isfinite(x)
        if abs(x) > _mul_th1(T) # not zero(x): (a, b) = (-2.1634867667116802e-200, 1.6930929484402486e-119) fails
            y > zero(T) ? nextfloat(x) : x
        else
            mult = _mul_th2(T)
            s, s2 = twoprod(a * mult, b * mult)
            t = (x * mult) * mult
            t < s || (t == s && s2 > zero(T)) ? nextfloat(x) : x
        end
    else
        x == typemin(T) && isfinite(a) && isfinite(b) ? -floatmax(T) : x
    end
end

function mul_down(a::T, b::T) where T <:Union{Float32, Float64} 
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = twoprod(a, b)
    if isfinite(x)
        if abs(x) > _mul_th1(T) # not zero(x): (a, b) = (6.640350825165134e-116, -1.1053488936824272e-202) fails
            y < zero(T) ? prevfloat(x) : x
        else
            mult = _mul_th2(T)
            s, s2 = twoprod(a * mult, b * mult)
            t = (x * mult) * mult 
            t > s || (t == s && s2 < zero(T)) ? prevfloat(x) : x
        end
    else
        x == typemax(T) && isfinite(a) && isfinite(b) ? floatmax(T) : x
    end
end

end # module
