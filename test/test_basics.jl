module TestBasics

using Test
using UniversalIdentity
using UniversalIdentity: isknown, hasidentity


@testset for op in [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]
    @test op(Id(op), :anything) === :anything
    @test hasidentity(op)
    @test hasidentity(typeof(op))
    @test isknown(Id(op))
end

@testset "show" begin
    @testset "$desired" for (op, desired) in [
        (+, "Id(+)"),
        (*, "Id(*)"),
        (|, "Id(|)"),
        (&, "Id(&)"),
        (min, "Id(min)"),
        (max, "Id(max)"),
    ]
        @test repr(Id(op); context=:limit => true) == desired
        @test repr(Id(op)) == "UniversalIdentity.$desired"
        @test string(Id(op)) == "UniversalIdentity.$desired"
    end
end

@testset "hasidentity" begin
    @test !hasidentity(-)
    @test !hasidentity(typeof(-))
    @test !hasidentity(Int)
    @test !hasidentity(Type{Int})
end

@testset "missing" begin
    @test min(Id(min), missing) === missing
    @test max(Id(max), missing) === missing
end

@testset "convert" begin
    @testset "float" begin
        @test float(Id(+)) === 0.0
        @test float(Id(*)) === 1.0
        @test float(Id(Base.add_sum)) === 0.0
        @test float(Id(Base.mul_prod)) === 1.0
    end
    @testset "Integer" begin
        @test Integer(Id(+)) === 0
        @test Integer(Id(*)) === 1
        @test Integer(Id(Base.add_sum)) === 0
        @test Integer(Id(Base.mul_prod)) === 1
    end
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
