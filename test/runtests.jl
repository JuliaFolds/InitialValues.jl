module TestInitialValues
using Test

@testset "$file" for file in sort([file for file in readdir(@__DIR__) if
                                   match(r"^test_.*\.jl$", file) !== nothing])
    # Ambiguity tests fail on Julia 1.0 as of writing.
    VERSION < v"1.1" && file == "test_aqua.jl" && continue

    include(file)
end

@testset "$file" for file in sort([
    file for file in readdir(joinpath(@__DIR__, "interop"))
    if match(r"^test_.*\.jl$", file) !== nothing
])
    include(joinpath("interop", file))
end

end  # module
