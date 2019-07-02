using Documenter, UniversalIdentity

makedocs(;
    modules=[UniversalIdentity],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/UniversalIdentity.jl/blob/{commit}{path}#L{line}",
    sitename="UniversalIdentity.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
    strict=VERSION < v"1.2-",
)

deploydocs(;
    repo="github.com/tkf/UniversalIdentity.jl",
)
