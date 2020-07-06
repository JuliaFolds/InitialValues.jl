module TestDeprecated

using Test
using InitialValues

@testset "Init" begin
    @test_deprecated Init(+)
end

end  # module
