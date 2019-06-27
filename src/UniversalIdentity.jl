module UniversalIdentity

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
end UniversalIdentity

using Requires

"""
    Identity(op)

A generic (left) identity for `op`.

# Examples
```jldoctest
julia> using UniversalIdentity: Identity

julia> Identity(*) * 1
1

julia> Identity(*) * :actual_anything_works
:actual_anything_works

julia> foldl(+, 1:3, init=Identity(+))
6
```
"""
struct Identity{OP} end

Identity(::OP) where OP = Identity{OP}()

itypeof(f) = typeof(Identity(f))

Base.:*(::itypeof(*), x) = x
Base.:+(::itypeof(+), x) = x
Base.:&(::itypeof(&), x) = x
Base.:|(::itypeof(|), x) = x
Base.min(::itypeof(min), x) = x
Base.max(::itypeof(max), x) = x
Base.add_sum(::itypeof(Base.add_sum), x) = x
Base.mul_prod(::itypeof(Base.mul_prod), x) = x

# Disambiguation:
Base.min(::itypeof(min), ::Missing) = missing
Base.max(::itypeof(max), ::Missing) = missing

function __init__()
    @require BangBang="198e06fe-97b7-11e9-32a5-e1d131e6ad66" begin
        BangBang.push!!(::itypeof(BangBang.push!!), x) = [x]
        BangBang.append!!(::itypeof(BangBang.append!!), x) = x
    end
end

end # module
