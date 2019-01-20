module ReadOnlyArrays

export ReadOnlyArray

"""
    ReadOnlyArray(a)

Return a read-only view into the parent array `a`. Most iteration, indexing,
abstract arrays and strided arrays interface functions defined for array `a`
are transparently defined for `ReadOnlyArray(a)`.
The exceptions are `setindex!` which is not allowed for `ReadOnlyArray`
and `similar` which uses the default definitions for `AbstractArray` from Base.
Also when used in broadcasting `ReadOnlyArray` uses default broadcast machinery.

Use `parent` function to access the parent array of `ReadOnlyArray`.

# Examples
```jldoctest
julia> a = [1 2; 3 4]
2×2 Array{Int64,2}:
 1  2
 3  4

julia> r = ReadOnlyArray(a)
2×2 ReadOnlyArray{Int64,2,Array{Int64,2}}:
 1  2
 3  4

julia> r[1]
1

julia> r[1] = 10
ERROR: setindex! not defined for ReadOnlyArray{Int64,2,Array{Int64,2}}
[...]
```
"""
struct ReadOnlyArray{T,N,P} <: AbstractArray{T,N}
    parent::P
    ReadOnlyArray(parent::AbstractArray{T,N}) where{T,N} =
        new{T, N, typeof(parent)}(parent)
end

Base.IteratorSize(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P} =
    Base.IteratorSize(P)
Base.IteratorEltype(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P} =
    Base.IteratorEltype(P)
Base.eltype(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P} =
    eltype(P)
Base.size(roa::ReadOnlyArray, args...) = size(roa.parent, args...)
Base.@propagate_inbounds Base.getindex(roa::ReadOnlyArray, I...) =
    getindex(roa.parent, I...)
Base.firstindex(roa::ReadOnlyArray) = firstindex(roa.parent)
Base.lastindex(roa::ReadOnlyArray) = lastindex(roa.parent)
Base.IndexStyle(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P} = IndexStyle(P)
Base.iterate(roa::ReadOnlyArray, args...) = iterate(roa.parent, args...)
Base.length(roa::ReadOnlyArray) = length(roa.parent)

Base.axes(roa::ReadOnlyArray) = axes(roa.parent)
Base.strides(roa::ReadOnlyArray) = strides(roa.parent)
Base.unsafe_convert(p::Type{Ptr{T}}, roa::ReadOnlyArray) where {T} =
    Base.unsafe_convert(p, roa.parent)
Base.stride(roa::ReadOnlyArray, i::Int) = stride(roa.parent, i)
Base.parent(roa::ReadOnlyArray) = roa.parent

end # module
