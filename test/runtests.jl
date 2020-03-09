using RoundingEmulation

import Base.Rounding
using Test

@testset "setrounding_raw" begin
    N = 10^5
    a, b = randn(N), randn(N)

    add_a_b_up = add_up.(a, b)
    add_b_a_up = add_up.(b, a)
    add_a_b_down = add_down.(a, b)
    add_b_a_down = add_down.(b, a)

    prod_a_b_up = prod_up.(a, b)
    prod_b_a_up = prod_up.(b, a)
    prod_a_b_down = prod_down.(a, b)
    prod_b_a_down = prod_down.(b, a)
    
    Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundUp))
    @test all(add_a_b_up .== a .+ b)
    @test all(add_b_a_up .== a .+ b)
    @test all(prod_a_b_up .== a .* b)
    @test all(prod_b_a_up .== a .* b)

    Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundDown))
    @test all(add_a_b_down .== a .+ b)
    @test all(add_b_a_down .== a .+ b)
    @test all(prod_a_b_down .== a .* b)
    @test all(prod_b_a_down .== a .* b)

    Rounding.setrounding_raw(Float64, Rounding.to_fenv(RoundNearest))
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
    @test twoprodfma(a, b) == (1.7976931348623157e308, -1.0027614963959625e291)
    @test twoprodfma(b, a) == (1.7976931348623157e308, -1.0027614963959625e291)

    @test prod_up(a, b) == a * b
    @test prod_up(b, a) == a * b
    @test prod_down(a, b) == prevfloat(a * b)
    @test prod_down(b, a) == prevfloat(b * a)
end