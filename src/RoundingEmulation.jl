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
    # TODO fix underflow
    x = a * b
    x, fma(a, b, -x)
end

# Rounding

for (op, ar) in zip((:add, :mul), (:sum, :prod))
    @eval begin
        # RoundUp
        function $(Symbol(op, "_up"))(a, b)
            x, y = $(Symbol("two", ar))(a, b)

            # `isless` is different from `<`
            # julia> -0.0 < 0.0
            # false

            # julia> isless(-0.0, 0.0)
            # true

            isless(zero(y), y) ? nextfloat(x) : x # y > 0
        end

        # RoundDown
        function $(Symbol(op, "_down"))(a, b)
            x, y = $(Symbol("two", ar))(a, b)
            isless(y, zero(y)) ? prevfloat(x) : x # y < 0
        end
    end
end

end # module
