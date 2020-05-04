using Documenter, InitialValues

makedocs(;
    modules=[InitialValues],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/InitialValues.jl/blob/{commit}{path}#L{line}",
    sitename="InitialValues.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
    strict = true,
)

deploydocs(;
    repo="github.com/tkf/InitialValues.jl",
)
