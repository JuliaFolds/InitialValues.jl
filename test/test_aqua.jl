module TestAqua

import Setfield
using Aqua
using BangBang
using InitialValues
using Test

Aqua.test_all(InitialValues)

Aqua.test_ambiguities(
    [InitialValues, BangBang, Base];
    exclude = [Base.get, Setfield.set, Setfield.modify],
)

@testset "Compare test/Project.toml and test/environments/main/Project.toml" begin
    @test Text(read(joinpath(@__DIR__, "Project.toml"), String)) ==
          Text(read(joinpath(@__DIR__, "environments", "main", "Project.toml"), String))
end

end  # module
