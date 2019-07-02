module TestDef

using Test
using UniversalIdentity: Id, hasidentity, isknown

module CleanNameSpace
    using UniversalIdentity: @def, @disambiguate
    add(x, y) = x + y
    @def add
    @disambiguate add Missing "Got: $x"
end

@testset "CleanNameSpace" begin
    add = CleanNameSpace.add
    @test !isdefined(CleanNameSpace, :UniversalIdentity)
    @test hasidentity(add)
    @test isknown(Id(add))
    @test add(Id(add), :x) == :x
    @test add(Id(add), missing) == "Got: missing"
end

module NonFunction
    using UniversalIdentity: @def, @disambiguate
    struct Add end
    const add = Add()
    add(x, y) = x + y
    @def add
    @disambiguate add Missing "Got: $x"
end

@testset "NonFunction" begin
    add = NonFunction.add
    @test !(add isa Function)
    @test hasidentity(add)
    @test isknown(Id(add))
    @test add(Id(add), :x) == :x
    @test add(Id(add), missing) == "Got: missing"
end

end  # module
