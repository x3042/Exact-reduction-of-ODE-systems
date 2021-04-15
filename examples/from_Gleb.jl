
#=
    Examples file
=#

include("../src/api.jl")


import Nemo: QQ


gen_matrices = [
    from_dense([
        1  0 0 0;
        0 -1 0 0;
        0  0 0 0;
        0  0 0 0
    ], QQ),
    from_dense([
        0 -1 0 0;
        1  0 0 0;
        0  0 0 0;
        0  0 0 0
    ], QQ),
    from_dense([
        0 0 0  0;
        0 0 0  0;
        0 0 1  0;
        0 0 0 -1
    ], QQ),
    from_dense([
        0 0  0 0;
        0 0  0 0;
        0 0  0 1;
        0 0 -1 0
    ], QQ)
]

invariant = invariant_subspaces(gen_matrices)
println(invariant)
