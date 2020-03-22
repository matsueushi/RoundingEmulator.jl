using Base.Rounding: setrounding_raw, to_fenv
using Printf

function compare_calc_raw(op, updown, calc, raw, args...)
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

function rounding_check(op, base_op, arrays...)
    elt = eltype(arrays[1])
    @eval begin
        setrounding_raw($elt, to_fenv(RoundNearest))
        up_calc = broadcast($(Symbol(op, "_up")), $(arrays...))
        down_calc = broadcast($(Symbol(op, "_down")), $(arrays...))

        setrounding_raw($elt, to_fenv(RoundUp))
        up_raw = broadcast($base_op, $(arrays...))

        setrounding_raw($elt, to_fenv(RoundDown))
        down_raw = broadcast($base_op, $(arrays...))

        # Compare
        for (calc, raw, args) in zip(up_calc, up_raw, $(arrays...))
            @test compare_calc_raw($op, "up", calc, raw, args)
        end

        for (calc, raw, args) in zip(down_calc, down_raw, $(arrays...))
            @test compare_calc_raw($op, "down", calc, raw, args)
        end
    end
end

function rounding_check_unary(a)
    rounding_check("sqrt", :sqrt, a)
    setrounding_raw(eltype(a), to_fenv(RoundNearest)) 
end

function rounding_check_binary(a, b)
    for (op, base_op) in zip(("add", "sub", "mul", "div"), (:+, :-, :*, :/))
        rounding_check(op, base_op, a, b)
    end
    setrounding_raw(eltype(a), to_fenv(RoundNearest))
end
