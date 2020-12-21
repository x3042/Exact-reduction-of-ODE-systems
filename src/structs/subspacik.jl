
#=
    The File contains `Subspacik<T>` and related funcs implementation
=#

# I guess find_basis funcs should be

#------------------------------------------------------------------------------

include("bidim_sparsik_lazy.jl")

#------------------------------------------------------------------------------

import Nemo: QQ, GF, Field

#------------------------------------------------------------------------------

# Subspacik
mutable struct Subspacik{T<:Field}
    # as I see, we do not need the dimension of the ambient space yet:
    # now it is just redundant
    field::T
    # the echelon form of vectors is an invariant!
    echelon_form::Dict{Int, AbstractSparsik{T}}
end

#------------------------------------------------------------------------------

# convenience ctor
function Subspacik(field::T) where {T}
    return Subspacik(field, Dict{Int, AbstractSparsik{T}}())
end

# deepcopy redefinition in order to preserve the field
function Base.deepcopy_internal(x::Subspacik, stackdict::IdDict)
    y = Subspacik(x.ambient_dim, field,
            Base.deepcopy_internal(x.echelon_form, stackdict))
    stackdict[x] = y
    return y
end

#------------------------------------------------------------------------------

# Ground field!
ground(v::Subspacik) = v.field

#------------------------------------------------------------------------------

# returns basis vectors of V sorted by pivot indices
function basis(V::Subspacik)
    return sort(collect(values(V.echelon_form)), by=first_nonzero)
end

#------------------------------------------------------------------------------

# returns the dimension of the ambient space of V
function ambient_dim(V::Subspacik)
    return dim(first(values(V.echelon_form)))
end

# returns the dimension of V
function dim(V::Subspacik)
    return length(V.echelon_form)
end

#------------------------------------------------------------------------------

# adds `new_vector` to the set of spanning vectors of V
# while modifying both
# returns -1 if `new_vector` lies in V, new pivot index otherwise
function eat_sparsik!(V::Subspacik, new_vector::AbstractSparsik)
    for (piv, vect) in V.echelon_form
        if !iszero(new_vector[piv])
            reduce!(new_vector, vect, -new_vector[piv])
        end
    end

    if iszero(new_vector)
        return -1
    end

    pivot = first_nonzero(new_vector)
    scale!(new_vector, inv(new_vector[pivot]))

    for (piv, vect) in V.echelon_form
        if !iszero(vect[pivot])
            reduce!(V.echelon_form[piv], new_vector, -vect[pivot])
        end
    end

    V.echelon_form[pivot] = new_vector
    return pivot
end

#------------------------------------------------------------------------------

# returns a new Subspacik formed as a linear span
# of the given vectors
function linear_span!(vectors)
    V = Subspacik(first(vectors).field)
    for vect in vectors
        eat_sparsik!(V, vect)
    end
    return V
end

#------------------------------------------------------------------------------

# transformes V to the smallest subspace invariant under
# the given matrices and containing the original one
function apply_matrices_inplace!(V::Subspacik, matrices)
    new_pivots = collect(keys(V.echelon_form))
    i = 0

    while !isempty(new_pivots)
        pivots_to_process = sort(deepcopy(new_pivots))
        empty!(new_pivots)

        for pivot in pivots_to_process
            for vect in matrices
                product = apply_vector(V.echelon_form[pivot], vect)

                i += 1
                i % 100 == 0 && print(".")

                if !iszero(product)
                    new_pivot = eat_sparsik!(V, product)
                    if new_pivot != -1
                        push!(new_pivots, new_pivot)
                    end
                end
            end
        end

    end

 end

#------------------------------------------------------------------------------

# checks whether the given vector lies in V
function check_inclusion(V::Subspacik, vector::AbstractSparsik)
    new_vector = deepcopy(vector)
    for (piv, vect) in V.echelon_form
        if ! iszero(new_vector[piv])
            reduce!(new_vector, vect, -new_vector[piv])
        end
    end
    return iszero(new_vector)
end

#------------------------------------------------------------------------------

# checks whether the given subspace is invariant under the matrices
function check_invariance(V::Subspacik, matrices)
    for matr in matrices
        for vec in values(V.echelon_form)
            product = matr * vec
            if ! check_inclusion(V, product)
                return false
            end
        end
    end
    return true
end

#------------------------------------------------------------------------------

function check_inclusion(V::Subspacik, vectors)
    for vec in vectors
        if ! check_inclusion(V, vec)
            return false
        end
    end
    return true
end

#------------------------------------------------------------------------------

function Base.show(V::Subspacik)
    "<\n $(join(map(v -> Base.show(v), values(V.echelon_form)), "\n\n"))\n>\n"
end

function print_subspacik(V::Subspacik)
    println(show(V))
end

#------------------------------------------------------------------------------

==(U::Subspacik{T}, V::Subspacik{T}) where {T} = (U.dim == V.dim &&
            U.field == V.field &&
            U.echelon_form == V.echelon_form;)