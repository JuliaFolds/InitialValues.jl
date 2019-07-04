module TestDef

using Test
using Initials: Init, hasinitial, isknown

module CleanNameSpace
    using Initials: @def, @disambiguate
    add(x, y) = x + y
    got(x) = string("Got: ", repr(x))
    @def add got(x)
    @disambiguate add Missing got(x)
end

@testset "CleanNameSpace" begin
    add = CleanNameSpace.add
    @test !isdefined(CleanNameSpace, :Initials)
    @test hasinitial(add)
    @test isknown(Init(add))
    @test add(Init(add), :x) == "Got: :x"
    @test add(Init(add), missing) == "Got: missing"
end

module NonFunction
    using Initials: @def, @disambiguate
    struct Add end
    const add = Add()
    add(x, y) = x + y
    @def add
    @disambiguate add Missing "Got: $x"
end

@testset "NonFunction" begin
    add = NonFunction.add
    @test !(add isa Function)
    @test hasinitial(add)
    @test isknown(Init(add))
    @test add(Init(add), :x) == :x
    @test add(Init(add), missing) == "Got: missing"
end

end  # module
