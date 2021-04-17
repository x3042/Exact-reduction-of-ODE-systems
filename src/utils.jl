
import Nemo: gfp_elem, gfp_fmpz_elem, QQ, FlintRationalField

import Base: rand

#------------------------------------------------------------------------------

function Base.convert(::Type{Int}, x::gfp_elem)
    return Int(x.data)
end

function Base.convert(::Type{BigInt}, x::gfp_fmpz_elem)
    return BigInt(x.data)
end

#------------------------------------------------------------------------------

# extends random generator to Rational field
Base.rand(::FlintRationalField) = QQ(rand(-2^8:2^8))
Base.rand(::FlintRationalField, n::Int) = [rand(QQ) for _ in 1:n]

#------------------------------------------------------------------------------

# estimates the elapsed time for `ex` and stores the result into the `storage`
macro savetime(ex, storage)
    return quote
        local t0 = time_ns()
        local val = $(esc(ex))
        local t1 = time_ns()
        push!($storage, (t1-t0)/1e6)
        val
    end
end

#------------------------------------------------------------------------------

# conveniece wrapper for `from_dense` function,
# which returns a sparse representation of an array
# and generally defaults to
#   1D vector --> Sparsik
#   2D vector --> DOK_Sparsik
# over the Rational field of Nemo.QQ instance
macro sparse(ex)
    return quote
        from_dense($(esc(ex)), QQ)
    end
end