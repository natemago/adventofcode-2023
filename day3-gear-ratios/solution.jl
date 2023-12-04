function read_input(fn)
    schematic = []
    open(fn) do f
        for line in readlines(f)
            row = []
            for c in strip(line)
                push!(row, c)
            end
            push!(schematic, row)
        end
    end
    return schematic
end

function neighbours(x, y, schematic)
    n = []
    for (xx, yy) in [
        (x-1, y-1), (x, y-1), (x+1, y-1),
        (x-1, y),             (x+1, y),
        (x-1, y+1), (x, y+1), (x+1, y+1)
    ]
        if xx < 1 || xx > length(schematic[1]) || yy < 1 || yy > length(schematic)
          continue
        end
        push!(n, (schematic[yy][xx], xx, yy))
    end
    return n
end

function is_symbol(c)
    if isnumeric(c) || c == '.'
        return false
    end
    return true
end

function has_symbol(arr)
    for c in arr
        if is_symbol(c)
            return true
        end
    end
    return false
end

function parse_schematic(schematic)
    parsed = Dict(
        "numbers" => [],
        "symbols" => Dict(),
    )

    for (y, row) in enumerate(schematic)
        buff = ""
        symbols = Dict()
        for (x, c) in enumerate(row)
            if isnumeric(c)
                for (c, xx, yy) in neighbours(x, y, schematic)
                    if is_symbol(c)
                        symbols[(xx, yy)] = c
                    end
                end
                buff = buff * c
            else
                if buff != ""
                    num = parse(Int64, buff)
                    push!(parsed["numbers"], (num, symbols, (x - length(buff), y)))
                    buff = ""
                    symbols = Dict()
                end
            end
        end
        if buff != ""
            push!(parsed["numbers"], (parse(Int64, buff), symbols, (length(row) - length(buff), y)))
        end
    end
    return parsed
end

function part1(schematic)
    p = parse_schematic(schematic)
    sum = 0
    for (num, symbols, pos) in p["numbers"]
        if length(symbols) > 0
            sum += num
        end
    end
    return sum
end

function part2(schematic)
    p = parse_schematic(schematic)

    gears = Dict()

    for (num, symbols, _) in p["numbers"]
        for ((x, y), c) in symbols
            if c == '*'
                gears[(x, y)] = get(gears, (x, y), [])
                push!(gears[(x, y)], num)
            end
        end
    end
    sum = 0
    for (_, numbers) in gears
        if length(numbers) == 2
            ratio = numbers[1] * numbers[2]
            sum += ratio
        end
    end
    return sum
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))