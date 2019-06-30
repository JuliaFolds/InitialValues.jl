module UniversalIdentity

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
end UniversalIdentity

export Id

"""
    Id(op) :: Identity

A generic (left) identity for `op`.

# Examples
```jldoctest
julia> using UniversalIdentity

julia> Id(*) isa UniversalIdentity.Identity
true

julia> Id(*) * 1
1

julia> Id(*) * missing
missing

julia> Id(*) * "right"
"right"

julia> Id(*) * :actual_anything_works
:actual_anything_works

julia> foldl(+, 1:3, init=Id(+))
6
```
"""
Id(::OP) where OP = IdentityOf{OP}()

include("prettyexpr.jl")

"""
    UniversalIdentity.Identity

An abstract super type of all identity types.
"""
abstract type Identity end
abstract type SpecificIdentity{OP} <: Identity end
# abstract type GenericIdentity <: AbstractIdentity end

struct IdentityOf{OP} <: SpecificIdentity{OP} end

itypeof_impl(op) = :(SpecificIdentity{typeof($op)})
@eval itypeof(op) = $(itypeof_impl(:op))

"""
    UniversalIdentity.hasidentity(op) :: Bool

# Examples
```jldoctest
julia> using UniversalIdentity

julia> all(UniversalIdentity.hasidentity, [
           *,
           +,
           &,
           |,
           min,
           max,
           Base.add_sum,
           Base.mul_prod,
       ])
true

julia> UniversalIdentity.hasidentity((x, y) -> x + y)
false
```
"""
hasidentity(::Any) = false

def_impl(op, y) =
    quote
        $op(::$(itypeof_impl(op)), x) = $y
        UniversalIdentity.hasidentity(::typeof($op)) = true
    end

"""
    UniversalIdentity.@def op [y = :x]

Define a generic (left) identity for `op`.

`UniversalIdentity.@def op` is expanded to

```julia
$(prettyexpr(def_impl(:op, :x)))
```

For operations like `push!`, it is useful to define the returned value
to be different from `x`.  This can be done by using the second
argument to the maco; i.e., `UniversalIdentity.@def op [x]` is
expanded to

```julia
$(prettyexpr(def_impl(:push!, "[x]")))
```

Note that the second argument to `op` is always `x`.
"""
macro def(op, y = :x)
    def_impl(esc(op), y)
end

disambiguate_impl(op, right) =
    quote
        $op(::$(itypeof_impl(op)), x::$right) = x
    end

"""
    UniversalIdentity.@disambiguate op RightType

Disambiguate the method introduced by [`@def`](@ref).

It is expanded to

```julia
$(prettyexpr(disambiguate_impl(:op, :RightType)))
```
"""
macro disambiguate(op, right)
    disambiguate_impl(esc(op), esc(right))
end

@def Base.:*
@def Base.:+
@def Base.:&
@def Base.:|
@def Base.min
@def Base.max
@def Base.add_sum
@def Base.mul_prod

@disambiguate Base.min Missing
@disambiguate Base.max Missing

const ZeroType = Union{
    SpecificIdentity{typeof(+)},
    SpecificIdentity{typeof(Base.add_sum)},
}
const OneType = Union{
    SpecificIdentity{typeof(*)},
    SpecificIdentity{typeof(Base.mul_prod)},
}

Base.convert(::Type{T}, ::ZeroType) where {T <: Number} = zero(T)
Base.convert(::Type{T}, ::OneType) where {T <: Union{Number, AbstractString}} =
    one(T)

# Technically true, but could be a disaster in practice?:
#=
Base.convert(::Type{T}, ::Union{SpecificIdentity{typeof(min)}}) where {T <: Number} =
    typemax(T)

Base.convert(::Type{T}, ::Union{SpecificIdentity{typeof(max)}}) where {T <: Number} =
    typemin(T)
=#

end # module
