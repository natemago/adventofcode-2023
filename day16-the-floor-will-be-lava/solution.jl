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

function print_energized(energized, grid)
    for (y, row) in enumerate(grid)
        for (x, c) in enumerate(row)
            if (x, y) in energized
                print("X")
            else
                print(c)
            end
        end
        println()
    end
end

function move_beams(x, y, grid, init_dir=right)
    stack = [(x, y, init_dir, Set(), Set())]
    if grid[y][x] == '\\'
        stack = [(x, y, down, Set(), Set())]
    elseif grid[y][x] == '/'
        stack = [(x, y, up, Set(), Set())]
    elseif grid[y][x] == '|'
        stack = [(x, y, down, Set(), Set())]
    elseif grid[y][x] == '-'
        stack = [(x, y, right, Set(), Set())]
    end
    energized = Set()
    push!(energized, (x, y))

    seen_junc = Set()

    while length(stack) > 0
        x, y, dir, path, seen_on_beam = pop!(stack)
        (nx, ny), op = move_beam(x, y, dir, grid, path)
        for (px, py) in path
            push!(energized, (px, py))
        end
        if op === nothing
            continue
        end
        if (x, y, op, dir) in seen_junc
            continue
        end
        push!(seen_junc, (x, y, op, dir))
        if op in "\\/"
            ndir = REFLECTIONS[op][dir]
            push!(stack, (nx, ny, ndir, copy(path), seen_on_beam))
        elseif op in "-|"
            for ndir in SPLITTERS[op][dir]
                push!(stack, (nx, ny, ndir, copy(path), seen_on_beam)) 
            end
        else
            throw("invalid op: " * op)
        end
    end
    return length(energized)
end

function part1(grid)
    return move_beams(1, 1, grid)
end

function move_beams_thr(x, y, dir, grid, res_chan)
    res = move_beams(x, y, grid, dir)
    put!(res_chan, res)
end


function part2(grid)
    best = 0
    lk = ReentrantLock()
    Threads.@threads for x in range(1, length(grid[1]))
        v1 = move_beams(x, 1, grid, down)
        v2 = move_beams(x, length(grid), grid, up)
        lock(lk)
        best = max(best, v1, v2)
        unlock(lk)
    end
    Threads.@threads for y in range(1, length(grid))
        v1 = move_beams(1, y, grid, right)
        v2 = move_beams(length(grid[1]), y, grid, left)
        lock(lk)
        best = max(best, v1, v2)
        unlock(lk)
    end
    return best
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))