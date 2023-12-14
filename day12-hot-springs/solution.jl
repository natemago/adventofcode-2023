function read_input(fn)
    open(fn) do f
        record = []
        for line in readlines(f)
            springs, groups = split(line)
            push!(record, (springs, map(p -> parse(Int64, strip(p)), split(groups, ","))))
        end
        return record
    end
end


function get_positions(x, records)
    positions = [x]
    prev = x
    for r in records[1:end-1]
        push!(positions, prev + r + 1)
        prev = prev + r + 1
    end
    return positions
end

function can_fit(x, l, ex, springs)
    for i in range(x, x+l-1)
        if springs[i] == '.'
            return false
        end
    end
    if x > 1 && springs[x-1] == '#'
        return false
    end
    for i in range(x+l, min(ex, length(springs)))
        if springs[i] == '#'
            return false
        end
    end
    return true
end

function valid_path(a, b, springs)
    for i in range(a, b)
        if springs[i] == '#'
            return false
        end
    end
    return true
end

function get_count(x, springs, groups, mem)
    ox = x
    og = groups
    if haskey(mem, (x, groups))
        return mem[(x, groups)]
    end
    count = 0
    if length(groups) == 1
        l = groups[1]
        while x + l - 1 <= length(springs)
            if can_fit(x, l, length(springs), springs) && valid_path(ox, x-1, springs)
                count += 1
            end
            x += 1
        end
        mem[(ox, og)] = count
        return count
    end
    l = groups[1]
    while true
        positions = get_positions(x, groups)
        if positions[end] + groups[end] - 1 > length(springs)
            break
        end
        if can_fit(x, l, positions[2]-1, springs) &&  valid_path(ox, x-1, springs)
            count += get_count(positions[2], springs, groups[2:end], mem)
        end
        x += 1
    end
    mem[(ox, og)] = count
    return count
end

function part1(record)
    s = 0
    for (springs, records) in record
        a = get_count(1, springs, records, Dict())
        s += a
    end
    return s
end

function part2(record)
    s = 0
    for (springs, records) in record
        extended_springs = springs
        extended_records = records
        for i in range(1, 4)
            extended_springs = extended_springs * "?" * springs
            extended_records = vcat(extended_records, records)
        end
        s += get_count(1, extended_springs, extended_records, Dict())
    end
    return s
end


@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))