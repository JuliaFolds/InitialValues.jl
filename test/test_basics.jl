module TestBasics

using Test
using Initials
using Initials: isknown, hasinitial


@testset for op in [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]
    @test op(Init(op), :anything) === :anything
    @test hasinitial(op)
    @test hasinitial(typeof(op))
    @test isknown(Init(op))
end

@testset "show" begin
    @testset "$desired" for (op, desired) in [
        (+, "Init(+)"),
        (*, "Init(*)"),
        (|, "Init(|)"),
        (&, "Init(&)"),
        (min, "Init(min)"),
        (max, "Init(max)"),
    ]
        @test repr(Init(op); context=:limit => true) == desired
        @test repr(Init(op)) == "Initials.$desired"
        @test string(Init(op)) == "Initials.$desired"
    end
end

@testset "hasinitial" begin
    @test !hasinitial(-)
    @test !hasinitial(typeof(-))
    @test !hasinitial(Int)
    @test !hasinitial(Type{Int})
end

@testset "missing" begin
    @test min(Init(min), missing) === missing
    @test max(Init(max), missing) === missing
end

@testset "convert" begin
    @testset "float" begin
        @test float(Init(+)) === 0.0
        @test float(Init(*)) === 1.0
        @test float(Init(Base.add_sum)) === 0.0
        @test float(Init(Base.mul_prod)) === 1.0
    end
    @testset "Integer" begin
        @test Integer(Init(+)) === 0
        @test Integer(Init(*)) === 1
        @test Integer(Init(Base.add_sum)) === 0
        @test Integer(Init(Base.mul_prod)) === 1
    end
    @testset for T in [
        Int,
        UInt8,
        Float64,
        Float32,
    ]
        @test convert(T, Init(+))::T == 0
        @test convert(T, Init(*))::T == 1
        @test convert(T, Init(Base.add_sum))::T == 0
        @test convert(T, Init(Base.mul_prod))::T == 1
    end

    @test convert(String, Init(*)) === ""
end

end  # module
