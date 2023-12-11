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


function part1(galaxies)
    println(galaxies)
end

println("Part 1: ", part1(read_input("input")))