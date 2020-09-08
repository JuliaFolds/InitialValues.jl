# InitialValues.jl: Canonical default initial values and identity elements for Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliafolds.github.io/InitialValues.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliafolds.github.io/InitialValues.jl/dev)
[![GitHub Actions](https://github.com/JuliaFolds/InitialValues.jl/workflows/Run%20tests/badge.svg)](https://github.com/JuliaFolds/InitialValues.jl/actions?query=workflow%3ARun+tests)
[![Codecov](https://codecov.io/gh/JuliaFolds/InitialValues.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaFolds/InitialValues.jl)
[![Coveralls](https://coveralls.io/repos/github/JuliaFolds/InitialValues.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaFolds/InitialValues.jl?branch=master)
[![Aqua QA](https://img.shields.io/badge/Aqua.jl-%F0%9F%8C%A2-aqua.svg)](https://github.com/tkf/Aqua.jl)

InitialValues.jl provides a generic singleton initial value `InitialValue(f)`
that can be used as `a₀` in `f(a₀, x)`.  For a binary operator `op`,
it means that `InitialValue(op)` acts like the identity for _any_ type of `x`:

```julia
julia> using InitialValues

julia> InitialValue(+) + 1
1

julia> 1.0 + InitialValue(+)
1.0

julia> foldl(+, 1:3, init=InitialValue(+))
6
```

Following methods are defined for the binary operators in `Base`:

```julia
julia> InitialValue(*) * 1
1

julia> InitialValue(&) & 1
1

julia> InitialValue(|) | 1
1

julia> min(InitialValue(min), 1)
1

julia> max(InitialValue(max), 1)
1

julia> Base.add_sum(InitialValue(Base.add_sum), 1)
1

julia> Base.mul_prod(InitialValue(Base.mul_prod), 1)
1
```

`InitialValue` is not called `Identity` because it is useful to define it for
functions that are not binary operator (symmetric in signature).  For
example, `push!!` in [BangBang.jl](https://github.com/JuliaFolds/BangBang.jl)
defines

``````julia
julia> using BangBang

julia> push!!(InitialValue(push!!), 1)
1-element Array{Int64,1}:
 1
``````

This provides a powerful pattern when combined with `foldl`:

``````julia
julia> foldl(push!!, (1, missing, 2.0), init=InitialValue(push!!))
3-element Array{Union{Missing, Float64},1}:
 1.0
  missing
 2.0
``````

[Transducers.jl](https://github.com/JuliaFolds/Transducers.jl) extensively
uses `InitialValue`.

As binary operators like `*` in `Base` are heavily overloaded,
creating generic definitions such as above could have introduced
method ambiguities.  To protect against such situation, InitialValues.jl is
tested using [Aqua.jl](https://github.com/tkf/Aqua.jl).
