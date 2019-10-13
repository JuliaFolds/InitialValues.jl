module TestAqua

using Aqua
using InitialValues
using BangBang

Aqua.test_all(InitialValues)

Aqua.test_ambiguities(
    [InitialValues, BangBang, Base];
)

end  # module
