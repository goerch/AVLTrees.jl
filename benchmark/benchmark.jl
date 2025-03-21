using AVLTrees, BenchmarkTools
using Random
using Plots
using DataFrames


function batch_insert!(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        insert!(t, i, i)
    end
end

function batch_delete!(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        delete!(t, i)
    end
end

function batch_find(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        i in t
    end
end

insertion_vec = []
deletion_vec = []
search_vec = []


d = DataFrame((op=[], time=[], n=[]))
x = [1_000, 10_000, 100_000, 1_000_000, 10_000_000]

function prepare_t(t)
    _t = deepcopy(t)
    for i in nums_test 
        insert!(_t, i, i) 
    end
    _t
end

for attempt in 1:1
    for N in x
        global t = AVLTree{Int64,Int64}()
        rng = MersenneTwister(1111)
        global nums_fill = rand(rng, Int64, N)
        global nums_test = rand(rng, Int64, 10_000)

        for i in nums_fill
            insert!(t, i, i)
        end

        insertion = @benchmark batch_insert!(_t, nums_test) setup=(_t =deepcopy(t))
        search = @benchmark batch_find(t, nums_test) setup=(_t = prepare_t(t))
        deletion = @benchmark batch_delete!(t, nums_test) setup=(_t = prepare_t(t))

        push!(d, ("insert", minimum(insertion).time, N))
        push!(d, ("delete", minimum(deletion).time,N))
        push!(d, ("search", minimum(search).time,N))
        println("done $N")
    end
end



c = combine(groupby(d, [:op,:n]), :time => minimum)

# plot(x, insertion_vec/1000, xscale=:log10, ylabel="us")
# plot(x, deletion_vec/1000, xscale=:log10, ylabel="us")
# plot(x, search_vec/1000, xscale=:log10, ylabel="us")


plot(
    x,
    [c[(c.op.=="insert"),:].time_minimum,c[(c.op.=="delete"),:].time_minimum, c[(c.op.=="search"),:].time_minimum],
    xscale = :log10,
    ylabel = "operation time [us]",
    xlabel = "N",
    xticks = [1e3, 1e4, 1e5, 1e6, 1e7],
    markershape =[:diamond :utriangle :dtriangle],
    labels= ["insert" "delete" "lookup"],
    legend=:topleft,
)

savefig("branch_results_new2.svg")
savefig("result_new2.png")
using CSV
CSV.write("branch_results_new2.csv", c)