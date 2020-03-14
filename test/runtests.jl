using RoundingEmulation

import Base.Rounding
using Printf
using Test

special_value_list(T::Type) = [
    zero(T), -zero(T), 
    one(T), -one(T),
    nextfloat(zero(T)), prevfloat(zero(T)),
    eps(T), -eps(T),
    floatmin(T), -floatmin(T),
    floatmax(T), -floatmax(T),
    typemax(T), typemin(T),
]

function check_op(op, updown, ai, bi, calc, raw)
    if isequal(calc, raw)
        return true
    else
        @info("Erorr", op, updown)
        @info(@sprintf("a = %0.18e, bit rep : %s", ai, bitstring(ai)))
        @info(@sprintf("b = %0.18e, bit rep : %s", bi, bitstring(bi)))

        @info(@sprintf("calc = %0.18e, bit rep : %s", calc, bitstring(calc)))
        @info(@sprintf("raw = %0.18e, bit rep : %s", raw, bitstring(raw)))
        return false
    end
end

function rounding_check(a, b)
    elt = eltype(a)
    for (op, base_op) in zip(("add", "mul", "sub"), (:+, :*, :-))
        @eval begin
            Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundNearest))
            $(Symbol(op, "_up_calc")) = $(Symbol(op, "_up")).($a, $b)
            $(Symbol(op, "_down_calc")) = $(Symbol(op, "_down")).($a, $b)

            Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundUp))
            $(Symbol(op, "_up_raw")) = broadcast($base_op, $a, $b)

            Rounding.setrounding_raw($elt, Rounding.to_fenv(RoundDown))
            $(Symbol(op, "_down_raw")) = broadcast($base_op, $a, $b)

            # Compare
            for (ai, bi, up_calc, up_raw) in zip($a, $b, $(Symbol(op, "_up_calc")), $(Symbol(op, "_up_raw")))
                @test check_op($op, "up", ai, bi, up_calc, up_raw)
            end

            for (ai, bi, down_calc, down_raw) in zip($a, $b, $(Symbol(op, "_down_calc")), $(Symbol(op, "_down_raw")))
                @test check_op($op, "down", ai, bi, down_calc, down_raw)
            end
        end
        Rounding.setrounding_raw(elt, Rounding.to_fenv(RoundNearest))
    end
end

for T in (Float64, Float32)
    @testset "$(T), Special Cases" begin
        special_values = special_value_list(T)
        len = Base.length(special_values)
        a = repeat(special_values, len)
        b = sort(a)
        rounding_check(a, b)
    end
end

@testset "Overflow, Underflow" begin
    # TODO
    # Add counterexamples for Float32

    # http://verifiedby.me/adiary/09
    a = [
        3.5630624444874539e+307, # twosum overflow
        6.929001713869936e+236, # twoprod overflow
        -2.1634867667116802e-200, # mul_up
        6.640350825165134e-116, # mul_down
    ]
    b = [
        -1.7976931348623157e+308,
        2.5944475251952003e+71,
        1.6930929484402486e-119,
        -1.1053488936824272e-202,
    ]
    rounding_check(a, b)
    rounding_check(b, a)
end

for T in (Float64, Float32)
    @testset "$(T), Random Sampling" begin
        N = 10^5 # enough?
        rand_a = reinterpret.(T, rand(Base.uinttype(T), N))
        rand_b = reinterpret.(T, rand(Base.uinttype(T), N))
        rounding_check(rand_a, rand_b)
        rounding_check(rand_b, rand_a)
    end
end