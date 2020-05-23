module InitialValues

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end InitialValues

export INIT, Init, SomeInit, asmonoid, initialize

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
Init

include("prettyexpr.jl")

"""
    InitialValues.InitialValue

An abstract super type of all generic initial value types.
"""
abstract type InitialValue end
abstract type SpecificInitialValue{OP} <: InitialValue end
abstract type NonspecificInitialValue <: InitialValue end

"""
    InitialValues.Initializer <: Function

An `Initializer` object is a callable object `f` such that `f(op)`
produces an initial value for `op`.  The initial value returned by `f`
can be a "concrete" initial value instead of an `InitialValue`.

[`Init`](@ref) is an example of an initializer.

# Examples
```jldoctest
julia> using InitialValues

julia> Init isa InitialValues.Initializer
true

julia> SomeInit(0) isa InitialValues.Initializer
true
```
"""
Initializer
abstract type Initializer <: Function end
struct InitOf{IV <: InitialValue} <: Initializer end
(::InitOf{IV})(::OP) where {IV, OP} = IV{OP}()

initialize(f::Initializer, op) = check_init(f(op), f, op)
initialize(init, _) = init

check_init(init, f, op) = (_check_init(init, f, op); init)
_check_init(_, _, _) = nothing
_check_init(init::SpecificInitialValue, f::Initializer, op) =
    isknown(init) || throw(UndefinedInitialValueError(f, op))

# Maybe parameterized by `initializer` type so that each initializer
# can creates specific error message?
struct UndefinedInitialValueError <: Exception
    initializer
    op
end

function Base.showerror(io::IO, e::UndefinedInitialValueError)
    initializer = e.initializer
    op = e.op
    additional_info = initializer === Init ? "" : """

    Additional information:
        Init = $(repr(initializer; context = io))
    """
    print(io, "UndefinedInitialValueError: ")
    print(io, strip("""
    Default initial value `Init(op)` is not defined for the binary function
        op = $(repr(op; context = io))
    Note that `op` must be a well known binary operations like `+` or `*`.
    See InitialValues.jl documentation for more information.

    This error can typically be avoided by providing the an initial value or
    the identity element (e.g., keyword argument `init` for `reduce`).
    $additional_info"""))
end

"""
    initialize(f::Initializer, op) -> f(op)
    initialize(init, _) -> init

Return an initial value for `op`.  Throw an error if `f(op)` creates unknown
initial value.

# Examples
```jldoctest
julia> using InitialValues

julia> initialize(Init, +)
Init(+)

julia> initialize(123, +)
123

julia> initialize(SomeInit(Init), +)  # wrap with `SomeInit` to skip `initialize`
Init

julia> unknown_op(x, y) = x + 2y;

julia> InitialValues.initialize(Init, unknown_op)
ERROR: UndefinedInitialValueError: Default initial value `Init(op)` is not defined for the binary function
    op = unknown_op
[...]
```
"""
initialize

struct TypeOfINIT <: NonspecificInitialValue end

"""
    INIT :: InitialValue

A generic initial value.  Unlike [`Init`](@ref), this does not detect
an error when `INIT` is used with unintended operations.

# Examples
```jldoctest
julia> using InitialValues

julia> Init(+) * 0  # `Init(op)` must be used with `op`
ERROR: MethodError: no method matching *(::InitialValues.InitialValueOf{typeof(+)}, ::Int64)
[...]

julia> INIT * 123
123

julia> foldl(+, 1:3, init=INIT)
6
```
"""
const INIT = TypeOfINIT()

function Base.show(io::IO, ::TypeOfINIT) where {OP}
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
        print(io, "Init(", op[length("typeof(") + 1 : end - length(")")], ")")
    else
        print(io, "Init(::", op, ")")
    end
end

const Init = InitOf{InitialValueOf}()

"""
    SomeInit(x) :: Initializer

`SomeInit(x)` creates an [`Initializer`](@ref).  Like `Some` guard against
`something` (i.e., `something(Some(x)) === x`), `SomeInit` guard against
`initialize` (i.e., `initialize(SomeInit(x), _) === x`).

# Examples
```jldoctest
julia> using InitialValues

julia> SomeInit(123)(+)
123

julia> initialize(SomeInit(123), +)
123

julia> initialize(SomeInit(Init), +)  # avoid calling `Init(+)`
Init
```
"""
SomeInit
struct SomeInit{T} <: Initializer
    value::T
end
(init::SomeInit)(_) = init.value

function Base.show(io::IO, ::InitOf{InitialValueOf})
    if !get(io, :limit, false)
        # Don't show full name in REPL etc.:
        print(io, "InitialValues.")
    end
    print(io, "Init")
end

function Base.show(io::IO, ::MIME"text/plain", init::InitOf)
    if !get(io, :limit, false)
        invoke(show, Tuple{IO,MIME"text/plain",Function}, io, MIME"text/plain"(), init)
        return
    end
    show(io, init)
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

julia> asmonoid(*) === *  # do nothing if `Init` is already defined
true

julia> append!′ = asmonoid(append!);

julia> xs = [];

julia> append!′(Init(append!′), xs) === xs
true

julia> foldl(append!′, [xs, [1], [2, 3]], init=Init(append!′))
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

end # module
