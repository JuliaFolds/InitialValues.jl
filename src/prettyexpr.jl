pprint(io, x) = print(io, x)
function pprint(io, x::Expr)
    if x.head == :block
        args = [a for a in x.args if !(a isa LineNumberNode)]
        if length(args) == 1
            pprint(io, args[1])
        else
            for (i, a) in enumerate(args)
                i == 1 || println(io)
                pprint(io, a)
            end
        end
    elseif x.head == :(=)
        @assert length(x.args) == 2
        pprint(io, x.args[1])
        print(io, " = ")
        pprint(io, x.args[2])
    else
        print(io, x)
    end
end

prettyexpr(x) = sprint(pprint, x)
