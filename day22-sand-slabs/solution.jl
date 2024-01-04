mutable struct Brick
    p1::Vector{Int64}
    p2::Vector{Int64}
    xr::Vector{Int64}
    yr::Vector{Int64}
    zr::Vector{Int64}

    function Brick(p1::Vector, p2::Vector)
        x1, x2 = p1[1], p2[1]
        y1, y2 = p1[2], p2[2]
        z1, z2 = p1[3], p2[3]
        new(
            p1, p2,
            [min(x1, x2), max(x1, x2)],
            [min(y1, y2), max(y1, y2)],
            [min(z1, z2), max(z1, z2)],
        )
    end

end

function top(b::Brick)
    return max(b.p1[3], b.p2[3])
end

function bottom(b::Brick)
    return min(b.p1[3], b.p2[3])
end

function vtranslate(b::Brick, n::Int64)
    b.p1[3] += n
    b.p2[3] += n
    b.zr = [min(b.p1[3], b.p2[3]), max(b.p1[3], b.p2[3])]
end

function intersection(r1::Vector{Int64}, r2::Vector{Int64})::Union{Vector{Int64},Nothing}
    s1, e1 = r1
    s2, e2 = r2
    if s1 > e2 || s2 > e1
        return nothing
    end
    if s1 > s2
        return intersection(r2, r1)
    end
    s = nothing
    e = nothing
    if s1 >= s2
        s = s1
    else
        s = s2
    end
    if e1 <= e2
        e = e1
    else
        e = e2
    end
    return [s, e]
end

function intersects(b1::Brick, b2::Brick)::Bool
    return (intersection(b1.xr, b2.xr) !== nothing) && 
        (intersection(b1.yr, b2.yr) !== nothing) && 
        (intersection(b1.zr, b2.zr) !== nothing)
end

function might_intersect(b1::Brick, b2::Brick)::Union{Tuple{Tuple{Vector{Int64}, Vector{Int64}}, Int64}, Nothing}
    x_intersect = intersection(b1.xr, b2.xr)
    y_intersect = intersection(b1.yr, b2.yr)
    if x_intersect === nothing || y_intersect === nothing
        return nothing
    end
    return ((x_intersect, y_intersect), top(b1))
end

function read_input(fn)
    open(fn) do f
        bricks = []
        for line in readlines(f)
            line = strip(line)
            if line == ""
                continue
            end
            p1, p2 = split(line, "~")
            p1 = map(p -> parse(Int64, p), split(p1, ","))
            p2 = map(p -> parse(Int64, p), split(p2, ","))
            push!(bricks, Brick(p1, p2))
        end
        return bricks
    end
end

function find_bricks_to_rest_on(brick, laid_bricks)
    possible = []
    for bb in laid_bricks
        intr = might_intersect(bb, brick)
        if intr !== nothing
            push!(possible, (intr, bb))
        end
    end
    if length(possible) == 0
        return []
    end
    possible = sort(possible, by=p-> top(p[2]), rev=true)
    t = top(possible[1][2])
    result = []
    for (intr, b) in possible
        if top(b) != t
            break
        end
        push!(result, b)
    end
    return result
end

function part1(bricks)
    sort!(bricks, by=b->bottom(b))

    graph = Dict()
    
    brick = bricks[1]
    d = bottom(brick) - 1
    vtranslate(brick, -d)

    final = [brick]
    graph[brick] = Dict(
        "atop" => [],
        "supports" => [],
    )

    for brick in bricks[2:end]
        rests_on = find_bricks_to_rest_on(brick, final)
        if length(rests_on) == 0
            # falls to bottom
            d = bottom(brick) - 1
            vtranslate(brick, -d)
            push!(final, brick)
            graph[brick] = Dict(
                "atop" => [],
                "supports" => [],
            )
        else
            d = bottom(brick) - top(rests_on[1]) - 1
            vtranslate(brick, -d)
            push!(final, brick)
            graph[brick] = Dict(
                "atop" => rests_on,
                "supports" => [],
            )
        end
    end
    
    for (brick, b) in graph
        for at in b["atop"]
            push!(graph[at]["supports"], brick)
        end
    end

    can_be_destroyed = Set()
    for brick in final
        d = graph[brick]
        if length(d["supports"]) == 0
            push!(can_be_destroyed, brick)
            continue
        end
        can_we = true
        for s in d["supports"]
            if length(graph[s]["atop"]) < 2
                can_we = false
                break
            end
        end
        if can_we
            push!(can_be_destroyed, brick)
        end
    end

    return length(can_be_destroyed), graph
end

function count_fall(brick, graph)
    q = [brick]
    fallen = Set()
    push!(fallen, brick)
    while length(q) > 0
        b = popfirst!(q)
        for s in graph[b]["supports"]
            atop = Set(graph[s]["atop"])
            if length(setdiff(atop, fallen)) == 0
                # this brick will faill
                push!(fallen, s)
                push!(q, s)
            end
        end
    end
    return length(fallen) - 1
end

function part2(_, graph)
    result = 0
    for (brick, _) in graph
        c = count_fall(brick, graph)
        result += c
    end
    return result
end

@time println("Part 1: ", part1(read_input("input"))[1])
@time println("Part 2: ", part2(part1(read_input("input"))...))
