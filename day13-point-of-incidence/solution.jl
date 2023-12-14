function read_input(fn)
    open(fn) do f
        shapes = []
        shape = []
        for line in readlines(f)
            line = strip(line)
            if line == ""
                push!(shapes, shape)
                shape = []
            else
                push!(shape, [c for c in line])
            end
        end
        if length(shape) > 0
            push!(shapes, shape)
        end
        return shapes
    end
end

function vreflect(x, row)
    i = x
    j = x+1
    if i < 1 || j > length(row)
        return false
    end
    mirrors = true
    while true
        if i < 1 || j > length(row)
            break
        end
        if row[i] != row[j]
            mirrors = false
            break
        end
        i -= 1
        j += 1
    end

    return mirrors
end

function hreflect(y, shape)
    i = y
    j = y+1
    if i < 1 || j > length(shape)
        return false
    end
    mirrors = true
    while true
        if i < 1 || j > length(shape)
            break
        end
        if shape[i] != shape[j]
            mirrors = false
            break
        end
        i -= 1
        j += 1
    end
    return mirrors
end

function find_reflections(shape, iv=nothing, ih=nothing)
    # Vertical line reflection
    vl = 0
    for x in range(1, length(shape[1]))
        mirrors = true
        for row in shape
            if !vreflect(x, row)
                mirrors = false
                break
            end
        end
        if mirrors
            if iv !== nothing && iv == x
                continue
            end
            vl = x
            break
        end
    end

    hl = 0
    for y in range(1, length(shape))
        if hreflect(y, shape)
            if ih !== nothing && ih == y
                continue
            end
            hl = y
            break
        end
    end

    return (vl, hl)
end

function fix_smudge(shape)
    for y in range(1, length(shape))
        for x in range(1, length(shape[y]))
            old = shape[y][x]
            vl, hl = find_reflections(shape)
            if old == '.'
                shape[y][x] = '#'
            else
                shape[y][x] = '.'
            end
            nvl, nhl = find_reflections(shape, vl, hl)
            
            if (vl, hl) != (nvl, nhl)
                if vl != nvl && nvl > 0
                    return (nvl, 0)
                end
                if hl != nhl && nhl > 0
                    return (0, nhl)
                end
            end
            shape[y][x] = old
        end
    end
    # Error?
    throw("error boom")
end

function part1(shapes)
    res = 0
    for shape in shapes
        vl, hl = find_reflections(shape)
        res += hl*100 + vl
    end
    return res
end

function part2(shapes)
    res = 0
    i = 1
    for shape in shapes
        vl, hl = fix_smudge(shape)
        i += 1
        res += hl*100 + vl
    end
    return res
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))