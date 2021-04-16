
#=
    The File contains tests for some project utils and etc..
=#

#------------------------------------------------------------------------------

include("../src/gizmos.jl")
include("../src/utils.jl")

#------------------------------------------------------------------------------

if !isdefined(Main, :testset)
    using Test
    using TestSetExtensions
end
import Nemo: QQ, GF, FlintRationalField, characteristic

#------------------------------------------------------------------------------

@testset "Gizmos -- construct_jacobians" begin

    R, (x₁, x₂, x₃, x₄) = QQ["x₁", "x₂", "x₃", "x₄"]

    system = [
        x₁^2 + 2*x₁*x₂,
        x₂^2 + x₃ + x₄,
        x₂ + x₄,
        x₁ + x₃
    ]
    true_js = [
        from_dense([
            2 0 0 0;
            2 0 0 0;
            0 0 0 0;
            0 0 0 0;
        ], QQ),
        from_dense([
            2 0 0 0;
            0 2 0 0;
            0 0 0 0;
            0 0 0 0;
        ], QQ),
        from_dense([
            0 0 0 1;
            0 0 1 0;
            0 1 0 1;
            0 1 1 0;
        ], QQ)
    ]

    js = construct_jacobians(system)

    @test all(J in true_js for J in js) && length(true_js) == length(js)


    # test #2
    R, (x₁, x₂, x₃) = QQ["x₁", "x₂", "x₃"]

    system = [
        x₂^2 + 4x₂*x₃ + 4x₃^2,  # derivative of x1
        4x₃ - 2x₁,              # derivative of x2
        x₁ + x₂                 # derivative of x3
    ]
    true_js = [
        from_dense([
            0 0 0;
            2 0 0;
            4 0 0;
        ], QQ),
        from_dense([
            0 0 0;
            4 0 0;
            8 0 0;
        ], QQ),
        from_dense([
            0 -2 1;
            0 0 1;
            0 4 0;
        ], QQ)
    ]

    js = construct_jacobians(system)

    @test all(J in true_js for J in js) && length(true_js) == length(js)

end

# TODO
@testset "Gizmos -- randomness" begin

    @test 1 == 1

end


@info "OK"
