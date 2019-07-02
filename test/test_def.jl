module TestDef

using Test
using UniversalIdentity: Id, hasidentity, isknown

module CleanNameSpace
    using UniversalIdentity: @def
    add(x, y) = x + y
    @def add
end

@testset "CleanNameSpace" begin
    add = CleanNameSpace.add
    @test !isdefined(CleanNameSpace, :UniversalIdentity)
    @test hasidentity(add)
    @test isknown(Id(add))
    @test add(Id(add), :x) == :x
end

module NonFunction
    using UniversalIdentity: @def
    struct Add end
    const add = Add()
    add(x, y) = x + y
    @def add
end

@testset "NonFunction" begin
    add = NonFunction.add
    @test !(add isa Function)
    @test hasidentity(add)
    @test isknown(Id(add))
    @test add(Id(add), :x) == :x
end

end  # module
