module InitialValues

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia" => "```jldoctest README")
end InitialValues

export Init

"""
    Init(op) :: Initial

Create a generic (left) identity for a binary operator `op`.  For
general binary function, it provides an identity-like generic default
value (see `BangBang.push!!`).

# Examples
```jldoctest
julia> using InitialValues

julia> Init(*) isa InitialValues.Initial
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
Init(::OP) where OP = InitialOf{OP}()

include("prettyexpr.jl")

"""
    InitialValues.Initial

An abstract super type of all generic initial value types.
"""
abstract type Initial end
abstract type SpecificInitial{OP} <: Initial end
# abstract type GenericIdentity <: AbstractIdentity end

struct InitialOf{OP} <: SpecificInitial{OP} end

function Base.show(io::IO, ::InitialOf{OP}) where {OP}
    if !get(io, :limit, false)
        # Don't show full name in REPL etc.:
        print(io, "InitialValues.")
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
    InitialValues.hasinitial(op) :: Bool

# Examples
```jldoctest
julia> using InitialValues

julia> all(InitialValues.hasinitial, [
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

julia> InitialValues.hasinitial((x, y) -> x + y)
false
```
"""
hasinitial(::OP) where OP = hasinitial(OP)
hasinitial(::Type) = false

"""
    InitialValues.isknown(::Initial) :: Bool

# Examples
```jldoctest
julia> using InitialValues

julia> InitialValues.isknown(Init(+))
true

julia> InitialValues.isknown(Init((x, y) -> x + y))
false
```
"""
isknown(::SpecificInitial{OP}) where OP = hasinitial(OP)

def_impl(op, x, y) =
    quote
        $op(::$(itypeof_impl(op)), $x) = $y
        InitialValues.hasinitial(::Type{typeof($op)}) = true
    end

"""
    InitialValues.@def op [y = :x]

Define a generic (left) identity for a binary operator `op`.  Specify
the second argument for a binary function in general.

`InitialValues.@def op` is expanded to

```julia
$(prettyexpr(def_impl(:op, :x, :x)))
```

For operations like `push!`, it is useful to define the returned value
to be different from `x`.  This can be done by using the second
argument to the maco; i.e., `InitialValues.@def push! [x]` is expanded to

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
    InitialValues.@disambiguate op RightType [y = :x]

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
