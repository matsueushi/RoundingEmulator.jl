import Base.Rounding
using Printf

function check_op(op, updown, calc, raw, args...)
    if isequal(calc, raw)
        true
    else
        @info("Erorr", op, updown)
        for (i, v) in enumerate(args)
            @info(@sprintf("a%d = %0.18e, bit rep : %s", i, v, bitstring(v)))
        end

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
        for (calc, raw, ai, bi) in zip(up_calc, up_raw, $a, $b)
            @test check_op($op, "up", calc, raw, ai, bi)
        end

        for (calc, raw, ai, bi) in zip(down_calc, down_raw, $a, $b)
            @test check_op($op, "down", calc, raw, ai, bi)
        end
    end

end

function rounding_check(a, b)
    for (op, base_op) in zip(("add", "sub", "mul", "div"), (:+, :-, :*, :/))
        rounding_check_op(op, base_op, a, b)
    end
    Rounding.setrounding_raw(eltype(a), Rounding.to_fenv(RoundNearest))
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
    for (calc, raw, ai) in zip(up_calc, up_raw, a)
        @test check_op("sqrt", "up", calc, raw, ai)
    end

    for (calc, raw, ai) in zip(down_calc, down_raw, a)
        @test check_op("sqrt", "down", calc, raw,  ai)
    end
    Rounding.setrounding_raw(elt, Rounding.to_fenv(RoundNearest))
end