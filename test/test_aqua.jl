module TestAqua

using Aqua
using InitialValues
using Setfield
using BangBang

Aqua.test_all(InitialValues)

Aqua.test_ambiguities(
    [InitialValues, BangBang, Base];
    exclude=[Base.get, Setfield.set, Setfield.modify],
)

end  # module
