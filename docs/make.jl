
push!(LOAD_PATH,"../src/")

#####

using Pkg, Documenter
using SparseAlgebra


makedocs(
    modules = [SparseAlgebra],
    sitename = "Documenter.jl",
    authors = "Elizaveta Demitraki, Alexander Demin, and Gleb Pogudin",
    pages = [
        "Home" => "index.md",
        "types.md"
    ]
)

makedocs(sitename="SparseAlgebra.jl")