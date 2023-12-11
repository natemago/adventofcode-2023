function read_input(fn)
    galaxies = Set()

    open(fn) do f
        for (y, row) in enumerate(readlines(f))
            for (x, c) in enumerate(row)
                if c == '#'
                    push!(galaxies, (x, y))
                end
            end
        end
    end

    return galaxies
end


function part1(galaxies, expansion_factor=2)
    galaxies = [g for g in galaxies]
    galaxies = sort(galaxies)
    prev = galaxies[1]
    for i in range(2, length(galaxies))
        curr = galaxies[i]
        diff = curr[1] - prev[1]
        if diff > 1
            for j in range(i, length(galaxies))
                galaxies[j] = (galaxies[j][1] + (diff-1)*(expansion_factor-1), galaxies[j][2])
            end
            curr = (curr[1] + (diff -1)*((expansion_factor-1)), curr[2])
        end
        prev = curr
    end

    galaxies = sort(galaxies, by=last)
    prev = galaxies[1]
    for i in range(2, length(galaxies))
        curr = galaxies[i]
        diff = curr[2] - prev[2]
        if diff > 1
            for j in range(i, length(galaxies))
                galaxies[j] = (galaxies[j][1], galaxies[j][2] + (diff-1)*(expansion_factor-1))
            end
            curr = (curr[1], curr[2] + (diff -1)*(expansion_factor-1))
        end
        prev = curr
    end

    paths = []
    for i in range(1, length(galaxies) - 1)
        for j in range(i+1, length(galaxies))
            ax, ay = galaxies[i]
            bx, by = galaxies[j]
            push!(paths, abs(ax-bx) + abs(ay - by))
        end
    end
    return sum(paths)
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part1(read_input("input"), 1000000))