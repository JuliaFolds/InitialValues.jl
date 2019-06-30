module UniversalIdentity

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
end UniversalIdentity

using Requires

include("prettyexpr.jl")

"""
    Identity(op)

A generic (left) identity for `op`.

# Examples
```jldoctest
julia> using UniversalIdentity: Identity

julia> Identity(*) * 1
1

julia> Identity(*) * missing
missing

julia> Identity(*) * "right"
"right"

julia> Identity(*) * :actual_anything_works
:actual_anything_works

julia> foldl(+, 1:3, init=Identity(+))
6
```
"""
struct Identity{OP} end

Identity(::OP) where OP = Identity{OP}()

itypeof_impl(op) = :(typeof(Identity($op)))
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

function __init__()
    @require BangBang="198e06fe-97b7-11e9-32a5-e1d131e6ad66" begin
        @def BangBang.push!! [x]
        @def BangBang.append!!
    end
end

end # module
