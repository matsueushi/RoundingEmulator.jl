module RoundingEmulation

export twosum, add_up, add_down
export twoprodfma, prod_up, prod_down

# Add

function fast_twosum(a, b)
    x = a + b
    tmp = x - a
    x, b - tmp
end

twosum(a, b) = abs(a) > abs(b) ? fast_twosum(a, b) : fast_twosum(b, a)

function add_up(a, b)
    x, y = twosum(a, b)
    y > 0 ? nextfloat(x) : x
end

function add_down(a, b)
    x, y = twosum(a, b)
    y < 0 ? prevfloat(x) : x
end

# Product

function twoprodfma(a, b)
    x = a * b
    x, fma(a, b, -x)
end

function prod_up(a, b)
    x, y = twoprodfma(a, b)
    y > 0 ? nextfloat(x) : x
end

function prod_down(a, b)
    x, y = twoprodfma(a, b)
    y < 0 ? prevfloat(x) : x
end

end # module
