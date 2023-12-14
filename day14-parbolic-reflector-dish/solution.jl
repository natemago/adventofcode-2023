function read_input(fn)
    open(fn) do f
        stones = []
        for line in readlines(f)
            row = [c for c in line]
            push!(stones, row)
        end
        return stones
    end
end

function find_stop_dir(x,y, d, stones)
    ox, oy = x, y
    dx, dy = d
    while true
        x, y = x+dx, y+dy
        if x < 1
            return (1, oy)
        elseif x > length(stones[1])
            return (length(stones[1]), oy)
        elseif y < 1
            return (ox, 1)
        elseif y > length(stones)
            return (ox, length(stones))
        end
        if stones[y][x] != '.'
            if dx == 0
                return (ox, y-dy)
            else
                return (x-dx, oy)
            end
        end
    end
end

function tilt_stone_dir(x,y, dir, stones)
    stones[y][x] = '.'
    sx, sy = find_stop_dir(x, y, dir, stones)
    stones[sy][sx] = 'O'
end

function tilt_dir(d, stones)
    if sum(d) < 0
        for y in range(1, length(stones))
            for x in range(1, length(stones[y]))
                if stones[y][x] == 'O'
                    tilt_stone_dir(x, y, d, stones)
                end
            end
        end
    else
        for y in reverse(range(1, length(stones)))
            for x in reverse(range(1, length(stones[y])))
                if stones[y][x] == 'O'
                    tilt_stone_dir(x, y, d, stones)
                end
            end
        end
    end
end

function tilt_north(stones)
    tilt_dir((0, -1), stones)
end

function tilt_cycle(stones)
    for d in ((0, -1), (-1, 0), (0, 1), (1, 0))
        tilt_dir(d, stones)
    end
end

function print_stones(stones)
    for row in stones
        println(join(row))
    end
end

function part1(stones)
    tilt_north(stones)
    res = 0
    for y in range(1, length(stones))
        for x in range(1, length(stones[y]))
            if stones[y][x] == 'O'
                res += length(stones) - y + 1
            end
        end
    end

    return res
end

function clone(stones)
    return [[c for c in row] for row in stones]
end


function part2(stones)
    seen = Dict()
    cycle = 0
    seen[clone(stones)] = cycle
    while true
        cycle += 1
        tilt_cycle(stones)
        if haskey(seen, stones)
            start = seen[stones]
            rep_len = cycle - start
            to_cycle = 1000000000 - start

            rem = to_cycle % rep_len
            while rem > 0
                tilt_cycle(stones)
                rem -= 1
            end

            res = 0
            for y in range(1, length(stones))
                for x in range(1, length(stones[y]))
                    if stones[y][x] == 'O'
                        res += length(stones) - y + 1
                    end
                end
            end

            return res


            break
        end
        seen[clone(stones)] = cycle
    end
end

@time println("Part 1: ", part1(read_input("test_input")))
@time println("Part 2: ", part2(read_input("input")))