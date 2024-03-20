module ReadOnlyArrays

export ReadOnlyArray, ReadOnlyVector, ReadOnlyMatrix

using Base: @propagate_inbounds

"""
    ReadOnlyArray(X)

Returns a read-only view into the parent array `X`.

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
CanonicalIndexError: setindex! not defined for ReadOnlyArray{Int64,2,Array{Int64,2}}
[...]
```
"""
struct ReadOnlyArray{T,N,A,LE,SI,AX,I} <: AbstractArray{T,N}
    parent::A
    _length::LE
    _size::SI
    _axes::AX
    _firstindex::I
    _lastindex::I

    function ReadOnlyArray(parent::AbstractArray{T,N}) where {T,N}
        _l = length(parent)
        _s = size(parent)
        _a = axes(parent)
        _f = firstindex(parent)
        _l = lastindex(parent)
        _I = typejoin(typeof(_f), typeof(_l))
        new{T,N,typeof.((parent,_l,_s,_a))...,_I}(parent, _l, _s, _a, _f, _l)
    end
end

ReadOnlyArray{T}(parent::AbstractArray{T,N}) where {T,N} = ReadOnlyArray(parent)

ReadOnlyArray{T,N}(parent::AbstractArray{T,N}) where {T,N} = ReadOnlyArray(parent)

ReadOnlyArray{T,N,P}(parent::P) where {T,N,P<:AbstractArray{T,N}} = ReadOnlyArray(parent)

#--------------------------------------
# aliases

const ReadOnlyVector{T,P} = ReadOnlyArray{T,1,P}

ReadOnlyVector(parent::AbstractVector) = ReadOnlyArray(parent)

const ReadOnlyMatrix{T,P} = ReadOnlyArray{T,2,P}

ReadOnlyMatrix(parent::AbstractMatrix) = ReadOnlyArray(parent)

#--------------------------------------
# interface, excluding setindex!() and similar()
# https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-parentay

Base.size(x::ReadOnlyArray) = x._size
Base.length(x::ReadOnlyArray) = x._length
Base.axes(x::ReadOnlyArray) = x._axes
Base.firstindex(x::ReadOnlyArray) = x._firstindex
Base.lastindex(x::ReadOnlyArray) = x._lastindex

# Special caching for `Array`
Base.size(a::ReadOnlyArray{<:Any,<:Any,<:Array}, d::Integer) = x._size[d]

Base.size(x::ReadOnlyArray, arg, args...) = size(x.parent, arg, args...)

@propagate_inbounds function Base.getindex(x::ReadOnlyArray, args...)
    getindex(x.parent, args...)
end

Base.IndexStyle(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P} = IndexStyle(P)

Base.iterate(x::ReadOnlyArray, args...) = iterate(x.parent, args...)

Base.similar(x::ReadOnlyArray) = similar(x.parent)

function Base.IteratorSize(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P}
    Base.IteratorSize(P)
end

function Base.IteratorEltype(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P}
    Base.IteratorEltype(P)
end

function Base.eltype(::Type{<:ReadOnlyArray{T,N,P}}) where {T,N,P}
    eltype(P)
end

Base.strides(x::ReadOnlyArray) = strides(x.parent)

function Base.unsafe_convert(p::Type{Ptr{T}}, x::ReadOnlyArray) where {T}
    Base.unsafe_convert(p, x.parent)
end

Base.stride(x::ReadOnlyArray, i::Int) = stride(x.parent, i)

Base.parent(x::ReadOnlyArray) = x.parent

function Base.convert(::Type{ReadOnlyArray{T,N}}, mutable_parent::AbstractArray{T,N}) where {T,N}
    ReadOnlyArray(mutable_parent)
end

end
