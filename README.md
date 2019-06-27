# UniversalIdentity

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tkf.github.io/UniversalIdentity.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/UniversalIdentity.jl/dev)
[![Build Status](https://travis-ci.com/tkf/UniversalIdentity.jl.svg?branch=master)](https://travis-ci.com/tkf/UniversalIdentity.jl)
[![Codecov](https://codecov.io/gh/tkf/UniversalIdentity.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tkf/UniversalIdentity.jl)
[![Coveralls](https://coveralls.io/repos/github/tkf/UniversalIdentity.jl/badge.svg?branch=master)](https://coveralls.io/github/tkf/UniversalIdentity.jl?branch=master)
[![Aqua QA](https://img.shields.io/badge/Aqua.jl-%F0%9F%8C%A2-aqua.svg)](https://github.com/tkf/Aqua.jl)

```julia
julia> using UniversalIdentity: Identity

julia> Identity(+) + 1
1

julia> foldl(+, 1:3, init=Identity(+))
6
```

Following methods are defined:

```julia
julia> Identity(*) * 1
1

julia> Identity(&) & 1
1

julia> Identity(|) | 1
1

julia> min(Identity(min), 1)
1

julia> max(Identity(max), 1)
1

julia> Base.add_sum(Identity(Base.add_sum), 1)
1

julia> Base.mul_prod(Identity(Base.mul_prod), 1)
1

julia> using BangBang: push!!, append!!

julia> push!!(Identity(push!!), 1.0)
1-element Array{Float64,1}:
 1.0

julia> append!!(Identity(append!!), [1.0])
1-element Array{Float64,1}:
 1.0
```

Method ambiguities are tested using [Aqua.jl](https://github.com/tkf/Aqua.jl).
