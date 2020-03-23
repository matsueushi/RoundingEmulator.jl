using RoundingEmulator
using Test

include("utils.jl")
include("corner_case.jl")

special_value_list(T::Type) = [
    zero(T), -zero(T),                                  # 0.0, -0.0
    one(T), -one(T),                                    # 1.0, -1.0
    nextfloat(zero(T)), prevfloat(zero(T)),             # N_min^s, -N_min^s
    prevfloat(floatmin(T)), nextfloat(-floatmin(T)),    # N_max^s, -N_max^s
    floatmin(T), -floatmin(T),                          # N_min^n, -N_min^n
    floatmax(T), -floatmax(T),                          # N_max^n, -N_max^n
    eps(T), -eps(T),                                    # machine epsilon
    typemax(T), typemin(T),                             # Inf, -Inf
    T(NaN)                                              # NaN
]

for T in (Float64, Float32)
    @testset "$(T), Special Cases" begin
        special_values = special_value_list(T)
        len = Base.length(special_values)
        a = repeat(special_values, len)
        b = sort(a)
        rounding_check_unary(filter(x->x ≥ zero(x), special_values)) # sqrt
        rounding_check_binary(a, b)
    end
end

for n in 3:6
    N = 10^n
    for T in (Float64, Float32)
        @testset "$(T), Random Sampling, 10^$(n)" begin
            rand_a = reinterpret.(T, rand(Base.uinttype(T), N))
            rand_b = reinterpret.(T, rand(Base.uinttype(T), N))
            rounding_check_unary(abs.(rand_a))
            rounding_check_unary(abs.(rand_b))
            rounding_check_binary(rand_a, rand_b)
            rounding_check_binary(rand_b, rand_a)
        end
    end
end
