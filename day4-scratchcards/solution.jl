function read_input(fn)
    open(fn) do f
        cards = []
        for line in readlines(f)
            head, rest = split(line, ":")
            _, card_num = split(head)
            numbers, my_numbers = split(rest, "|")
            push!(cards, Dict(
                "id" => parse(Int64, card_num),
                "numbers" => map(n -> parse(Int64, n),  split(numbers)),
                "my_numbers" => map(n -> parse(Int64, n),  split(my_numbers)),
            ))
        end
        return cards
    end
end

function points(card)
    i = length(intersect(Set(card["my_numbers"]), Set(card["numbers"])))
    if i == 0
        return 0, 0
    end
    return 2^(i-1), i
end

function part1(cards)
    return reduce(+, map(c -> points(c)[1], cards))
end


function score(card, cm, res)
    _, p = points(card)
    if p == 0
        return
    end
    for i in range(card["id"] + 1, card["id"] + p)
        if haskey(cm, i)
            res[i] = res[i] + res[card["id"]]
        end
    end
end

function part2(cards)
    cm = Dict((c["id"], c) for c in cards)
    res = Dict((c["id"], 1) for c in cards)
    for c in cards
        score(c, cm, res)
    end
    return reduce(+, values(res))
end


println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))