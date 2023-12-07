function read_input(fn)
    open(fn) do f
        hands = []
        for line in readlines(f)
            hand, bet = split(line)
            push!(hands, (hand, parse(Int64, bet)))
        end
        return hands
    end
end

CARDS = "23456789TJQKA"
KINDS = reverse!(["five", "four", "full-house", "three", "two-pair", "pair", "high-card"])


function kind(hand)
    count = Dict()
    for c in hand
        count[c] = get!(count, c, 0) + 1
    end
    if length(count) == 1
        return "five"
    elseif length(count) == 2
        if 1 in values(count)
            return "four"
        else
            return "full-house"
        end
    elseif length(count) == 3
        if 3 in values(count)
            return "three"
        else
            return "two-pair"
        end
    elseif length(count) == 4
        return "pair"
    else
        return "high-card"
    end
end

function cards_lt(a, b)
    ka, kb = kind(a), kind(b)
    ka, kb = findfirst(==(ka), KINDS), findfirst(==(kb), KINDS)
    if ka == kb 
        for (i, ac) in enumerate(a)
            bc = b[i]
            ai, bi = findfirst(==(ac), CARDS), findfirst(==(bc), CARDS)
            if ai != bi
                return ai < bi
            end
        end
        return 0
    end
    return ka < kb
end

function part1(hands)
    hands = sort!(hands, lt=(a, b)-> cards_lt(a[1], b[1]))
    total = 0
    for (rank, hand) in enumerate(hands)
        println(hand)
        _, bid = hand
        total += rank*bid
    end
    return total
end

println("Part 1: ", part1(read_input("input")))