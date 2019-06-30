module TestBasics

using Test
using UniversalIdentity: Identity

@testset for op in [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]
    @test op(Identity(op), :anything) === :anything
end

@testset "missing" begin
    @test min(Identity(min), missing) === missing
    @test max(Identity(max), missing) === missing
end

@testset "convert" begin
    @testset for T in [
        Int,
        UInt8,
        Float64,
        Float32,
    ]
        @test convert(T, Identity(+))::T == 0
        @test convert(T, Identity(*))::T == 1
        @test convert(T, Identity(Base.add_sum))::T == 0
        @test convert(T, Identity(Base.mul_prod))::T == 1
    end

    @test convert(String, Identity(*)) === ""
end

end  # module
