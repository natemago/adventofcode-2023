function read_input(fn)
    open(fn) do f
        record = []
        for line in readlines(f)
            springs, groups = split(line)
            push!(record, (springs, map(p -> parse(Int64, strip(p)), split(groups, ","))))
        end
        return record
    end
end

# function can_fit(x, l, springs)
#     for i in range(x, x+l-1)
#         if springs[i] == '.'
#             return false
#         end
#     end
#     if x > 1 && springs[x-1] == '#'
#         return false
    
#     elseif (x+l-1) < length(springs) && springs[x+l] == '#'
#         return false
#     end
#     return true
# end

# function num_combinations(sx, ex, l, springs)
#     if (ex - sx) > l || ex > length(springs)
#         return 0
#     end
#     count = 0
#     for i in range(sx, ex - l + 1)
#         if can_fit(i, l, springs)
#             count += 1
#         end
#     end
#     return count
# end

# function get_positions(x, records)
#     positions = [x]
#     prev = x
#     for r in records[1:end-1]
#         push!(positions, prev + r + 1)
#         prev = prev + r + 1
#     end
#     return positions
# end

# function springs_combinations(x, records, springs)
#     #println("springs_combinations", (x, records, springs))
#     if length(records) == 0
#         return 0
#     end
#     count = 0
#     while true
#         #println(" @pos=", x)
#         positions = get_positions(x, records)
#         #println("pos:", (positions, x, records, springs))
#         if (positions[end] + records[end] -1 ) > length(springs)
#             break
#         end
#         if x > 1
#             if springs[x-1] == '#'
#                 break
#             end
#         end
#         if can_fit(positions[1], records[1], springs)
#             #println("can fit: ", (positions, positions[1], records[1], springs))
#             if length(positions) > 1
#                 # check in-between
#                 valid = true
#                 for i in range(positions[1]+records[1], positions[2]-1)
#                     if springs[i] == '#'
#                         valid = false
#                         break
#                     end
#                 end
#                 #println((positions[1]+records[1], positions[2]-1), "valid=", valid, "; ", springs)
#                 if valid
#                     count += springs_combinations(positions[2], records[2:end], springs)
#                 end
#             else
#                 valid = true
#                 if x+records[1]+1 < length(springs)
#                     for i in range(x+records[1]+1, length(springs))
#                         if springs[i] == '#'
#                             valid = false
#                             break
#                         end
#                     end
#                 end
#                 if valid
#                     count += 1
#                 end
#             end
#         # else
#         #     println("cannot fit:", (positions, positions[1], records[1], springs))
#         end

        
#         x += 1
#     end
#     return count
# end

function get_positions(x, records)
    positions = [x]
    prev = x
    for r in records[1:end-1]
        push!(positions, prev + r + 1)
        prev = prev + r + 1
    end
    return positions
end

function can_fit(x, l, ex, springs)
    for i in range(x, x+l-1)
        if springs[i] == '.'
            return false
        end
    end
    if x > 1 && springs[x-1] == '#'
        return false
    end
    for i in range(x+l, min(ex, length(springs)))
        if springs[i] == '#'
            return false
        end
    end
    return true
end

function get_groups(springs)
    groups = []
    curr_group = 0
    for s in springs
        if s == '.'
            if curr_group > 0
                push!(groups, curr_group)
                curr_group = 0
            end
        else
            curr_group += 1
        end
    end
    if curr_group > 0
        push!(groups, curr_group)
    end
    return groups
end

function get_alts(springs)
    idxs = []
    for (i, s) in enumerate(springs)
        if s == '?'
            push!(idxs, i)
        end
    end
    return idxs
end

function get_arragements_count(springs, groups)
    alts = get_alts(springs)
    if length(alts) == 0
        if groups == get_groups(springs)
            return 1
        end
        return 0
    end
    count = 0
    for options in variations("#.", length(alts))
        springs = [s for s in springs]
        for (i, o) in enumerate(options)
            springs[alts[i]] = o
        end
        if groups == get_groups(springs)
            count += 1
        end
    end
    return count
end

function part1(record)
    s = 0
    for (springs, records) in record
        println("=========")
        #a = springs_combinations(1, records, springs)
        a = get_arragements_count(springs, records)
        s += a
        println("->", (springs, records, a))
    end
    return s
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

function get_count(x, springs, groups, mem)
    ox = x
    og = groups
    if haskey(mem, (x, groups))
        return mem[(x, groups)]
    end
    count = 0
    if length(groups) == 1
        l = groups[1]
        while x + l - 1 <= length(springs)
            if can_fit(x, l, length(springs), springs)
                count += 1
            end
            x += 1
        end
        mem[(ox, og)] = count
        return count
    end
    l = groups[1]
    while true
        positions = get_positions(x, groups)
        if positions[end] + groups[end] - 1 > length(springs)
            break
        end
        if can_fit(x, l, x+l+1, springs) &&  springs[x+l] != '#'
            count += get_count(x + l, springs, groups[2:end], mem)
        end
        x += 1
    end
    mem[(ox, og)] = count
    return count
end

function part2(record)
    s = 0
    for (springs, records) in record
        extended_springs = springs
        extended_records = records
        # for i in range(1, 4)
        #     extended_springs = extended_springs * "?" * springs
        #     extended_records = vcat(extended_records, records)
        # end
        s += get_count(1, extended_springs, extended_records, Dict())
    end
    return s
end

#@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))