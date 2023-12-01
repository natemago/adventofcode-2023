function read_input(fn)
    open(fn) do f
        return filter(l -> strip(l) != "", readlines(f))
    end
end

function part1(lines)
    sum = 0
    for line in lines
        first = match(r"^\D*(\d)", line)
        if first != nothing
            first = first[1]
        else
            throw("No digits in string:" * line)
        end
        last = match(r"(\d)\D*$", line)
        if last != nothing
            last = last[1]
        else
            throw("No digits in string:" * line)
        end
        sum += parse(Int64, first * last)
    end
    return sum
end

function get_digits(line)
    first = match(r"^\D*(\d)", line)
    last = match(r"(\d)\D*$", line)
    return first, last
end

digits = Dict(
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
)

function get_word_digits(line)
    first = nothing
    last = nothing

    mf = findall(Regex("$(join(keys(digits), "|"))"), line)
    if mf != nothing && length(mf) > 0
        first = (digits[line[mf[1]]], mf[1][1])
    end

    ml = findall(Regex("$(reverse(join(keys(digits), "|")))"), reverse(line))
    if ml != nothing && length(ml) > 0
        last = (digits[reverse(reverse(line)[ml[1]])], length(line) - ml[1][end] + 1)
    end

    return first, last
end

function part2(lines)
    sum = 0
    for line in lines
        f, l = get_digits(line)
        wf, wl = get_word_digits(line)

        first = nothing
        if wf == nothing || (f != nothing && f.offsets[1] < wf[2])
            first = f[1]
        else
            first = wf[1]
        end

        last = nothing
        if wl == nothing || (l != nothing && l.offsets[1] > wl[2])
            last = l[1]
        else
            last = wl[1]
        end

        sum += parse(Int64, first * last)
    end

    return sum
end

print("Part 1: ", part1(read_input("input")), "\n")
print("Part 2: ", part2(read_input("input")), "\n")