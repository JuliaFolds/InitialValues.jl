module TestAqua

using Aqua
using Initials
using Setfield
using BangBang

Aqua.test_all(Initials)

Aqua.test_ambiguities(
    [Initials, BangBang, Base];
    exclude=[Base.get, Setfield.set, Setfield.modify],
)

end  # module
