using RoundingEmulation

import Base.Rounding
using Printf
using Test

function check_op(op, updown, ai, bi, calc, raw)
    if isequal(calc, raw) # -0.0 is equal to 0.0 ?
        return true
    else
        @info("Erorr", op, updown)
        @info(@sprintf("a = %0.20e, bit rep : %s", ai, bitstring(ai)))
        @info(@sprintf("b = %0.20e, bit rep : %s", bi, bitstring(bi)))

        @info(@sprintf("calc = %0.20e, bit rep : %s", calc, bitstring(calc)))
        @info(@sprintf("raw = %0.20e, bit rep : %s", raw, bitstring(raw)))
        return false
    end
end

function rounding_check(a, b)
    for (op, base_op) in zip(("add", "mul", "sub"), (:+, :*, :-))
        @eval begin
            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))
            $(Symbol(op, "_up_calc")) = $(Symbol(op, "_up")).($a, $b)
            $(Symbol(op, "_down_calc")) = $(Symbol(op, "_down")).($a, $b)

            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundUp))
            $(Symbol(op, "_up_raw")) = broadcast($base_op, $a, $b)

            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundDown))
            $(Symbol(op, "_down_raw")) = broadcast($base_op, $a, $b)

            # Compare
            for (ai, bi, up_calc, up_raw) in zip($a, $b, $(Symbol(op, "_up_calc")), $(Symbol(op, "_up_raw")))
                @test check_op($op, "up", ai, bi, up_calc, up_raw)
            end

            for (ai, bi, down_calc, down_raw) in zip($a, $b, $(Symbol(op, "_down_calc")), $(Symbol(op, "_down_raw")))
                @test check_op($op, "down", ai, bi, down_calc, down_raw)
            end
        end
        Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))
    end
end

@testset "setrounding_raw" begin
    N = 10^5 # enough?
    a, b = randn(N), randn(N)

    special_values = [
        0.0, -0.0, 1.0, -1.0,
        nextfloat(zero(Float64)), prevfloat(zero(Float64)),
        floatmin(Float64), -floatmin(Float64),
        eps(Float64), -eps(Float64),
        floatmax(Float64), -floatmax(Float64),
        -Inf, Inf,
        ]

    @testset "randn" begin
        rounding_check(a, b)
        rounding_check(b, a)
    end

    @testset "special cases" begin
        len = Base.length(special_values)
        a = repeat(special_values, len)
        b = sort(a)
        rounding_check(a, b)
    end
end

@testset "Overflow, Underflow" begin
    # http://verifiedby.me/adiary/09
    a = [
        3.5630624444874539e+307, # twosum overflow
        6.929001713869936e+236, # twoprod overflow
        2.0^-600, # twoprod underflow
    ]
    b = [
        -1.7976931348623157e+308,
        2.5944475251952003e+71,
        2.0^-400
    ]
    rounding_check(a, b)
    rounding_check(b, a)
end
