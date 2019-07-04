module Initials

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
end Initials

export Init

"""
    Init(op) :: Initial

A generic (left) identity for `op`.

# Examples
```jldoctest
julia> using Initials

julia> Init(*) isa Initials.Initial
true

julia> Init(*) * 1
1

julia> Init(*) * missing
missing

julia> Init(*) * "right"
"right"

julia> Init(*) * :actual_anything_works
:actual_anything_works

julia> foldl(+, 1:3, init=Init(+))
6

julia> float(Init(*))
1.0

julia> Integer(Init(+))
0
```
"""
Init(::OP) where OP = IdentityOf{OP}()

include("prettyexpr.jl")

"""
    Initials.Initial

An abstract super type of all identity types.
"""
abstract type Initial end
abstract type SpecificInitial{OP} <: Initial end
# abstract type GenericIdentity <: AbstractIdentity end

struct IdentityOf{OP} <: SpecificInitial{OP} end

function Base.show(io::IO, ::IdentityOf{OP}) where {OP}
    if !get(io, :limit, false)
        # Don't show full name in REPL etc.:
        print(io, "Initials.")
    end
    op = string(OP)
    if startswith(op, "typeof(") && endswith(op, ")")
        print(io, "Init(", op[length("typeof(") + 1 : end - length(")")], ")")
    else
        print(io, "Init(::", op, ")")
    end
end

itypeof_impl(op) = :(SpecificInitial{typeof($op)})
@eval itypeof(op) = $(itypeof_impl(:op))

"""
    Initials.hasinitial(op) :: Bool

# Examples
```jldoctest
julia> using Initials

julia> all(Initials.hasinitial, [
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

julia> Initials.hasinitial((x, y) -> x + y)
false
```
"""
hasinitial(::OP) where OP = hasinitial(OP)
hasinitial(::Type) = false

"""
    Initials.isknown(::Initial) :: Bool

# Examples
```jldoctest
julia> using Initials

julia> Initials.isknown(Init(+))
true

julia> Initials.isknown(Init((x, y) -> x + y))
false
```
"""
isknown(::SpecificInitial{OP}) where OP = hasinitial(OP)

def_impl(op, x, y) =
    quote
        $op(::$(itypeof_impl(op)), $x) = $y
        Initials.hasinitial(::Type{typeof($op)}) = true
    end

"""
    Initials.@def op [y = :x]

Define a generic (left) identity for `op`.

`Initials.@def op` is expanded to

```julia
$(prettyexpr(def_impl(:op, :x, :x)))
```

For operations like `push!`, it is useful to define the returned value
to be different from `x`.  This can be done by using the second
argument to the maco; i.e., `Initials.@def op [x]` is
expanded to

```julia
$(prettyexpr(def_impl(:push!, :x, "[x]")))
```

Note that the second argument to `op` is always `x`.
"""
macro def(op, y = :x)
    def_impl(esc(op), esc(:x), esc(y))
end

disambiguate_impl(op, right, x, y) =
    quote
        $op(::$(itypeof_impl(op)), $x::$right) = $y
    end

"""
    Initials.@disambiguate op RightType [y = :x]

Disambiguate the method introduced by [`@def`](@ref).

It is expanded to

```julia
$(prettyexpr(disambiguate_impl(:op, :RightType, :x, :x)))
```
"""
macro disambiguate(op, right, y = :x)
    disambiguate_impl(esc(op), esc(right), esc(:x), esc(y))
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
    SpecificInitial{typeof(+)},
    SpecificInitial{typeof(Base.add_sum)},
}
const OneType = Union{
    SpecificInitial{typeof(*)},
    SpecificInitial{typeof(Base.mul_prod)},
}

Base.float(::ZeroType) = 0.0
Base.float(::OneType) = 1.0
Base.Integer(::ZeroType) = 0
Base.Integer(::OneType) = 1

Base.convert(::Type{T}, ::ZeroType) where {T <: Number} = zero(T)
Base.convert(::Type{T}, ::OneType) where {T <: Union{Number, AbstractString}} =
    one(T)

# Technically true, but could be a disaster in practice?:
#=
Base.convert(::Type{T}, ::Union{SpecificInitial{typeof(min)}}) where {T <: Number} =
    typemax(T)

Base.convert(::Type{T}, ::Union{SpecificInitial{typeof(max)}}) where {T <: Number} =
    typemin(T)
=#

end # module
