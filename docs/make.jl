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
    assets=String[],
)

deploydocs(;
    repo="github.com/tkf/UniversalIdentity.jl",
)
