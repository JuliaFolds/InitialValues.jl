module InitialValues

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end InitialValues

export INIT, InitialValue, asmonoid

include("prettyexpr.jl")
include("broadcastable.jl")

abstract type InitialValue end
abstract type SpecificInitialValue{OP} <: InitialValue end
abstract type NonspecificInitialValue <: InitialValue end

"""
    InitialValue(OP)

Create a generic (left) identity for a binary operator `op`.  For
general binary function, it provides an identity-like generic default
value (see `BangBang.push!!`).

# Examples
```jldoctest
julia> using InitialValues

julia> InitialValue(*) isa InitialValues.InitialValue
true

julia> InitialValue(*) * 1
1

julia> InitialValue(*) * missing
missing

julia> InitialValue(*) * "right"
"right"

julia> InitialValue(*) * :actual_anything_works
:actual_anything_works

julia> foldl(+, 1:3, init=InitialValue(+))
6

julia> float(InitialValue(*))
1.0

julia> Integer(InitialValue(+))
0
```
"""
InitialValue(::OP) where {OP} = InitialValueOf{OP}()
@deprecate Init(op) InitialValue(op)

struct TypeOfINIT <: NonspecificInitialValue end

"""
    INIT :: InitialValue

A generic initial value.  Unlike [`InitialValue`](@ref), this does not detect
an error when `INIT` is used with unintended operations.

# Examples
```jldoctest
julia> using InitialValues

julia> InitialValue(+) * 0  # `InitialValue(op)` must be used with `op`
ERROR: MethodError: no method matching *(::InitialValues.InitialValueOf{typeof(+)}, ::Int64)
[...]

julia> INIT * 123
123

julia> foldl(+, 1:3, init=INIT)
6
```
"""
const INIT = TypeOfINIT()

function Base.show(io::IO, ::TypeOfINIT)
    if !get(io, :limit, false)
        # Don't show full name in REPL etc.:
        print(io, "InitialValues.")
    end
    print(io, "INIT")
end

struct InitialValueOf{OP} <: SpecificInitialValue{OP} end

const GenericInitialValue{OP} = Union{SpecificInitialValue{OP},NonspecificInitialValue}

function Base.show(io::IO, ::InitialValueOf{OP}) where {OP}
    if !get(io, :limit, false)
        # Don't show full name in REPL etc.:
        print(io, "InitialValues.")
    end
    op = string(OP)
    if startswith(op, "typeof(") && endswith(op, ")")
        print(io, "InitialValue(", op[length("typeof(") + 1 : end - length(")")], ")")
    else
        print(io, "InitialValue(::", op, ")")
    end
end

itypeof_impl(op) = :(GenericInitialValue{typeof($op)})
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

julia> InitialValues.isknown(InitialValue(+))
true

julia> InitialValues.isknown(InitialValue((x, y) -> x + y))
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

Base.promote_rule(::Type{I}, ::Type{S}) where {I<:InitialValue,S} = Union{I,S}
if VERSION < v"1.3"
    Base.promote_rule(::Type{I}, ::Type{Any}) where {I<:InitialValue} = Any
end

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

struct AdjoinIdentity{T} <: Function
    op::T
end

"""
    asmonoid(op) -> op′

"Add" (adjoin) an identity element to the semigroup `op` if necessary
and return the monoid `op′`.

# Examples
```jldoctest
julia> using InitialValues

julia> asmonoid(*) === *  # do nothing if `InitialValue` is already defined
true

julia> append!′ = asmonoid(append!);

julia> xs = [];

julia> append!′(InitialValue(append!′), xs) === xs
true

julia> foldl(append!′, [xs, [1], [2, 3]], init=InitialValue(append!′))
3-element Array{Any,1}:
 1
 2
 3

julia> ans === xs  # `xs` is modified
true
```
"""
asmonoid(op) = hasinitialvalue(op) ? op : AdjoinIdentity(op)

(sg::AdjoinIdentity)(x, y) = sg.op(x, y)
(::AdjoinIdentity{OP})(::SpecificInitialValue{AdjoinIdentity{OP}}, x) where OP =
    x
(::AdjoinIdentity{OP})(x, ::SpecificInitialValue{AdjoinIdentity{OP}}) where OP =
    x
(::AdjoinIdentity{OP})(::SpecificInitialValue{AdjoinIdentity{OP}},
                       x::SpecificInitialValue{AdjoinIdentity{OP}}) where OP = x
hasinitialvalue(::Type{AdjoinIdentity{T}}) where {T} = true

Broadcast.broadcastable(init::InitialValue) = Singleton(init)

end # module
