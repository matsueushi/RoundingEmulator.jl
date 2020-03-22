using RoundingEmulator
using Test

include("utils.jl")

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
        rounding_check(a, b)
        rounding_check_sqrt(filter(x->x ≥ zero(x), special_values))
    end
end

@testset "Overflow, Underflow" begin
    # TODO
    # Add counterexamples for Float32

    ces = [3.5630624444874539e+307  -1.7976931348623157e+308;   # twosum overflow, http://verifiedby.me/adiary/09
           6.929001713869936e+236   2.5944475251952003e+71;     # twoprod overflow, http://verifiedby.me/adiary/09
           -2.1634867667116802e-200 1.6930929484402486e-119;    # mul_up
           6.640350825165134e-116   -1.1053488936824272e-202;   # mul_down
           2.1963398713704127e-308  5.082385199753506e-149;     # div_up
           -2.592045137385347e-308  -0.024378802704431428;      # div_down
    ]
    a = ces[:, 1]
    b = ces[:, 2]
    rounding_check(a, b)
    rounding_check(b, a)
    rounding_check_sqrt(abs.(a))
    rounding_check_sqrt(abs.(b))
end

for n in 3:6
    for T in (Float64, Float32)
        @testset "$(T), Random Sampling, 10^$(n)" begin
            N = 10^n
            rand_a = reinterpret.(T, rand(Base.uinttype(T), N))
            rand_b = reinterpret.(T, rand(Base.uinttype(T), N))
            rounding_check(rand_a, rand_b)
            rounding_check(rand_b, rand_a)
            rounding_check_sqrt(abs.(rand_a))
            rounding_check_sqrt(abs.(rand_b))
        end
    end
end
