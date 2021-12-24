module TestBasics

using Test
using InitialValues
using InitialValues: isknown, hasinitialvalue

OPS = [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]

@testset for op in OPS
    @test op(InitialValue(op), :anything) === :anything
    @test op(:anything, InitialValue(op)) === :anything
    @test op(INIT, :anything) === :anything
    @test op(:anything, INIT) === :anything
    @test hasinitialvalue(op)
    @test hasinitialvalue(typeof(op))
    @test isknown(InitialValue(op))
end

@testset "show" begin
    @testset "$desired" for (op, desired) in [
        (+, "InitialValue(+)"),
        (*, "InitialValue(*)"),
        (|, "InitialValue(|)"),
        (&, "InitialValue(&)"),
        (min, "InitialValue(min)"),
        (max, "InitialValue(max)"),
    ]
        @test repr(InitialValue(op); context=:limit => true) == desired
        @test repr(InitialValue(op)) == "InitialValues.$desired"
        @test string(InitialValue(op)) == "InitialValues.$desired"
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
    @test min(InitialValue(min), missing) === missing
    @test max(InitialValue(max), missing) === missing
end

@testset "promote" begin
    for op in OPS
        T = typeof(InitialValue(op))
        @test promote_type(T, Val{0}) == Union{T,Val{0}}
    end
end

@testset "convert" begin
    @testset "float" begin
        @test float(InitialValue(+)) === 0.0
        @test float(InitialValue(*)) === 1.0
        @test float(InitialValue(Base.add_sum)) === 0.0
        @test float(InitialValue(Base.mul_prod)) === 1.0
    end
    @testset "Integer" begin
        @test Integer(InitialValue(+)) === 0
        @test Integer(InitialValue(*)) === 1
        @test Integer(InitialValue(Base.add_sum)) === 0
        @test Integer(InitialValue(Base.mul_prod)) === 1
    end
    @testset for T in [
        Int,
        UInt8,
        Float64,
        Float32,
    ]
        @test convert(T, InitialValue(+))::T == 0
        @test convert(T, InitialValue(*))::T == 1
        @test convert(T, InitialValue(Base.add_sum))::T == 0
        @test convert(T, InitialValue(Base.mul_prod))::T == 1
    end

    @test convert(String, InitialValue(*)) === ""
end

@testset "asmonoid" begin
    absmin = asmonoid() do a, b
        abs(a) < abs(b) ? a : b
    end
    @test absmin(InitialValue(absmin), Inf) === Inf
    @test absmin(missing, InitialValue(absmin)) === missing
    @test absmin(InitialValue(absmin), InitialValue(absmin)) === InitialValue(absmin)
    @test hasinitialvalue(absmin)
    @test hasinitialvalue(typeof(absmin))
    @test isknown(InitialValue(absmin))

    @test asmonoid(+) === +

    @test_throws Union{ArgumentError,MethodError} Base.reduce_empty(absmin, Int)
end

end  # module
