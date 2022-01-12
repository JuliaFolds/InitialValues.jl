# See also https://github.com/JuliaLang/julia/pull/35778

struct Singleton{T}
    value::T
end

Base.ndims(::Singleton) = 0
Base.ndims(::Type{<:Singleton}) = 0
Base.size(::Singleton) = ()
Base.axes(::Singleton) = ()
Base.length(::Singleton) = 1
Base.eltype(::Type{Singleton{T}}) where {T} = T
Base.getindex(s::Singleton) = s.value
Base.getindex(s::Singleton, ::CartesianIndex{0}) = s.value
Base.iterate(s::Singleton) = (s.value, nothing)
Base.iterate(::Singleton, ::Nothing) = nothing

Base.IteratorSize(::Type{<:Singleton}) = Base.HasLength()
Base.IteratorEltype(::Type{Singleton{T}}) where {T} = Base.HasEltype()
