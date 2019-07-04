using Documenter, Initials

makedocs(;
    modules=[Initials],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/Initials.jl/blob/{commit}{path}#L{line}",
    sitename="Initials.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
    strict=VERSION < v"1.2-",
)

deploydocs(;
    repo="github.com/tkf/Initials.jl",
)
