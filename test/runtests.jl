using ReadOnlyArrays, Test, SparseArrays

@testset "ReadOnlyArrays" begin
    x = rand(5, 10)
    vx = view(x, 2:4, 3:8)
    s = sparse(x)
    vs = view(s, 2:4, 3:8)

    for a in [x, vx, s, vs]
        @testset "tests for $(typeof(a))" begin
            r = ReadOnlyArray(a)

            # Check the ability to construct it with type parameters.
            @test ReadOnlyArray{Float64}(a) == r
            @test ReadOnlyArray{Float64, 2}(a) == r
            @test ReadOnlyArray{Float64, 2, typeof(a)}(a) == r

            @test Base.IteratorSize(typeof(r)) == Base.IteratorSize(typeof(a))
            @test Base.IteratorEltype(typeof(r)) == Base.IteratorEltype(typeof(a))
            @test eltype(typeof(r)) == eltype(r) == eltype(a)
            @test size(r) == size(a)
            @test size(r, 1) == size(a, 1)
            @test size(r, 2) == size(a, 2)
            for (p, q) in zip(r, a)
                @test p == q
            end
            @test r[end] == a[end]
            @test r[1:2, end] == a[1:2, end]
            @test_throws BoundsError r[0]
            @test_throws BoundsError r[end+1]

            @test firstindex(r) == firstindex(a)
            @test lastindex(r) == lastindex(a)

            @test IndexStyle(typeof(r)) == IndexStyle(typeof(a))
            @test iterate(r) == iterate(a)
            @test iterate(r, firstindex(r)) == iterate(a, firstindex(a))
            @test iterate(r, lastindex(r)) == iterate(a, lastindex(a))
            @test iterate(r, iterate(r, lastindex(r))[2]) ==
                  iterate(a, iterate(a, lastindex(a))[2])
            @test length(r) == length(a)

            @test axes(r) == axes(a)
            @test parent(r) === a

            if !issparse(parent(a))
                @test strides(r) == strides(a)
                @test Base.unsafe_convert(Ptr{Float64}, r) ==
                      Base.unsafe_convert(Ptr{Float64}, a)
                @test stride(r, 1) == stride(a, 1)
            end
        end
    end

    @testset "Aliases" begin
        @test ReadOnlyVector([4, 5]) isa ReadOnlyArray{Int, 1, Vector{Int}}
        @test ReadOnlyVector{Int}([4, 5]) isa ReadOnlyArray{Int, 1, Vector{Int}}
        @test ReadOnlyVector{Int, Vector{Int}}([4, 5]) isa ReadOnlyVector{Int, Vector{Int}}
        @test ReadOnlyMatrix([1 2 ; 3 4]) isa ReadOnlyArray{Int, 2, Matrix{Int}}
        @test ReadOnlyMatrix{Int}([1 2 ; 3 4]) isa ReadOnlyArray{Int, 2, Matrix{Int}}
        @test ReadOnlyMatrix{Int, Matrix{Int}}([1 2 ; 3 4]) isa ReadOnlyArray{Int, 2, Matrix{Int}}
    end
end
