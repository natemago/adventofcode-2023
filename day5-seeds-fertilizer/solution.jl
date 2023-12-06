struct Category
    low::Int64
    high::Int64
end

struct Range 
    source::Category
    dest::Category
end

struct Map
    source::String
    dest::String
    ranges::Vector{Range}
end

function read_input(fn)
    open(fn) do f
        seeds = map(p -> parse(Int, p), split(split(readline(f), ":")[2]))
        readline(f)
        maps = Map[]

        map_head = nothing
        ranges = Range[]
        for line in readlines(f)
            if endswith(line, "map:")
                map_head = strip(split(line)[1])
                continue
            end
            if strip(line) == ""
                src, _, dest = split(map_head, "-")
                push!(
                    maps,
                    Map(src, dest, ranges)
                )
                map_head = nothing
                ranges = Range[]
                continue
            end
            rng_dest, rng_src, rng_size = map(p -> parse(Int64, p), split(line))
            push!(ranges, Range(Category(rng_src, rng_src+rng_size-1), Category(rng_dest, rng_dest+rng_size-1)))
        end

        if map_head !== nothing
            src, _, dest = split(map_head, "-")
            push!(
                maps,
                Map(src, dest, ranges)
            )
        end

        almanac = Dict(
            "seeds" => seeds,
            "maps" => maps,
        )
        return almanac
    end
end


function in_src_category(seed::Int, cat::Category)
    return seed >= cat.low && seed <= cat.high
end

function in_range(seed::Int, range::Range)
    return in_src_category(seed, range.source)
end

function map_seed(seed::Int, map::Map)
    for range in map.ranges
        if in_range(seed, range)
            return range.dest.low + (seed - range.source.low)
        end
    end
    return seed
end

function intersect(a::Category, b::Category)
    if a.low > b.high || a.high < b.low
        # No overlap
        return nothing, Category[a]
    end

    #       a[  ]
    #  b[    XXXX      ]
    if a.low >= b.low && a.high <= b.high
        # fully within interval b
        return a, Category[]
    end

    #   a[     XXXXXXXXX     ]
    #         b[       ]
    if a.low < b.low && a.high > b.high
        # Three parts with overlap in the middle
        return b, Category[
            Category(a.low, b.low-1),
            Category(b.high+1, a.high),
        ]
    end

    #      a[     ]
    #    b[    ]
    if a.low >= b.low && a.low <= b.high
        return Category(a.low, b.high), Category[Category(b.high+1, a.high)]
    end

    #  a[    ]
    #     b[    ]
    if b.low >= a.low && b.low <= a.high
        return Category(b.low, a.high), Category[Category(a.low, b.low-1)]
    end

    throw("nope.")
end


function map_cat_to_range(cat::Category, range::Range)
    overlap, rest = intersect(cat, range.source)
    if overlap === nothing
        return Category[], rest
    end
    # map the overlap
    overlap = Category(
        range.dest.low + (overlap.low - range.source.low),
        range.dest.low + (overlap.high - range.source.low)
    )
    return Category[overlap], rest
end

function map_cats(cats::Vector{Category}, range::Range)
    mapped = Category[]
    unmapped = Category[]
    for cat in cats
        overlap, rest = map_cat_to_range(cat, range)
        mapped = vcat(mapped, overlap)
        unmapped = vcat(unmapped, rest)
    end
    return mapped, unmapped
end

function map_to_ranges(cats::Vector{Category}, ranges::Vector{Range})::Vector{Category}
    mapped = Category[]
    unmapped = vcat(Category[], cats)
    for range in ranges
        m, u = map_cats(unmapped, range)
        mapped = vcat(mapped, m)
        unmapped = u
    end
    return vcat(mapped, unmapped)
end




function map_categories()
    
end

function part1(almanac)
    result = Inf64
    for seed in almanac["seeds"]
        mapped = seed
        for map in almanac["maps"]
            mapped = map_seed(mapped, map)
        end
        result = min(result, mapped)
    end
    return Int64(result)
end


function part2(almanac)
    minimal = Inf
    for i in range(0, Int(length(almanac["seeds"])/2) - 1)
        cat = Category(almanac["seeds"][i*2+1], almanac["seeds"][i*2+1] + almanac["seeds"][i*2+2] - 1)
        mapped = [cat]
        for m in almanac["maps"]
            mapped = map_to_ranges(mapped, m.ranges)
        end
        minimal = min(minimal, minimum(map(m -> m.low, mapped)))
    end
    return Int64(minimal)
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))