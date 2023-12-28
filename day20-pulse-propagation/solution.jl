abstract type ICM end

mutable struct FlipFlop <: ICM
    name::String
    is_on::Bool
    outputs::Vector{String}
end

mutable struct Conjuction <: ICM
    name::String
    inputs::Dict{String, String}
    outputs::Vector{String}
end

struct Broadcaster <: ICM
    name::String
    outputs::Vector{String}
end

struct OtherMod <: ICM
    name::String
    outputs::Vector{String}
end

function trigger(flp::FlipFlop, pulse::String, from_mod::String)::Vector{Tuple{String, String}}
    if pulse == "low"
        if flp.is_on
            flp.is_on = false
            result = Vector{Tuple{String,String}}()
            for out in flp.outputs
                push!(result, (out, "low"))
            end
            return result
        else
            flp.is_on = true
            result = Vector{Tuple{String,String}}()
            for out in flp.outputs
                push!(result, (out, "high"))
            end
            return result
        end
    end
    return Vector{Tuple{String,String}}()
end

function trigger(conj::Conjuction, pulse::String, from_mod::String)::Vector{Tuple{String,String}}
    conj.inputs[from_mod] = pulse
    all_high = true
    for v in values(conj.inputs)
        if v != "high"
            all_high = false
            break
        end
    end
    send_pulse = "high"
    if all_high
        send_pulse = "low"
    end
    result = Vector{Tuple{String,String}}()
    for out in conj.outputs
        push!(result, (out, send_pulse))
    end
    return result
end

function trigger(brd::Broadcaster, pulse::String, from_mod::String)::Vector{Tuple{String,String}}
    result = Vector{Tuple{String,String}}()
    for out in brd.outputs
        push!(result, (out, pulse))
    end
    return result
end

RX_COUNT = 0

function trigger(othr::OtherMod, pulse::String, from_mod::String)::Vector{Tuple{String,String}}
    global RX_COUNT
    
    if othr.name == "rx" && pulse == "low"
        println(othr.name, "->", pulse)
        RX_COUNT += 1
    end
    return Vector{Tuple{String,String}}()
end



function read_input(fn)
    open(fn) do f
        modules = Dict()
        for line in readlines(f)
            mod, outputs = map(p -> strip(p), split(line, "->"))
            outputs = map(p -> strip(p), split(outputs, ","))
            
            if mod[1] == '%'
                mod_name = mod[2:end]
                modules[mod_name] = FlipFlop(mod_name, false, outputs)
            elseif  mod[1] == '&'
                mod_name = mod[2:end]
                modules[mod_name] = Conjuction(mod_name, Dict(), outputs)
            elseif mod == "broadcaster"
                modules[mod] = Broadcaster(mod, outputs)
            else
                throw("what module: $(mod)")
            end
        end

        # Now fix the graph for outputs -> inputs for conjuction
        for (_, mod) in modules
            for out in mod.outputs
                if !haskey(modules, out)
                    modules[out] = OtherMod(out, [])
                end
                target = modules[out]
                if typeof(target) <: Conjuction
                    target.inputs[mod.name] = "low"
                end
            end
        end
        return modules
    end
end

function push_button(modules, watch_for_high=Dict(), in_mod_name=nothing)
    high_count = 0
    low_count = 0
    broadcaster = modules["broadcaster"]
    q = []::Vector{Any}
    push!(q, (broadcaster, "low", "button"))

    while length(q) > 0
        mod, pulse, from_mod = popfirst!(q)
        if pulse == "low"
            low_count += 1
        else
            high_count += 1
        end
        if in_mod_name !== nothing
            if "high" in values(modules[in_mod_name].inputs)
                for (k, v) in modules[in_mod_name].inputs
                    if v == "high"
                        watch_for_high[k] = "yes"
                    end
                end
            end
        end
        for (out, pulse) in trigger(mod, pulse, from_mod)
            #println(mod.name, " -> ", out, ": ", pulse)
            push!(q, (modules[out], pulse, mod.name))
        end
    end
    return (low_count, high_count)
end


function part1(modules)
    high_count, low_count = 0, 0
    for _ in range(1, 1000)
        hc, lc = push_button(modules)
        high_count += hc
        low_count += lc
    end
    return high_count * low_count
end

function find_paths_to_rx(modules)
    broadcaster = modules["broadcaster"]
    paths = []
    # module, path
    q = []::Vector{Any}
    push!(q, (broadcaster, []))

    while length(q) > 0
        mod, path = popfirst!(q)
        if mod.name == "rx"
            push!(paths, vcat(path, ["rx"]))
            continue
        end
        for out in mod.outputs
            if out in path
                continue
            end
            push!(q, (modules[out], vcat(path, [mod.name])))
        end
    end
    return paths
end

function which_nodes_connect_to(mod, modules)
    nodes = []
    for (n, m) in modules
        if mod in m.outputs
            push!(nodes, (n, m))
        end
    end
    return nodes
end

function part2(modules)
    global RX_COUNT
    count = 0
    while true
        count += 1
        push_button(modules)
        if count % 10000 == 0
            println(count,": ", RX_COUNT)
        end
        if RX_COUNT == 1
            return count
        end
        if RX_COUNT >= 1
            println(" *** count=", count)
        end
        RX_COUNT = 0
    end
    return count
end

function part2(modules)
    to_mod = which_nodes_connect_to("rx", modules) # "rx" is always connected to conjuction (assumption)
    while length(to_mod) == 1
        to_mod = which_nodes_connect_to(to_mod[1][1], modules)
    end

    for (n, m) in to_mod
        println("Module $(n) of type: $(typeof(m))")
    end

    # rx connects to a conjuction and we want all inputs to the conjuction to hbe "high".
    # If rx connects to a flip-flop, then we want "low" etc.
    # But fortunately it just goes to conjuction straight away.
    conj_to_rx = which_nodes_connect_to("rx", modules)[1]
    println(conj_to_rx[2])
    count = 0
    where_high = Dict()
    while true
        count += 1
        any_high = Dict()
        # Push the button, but chech if the last conjuction to "rx" has any of the inputs set to "high".
        push_button(modules, any_high, conj_to_rx[1])
        if length(any_high) > 0
            for (m, _) in any_high
                if !haskey(where_high, m)
                    where_high[m] = []
                end
                # If it does, record the number of button presses so far - we're looking for a cycle
                push!(where_high[m], count)
            end
            println(where_high)
        end

        # We want to collect data for all inputs on the last conjuction.
        if length(where_high) == length(conj_to_rx[2].inputs)
            # And we assume that 2 numbers are enough to extract a cycle sequence.
            # So if we have found at least 2 times where we had "high" on all inputs, the find the cycles.
            at_least_2 = true
            for (_, v) in where_high
                if length(v) < 2
                    at_least_2 = false
                    break
                end
            end
            if at_least_2
                # We have the data points, extract the cycles.
                diffs = []
                for (_, v) in where_high
                    push!(diffs, v[2] - v[1])
                end
                println(diffs)
                # No LCM over those cycles, and done.
                return lcm(diffs...)
            end
        end
    end
end

println("Part 1: ", part1(read_input("input")))
println("Part 2: ", part2(read_input("input")))
