module RoundingEmulation

export twosum, add_up, add_down
export twoprod, mul_up, mul_down

# Add

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

function add_up(a, b)
    x, y = twosum(a, b)
    # y > 0
    isless(zero(y), y) ? nextfloat(x) : x 
end

function add_down(a, b)
    x, y = twosum(a, b)
    # y < 0
    isless(y, zero(y)) ? prevfloat(x) : x
end

function mul_up(a, b)
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = twoprod(a, b)
    # y > 0
    if abs(x) >= 2.0^(-969)
        isless(zero(y), y) ? nextfloat(x) : x
    else
        mult = 2.0^537
        s, s2 = twoprod(a * mult, b * mult)
        t = (x * mult) * mult
        t < s || (t == s && s2 > 0) ? nextfloat(x) : x
    end
end

function mul_down(a, b)
    # http://verifiedby.me/adiary/pub/kashi/image/201406/nas2014.pdf
    x, y = twoprod(a, b)
    # y < 0
    if abs(x) >= 2.0^(-969)
        isless(y, zero(y)) ? prevfloat(x) : x
    else
        mult = 2.0^537
        s, s2 = twoprod(a * mult, b * mult)
        t = (x * mult) * mult 
        t > s || (t == s && s2 < 0) ? prevfloat(x) : x
    end
end

end # module
