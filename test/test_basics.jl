module TestBasics

using Test
using UniversalIdentity

@testset for op in [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]
    @test op(Id(op), :anything) === :anything
end

@testset "missing" begin
    @test min(Id(min), missing) === missing
    @test max(Id(max), missing) === missing
end

@testset "convert" begin
    @testset for T in [
        Int,
        UInt8,
        Float64,
        Float32,
    ]
        @test convert(T, Id(+))::T == 0
        @test convert(T, Id(*))::T == 1
        @test convert(T, Id(Base.add_sum))::T == 0
        @test convert(T, Id(Base.mul_prod))::T == 1
    end

    @test convert(String, Id(*)) === ""
end

end  # module
