using RoundingEmulation

import Base.Rounding
using Printf
using Test

@testset "setrounding_raw" begin

    # check_op(ai, bi, up_calc, up_raw) = up_calc == up_raw # ? true : throw(@sprintf("%s, %.17f, %.17f", op, ai, bi))

    function rounding_check(a, b)
        for (op, base_op) in zip((:add, :mul), (:+, :*))
            @eval begin

                function check_op(ai, bi, calc, raw)
                    if calc == raw
                        return true
                    else
                        throw(@sprintf("%.23f, %.23f", ai, bi))
                    end
                end

                Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))
                $(Symbol(op, "_up_calc")) = $(Symbol(op, "_up")).($a, $b)
                $(Symbol(op, "_down_calc")) = $(Symbol(op, "_down")).($a, $b)
    
                Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundUp))
                $(Symbol(op, "_up_raw")) = broadcast($base_op, $a, $b)
    
                Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundDown))
                $(Symbol(op, "_down_raw")) = broadcast($base_op, $a, $b)

                # Compare
                for (ai, bi, up_calc, up_raw) in zip($a, $b, $(Symbol(op, "_up_calc")), $(Symbol(op, "_up_raw")))
                    @test check_op(ai, bi, up_calc, up_raw)
                end
            end

            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))
        end
    end

    @testset "randn" begin
        N = 10 # enough?
        a, b = randn(N), randn(N)

        rounding_check(a, b)
        rounding_check(b, a)
    end

    @testset "special cases" begin
        special_values = [
            0.0, 1.0, -1.0,
            nextfloat(zero(Float64)), -nextfloat(zero(Float64)),
            floatmin(Float64), -floatmin(Float64),
            # floatmax(Float64), -floatmax(Float64),
            eps(Float64), -eps(Float64)
            ]
        len = Base.length(special_values)

        a = repeat(special_values, len)
        b = sort(a)

        rounding_check(a, b)
    end
end


@testset "twosum overflow" begin
    # http://verifiedby.me/adiary/09
    a, b = 3.5630624444874539e+307, -1.7976931348623157e+308
    @test twosum(a, b) == (-1.4413868904135704e308, 9.9792015476736e291)
    @test twosum(b, a) == (-1.4413868904135704e308, 9.9792015476736e291)

    @test add_up(a, b) == nextfloat(a + b)
    @test add_up(b, a) == nextfloat(a + b)
    @test add_down(a, b) == a + b
    @test add_down(b, a) == a + b
end

@testset "twoprod overflow" begin
    # http://verifiedby.me/adiary/09
    a, b = 6.929001713869936e+236, 2.5944475251952003e+71
    @test twoprod(a, b) == (1.7976931348623157e308, -1.0027614963959625e291)
    @test twoprod(b, a) == (1.7976931348623157e308, -1.0027614963959625e291)

    @test mul_up(a, b) == a * b
    @test mul_up(b, a) == a * b
    @test mul_down(a, b) == prevfloat(a * b)
    @test mul_down(b, a) == prevfloat(b * a)
end