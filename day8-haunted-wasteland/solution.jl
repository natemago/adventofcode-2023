function read_input(fn)
    open(fn) do f
        instructions = strip(readline(f))
        nodes = Dict()
        readline(f)
        for line in readlines(f)
            m = match(r"(\w+) = \((\w+), (\w+)\)", line)
            if m === nothing
                throw(line)
            end
            name, left, right = m[1], m[2], m[3]
            nodes[name] = Dict(
                "name" => name,
                "left" => left,
                "right" => right,
            )
        end
        return (instructions, nodes)
    end
end


function part1(instructions, nodes)
    start = nodes["AAA"]
    node = start
    steps = 0
    while true
        stop = false
        for inst in instructions
            steps += 1
            if inst == 'L'
                node = nodes[node["left"]]
            elseif inst == 'R'
                node = nodes[node["right"]]
            else
                throw(inst)
            end
            if node["name"] == "ZZZ"
                stop = true
                break
            end
        end
        if stop
            break
        end
    end
    return steps
end

function find_loop(node, nodes, instructions)
    seen = Dict(
        (0, node["name"]) => 0,
    )

    cycle::Dict{String, Any} = Dict(
        "detected" => Dict(),
    )

    steps = 0
    while true
        for (i, inst) in enumerate(instructions)
            steps += 1
            if inst == 'L'
                node = nodes[node["left"]]
            elseif inst == 'R'
                node = nodes[node["right"]]
            else
                throw(inst)
            end
            
            if endswith(node["name"], 'Z')
                cycle["detected"][node["name"]] = steps
            end

            if haskey(seen, (i, node["name"]))
                cycle["offset"] = seen[(i, node["name"])]
                cycle["length"] = steps - seen[(i, node["name"])]
                detected = Dict()
                for (k,v) in cycle["detected"]
                    detected[k] = v - cycle["offset"]
                end
                cycle["detected"] = detected
                return cycle
            end
            seen[(i, node["name"])] = steps
        end
    end

end


function merge_cycles(cycle1, cycle2)
    offset1, len1 = cycle1
    offset2, len2 = cycle2

    delta = min(offset1, offset2)
    offset1 -= delta
    offset2 -= delta

    r1 = offset1
    r2 = offset2

    final_offset = nothing
    i = 0
    while true
        if i > 100000
            throw("cannot merge cycles")
        end
        i += 1
        if r1 == r2
            final_offset = r1
            break
        end
        if r1 < r2 
            r1 = len1 * big(ceil(r2/len1))
        elseif r1 == r2
            r1 += len1
        else
            r2 = len2 *big(ceil(r1/len2))
        end
    end
    return (final_offset + delta, lcm(len1, len2))
end

function product(setA, setB)
    setP = []
    for a in setA
        for b in setB
            push!(setP, (a, b))
        end
    end

    return setP
end

function unfoldr(folded)
    res = []
    while typeof(folded) != Tuple{BigInt, BigInt}
        push!(res, folded[2])
        folded = folded[1]
    end
    push!(res, folded)
    return reverse(res)
end

function part2(instructions, nodes)
    # Initial setup
    players = []
    
    for (_, n) in nodes
        if endswith(n["name"], 'A')
            push!(players, n) 
        end
    end

    # Find cycles for each possible ghost
    cycles = []
    for p in players
        cycle = find_loop(p, nodes, instructions)
        if length(cycle["detected"]) == 0
            throw(p["name"])
        end
        push!(cycles, cycle)
    end

    ghosts = []
    for c in cycles
        # If multiple nodes end in xxZ, then add them as alternatives.
        alternatives = []
        for (_, k) in c["detected"]
            push!(alternatives, (
                big(c["offset"]) + big(k), 
                big(c["length"])
            ))
        end
        push!(ghosts, alternatives)
    end

    # Generate one ghost group for each and every alternative.
    alt_ghosts = ghosts[1]
    for g in ghosts[2:end]
        alt_ghosts = product(alt_ghosts, g)
    end
    alt_ghosts = map(alt -> unfoldr(alt), alt_ghosts)

    solutions = []
    for alts in alt_ghosts

        # Merge down the cycles until just one left - then that one is the solution!
        while length(alts) > 1
            a = pop!(alts)
            b = pop!(alts)
            push!(alts, merge_cycles(a, b))
        end

        offset, _ = alts[1]
        # Add this as a possible solution.
        # we want the next "step" after the offset, where the cycle actually starts
        push!(solutions, BigInt(offset + 1))
    end

    return minimum(solutions) # we want the smallest one.
end

@time println("Part 1: ", part1(read_input("input")...))
@time println("Part 2: ", part2(read_input("input")...))
