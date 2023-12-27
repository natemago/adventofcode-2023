OPS = Dict(
    ">" => (a, b) -> a > b,
    "<" => (a, b) -> a < b,
)

function rule(prop, op, value, outcome)
    opf = OPS[op]
    if opf === nothing
        throw("Invalid op '$(op)'.")
    end
    return part -> begin
        if opf(part[prop], value)
            return outcome
        end
        return nothing
    end
end

function read_input(fn)
    open(fn) do f
        workflows = []
        parts = []
        
        read_parts = false
        for line in readlines(f)
            line = strip(line)
            if line == ""
                if !read_parts
                    read_parts = true
                    continue
                end
            end
            if read_parts
                m = match(r"^{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}$", line)
                if m === nothing
                    throw(line)
                end
                push!(parts, Dict(
                    "x" => parse(Int64, m[1]),
                    "m" => parse(Int64, m[2]),
                    "a" => parse(Int64, m[3]),
                    "s" => parse(Int64, m[4]),
                ))
            else
                wkf_name, rest = split(line, "{")
                workflow = Dict(
                    "name" => wkf_name,
                    "rules" => [],
                )
                for part in split(rest[1:end-1], ",")
                    m = match(r"^([xmas])([><])(\d+):(\w+)$", part)
                    if m !== nothing
                        prop = m[1]
                        op = m[2]
                        value = parse(Int64, m[3])
                        outcome = m[4]

                        push!(workflow["rules"], Dict(
                            "prop" => prop,
                            "op" => op,
                            "value" => value,
                            "outcome" => outcome,
                            "rulefn" => rule(prop, op, value, outcome),
                        ))
                    else
                        push!(workflow["rules"], Dict(
                            "outcome" => part,
                            "rulefn" => x -> part,
                        ))
                    end
                end
                push!(workflows, workflow)
            end
        end

        return (workflows, parts)
    end
end


function process_in_workflow(part, workflow)
    for r in workflow["rules"]
        rulefn = r["rulefn"]
        outcome = rulefn(part)
        if outcome !== nothing
            return outcome
        end
    end
    println("Failed to process part: ", part, "; in workflow: ", workflow)
    throw("ERROR")
end

function process_part(part, workflows)
    wkf = workflows["in"]
    while true
        outcome = process_in_workflow(part, wkf)
        if outcome == "R" || outcome == "A"
            return outcome
        end
        wkf = workflows[outcome]
    end
end

function rule_as_bitmap(rule, vmax=4000)
    result = Dict(
        "x" => [true for _ in range(1, vmax)],
        "m" => [true for _ in range(1, vmax)],
        "a" => [true for _ in range(1, vmax)],
        "s" => [true for _ in range(1, vmax)],
    )
    if haskey(rule, "inverse")
        for i in range(1, vmax)
            result[rule["prop"]][i] = !OPS[rule["op"]](i, rule["value"])
        end
    else
        for i in range(1, vmax)
            result[rule["prop"]][i] = OPS[rule["op"]](i, rule["value"])
        end
    end

    return result
end

function merge_bitmaps(bmp1, bmp2)
    result = Dict()
    for (k, b1) in bmp1
        b2 = bmp2[k]
        result[k] = b1.&&b2
    end
    return result
end

function rule_bitmap_coms(rbmp)
    res = sum(rbmp["x"])
    for k in ["m", "a", "s"]
        res = res * sum(rbmp[k])
    end
    return res
end

function part1(workflows, parts)
    wkfs_by_name = Dict()
    for wkf in workflows
        wkfs_by_name[wkf["name"]] = wkf
    end
    res = 0
    for part in parts
        outcome = process_part(part, wkfs_by_name)
        if outcome == "A"
            res += part["x"] + part["m"] + part["a"] + part["s"]
        end
    end
    return res
end

function part2(workflows, parts)
    g = Dict()
    for wkf in workflows
        g[wkf["name"]] = wkf
    end

    # (wkf_name, rules, path)
    q = [("in", [], Set())]

    possible_paths = []
    while length(q) > 0
        w, rules, path = popfirst!(q)
        if w == "A"
            # We want this
            push!(possible_paths, rules)
            continue
        end
        if w == "R"
            # we don't want this
            continue
        end
        for (i, r) in enumerate(g[w]["rules"])
            if r["outcome"] in path
                # Cyclic?
                throw("Cyclic!")
                continue
            end
            nrules = vcat([], rules)
            if haskey(r, "prop")
                if i > 1
                    inv_rules = []
                    for j in range(1, i-1)
                        ivr = merge(Dict(
                            "inverse" => true,
                        ), g[w]["rules"][j])
                        push!(inv_rules, ivr)
                    end
                    nrules = vcat(nrules, inv_rules)
                end
                nrules = vcat(nrules, [r])
            else
                # put the inverse rules here
                inverse_rules = []
                for ivr in g[w]["rules"][1:i-1]
                    ivr = merge(Dict(
                        "inverse" => true,
                    ), ivr)
                    push!(inverse_rules, ivr)
                end
                nrules = vcat(nrules, inverse_rules)
            end
            push!(q, (r["outcome"], nrules, union(path, Set([r["outcome"]]))))
        end
    end
    println("Total paths to acceptance: ", length(possible_paths))
    merged = []
    result = 0
    for paths in possible_paths
        res = rule_as_bitmap(paths[1])
        for p in paths[2:end]
            res = merge_bitmaps(res, rule_as_bitmap(p))
        end
        push!(merged, res)
        result += rule_bitmap_coms(res)
    end
    return result
end

println("Part 1: ", part1(read_input("input")...))
println("Part 2: ", part2(read_input("input")...))