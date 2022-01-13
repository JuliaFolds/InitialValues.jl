module TestSingleton

using InitialValues: Singleton
using Test

@testset begin
    s = Singleton(nothing)
    @test ndims(s) == 0
    @test ndims(typeof(s)) == 0
    @test size(s) == ()
    @test axes(s) == ()
    @test length(s) == 1
    @test eltype(s) === Nothing
    @test s[] === nothing
    @test s[CartesianIndex()] === nothing
    @test collect(s)::Vector{Nothing} == [nothing]
end

end  # module
