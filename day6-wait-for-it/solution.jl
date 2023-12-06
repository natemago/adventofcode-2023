function read_input(fn)
    open(fn) do f
        times = map(n -> parse(Int64, n), split(readline(f))[2:end])
        distances = map(n -> parse(Int64, n), split(readline(f))[2:end])
        if length(times) != length(distances)
            throw("invalid input")
        end
        races = []
        for (i, t) in enumerate(times)
            push!(races, (t, distances[i]))
        end
        return races
    end
end

function number_of_possible_wins(tm, best_distance)
    count = 0
    for n in range(0, tm)
        reached = (tm - n) * n
        if reached > best_distance
            count += 1
        end
    end
    return count
end

function part1(races)
    res = 1
    for (tm, dist) in races
        count = number_of_possible_wins(tm, dist)
        println("for ", tm, "ms and ", dist, "mm, count is: ", count)
        res = res * count
    end
    return res
end

function part2(races)
    actual_time = ""
    actual_distance = ""
    for (tm, dist) in races
        actual_time = actual_time * string(tm)
        actual_distance = actual_distance * string(dist)
    end
    return number_of_possible_wins(parse(Int64, actual_time), parse(Int64, actual_distance))
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))