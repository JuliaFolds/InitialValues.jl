module TestDef

using Test
using InitialValues: Init, hasinitialvalue, isknown

module CleanNameSpace
    using InitialValues: @def, @disambiguate
    add(x, y) = x + y
    got(x) = string("Got: ", repr(x))
    @def add got(x)
    @disambiguate add Missing
end

@testset "CleanNameSpace" begin
    add = CleanNameSpace.add
    @test !isdefined(CleanNameSpace, :InitialValues)
    @test hasinitialvalue(add)
    @test isknown(Init(add))
    @test add(Init(add), :x) == "Got: :x"
    @test add(Init(add), missing) === missing
end

module NonFunction
    using InitialValues: @def, @disambiguate
    struct Add end
    const add = Add()
    add(x, y) = x + y
    @def add
    @disambiguate add Missing
end

@testset "NonFunction" begin
    add = NonFunction.add
    @test !(add isa Function)
    @test hasinitialvalue(add)
    @test isknown(Init(add))
    @test add(Init(add), :x) == :x
    @test add(Init(add), missing) === missing
end

end  # module
