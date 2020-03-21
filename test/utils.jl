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

function rounding_check_op(op, base_op, arrays...)
    elt = eltype(arrays[1])
    @eval begin
        Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundNearest))
        up_calc = $(Symbol(op, "_up")).($(arrays...))
        down_calc = $(Symbol(op, "_down")).($(arrays...))

        Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundUp))
        up_raw = broadcast($base_op, $(arrays...))

        Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundDown))
        down_raw = broadcast($base_op, $(arrays...))

        # Compare
        for (calc, raw, args) in zip(up_calc, up_raw, $(arrays...))
            @test check_op($op, "up", calc, raw, args)
        end

        for (calc, raw, args) in zip(down_calc, down_raw, $(arrays...))
            @test check_op($op, "down", calc, raw, args)
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
    rounding_check_op("sqrt", :sqrt, a)
    Rounding.setrounding_raw(eltype(a), Rounding.to_fenv(RoundNearest)) 
end
