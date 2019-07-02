# UniversalIdentity

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tkf.github.io/UniversalIdentity.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/UniversalIdentity.jl/dev)
[![Build Status](https://travis-ci.com/tkf/UniversalIdentity.jl.svg?branch=master)](https://travis-ci.com/tkf/UniversalIdentity.jl)
[![Codecov](https://codecov.io/gh/tkf/UniversalIdentity.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tkf/UniversalIdentity.jl)
[![Coveralls](https://coveralls.io/repos/github/tkf/UniversalIdentity.jl/badge.svg?branch=master)](https://coveralls.io/github/tkf/UniversalIdentity.jl?branch=master)
[![Aqua QA](https://img.shields.io/badge/Aqua.jl-%F0%9F%8C%A2-aqua.svg)](https://github.com/tkf/Aqua.jl)

```julia
julia> using UniversalIdentity

julia> Id(+) + 1
1

julia> foldl(+, 1:3, init=Id(+))
6
```

Following methods are defined:

```julia
julia> Id(*) * 1
1

julia> Id(&) & 1
1

julia> Id(|) | 1
1

julia> min(Id(min), 1)
1

julia> max(Id(max), 1)
1

julia> Base.add_sum(Id(Base.add_sum), 1)
1

julia> Base.mul_prod(Id(Base.mul_prod), 1)
1
```

Method ambiguities are tested using [Aqua.jl](https://github.com/tkf/Aqua.jl).
