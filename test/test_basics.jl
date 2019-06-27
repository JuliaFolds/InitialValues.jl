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

end  # module
