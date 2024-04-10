using ReadOnlyArrays, Test

const x = rand(5, 10)
const r = ReadOnlyArray(x)

@testset "Constructors" begin
    @test ReadOnlyArray{Float64}(x) == r
    @test ReadOnlyArray{Float64,2}(x) == r
    @test ReadOnlyArray{Float64,2,typeof(x)}(x) == r
end


@testset "Interface" begin
    @testset "size" begin
        @test size(r) == size(x)
        @test size(r, 1) == size(x, 1)
        @test size(r, 2) == size(x, 2)
        @test length(r) == length(x)
    end

    @testset "indexing" begin
        @test firstindex(r) == firstindex(x)
        @test lastindex(r) == lastindex(x)
        @test IndexStyle(typeof(r)) == IndexStyle(typeof(x))
    end

    @testset "iteration" begin

        @test Base.IteratorSize(typeof(r)) == Base.IteratorSize(typeof(x))
        @test Base.IteratorEltype(typeof(r)) == Base.IteratorEltype(typeof(x))
        @test eltype(typeof(r)) == eltype(r) == eltype(x)

        @test r[end] == x[end]
        @test r[1:2, end] == x[1:2, end]
        @test_throws BoundsError r[0]
        @test_throws BoundsError r[end+1]

        @test iterate(r) == iterate(x)
        @test iterate(r, firstindex(r)) == iterate(x, firstindex(x))
        @test iterate(r, lastindex(r)) == iterate(x, lastindex(x))
        @test begin
            iterate(r, iterate(r, lastindex(r))[2]) == iterate(x, iterate(x, lastindex(x))[2])
        end
    end

    @testset "misc" begin
        @test axes(r) == axes(x)
        @test parent(r) === x
        # Test the implicit conversion from mutable array to read-only.
        f()::ReadOnlyArray{Float64,2} = x
        fa = f()
        @test fa isa ReadOnlyArray{Float64,2}
        @test fa == x

        a = ReadOnlyArray([1, 2])
        @test typeof(similar(a)) === Vector{Int64}

        @test copy(a) == [1, 2]
        @test typeof(copy(a)) === Vector{Int64}
    end
end


@testset "Aliases" begin
    @test ReadOnlyVector([4, 5]) isa ReadOnlyArray{Int,1,Vector{Int}}
    @test ReadOnlyVector{Int}([4, 5]) isa ReadOnlyArray{Int,1,Vector{Int}}
    @test ReadOnlyVector{Int,Vector{Int}}([4, 5]) isa ReadOnlyVector{Int,Vector{Int}}
    @test ReadOnlyMatrix([1 2; 3 4]) isa ReadOnlyArray{Int,2,Matrix{Int}}
    @test ReadOnlyMatrix{Int}([1 2; 3 4]) isa ReadOnlyArray{Int,2,Matrix{Int}}
    @test ReadOnlyMatrix{Int,Matrix{Int}}([1 2; 3 4]) isa ReadOnlyArray{Int,2,Matrix{Int}}
end

