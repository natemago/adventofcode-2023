function read_input(fn)
    open(fn) do f
        dig_plan = []
        for line in readlines(f)
            parts = split(line)
            push!(dig_plan, (
                parts[1],
                parse(Int64, parts[2]),
                parts[3][2:end-1],
            ))
        end
        return dig_plan
    end
end

DIRECTIONS = Dict(
    "U" => (0, -1),
    "D" => (0, 1),
    "L" => (-1, 0),
    "R" => (1, 0),
)


function dig_trench(dig_plan)
    trench = Dict()
    pos = (0, 0)
    for (dir, steps, color) in dig_plan
        dx, dy = DIRECTIONS[dir]
        for _ in range(1, steps)
            trench[pos] = color
            pos = (pos[1] + dx, pos[2] + dy)
        end
    end
    return trench
end

function dig_trench_p2(dig_plan)
    pos = (0, 0)
    trench = [pos]
    for (_, _, color) in dig_plan
        color = color[2:end]
        steps = parse(Int64, color[1:5], base=16)
        d = parse(Int64, color[6])
        dx, dy = DIRECTIONS[string("RDLU"[d+1])]
        x, y = pos
        next = (x + dx*steps, y + dy*steps)
        push!(trench, next)
        pos = next
    end
    return trench
end

function trench_bouds(trench)
    min_x, max_x, min_y, max_y = nothing, nothing, nothing, nothing
    for ((x, y), _) in trench
        if min_x === nothing || x < min_x
            min_x = x
        end
        if min_y === nothing || y < min_y
            min_y = y
        end
        if max_x === nothing || x > max_x
            max_x = x
        end
        if max_y === nothing || y > max_y
            max_y = y
        end
    end
    return ((min_x, max_x), (min_y, max_y))
end


function dig_inside(x, y, trench, bounds)
    (min_x, max_x), (min_y, max_y) = bounds
    dug_out = Set()


    q = [(x, y)]
    while length(q) > 0
        x,y = popfirst!(q)
        if (x, y) in dug_out || haskey(trench, (x, y))
            continue
        end
        push!(dug_out, (x, y))
        for (xx, yy) in ((x, y-1), (x-1, y), (x, y+1), (x+1, y))
            if xx < min_x || xx > max_x || yy < min_y || yy > max_y
                # We're on the outside, revert all digging
                return Set()
            end
            if (xx, yy) in dug_out || haskey(trench, (xx, yy))
                continue
            end
            push!(q, (xx, yy))
        end
    end

    return dug_out
end

function dug_out_interior(trench)
    bounds = trench_bouds(trench)
    (min_x, max_x), (min_y, max_y) = bounds
    for i in range(0, max_x - min_x + 1)
        x = min_x + i
        for j in range(0, max_y - min_y + 1)
            y = min_y + j
            dug_out = dig_inside(x, y, trench, bounds)
            for (xx, yy) in dug_out
                trench[(xx, yy)] = "#FFFFFF"
            end
        end
    end
    return trench
end


function part1(dig_plan)
    trench = dig_trench(dig_plan)
    trench = dug_out_interior(trench)
    return length(trench)
end

function part2(dig_plan)
    trench = dig_trench_p2(dig_plan)

    A = 0
    B = 0
    (x1, y1) = trench[1]
    for (x2, y2) in trench[2:end-1]
        # Shoelace/trapesoid formula
        A += (y1+y2)*(x1-x2)
        # Lenght of boundary
        B += abs((y2-y1) + (x2-x1))
        x1, y1 = x2, y2
    end
    ex1, ey1 = trench[1]
    B += abs((ex1-x1) + (ey1-y1))
    A = Int64(A/2)


    # Pick's theorem
    return Int64(A + B/2 + 1)
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))