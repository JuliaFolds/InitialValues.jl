module TestDef

using Test
using UniversalIdentity: Identity, hasidentity

module CleanNameSpace
    using UniversalIdentity: @def
    add(x, y) = x + y
    @def add
end

@testset "CleanNameSpace" begin
    add = CleanNameSpace.add
    @test !isdefined(CleanNameSpace, :UniversalIdentity)
    @test hasidentity(add)
    @test add(Identity(add), :x) == :x
end

end  # module
