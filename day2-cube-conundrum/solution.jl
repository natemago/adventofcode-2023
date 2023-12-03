function read_input(fn)
    games = []
    open(fn) do f
        for line in readlines(f)
            game = Dict()
            head, tail = split(line, ":")
            game_id = parse(Int64, match(r"\d+", head).match)

            game["game_id"] = game_id
            sets = split(tail, ";")
            game["sets"] = []
            for s in sets
                ss = Dict()
                for m in eachmatch(r"(\d+)\s+(\w+)", s)
                    ss[m[2]] = parse(Int64, m[1])
                end
                push!(game["sets"], ss)
            end
            push!(games, game)
        end
    end
    return games
end

limits = Dict(
    "red" => 12,
    "green" => 13,
    "blue" => 14,
)

function part1(games)
    sum = 0
    for game in games
        possible = true
        for s in game["sets"]
            for (color, count) in s
                if count > limits[color]
                    possible = false
                    break
                end
            end
        end
        if possible
            sum += game["game_id"]
        end
    end
    return sum
end


function part2(games)
    sum = 0
    for game in games
        mins = Dict()
        for s in game["sets"]
            for (color, count) in s
                #if count <= limits[color]
                mins[color] = max(count, get!(mins, color, 0))
                #end
            end
        end
        sum += reduce(*, values(mins))
    end
    return sum
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))