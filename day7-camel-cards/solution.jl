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

CARDS    = "23456789TJQKA"
CARDS_P2 = "J23456789TQKA"
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

function variations(elems, choose)
    return _variations(choose, [], elems)
end

function _variations(choose, variation, elems)
    res = []
    if length(variation) == choose
        return [variation]
    end
    for el in elems
        for_el = _variations(choose, vcat(variation, [el]), elems)
        res = vcat(res, for_el)
    end
    return res
end

function kind_with_joker(hand)
    jokers_at = findall(==('J'), hand)
    if length(jokers_at) == 0
        return kind(hand)
    end
    other_cards = replace(hand, "J" => "")
    if other_cards == ""
        return "five"
    end
    hand = [c for c in hand]

    best_kind = kind(hand)
    best_rank = findfirst(==(best_kind), KINDS)

    for var in variations(other_cards, length(jokers_at))
        curr_hand = [c for c in hand]
        for (i, r) in enumerate(var)
            curr_hand[jokers_at[i]] = r
        end
        curr_kind = kind(curr_hand)
        kind_rank = findfirst(==(curr_kind), KINDS)
        if kind_rank > best_rank
            best_rank = kind_rank
            best_kind = curr_kind
        end
    end
    return best_kind
end

function cards_lt(a, b, get_kind=nothing, cards_rank=CARDS)
    if get_kind === nothing
        get_kind = kind
    end
    ka, kb = get_kind(a), get_kind(b)
    ka, kb = findfirst(==(ka), KINDS), findfirst(==(kb), KINDS)
    if ka == kb 
        for (i, ac) in enumerate(a)
            bc = b[i]
            ai, bi = findfirst(==(ac), cards_rank), findfirst(==(bc), cards_rank)
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
        _, bid = hand
        total += rank*bid
    end
    return total
end

function part2(hands)
    hands = sort!(hands, lt=(a, b)-> cards_lt(a[1], b[1], kind_with_joker, CARDS_P2))
    total = 0
    for (rank, hand) in enumerate(hands)
        _, bid = hand
        total += rank*bid
    end
    return total
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))