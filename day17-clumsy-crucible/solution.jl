function read_input(fn)
    open(fn) do f
        return [[parse(Int64, c) for c in line] for line in readlines(f)]
    end
end

function print_grid(heatmap, path)
    for (y, row) in enumerate(heatmap)
        for (x, c) in enumerate(row)
            in_path = false
            for ((px, py), dir) in path
                if (x, y) == (px, py)
                    print(Dict(
                        (1, 0) => '>',
                        (0, 1) => 'V',
                        (-1, 0) => '<',
                        (0, -1) => '^',
                    )[dir])
                    in_path = true
                end
            end
            if !in_path
                print(c)
            end
        end
        println()
    end
end

mutable struct Heapqueue
    elements::Vector{Vector{Any}}
    elmap::Dict{Any, Any}
    count::Int64
end

function new_heap_q(size)
    elements = [[] for i in range(1, size)]
    return Heapqueue(elements, Dict(), 0)
end

function pushq(q::Heapqueue, elem, value)
    push!(q.elements[value], elem)
    q.elmap[elem] = (value, length(q.elements[value]))
    q.count += 1
end

function update_priority(q::Heapqueue, elem, new_value)
    value, i = q.elmap[elem]
    #deleteat!(q.elements[value], i)
    pop!(q.elements[value])
    q.count -= 1
    pushq(q, elem, new_value)
end

function pop_min(q::Heapqueue)
    if q.count == 0
        throw("pop from empty queue")
    end
    for els in q.elements
        if length(els) > 0
            el = popfirst!(els)
            q.count -= 1
            return el
        end
    end
end

function solve(heatmap, min_steps=0, max_steps=3)
    # (x, y, from_dir, to_dir, steps)
    MAX = 10000
    q = new_heap_q(MAX+1)
    pushq(q, (1, 1, (1, 0), (1, 0), 0), 1)
    pushq(q, (1, 1, (1, 0), (0, 1), 0), 1)
    dist = Dict()
    dist[(1, 1, (1, 0), (1, 0), 0)] = 0
    dist[(1, 1, (1, 0), (0, 1), 0)] = 0

    seen = Set()

    while q.count > 0
        x, y, fdir, todir, steps = pop_min(q)
        d = get(dist, (x, y, fdir, todir, steps), MAX)

        push!(seen, (x, y, fdir, todir, steps))
        
        nx, ny = x + todir[1], y + todir[2]

        if nx < 1 || nx > length(heatmap[1]) || ny < 1 || ny > length(heatmap)
            continue
        end

        available_dirs = []
        for (dx, dy) in ((0, 1), (0, -1), (1, 0), (-1, 0))
            if (dx, dy) == (-todir[1], -todir[2])
                continue
            end
            nsteps = 0
            if (dx, dy) == todir
                # forward
                if steps >= max_steps
                    continue
                end
                push!(available_dirs, ((dx, dy), steps+1))
            else
                # left/right
                if min_steps > 0 && steps < min_steps
                    continue
                end
                push!(available_dirs, ((dx, dy), 1))
            end
            for (ndir, nsteps) in available_dirs
                nnode = (nx, ny, todir, ndir, nsteps)
                if nnode in seen
                    continue
                end

                curr = get(dist, nnode, MAX)
                alt = d + heatmap[ny][nx]

                if !haskey(q.elmap, nnode)
                    pushq(q, nnode, MAX+1)
                end

                if alt < curr
                    dist[nnode] = alt
                    update_priority(q, nnode, alt+1)
                end

            end
        end

    end
    min_dist = MAX
    for (key, val) in dist
        if key[1] == length(heatmap[1]) && key[2] == length(heatmap)
            if min_steps > 0 && key[end] >= min_steps
                if val < min_dist
                    min_dist = val
                end
            else
                if val < min_dist
                    min_dist = val
                end
            end
        end
    end
    return min_dist
end

println("Part 1: ", solve(read_input("input"), 0, 3))
println("Part 2: ", solve(read_input("input"), 4, 10))