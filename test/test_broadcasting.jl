module TestBroadcasting

using Test
using InitialValues

OPS = [*, +, |, &, min, max, Base.add_sum, Base.mul_prod]

@testset for op in OPS
    @test op.(InitialValue(op), 1:3) == 1:3
end

@testset "binary op" begin
    @test InitialValue(+) .+ (1:3) == 1:3
    @test InitialValue(*) .* (1:3) == 1:3
    @test InitialValue(|) .| (1:3) == 1:3
    @test InitialValue(&) .& (1:3) == 1:3
end

end  # module
