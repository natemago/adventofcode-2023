function read_input(fn)
    open(fn) do f
        graph = Dict()
        for line in readlines(f)
            line = strip(line)
            if line == ""
                continue
            end
            node, nodes = split(line, ":")
            node = strip(node)
            nodes = [strip(p) for p in split(nodes)]
            if !haskey(graph, node)
                graph[node] = Set()
            end
            for n in nodes
                push!(graph[node], n)
                if !haskey(graph, n)
                    graph[n] = Set()
                end
                push!(graph[n], node)
            end
        end
        return graph
    end
end

function longest_tree_path(node, graph)
    q = [(node, 0)]
    seen = Set()
    longest_path = 0
    while length(q) > 0
        node, path = popfirst!(q)
        if node in seen
            continue
        end
        push!(seen, node)
        if path > longest_path
            longest_path = path
        end
        for n in graph[node]
            if n in seen
                continue
            end
            push!(q, (n, path+1))
        end
    end
    return longest_path
end

function part1(graph)
    nodes = [k for k in keys(graph)]
    longest_paths = Dict()
    for n in nodes
        longest_paths[n] = longest_tree_path(n, graph)
    end

    edges = Dict()
    all_edges = []

    for (n1, conns) in graph
        for n2 in conns
            edges[(n1, n2)] = max(longest_paths[n1], longest_paths[n2])
            push!(all_edges, (n1, n2))
        end
    end

    sort!(all_edges, by=e -> edges[e])
    # Take the first 6 - should be both a -> b, and b -> a

    cut_wires = Set(all_edges[1:6])

    # BFS, but cannot go over cut_wires edges
    q = [all_edges[end][1]] # take one node
    group = Set()

    while length(q) > 0
        node = popfirst!(q)
        if q in group
            continue
        end
        push!(group, node)
        for n2 in graph[node]
            if (node, n2) in cut_wires
                continue
            end
            if n2 in group
                continue
            end
            push!(q, n2)
        end
    end
    group1 = length(group)
    group2 = length(graph) - group1
    return group1 * group2
end

println("Part 1: ", part1(read_input("input")))