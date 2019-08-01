module TestPrettyExpr

using Test
using InitialValues: prettyexpr, def_impl, disambiguate_impl

parseall(code) = Meta.parse("begin $code end")

roundtrip(code::AbstractString) = prettyexpr(parseall(code))
roundtrip(ex::Expr) = parseall(prettyexpr(ex))

isalnn(x) = x isa LineNumberNode

normalize(x) = x
function normalize(x::Expr)
    args = normalize.(filter(!isalnn, x.args))
    if x.head == :block && length(args) == 1
        return args[1]
    end
    return Expr(x.head, args...)
end

eq(x, y) = normalize(x) == normalize(y)

@testset "$label" for (label, ex) in [
    (
        label = "f(x) = x",
        ex = :(f(x) = x),
    ),
    (
        label = "def_impl",
        ex = def_impl(:op, :x, :y),
    ),
    (
        label = "disambiguate_impl",
        ex = disambiguate_impl(:op, :RightType, :x),
    ),
]
    code = prettyexpr(ex)
    @test roundtrip(code) === code
    @test eq(roundtrip(ex), ex)
end

end  # module
