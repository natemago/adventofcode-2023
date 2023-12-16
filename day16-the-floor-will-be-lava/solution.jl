function read_input(fn)
    open(fn) do f
        return [[c for c in line] for line in readlines(f)]
    end
end

up = (0, -1)
down = (0, 1)
left = (-1, 0)
right = (1, 0)

REFLECTIONS = Dict(
    '\\' => Dict(
        up => left,
        left => up,
        down => right,
        right => down,
    ),
    '/' => Dict(
        up => right,
        left => down,
        down => left,
        right => up,
    ),
)

SPLITTERS = Dict(
    '|' => Dict(
        up => [up],
        left => [up, down],
        down => [down],
        right => [up, down]
    ),
    '-' => Dict(
        up => [left, right],
        left => [left],
        down => [left, right],
        right => [right]
    )
)

function move_beam(x, y, dir, grid, path)
    dx, dy = dir
    while true
        x, y = x+dx, y+dy
        if x < 1 || x > length(grid[1]) || y < 1 || y > length(grid)
            # out of bounds
            return (x-dx, y-dy), nothing
        end
        push!(path, (x, y))
        if grid[y][x] in "/\\|-"
            return (x, y), grid[y][x]
        end
    end
    throw("BoomZ!")
end

function move_beams(x, y, grid)
    stack = [(x, y, right, Set(), Set())]
    energized = Set()
    push!(energized, (x, y))
    while length(stack) > 0
        x, y, dir, path, seen_on_beam = pop!(stack)
        (nx, ny), op = move_beam(x, y, dir, grid, path)
        for (px, py) in path
            push!(energized, (px, py))
        end
        if op === nothing
            continue
        end
        if (nx, ny, op) in seen_on_beam
            continue
        end
        if op in "\\/"
            ndir = REFLECTIONS[op][dir]
            push!(stack, (nx, ny, ndir, copy(path), push!(copy(seen_on_beam), (nx, ny, op))))
        elseif op in "-|"
            for ndir in SPLITTERS[op][dir]
                push!(stack, (nx, ny, ndir, copy(path), push!(copy(seen_on_beam), (nx, ny, op)))) 
            end
        else
            throw("invalid op: " * op)
        end
    end
    return length(energized)
end

function part1(grid)
    #println(grid)
    move_beams(1, 1, grid)
end

println("Part 1: ", part1(read_input("input")))