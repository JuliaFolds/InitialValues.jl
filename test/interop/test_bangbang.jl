module TestBangBang

using Test
using BangBang
using InitialValues: InitialValue, hasinitialvalue

@testset begin
    @test hasinitialvalue(push!!)
    @test hasinitialvalue(append!!)
    @test push!!(InitialValue(push!!), 1) == [1]
    @test append!!(InitialValue(append!!), [1]) == [1]
    @test append!!([1], InitialValue(append!!)) == [1]
end

@testset "promote" begin
    init = InitialValue(+)
    @test eltype(push!!([init], 0)) == Union{typeof(init),Int}
end

end  # module
