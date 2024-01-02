function read_input(fn)
    open(fn) do f
        garden = []
        for line in readlines(f)
            line = strip(line)
            if line == ""
                continue
            end
            push!(garden, line)
        end
        return garden
    end
end

function find_start(garden)
    for (y, row) in enumerate(garden)
        for (x, c) in enumerate(row)
            if c == 'S'
                return (x, y)
            end
        end
    end
    throw("no start")
end

function bfs_reachable(garden)
    sx, sy = find_start(garden)

    q = [(sx, sy)]
    seen = Set()

    while length(q) > 0
        x, y = popfirst!(q)

        if (x, y) in seen
            continue
        end
        push!(seen, (x, y))

        for (xx, yy) in ((x+1, y), (x-1, y), (x, y+1), (x, y-1))
            if xx < 1 || xx > length(garden[1]) || yy < 1 || yy > length(garden)
                continue
            end
            if (xx, yy) in seen
                continue
            end
            if garden[yy][xx] == '#'
                continue
            end
            push!(q, (xx, yy))
        end
    end
    return seen
end

function get_odd_even(garden, reachable)
    sx, sy = find_start(garden)
    odd = Set()
    even = Set()
    for (x, y) in reachable
        d = abs(x-sx) + abs(y-sy)
        if d % 2 == 0
            push!(even, (x, y))
        else
            push!(odd, (x, y))
        end
    end
    return (odd, even)
end

function part1(garden)
    sx, sy = find_start(garden)
    reachable = bfs_reachable(garden)
    _, even = get_odd_even(garden, reachable)
    count = 0
    for (x, y) in even
        d = abs(x - sx) + abs(y - sy)
        if d <= 64
            count += 1
        end
    end
    return count
end

# +------------+
# | p2 |  | p3 |
# |  +-+  +-+  |
# +--+      +--+
# |     p1     |
# +--+      +--+
# |  +-+  +-+  |
# | p5 |  | p4 |
# +------------+
#


function get_p2(reachable, start)
    sx, sy = start
    p2 = Set()
    odd = 0
    even = 0
    for y in range(1, 65)
        for x in range(1, 65-y+1)
            if (x, y) in reachable
                push!(p2, (x, y))
                d = abs(x-sx) + abs(y-sy)
                if d % 2 == 0
                   even += 1
                else
                    odd += 1 
                end
            end
        end
    end
    return (p2, odd, even)
end

function get_p3(reachable, start)
    sx, sy = start
    p3 = Set()
    odd = 0
    even = 0
    for y in range(1, 65)
        for x in range(67 + y - 1, 131)
            if (x, y) in reachable
                push!(p3, (x, y))
                d = abs(x-sx) + abs(y-sy)
                if d % 2 == 0
                   even += 1
                else
                    odd += 1 
                end
            end
        end
    end
    return (p3, odd, even)
end

function get_p4(reachable, start)
    sx, sy = start
    p4 = Set()
    odd = 0
    even = 0
    c = 0
    for y in range(67, 131)
        for x in range(131 - c, 131)
            if (x, y) in reachable
                push!(p4, (x, y))
                d = abs(x-sx) + abs(y-sy)
                if d % 2 == 0
                    even += 1
                 else
                     odd += 1 
                 end
            end
        end
        c += 1
    end
    return (p4, odd, even)
end

function get_p5(reachable, start)
    sx, sy = start
    p5 = Set()
    odd = 0
    even = 0
    c = 0
    for y in range(67, 131)
        c += 1
        for x in range(1, c)
            if (x, y) in reachable
                push!(p5, (x, y))
                d = abs(x-sx) + abs(y-sy)
                if d % 2 == 0
                    even += 1
                 else
                     odd += 1 
                 end
            end
        end
    end
    return (p5, odd, even)
end

function get_p1(reachable, start, p2,p3,p4,p5)
    sx, sy = start
    odd = 0
    even = 0
    rest = union(p2, p3, p4, p5)
    p1 = setdiff(reachable, rest)
    for (x, y) in p1
        d = abs(x-sx) + abs(y-sy)
        if d % 2 == 0
            even += 1
        else
            odd += 1 
        end
    end
    return (p1, odd, even)
end

function part2(garden)
    N = 26501365
    L = length(garden)
    if length(garden) != length(garden[1])
        throw("woops!")
    end
    reachable = bfs_reachable(garden)
    odd, even = get_odd_even(garden, reachable)
    start = find_start(garden)
    p2s, p2odd, p2even = get_p2(reachable, start)
    p3s, p3odd, p3even = get_p3(reachable, start)
    p4s, p4odd, p4even = get_p4(reachable, start)
    p5s, p5odd, p5even = get_p5(reachable, start)

    p1s, p1odd, p1even = get_p1(reachable, start, p2s, p3s, p4s, p5s)

    p1,p2,p3,p4,p5 = p1odd, p2odd, p3odd, p4odd, p5odd
    p1f, p2f, p3f, p4f, p5f = p1even, p2even, p3even, p4even, p5even

    # Odds are non-flipped and reachable, even are flipped

    B = (N-65)÷131 - 1
    F = (B+1)^2
    U = B^2

    return (F*length(even) + U*length(odd) + 
        B*(p1+p3+p4+p5) + (B+1)*p4f + 
        B*(p1+p2+p4+p5) + (B+1)*p5f + 
        B*(p1+p2+p3+p5) + (B+1)*p2f + 
        B*(p1+p2+p3+p4) + (B+1)*p3f +
        (p1+p4+p5) + 
        (p1+p2+p5) + 
        (p1+p2+p3) +
        (p1+p3+p4)
        )
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))