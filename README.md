# Initials

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tkf.github.io/Initials.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/Initials.jl/dev)
[![Build Status](https://travis-ci.com/tkf/Initials.jl.svg?branch=master)](https://travis-ci.com/tkf/Initials.jl)
[![Codecov](https://codecov.io/gh/tkf/Initials.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tkf/Initials.jl)
[![Coveralls](https://coveralls.io/repos/github/tkf/Initials.jl/badge.svg?branch=master)](https://coveralls.io/github/tkf/Initials.jl?branch=master)
[![Aqua QA](https://img.shields.io/badge/Aqua.jl-%F0%9F%8C%A2-aqua.svg)](https://github.com/tkf/Aqua.jl)

```julia
julia> using Initials

julia> Init(+) + 1
1

julia> foldl(+, 1:3, init=Init(+))
6
```

Following methods are defined:

```julia
julia> Init(*) * 1
1

julia> Init(&) & 1
1

julia> Init(|) | 1
1

julia> min(Init(min), 1)
1

julia> max(Init(max), 1)
1

julia> Base.add_sum(Init(Base.add_sum), 1)
1

julia> Base.mul_prod(Init(Base.mul_prod), 1)
1
```

Method ambiguities are tested using [Aqua.jl](https://github.com/tkf/Aqua.jl).
