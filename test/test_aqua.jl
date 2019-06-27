module TestAqua

using Aqua
using UniversalIdentity
using Setfield
using BangBang

Aqua.test_all(UniversalIdentity)

Aqua.test_ambiguities(
    [UniversalIdentity, BangBang, Base];
    exclude=[Base.get, Setfield.set, Setfield.modify],
)

end  # module
