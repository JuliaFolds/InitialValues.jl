var documenterSearchIndex = {"docs":
[{"location":"#InitialValues.jl-1","page":"Home","title":"InitialValues.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"InitialValues\nInitialValues.Init\nInitialValues.@def\nInitialValues.@def_monoid\nInitialValues.@disambiguate\nInitialValues.hasinitialvalue\nInitialValues.isknown\nInitialValues.InitialValue","category":"page"},{"location":"#InitialValues","page":"Home","title":"InitialValues","text":"InitialValues.jl: Canonical default initial values and identity elements for Julia\n\n(Image: Stable) (Image: Dev) (Image: Build Status) (Image: Codecov) (Image: Coveralls) (Image: Aqua QA)\n\nInitialValues.jl provides a generic singleton initial value Init(f) that can be used as a₀ in f(a₀, x).  For a binary operator op, it means that Init(op) acts like the identity for any type of x:\n\njulia> using InitialValues\n\njulia> Init(+) + 1\n1\n\njulia> 1.0 + Init(+)\n1.0\n\njulia> foldl(+, 1:3, init=Init(+))\n6\n\nFollowing methods are defined for the binary operators in Base:\n\njulia> Init(*) * 1\n1\n\njulia> Init(&) & 1\n1\n\njulia> Init(|) | 1\n1\n\njulia> min(Init(min), 1)\n1\n\njulia> max(Init(max), 1)\n1\n\njulia> Base.add_sum(Init(Base.add_sum), 1)\n1\n\njulia> Base.mul_prod(Init(Base.mul_prod), 1)\n1\n\nInit is not called Identity because it is useful to define it for functions that are not binary operator (symmetric in signature).  For example, push!! in BangBang.jl defines\n\njulia> using BangBang\n\njulia> push!!(Init(push!!), 1)\n1-element Array{Int64,1}:\n 1\n\nThis provides a powerful pattern when combined with foldl:\n\njulia> foldl(push!!, (1, missing, 2.0), init=Init(push!!))\n3-element Array{Union{Missing, Float64},1}:\n 1.0\n  missing\n 2.0\n\nTransducers.jl extensively uses Init.\n\nAs binary operators like * in Base are heavily overloaded, creating generic definitions such as above could have introduced method ambiguities.  To protect against such situation, InitialValues.jl is tested using Aqua.jl.\n\n\n\n\n\n","category":"module"},{"location":"#InitialValues.Init","page":"Home","title":"InitialValues.Init","text":"Init(op) :: InitialValue\n\nCreate a generic (left) identity for a binary operator op.  For general binary function, it provides an identity-like generic default value (see BangBang.push!!).\n\nExamples\n\njulia> using InitialValues\n\njulia> Init(*) isa InitialValues.InitialValue\ntrue\n\njulia> Init(*) * 1\n1\n\njulia> Init(*) * missing\nmissing\n\njulia> Init(*) * \"right\"\n\"right\"\n\njulia> Init(*) * :actual_anything_works\n:actual_anything_works\n\njulia> foldl(+, 1:3, init=Init(+))\n6\n\njulia> float(Init(*))\n1.0\n\njulia> Integer(Init(+))\n0\n\n\n\n\n\n","category":"function"},{"location":"#InitialValues.@def","page":"Home","title":"InitialValues.@def","text":"InitialValues.@def op [y = :x]\n\nDefine a generic (left) identity for a binary operator op.  Specify the second argument for a binary function in general.\n\nInitialValues.@def op is expanded to\n\nop(::SpecificInitialValue{typeof(op)}, x) = x\nInitialValues.hasinitialvalue(::Type{typeof(op)}) = true\n\nFor operations like push!, it is useful to define the returned value to be different from x.  This can be done by using the second argument to the maco; i.e., InitialValues.@def push! [x] is expanded to\n\npush!(::SpecificInitialValue{typeof(push!)}, x) = [x]\nInitialValues.hasinitialvalue(::Type{typeof(push!)}) = true\n\nNote that the second argument to op is always x.\n\n\n\n\n\n","category":"macro"},{"location":"#InitialValues.@def_monoid","page":"Home","title":"InitialValues.@def_monoid","text":"InitialValues.@def_monoid op\n\nDefine a generic identity for a binary operator op. InitialValues.@def_monoid op is expanded to\n\nop(::SpecificInitialValue{typeof(op)}, x::SpecificInitialValue{typeof(op)}) = x\nop(x, ::SpecificInitialValue{typeof(op)}) = x\nop(::SpecificInitialValue{typeof(op)}, x) = x\nInitialValues.hasinitialvalue(::Type{typeof(op)}) = true\n\n\n\n\n\n","category":"macro"},{"location":"#InitialValues.@disambiguate","page":"Home","title":"InitialValues.@disambiguate","text":"InitialValues.@disambiguate op OtherType\n\nDisambiguate the method introduced by @def_monoid.\n\nIt is expanded to\n\nop(::SpecificInitialValue{typeof(op)}, x::OtherType) = x\nop(x::OtherType, ::SpecificInitialValue{typeof(op)}) = x\n\n\n\n\n\n","category":"macro"},{"location":"#InitialValues.hasinitialvalue","page":"Home","title":"InitialValues.hasinitialvalue","text":"InitialValues.hasinitialvalue(op) :: Bool\n\nExamples\n\njulia> using InitialValues\n\njulia> all(InitialValues.hasinitialvalue, [\n           *,\n           +,\n           &,\n           |,\n           min,\n           max,\n           Base.add_sum,\n           Base.mul_prod,\n       ])\ntrue\n\njulia> InitialValues.hasinitialvalue((x, y) -> x + y)\nfalse\n\n\n\n\n\n","category":"function"},{"location":"#InitialValues.isknown","page":"Home","title":"InitialValues.isknown","text":"InitialValues.isknown(::InitialValue) :: Bool\n\nExamples\n\njulia> using InitialValues\n\njulia> InitialValues.isknown(Init(+))\ntrue\n\njulia> InitialValues.isknown(Init((x, y) -> x + y))\nfalse\n\n\n\n\n\n","category":"function"},{"location":"#InitialValues.InitialValue","page":"Home","title":"InitialValues.InitialValue","text":"InitialValues.InitialValue\n\nAn abstract super type of all generic initial value types.\n\n\n\n\n\n","category":"type"}]
}
