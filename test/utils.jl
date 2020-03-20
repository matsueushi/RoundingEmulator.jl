import Base.Rounding
using Printf

function check_op(op, updown, ai, bi, calc, raw)
    if isequal(calc, raw)
        true
    else
        @info("Erorr", op, updown)
        @info(@sprintf("a = %0.18e, bit rep : %s", ai, bitstring(ai)))
        @info(@sprintf("b = %0.18e, bit rep : %s", bi, bitstring(bi)))

        @info(@sprintf("calc = %0.18e, bit rep : %s", calc, bitstring(calc)))
        @info(@sprintf("raw = %0.18e, bit rep : %s", raw, bitstring(raw)))
        false
    end
end

function rounding_check_op(op, base_op, a, b)
    elt = eltype(a)
    @eval begin
        Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundNearest))
        up_calc = $(Symbol(op, "_up")).($a, $b)
        down_calc = $(Symbol(op, "_down")).($a, $b)

        Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundUp))
        up_raw = broadcast($base_op, $a, $b)

        Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundDown))
        down_raw = broadcast($base_op, $a, $b)

        # Compare
        for (ai, bi, calc, raw) in zip($a, $b, up_calc, up_raw)
            @test check_op($op, "up", ai, bi, calc, raw)
        end

        for (ai, bi, calc, raw) in zip($a, $b, down_calc, down_raw)
            @test check_op($op, "down", ai, bi, calc, raw)
        end
    end

end

function rounding_check(a, b)
    for (op, base_op) in zip(("add", "sub", "mul", "div"), (:+, :-, :*, :/))
        rounding_check_op(op, base_op, a, b)
    end
    Rounding.setrounding_raw(eltype(a), Rounding.to_fenv(RoundNearest))
end

function check_op_sqrt(op, updown, ai, calc, raw)
    if isequal(calc, raw)
        true
    else
        @info("Erorr", op, updown)
        @info(@sprintf("a = %0.18e, bit rep : %s", ai, bitstring(ai)))

        @info(@sprintf("calc = %0.18e, bit rep : %s", calc, bitstring(calc)))
        @info(@sprintf("raw = %0.18e, bit rep : %s", raw, bitstring(raw)))
        false
    end
end

function rounding_check_sqrt(a)
    elt = eltype(a)
    Rounding.setrounding_raw(elt, Rounding.to_fenv(RoundNearest))
    # Sqrt
    up_calc = sqrt_up.(a)
    down_calc = sqrt_down.(a)

    Rounding.setrounding_raw(elt, Rounding.to_fenv(RoundUp))
    up_raw = sqrt.(a)

    Rounding.setrounding_raw(elt, Rounding.to_fenv(RoundDown))
    down_raw = sqrt.(a)

    # Compare
    for (ai, calc, raw) in zip(a, up_calc, up_raw)
        @test check_op_sqrt("sqrt", "up", ai, calc, raw)
    end

    for (ai, calc, raw) in zip(a, down_calc, down_raw)
        @test check_op_sqrt("sqrt", "down", ai, calc, raw)
    end
    Rounding.setrounding_raw(elt, Rounding.to_fenv(RoundNearest))
end