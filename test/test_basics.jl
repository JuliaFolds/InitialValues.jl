module TestBasics

using Test
using InitialValues
using InitialValues: isknown, hasinitialvalue

OPS = [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]

@testset for op in OPS
    @test op(Init(op), :anything) === :anything
    @test op(:anything, Init(op)) === :anything
    @test op(INIT, :anything) === :anything
    @test op(:anything, INIT) === :anything
    @test hasinitialvalue(op)
    @test hasinitialvalue(typeof(op))
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
        @test repr(Init(op)) == "InitialValues.$desired"
        @test string(Init(op)) == "InitialValues.$desired"
    end
    @testset "INIT" begin
        @test repr(INIT; context=:limit => true) == "INIT"
        @test repr(INIT) == "InitialValues.INIT"
        @test string(INIT) == "InitialValues.INIT"
    end
end

@testset "hasinitialvalue" begin
    @test !hasinitialvalue(-)
    @test !hasinitialvalue(typeof(-))
    @test !hasinitialvalue(Int)
    @test !hasinitialvalue(Type{Int})
end

@testset "missing" begin
    @test min(Init(min), missing) === missing
    @test max(Init(max), missing) === missing
end

@testset "promote" begin
    for op in OPS
        T = typeof(Init(op))
        @test promote_type(T, Val{0}) == Union{T,Val{0}}
    end
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

@testset "asmonoid" begin
    absmin = asmonoid() do a, b
        abs(a) < abs(b) ? a : b
    end
    @test absmin(Init(absmin), Inf) === Inf
    @test absmin(missing, Init(absmin)) === missing
    @test absmin(Init(absmin), Init(absmin)) === Init(absmin)
    @test hasinitialvalue(absmin)
    @test hasinitialvalue(typeof(absmin))
    @test isknown(Init(absmin))

    @test asmonoid(+) === +
end

end  # module
