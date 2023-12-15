function read_input(fn)
    open(fn) do f
        return split(strip(readline(f)), ",")
    end
end

function aoc_hash(s)
    v = 0
    for c in s
        c = Int(c)
        v += c
        v *= 17
        v = v % 256
    end
    return v
end

function part1(instructions)
    res = 0
    for instr in instructions
        res += aoc_hash(instr)
    end
    return res
end

function part2(instructions)
    boxes = [[] for i in range(1, 256)]
    for instr in instructions
        if '-' in instr
            label = split(instr, "-")[1]
            ihash = aoc_hash(label)
            for (i, lens) in enumerate(boxes[ihash+1])
                if lens[1] == label
                    # remove from box
                    deleteat!(boxes[ihash+1], i)
                    break
                end
            end
        else
            label, focus = split(instr, "=")
            focus = parse(Int64, focus)
            ihash = aoc_hash(label)
            already_in = false
            for (i, lens) in enumerate(boxes[ihash+1])
                if lens[1] == label
                    already_in = true
                    boxes[ihash+1][i] = (label, focus)
                    break
                end
            end
            if !already_in
                push!(boxes[ihash + 1], (label, focus))
            end
        end
    end

    res = 0

    for (i, box) in enumerate(boxes)
        for (j, lens) in enumerate(box)
            res += i * j * lens[2]
        end
    end

    return res
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))