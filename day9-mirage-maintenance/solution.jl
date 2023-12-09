function read_input(fn)
    open(fn) do f
        return map(
            l -> map(p -> parse(Int64, p), split(l)), 
            readlines(f),
        )
    end
end

function compute(values)
    result = []
    if length(values) == 0
        return values, true
    elseif length(values) == 1
        return [-values[1]], values[1] == 0
    end
    p = values[1]
    z = true
    for c in values[2:end]
        r = c - p
        push!(result, r)
        p = c
        if r != 0
            z = false
        end
    end
    return result, z
end

function part1(oasis)
    s = 0
    for line in oasis
        s += line[end]
        z = false
        while !z
            line, z = compute(line)
            s += line[end]
        end
    end
    return s
end

function part2(oasis)
    s = 0
    for line in oasis
        curr = [line[1]]
        z = false
        while !z
            line, z = compute(line)
            push!(curr, line[1])
        end

        # compute
        curr = reverse(curr)
        p = curr[1]
        for c in curr[2:end]
            p = c - p
        end
        s += p
    end
    return s
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))