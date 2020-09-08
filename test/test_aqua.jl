module TestAqua

import Setfield
using Aqua
using BangBang
using InitialValues
using Test

Aqua.test_all(InitialValues)

@testset "Test ambiguities with `BangBang`" begin
    if VERSION >= v"1.6.0-DEV.816"
        @warn "Ignoring ambiguities from `Base` to workaround JuliaLang/julia#36962"
        packages = [InitialValues, BangBang]
    else
        packages = [InitialValues, BangBang, Base]
    end
    Aqua.test_ambiguities(packages; exclude = [Base.get, Setfield.set, Setfield.modify])
end

end  # module
