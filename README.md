ReadOnlyArrays.jl
=============

This small package provides the `ReadOnlyArray` type, which wraps any `AbstractArray` and reimplements the array inferface without the setindex! function. The array can be used in all the usually ways but its elements cannot be modified. Attempting to set an element's value will raise an error. This functionality can be used to protect arrays that are intended to have unchanged values from unintended changes.

A `ReadOnlyArray` is not a `StaticArray` from [`StaticArrays.jl`](https://github.com/JuliaArrays/StaticArrays.jl). Static arrays are statically sized and also usually immutable, but are intended to accelerate common operations on *small* arrays. A `ReadOnlyArray` wraps arrays of any size and does not reimplement any functionality except the usual [array interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).

For convenience, there are also `ReadOnlyVector` and `ReadOnlyMatrix` aliases available.

### Installation

In the Julia REPL:

```julia
using Pkg
Pkg.add("ReadOnlyArrays")
```

or use package management mode by pressing `]` and entering `add ReadOnlyArrays`.

### Usage

Wrap any array by contructing a read-only version.
```julia
using ReadOnlyArrays

x = [1.0, 2.0, 3.0]
x = ReadOnlyArray(x)
```
The elements of this array cannot be modified. Attempting to set element values
```julia
x[1] = 2.0
```
will raise an error
```
ERROR: CanonicalIndexError: setindex! not defined for ReadOnlyVector{Float64, Vector{Float64}}
```
This read only array also identifies as a read only vector, for convenience.
```julia
typeof(y) <: ReadOnlyVector
```