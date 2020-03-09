using RoundingEmulation

import Base.Rounding
using Test

@testset "setrounding_raw" begin

    N = 3
    a, b = randn(N), randn(N)

    for (op, base_op) in zip((:add, :mul), (:+, :*))
        @eval begin
            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))

            $(Symbol(op, "_a_b_up")) = $(Symbol(op, "_up")).($a, $b)
            $(Symbol(op, "_b_a_up")) = $(Symbol(op, "_up")).($b, $a)
            $(Symbol(op, "_a_b_down")) = $(Symbol(op, "_down")).($a, $b)
            $(Symbol(op, "_b_a_down")) = $(Symbol(op, "_down")).($b, $a)

            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundUp))
            @test all($(Symbol(op, "_a_b_up")) .== broadcast($base_op, $a, $b))
            @test all($(Symbol(op, "_b_a_up")) .== broadcast($base_op, $b, $a))

            Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundDown))
            @test all($(Symbol(op, "_a_b_down")) .== broadcast($base_op, $a, $b))
            @test all($(Symbol(op, "_b_a_down")) .== broadcast($base_op, $b, $a))
        end

        Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))
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