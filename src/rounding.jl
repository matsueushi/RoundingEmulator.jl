# Add
function add_up(a::T, b::T) where T<:FloatTypes
    x, y = Base.add12(a, b) # twosum
    if isfinite(x)
        y > zero(T) ? nextfloat(x) : x
    else
        ifelse(x == typemin(T) && isfinite(a) && isfinite(b), -floatmax(T), x)
    end
end

function add_down(a::T, b::T) where T<:FloatTypes
    x, y = Base.add12(a, b) # twosum
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
            ifelse(x == zero(T) && (signbit(a) || signbit(b)), -zero(T), x)
        end
    else
        ifelse(x == typemax(T) && isfinite(a) && isfinite(b), floatmax(T), x)
    end
end

# Sub
sub_up(a::T, b::T) where T<:FloatTypes = add_up(a, -b)
sub_down(a::T, b::T) where T<:FloatTypes = add_down(a, -b)

# Mul
# const
for T in (Float32, Float64)
    # http://verifiedby.me/adiary/09
    @eval c_m1(::Type{$T}) = $(exp2(T(log2u(T) + 2 * precision(T) + 1)))
    @eval c_m2(::Type{$T}) = $(exp2(T(ceil(Int, -log2u(T)//2))))
end

function mul_up(a::T, b::T) where T<:FloatTypes
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = Base.mul12(a, b)
    if isfinite(x)
        if abs(x) > c_m1(T) # not zero(x): (a, b) = (-2.1634867667116802e-200, 1.6930929484402486e-119) fails
            y > zero(T) ? nextfloat(x) : x
        else
            mult = c_m2(T)
            s, s2 = Base.mul12(a * mult, b * mult)
            t = (x * mult) * mult
            t < s || (t == s && s2 > zero(T)) ? nextfloat(x) : x
        end
    else
        ifelse(x == typemin(T) && isfinite(a) && isfinite(b), -floatmax(T), x)
    end
end

function mul_down(a::T, b::T) where T<:FloatTypes
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = Base.mul12(a, b)
    if isfinite(x)
        if abs(x) > c_m1(T) # not zero(x): (a, b) = (6.640350825165134e-116, -1.1053488936824272e-202) fails
            y < zero(T) ? prevfloat(x) : x
        else
            mult = c_m2(T)
            s, s2 = Base.mul12(a * mult, b * mult)
            t = (x * mult) * mult 
            t > s || (t == s && s2 < zero(T)) ? prevfloat(x) : x
        end
    else
        ifelse(x == typemax(T) && isfinite(a) && isfinite(b), floatmax(T), x)
    end
end

# Div
