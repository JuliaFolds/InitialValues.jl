module TestBangBang

using Test
using BangBang
using InitialValues: Init, hasinitialvalue

@testset begin
    @test hasinitialvalue(push!!)
    @test hasinitialvalue(append!!)
    @test push!!(Init(push!!), 1) == [1]
    @test append!!(Init(append!!), [1]) == [1]
    @test append!!([1], Init(append!!)) == [1]
end

@testset "promote" begin
    init = Init(+)
    @test eltype(push!!([init], 0)) == Union{typeof(init),Int}
end

end  # module
