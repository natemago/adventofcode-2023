function read_input(fn)
    open(fn) do f
        return [[parse(Int64, c) for c in line] for line in readlines(f)]
    end
end

function in_same_dir(dir, path)
    i = length(path)
    count = 0
    x, y = nothing, nothing
    dx, dy = dir
    while i > 0
        if x === nothing
            x,y = path[i]
            count += 1
            i -= 1
            continue
        end
        cx, cy = path[i]
        #println(i, " -> ", (cx, cy), (x, y), dir)
        if (cx + dx, cy + dy) != (x, y)
            break
        end
        x, y = cx, cy
        count += 1
        i -= 1
    end
    return count
end

function neighbours(x, y, heatmap)
    res = []
    for (xx, yy) in ((x, y-1), (x-1, y), (x, y+1), (x+1, y))
        if xx < 1 || xx > length(heatmap[1]) || yy < 1 || yy > length(heatmap)
            continue
        end
        push!(res, (xx, yy))
    end
    return res
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

function bfs_path(start, target, heatmap)
    q = [(start, 0, 1, (1, 0), [])]
    seen = Set()
    final_path = nothing
    final_heat = nothing
    steps = 0
    while length(q) > 0
        (x, y), heat, in_dir, dir, path = popfirst!(q)
        #println("Looking at:", (x, y, heat, path))
        steps += 1
        if (x, y, in_dir, dir) in seen
            continue
        end
        push!(seen, (x, y, in_dir, dir))
        if (x, y) == target
            final_heat = heat + heatmap[y][x]
            final_path = vcat(path, [(target, dir)])
            break
        end
        ns = neighbours(x, y, heatmap)
        #println(" :: neighbours:", ns)
        for (nx, ny) in ns
            ndir = (nx - x, ny - y)
            # println("  :: -> dir=", dir, "=", in_same_dir(dir, path))
            # if in_same_dir(dir, path) >= 3
            #     println(" ::", (nx, ny), " in same dir >= 3 with ", (x, y), "; dir=", dir)
            #     continue
            # end
            if (nx, ny) == (x, y)
                continue
            end
            n_in_dir = 1
            if ndir == (-dir[1], -dir[2])
                continue
            end
            if ndir == dir
                if in_dir >= 3
                    continue
                end
                n_in_dir = in_dir + 1
            end
            push!(q, ((nx, ny), heat + heatmap[y][x], n_in_dir, ndir, path))# vcat(path, [((x, y), dir)])))
        end
        sort!(q, by=n -> n[2])
    end
    println("Steps: ", steps)
    println("Grid:", length(heatmap) * length(heatmap[1]))
    println("Est:", length(heatmap) * length(heatmap[1]) * 4 * 4)
    return final_heat - heatmap[start[2]][start[1]], final_path
end

function part2(heatmap)
    start = (1, 1)
    target = (length(heatmap[1]), length(heatmap))
    q = [(start, 0, 0, (1, 0), [])]
    seen = Set()
    final_path = nothing
    final_heat = nothing
    estimated = length(heatmap) * length(heatmap[1]) * 11 * 4
    steps = 0
    while length(q) > 0
        (x, y), heat, in_dir, dir, path = popfirst!(q)
        #println("Looking at:", (x, y, heat, path))
        steps += 1
        if (x, y, in_dir, dir) in seen
            continue
        end
        push!(seen, (x, y, in_dir, dir))
        if (x, y) == target && in_dir >= 4
            final_heat = heat + heatmap[y][x]
            final_path = vcat(path, [(target, dir)])
            break
        end
        ns = neighbours(x, y, heatmap)
        #println(" :: neighbours:", ns)
        modified = false
        for (nx, ny) in ns
            ndir = (nx - x, ny - y)
            n_in_dir = 1
            if ndir == (-dir[1], -dir[2])
                continue
            end
            
            if ndir == dir
                if in_dir >= 10
                    continue
                end
                n_in_dir = in_dir + 1
            end
            if ndir != dir && in_dir < 4
                continue
            end
            if (nx, ny, n_in_dir, ndir) in seen
                continue
            end
            push!(q, ((nx, ny), heat + heatmap[y][x], n_in_dir, ndir, path)) # vcat(path, [((x, y), dir)])))
            modified = true
        end
        if modified
            sort!(q, by=n -> n[2])
        end
        if steps % 1000 == 0
            println("$(steps) steps of $(estimated) ~$((steps*100)/estimated)% q=$(length(q))")
        end
    end

    print_grid(heatmap, final_path)

    return final_heat - heatmap[start[2]][start[1]], final_path
end

function part1(heatmap)
    #println(in_same_dir((0, 1), [(1,1), (1,2), (1, 3)]))
    heatloss, path = bfs_path((1, 1), (length(heatmap[1]), length(heatmap)), heatmap)
    println(path)
    print_grid(heatmap, path)
    s = 0
    for ((x, y), _) in path
        println((x, y), "->", heatmap[y][x])
        s += heatmap[y][x]
    end
    println("S->", s)
    return heatloss
end

println("Part 1: ", part1(read_input("test_input")))
println("Part 2: ", part2(read_input("input")))