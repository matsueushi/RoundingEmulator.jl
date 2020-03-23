@testset "Corner cases" begin
    # TODO
    # Add tests for Float32

    @testset "twosum intermediate overflow" begin
        # http://verifiedby.me/adiary/09
        a = 3.5630624444874539e+307
        b = -1.7976931348623157e+308
        x = a + b
        @test isfinite(x)
        tmp = x - a
        @test isinf(tmp)
        rounding_check_binary(a, b)
    end

    @testset "twoprod intermediate overflow" begin
        # http://verifiedby.me/adiary/09
        function split(a)
            tmp = a * (2.0^27 + 1.0)
            x = tmp - (tmp - a)
            y = a - x
            x, y
        end
        a = 6.929001713869936e+236
        b = 2.5944475251952003e+71
        x = a * b
        @test isfinite(x)
        a1, _ = split(a)
        b1, _ = split(a)
        tmp = a1 * b1
        @test isinf(tmp)
        rounding_check_binary(a, b)
    end
end

