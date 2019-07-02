var documenterSearchIndex = {"docs":
[{"location":"#UniversalIdentity.jl-1","page":"Home","title":"UniversalIdentity.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"UniversalIdentity\nUniversalIdentity.Id\nUniversalIdentity.@def\nUniversalIdentity.@disambiguate\nUniversalIdentity.hasidentity\nUniversalIdentity.isknown\nUniversalIdentity.Identity","category":"page"},{"location":"#UniversalIdentity","page":"Home","title":"UniversalIdentity","text":"UniversalIdentity\n\n(Image: Stable) (Image: Dev) (Image: Build Status) (Image: Codecov) (Image: Coveralls) (Image: Aqua QA)\n\njulia> using UniversalIdentity\n\njulia> Id(+) + 1\n1\n\njulia> foldl(+, 1:3, init=Id(+))\n6\n\nFollowing methods are defined:\n\njulia> Id(*) * 1\n1\n\njulia> Id(&) & 1\n1\n\njulia> Id(|) | 1\n1\n\njulia> min(Id(min), 1)\n1\n\njulia> max(Id(max), 1)\n1\n\njulia> Base.add_sum(Id(Base.add_sum), 1)\n1\n\njulia> Base.mul_prod(Id(Base.mul_prod), 1)\n1\n\nMethod ambiguities are tested using Aqua.jl.\n\n\n\n\n\n","category":"module"},{"location":"#UniversalIdentity.Id","page":"Home","title":"UniversalIdentity.Id","text":"Id(op) :: Identity\n\nA generic (left) identity for op.\n\nExamples\n\njulia> using UniversalIdentity\n\njulia> Id(*) isa UniversalIdentity.Identity\ntrue\n\njulia> Id(*) * 1\n1\n\njulia> Id(*) * missing\nmissing\n\njulia> Id(*) * \"right\"\n\"right\"\n\njulia> Id(*) * :actual_anything_works\n:actual_anything_works\n\njulia> foldl(+, 1:3, init=Id(+))\n6\n\njulia> float(Id(*))\n1.0\n\njulia> Integer(Id(+))\n0\n\n\n\n\n\n","category":"function"},{"location":"#UniversalIdentity.@def","page":"Home","title":"UniversalIdentity.@def","text":"UniversalIdentity.@def op [y = :x]\n\nDefine a generic (left) identity for op.\n\nUniversalIdentity.@def op is expanded to\n\nop(::SpecificIdentity{typeof(op)}, x) = x\nUniversalIdentity.hasidentity(::Type{typeof(op)}) = true\n\nFor operations like push!, it is useful to define the returned value to be different from x.  This can be done by using the second argument to the maco; i.e., UniversalIdentity.@def op [x] is expanded to\n\npush!(::SpecificIdentity{typeof(push!)}, x) = [x]\nUniversalIdentity.hasidentity(::Type{typeof(push!)}) = true\n\nNote that the second argument to op is always x.\n\n\n\n\n\n","category":"macro"},{"location":"#UniversalIdentity.@disambiguate","page":"Home","title":"UniversalIdentity.@disambiguate","text":"UniversalIdentity.@disambiguate op RightType [y = :x]\n\nDisambiguate the method introduced by @def.\n\nIt is expanded to\n\nop(::SpecificIdentity{typeof(op)}, x::RightType) = x\n\n\n\n\n\n","category":"macro"},{"location":"#UniversalIdentity.hasidentity","page":"Home","title":"UniversalIdentity.hasidentity","text":"UniversalIdentity.hasidentity(op) :: Bool\n\nExamples\n\njulia> using UniversalIdentity\n\njulia> all(UniversalIdentity.hasidentity, [\n           *,\n           +,\n           &,\n           |,\n           min,\n           max,\n           Base.add_sum,\n           Base.mul_prod,\n       ])\ntrue\n\njulia> UniversalIdentity.hasidentity((x, y) -> x + y)\nfalse\n\n\n\n\n\n","category":"function"},{"location":"#UniversalIdentity.isknown","page":"Home","title":"UniversalIdentity.isknown","text":"UniversalIdentity.isknown(::Identity) :: Bool\n\nExamples\n\njulia> using UniversalIdentity\n\njulia> UniversalIdentity.isknown(Id(+))\ntrue\n\njulia> UniversalIdentity.isknown(Id((x, y) -> x + y))\nfalse\n\n\n\n\n\n","category":"function"},{"location":"#UniversalIdentity.Identity","page":"Home","title":"UniversalIdentity.Identity","text":"UniversalIdentity.Identity\n\nAn abstract super type of all identity types.\n\n\n\n\n\n","category":"type"}]
}
