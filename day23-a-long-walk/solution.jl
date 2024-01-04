function read_input(fn)
    open(fn) do f
        grid = []
        for line in readlines(f)
            line = strip(line)
            if line == ""
                continue
            end
            push!(grid, line)
        end
        return grid
    end
end

function get_start_end(grid)
    start = nothing
    e = nothing
    for (x, c) in enumerate(grid[1])
        if c == '.'
            start = (x, 1)
            break
        end
    end

    for (x, c) in enumerate(grid[end])
        if c == '.'
            e = (x, length(grid))
            break
        end
    end

    return (start, e)
end


function get_available_steps(x, y, grid, ice=true)
    c = grid[y][x]
    steps = []
    for (dx, dy) in ((1, 0), (-1, 0), (0, 1), (0, -1))
        xx, yy = x+dx, y+dy
        if xx < 1 || xx > length(grid[1]) || yy < 1 || yy > length(grid)
            continue
        end
        if grid[yy][xx] == '#'
            continue
        end
        if ice
            if c == '>' && (dx, dy) != (1, 0)
                continue
            elseif c == '<' && (dx, dy) != (-1, 0)
                continue
            elseif c == '^' && (dx, dy) != (0, -1)
                continue
            elseif c == 'v' && (dx, dy) != (0, 1)
                continue
            end
        end
        push!(steps, (xx, yy))
    end
    return steps
end

function part1(grid)
    start, target = get_start_end(grid)

    q = [(start, Set())]
    max_steps = 0
    while length(q) > 0
        tile, path = popfirst!(q)
        if tile == target
            if length(path) > max_steps
                max_steps = length(path) 
                continue
            end
        end

        for (nx, ny) in get_available_steps(tile[1], tile[2], grid)
            if grid[ny][nx] == '#'
                continue
            end
            if (nx, ny) in path
                continue
            end
            push!(q, ((nx, ny), union(path, Set([tile]))))
        end
    end

    return max_steps
end

function find_junctions(grid)
    junctions = Set()
    for (y, row) in enumerate(grid)
        for (x, c) in enumerate(row)
            if c != '#'
                steps = get_available_steps(x, y, grid, false)
                if length(steps) > 2
                    push!(junctions, (x, y))
                end
            end
        end
    end
    return junctions
end

function reach_junctions(node, grid, junctions)
    q = [(node, 0)]
    seen = Set()
    reachable = Dict()
    
    while length(q) > 0
        n, steps = popfirst!(q)
        if n in seen
            continue
        end
        push!(seen, n)
        if n in junctions && n != node
            reachable[n] = max(get(reachable, n, 0), steps)
            continue
        end
        for (sx, sy) in get_available_steps(n[1], n[2], grid, false)
            if (sx, sy) in seen
                continue
            end
            push!(q, ((sx, sy), steps+1))
        end
    end
    return reachable
end

function build_graph(grid)
    graph = Dict()
    junctions = find_junctions(grid)
    start, exit = get_start_end(grid)
    push!(junctions, start)
    push!(junctions, exit)

    for node in junctions
        reachable = reach_junctions(node, grid, junctions)
        graph[node] = reachable
    end

    return graph
end

function longest_path(node, target, graph, path, cache)
    if node == target
        return 0
    end
    results = []
    for (ns, nsteps) in graph[node]
        if ns in path
            continue
        end
        result = longest_path(ns, target, graph, union(path, Set([ns])), cache)
        if result !== nothing
            push!(results, result + nsteps)
        end
    end
    if length(results) == 0
        return nothing
    end

    return max(results...)
end

function part2(grid)
    start, target = get_start_end(grid)
    graph = build_graph(grid)
    return longest_path(start, target, graph, Set([start]), Dict())
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))