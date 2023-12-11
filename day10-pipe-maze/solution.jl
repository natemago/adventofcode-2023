function read_input(fn)
    open(fn) do f
        return map(l -> [c for c in l], readlines(f))
    end
end

PIPES = Dict(
    '|' => [(0, -1), (0, 1)],
    '-' => [(-1, 0), (1, 0)],
    'L' => [(0, -1), (1, 0)],
    'J' => [(0, -1), (-1, 0)],
    '7' => [(-1, 0), (0, 1)],
    'F' => [(1, 0), (0, 1)],
    'S' => [(-1, 0), (0, -1), (1, 0), (0, 1)],
)

function get_animal_start_pos(maze)
    for (y, row) in enumerate(maze)
        for (x, c) in enumerate(row)
            if c == 'S'
                return (x, y)
            end
        end
    end
end

function connections(x,y, maze)
    v = maze[y][x]
    if !haskey(PIPES, v)
        return []
    end
    res = []
    for (dx, dy) in PIPES[v]
        xx = x + dx
        yy = y + dy
        if xx < 1 || xx > length(maze[1]) || yy < 1 || yy > length(maze)
            continue
        end
        push!(res, (xx, yy))
    end
    return res
end


function follow_pipe(pos, maze)
    pipe = [pos]
    seen = Set([pos])

    # Choose 1 direction to follow
    cons = connections(pos[1], pos[2], maze)
    if length(cons) == 0
        return [pos], false
    end
    curr = cons[1]
    came_from = pos
    while true
        if curr in seen
            return pipe, curr == pos
        end
        push!(seen, curr)
        push!(pipe, curr)
        
        cons = connections(curr[1], curr[2], maze)
        if length(cons) == 0
            return pipe, false
        end
        next = nothing
        for c in cons
            if c ∉ seen
                next = c
                break
            elseif c == pos && length(pipe) > 2 c in connections(pos[1], pos[2], maze)
                return pipe, true
            end
        end
        if next === nothing
            return curr, curr == pos
        end
        curr = next
    end
end

function get_longest_pipe(maze)
    start = get_animal_start_pos(maze)
    valid_pipes = []
    for c in "|-LJ7F"
        sx, sy = start
        maze[sy][sx] = c
        pipe, is_loop = follow_pipe(start, maze)
        if is_loop
            push!(valid_pipes, (pipe, c))
        end
    end
    pipe = valid_pipes[1]
    for p in valid_pipes[2:end]
        if length(p[1]) > length(pipe[1])
            pipe = p
        end
    end

    return pipe
end

function part1(maze)
    pipe = get_longest_pipe(maze)
    return Int64(ceil(length(pipe[1])/2))
end

function part2(maze)
    sx, sy = get_animal_start_pos(maze)
    pipe, s = get_longest_pipe(maze)
    maze[sy][sx] = s
    rows = []

    for (y, row) in enumerate(maze)
        r = ""
        for (x, c) in enumerate(row)
            if (x, y) in pipe
                r = r*c
            else
                r = r*'.'
            end
        end
        push!(rows, r)
    end

    count = 0
    for row in rows
        row = replace(replace(row, "-" => ""), "F7" => "||", "LJ" => "||", "FJ" => "|", "L7" => "|")
        _in = false
        
        for c in row
            if c == '|'
                _in = !_in
            end
            if c == '.' && _in
                count += 1
            end
        end
    end

    return count
end

@time println("Part 1:", part1(read_input("input")))
@time println("Part 2:", part2(read_input("input")))
