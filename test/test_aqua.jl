module TestAqua

import Setfield
using Aqua
using BangBang
using InitialValues
using Test

Aqua.test_all(InitialValues)

@testset "Test ambiguities with `BangBang`" begin
    if v"1.6.0-DEV.816" <= VERSION < v"1.6.0-DEV.875"
        # Maybe remove this branch?
        @warn "Ignoring ambiguities from `Base` to workaround JuliaLang/julia#36962"
        packages = [InitialValues, BangBang]
    else
        packages = [InitialValues, BangBang, Base]
    end
    Aqua.test_ambiguities(packages; exclude = [Base.get, Setfield.set, Setfield.modify])
end

@testset "Compare test/Project.toml and test/environments/main/Project.toml" begin
    @test Text(read(joinpath(@__DIR__, "Project.toml"), String)) ==
          Text(read(joinpath(@__DIR__, "environments", "main", "Project.toml"), String))
end

end  # module
