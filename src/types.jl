type PWLFunction{D}
    x::Vector{NTuple{D,Float64}}
    z::Vector{Float64}
    T::Vector{Vector{Int}}
    meta::Dict
end
function PWLFunction{D}(x::Vector{NTuple{D}}, z::Vector, T::Vector{Vector}, meta::Dict)
    (n = length(x)) == length(z) || error()
    for t in T
        (minimum(t) > 0 && maximum(t) <= n) || error()
    end
    PWLFunction{D}(x, z, T, meta)
end

PWLFunction(x, z, T) = PWLFunction(x, z, T, Dict())

typealias UnivariatePWLFunction PWLFunction{1}

function UnivariatePWLFunction(x, z)
    @assert issorted(x)
    PWLFunction(Tuple{Float64}[(xx,) for xx in x], convert(Vector{Float64}, z), [[i,i+1] for i in 1:length(x)-1])
end

function UnivariatePWLFunction(x, fz::Function)
    @assert issorted(x)
    PWLFunction(Tuple{Float64}[(xx,) for xx in x], map(t->convert(Float64,fz(t)), x), [[i,i+1] for i in 1:length(x)-1])
end

typealias  BivariatePWLFunction PWLFunction{2}

function BivariatePWLFunction(x, y, fz::Function; pattern=:BestFit)
    @assert issorted(x)
    @assert issorted(y)
    X = vec(Tuple{Float64,Float64}[(_x,_y) for _x in x, _y in y])
    Z = map(t -> convert(Float64,fz(t[1],t[2])), X)
    T = Vector{Vector{Int}}()
    m = length(x)
    n = length(y)
    for i in 1:length(x)-1, j in 1:length(y)-1
        SWt, NWt, NEt, SEt = sub2ind((m,n),i,j), sub2ind((m,n),i,j+1), sub2ind((m,n),i+1,j+1), sub2ind((m,n),i+1,j)
        xL, xU, yL, yU = x[i], x[i+1], y[j], y[j+1]
        @assert xL == X[SWt][1] == X[NWt][1]
        @assert xU == X[SEt][1] == X[NEt][1]
        @assert yL == X[SWt][2] == X[SEt][2]
        @assert yU == X[NWt][2] == X[NEt][2]
        SW, NW, NE, SE = fz(xL,yL), fz(xL,yU), fz(xU,yU), fz(xU,yL)
        mid1 = 0.5*(SW+NE)
        mid2 = 0.5*(NW+SE)

        # TODO: add methods for Union Jack
        if pattern == :Upper
            if mid1 > mid2
                t1 = [SWt,NWt,NEt]
                t2 = [SWt,NEt,SEt]
            else
                t1 = [SWt,NWt,SEt]
                t2 = [SEt,NWt,NEt]
            end
        elseif pattern == :Lower
            if mid1 > mid2
                t1 = [SWt,NWt,SEt]
                t2 = [SEt,NWt,NEt]
            else
                t1 = [SWt,NWt,NEt]
                t2 = [SWt,NEt,SEt]
            end
        elseif pattern == :BestFit
            mid3 = fz(0.5*(xL+xU), 0.5*(yL+yU))
            if abs(mid1-mid3) < abs(mid2-mid3)
                t1 = [SWt,NWt,NEt]
                t2 = [SWt,NEt,SEt]
            else
                t1 = [SWt,NWt,SEt]
                t2 = [SEt,NWt,NEt]
            end
        elseif pattern == :UnionJack

        else
            error()
        end
        push!(T, t1)
        push!(T, t2)
    end
    PWLFunction(X, Z, T, Dict(:structure=>pattern))
end
