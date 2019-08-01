module InitialValues

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia" => "```jldoctest README")
end InitialValues

export Init

"""
    Init(op) :: InitialValue

Create a generic (left) identity for a binary operator `op`.  For
general binary function, it provides an identity-like generic default
value (see `BangBang.push!!`).

# Examples
```jldoctest
julia> using InitialValues

julia> Init(*) isa InitialValues.InitialValue
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
Init(::OP) where OP = InitialValueOf{OP}()

include("prettyexpr.jl")

"""
    InitialValues.InitialValue

An abstract super type of all generic initial value types.
"""
abstract type InitialValue end
abstract type SpecificInitialValue{OP} <: InitialValue end
# abstract type GenericIdentity <: AbstractIdentity end

struct InitialValueOf{OP} <: SpecificInitialValue{OP} end

function Base.show(io::IO, ::InitialValueOf{OP}) where {OP}
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

itypeof_impl(op) = :(SpecificInitialValue{typeof($op)})
@eval itypeof(op) = $(itypeof_impl(:op))

"""
    InitialValues.hasinitialvalue(op) :: Bool

# Examples
```jldoctest
julia> using InitialValues

julia> all(InitialValues.hasinitialvalue, [
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

julia> InitialValues.hasinitialvalue((x, y) -> x + y)
false
```
"""
hasinitialvalue(::OP) where OP = hasinitialvalue(OP)
hasinitialvalue(::Type) = false

"""
    InitialValues.isknown(::InitialValue) :: Bool

# Examples
```jldoctest
julia> using InitialValues

julia> InitialValues.isknown(Init(+))
true

julia> InitialValues.isknown(Init((x, y) -> x + y))
false
```
"""
isknown(::SpecificInitialValue{OP}) where OP = hasinitialvalue(OP)

def_impl(op, x, y) =
    quote
        $op(::$(itypeof_impl(op)), $x) = $y
        InitialValues.hasinitialvalue(::Type{typeof($op)}) = true
    end

def_monoid_impl(op, x) =
    quote
        $op(::$(itypeof_impl(op)), $x::$(itypeof_impl(op))) = $x
        $op($x, ::$(itypeof_impl(op))) = $x
        $(def_impl(op, x, x))
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

"""
    InitialValues.@def_monoid op

Define a generic identity for a binary operator `op`.
`InitialValues.@def_monoid op` is expanded to

```julia
$(prettyexpr(def_monoid_impl(:op, :x)))
```
"""
macro def_monoid(op)
    def_monoid_impl(esc(op), esc(:x))
end

disambiguate_impl(op, other, x) =
    quote
        $op(::$(itypeof_impl(op)), $x::$other) = $x
        $op($x::$other, ::$(itypeof_impl(op))) = $x
    end

"""
    InitialValues.@disambiguate op OtherType

Disambiguate the method introduced by [`@def_monoid`](@ref).

It is expanded to

```julia
$(prettyexpr(disambiguate_impl(:op, :OtherType, :x)))
```
"""
macro disambiguate(op, other)
    disambiguate_impl(esc(op), esc(other), esc(:x))
end

@def_monoid Base.:*
@def_monoid Base.:+
@def_monoid Base.:&
@def_monoid Base.:|
@def_monoid Base.min
@def_monoid Base.max
@def_monoid Base.add_sum
@def_monoid Base.mul_prod

@disambiguate Base.min Missing
@disambiguate Base.max Missing

const ZeroType = Union{
    SpecificInitialValue{typeof(+)},
    SpecificInitialValue{typeof(Base.add_sum)},
}
const OneType = Union{
    SpecificInitialValue{typeof(*)},
    SpecificInitialValue{typeof(Base.mul_prod)},
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
Base.convert(::Type{T}, ::Union{SpecificInitialValue{typeof(min)}}) where {T <: Number} =
    typemax(T)

Base.convert(::Type{T}, ::Union{SpecificInitialValue{typeof(max)}}) where {T <: Number} =
    typemin(T)
=#

end # module
