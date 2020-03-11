module RoundingEmulation

using Base: IEEEFloat

export twosum, add_up, add_down
export sub_up, sub_down
export twoprod, mul_up, mul_down

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
function add_up(a, b)
    x, y = twosum(a, b)
    if isfinite(x)
        y > zero(y) ? nextfloat(x) : x
    else
        x == typemin(x) && isfinite(a) && isfinite(b) ? -floatmax(x) : x
    end
end

function add_down(a, b)
    x, y = twosum(a, b)
    if isfinite(x)
        if y < zero(y)
            prevfloat(x)
        else
            # y = 0 -> x = a + b
            # 1) x ≂̸ 0 => x
            # 2) x = 0, a = -b ≂̸ 0 => -0.0
            # 3) x = 0, a = b = 0
            #    (a, b) = (0.0, 0.0) => 0.0
            #    (a, b) = (-0.0, 0.0) => -0.0
            #    (a, b) = (-0.0, -0.0) => -0.0
            x == zero(x) && (signbit(a) || signbit(b)) ? -zero(x) : x
        end
    else
        x == typemax(x) && isfinite(a) && isfinite(b) ? floatmax(x) : x
    end
end

# Sub
sub_up(a, b) = add_up(a, -b)
sub_down(a, b) = add_down(a, -b)

# Mul
const_mul_th1(x) = oftype(x, 2)^-969
const_mul_th2(x) = oftype(x, 2)^537

function mul_up(a, b)
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = twoprod(a, b)
    if isfinite(x)
        if abs(x) > const_mul_th1(x) # not zero(x): (a, b) = (-2.1634867667116802e-200, 1.6930929484402486e-119) fails
            y > zero(y) ? nextfloat(x) : x
        else
            mult = const_mul_th2(x)
            s, s2 = twoprod(a * mult, b * mult)
            t = (x * mult) * mult
            t < s || (t == s && s2 > zero(s)) ? nextfloat(x) : x
        end
    else
        x == typemin(x) && isfinite(a) && isfinite(b) ? -floatmax(x) : x
    end
end

function mul_down(a, b)
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = twoprod(a, b)
    if isfinite(x)
        th =  const_mul_th1(x) # not zero(x): (a, b) = (6.640350825165134e-116, -1.1053488936824272e-202) failss
        if abs(x) > th
            y < zero(y) ? prevfloat(x) : x
        else
            mult = const_mul_th2(x)
            s, s2 = twoprod(a * mult, b * mult)
            t = (x * mult) * mult 
            t > s || (t == s && s2 < zero(s)) ? prevfloat(x) : x
        end
    else
        x == typemax(x) && isfinite(a) && isfinite(b) ? floatmax(x) : x
    end
end

end # module
