#!luajit

local MAT_ORE = 1
local MAT_CLY = 2
local MAT_OBS = 3
local MAT_GEO = 4

local function mat_idx_to_str(mat)
    if mat == MAT_ORE then
        return "ore"
    elseif mat == MAT_CLY then
        return "cly"
    elseif mat == MAT_OBS then
        return "obs"
    elseif mat == MAT_GEO then
        return "geo"
    end
    assert(false)
end

local function mat_str_to_idx(mat)
    if mat == "ore" then
        return MAT_ORE
    elseif mat == "clay" then
        return MAT_CLY
    elseif mat == "obsidian" then
        return MAT_OBS
    elseif mat == "geode" then
        return MAT_GEO
    end
    assert(false)
end

local function state_init()
    local s = {
        bots = {1, 0, 0, 0},
        mat = {0, 0, 0, 0},
        viable = {1, 1, 1, 1},
    }
    return s
end

local function state_clone(state)
    local nstate = state_init()
    for k, arr in pairs(state) do
        for i, v in ipairs(arr) do
            nstate[k][i] = v
        end
    end
    return nstate
end

local function blueprint_init()
    local bp = {
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
    }
    return bp
end

local function blueprint_print(bp)
    for mat, costs in ipairs(bp) do
        print("  Bot: " .. mat_idx_to_str(mat))
        for _, cost in ipairs(costs) do
            print("    " .. cost)
        end
    end
end

local function blueprints_print(bps)
    for i, bp in ipairs(bps) do
        print("BP #" .. i .. ":")
        blueprint_print(bp)
    end
end

local function blueprints_get()
    local bps = {}

    for line in io.lines("problems/problem_19.txt") do
        local bp = blueprint_init()

        for bot, cost_str in string.gmatch(line, "Each (%a+) robot costs (.-)%.") do
            for quant, mat in string.gmatch(cost_str, "(%d+) (%a+)") do
                bp[mat_str_to_idx(bot)][mat_str_to_idx(mat)] = tonumber(quant)
            end
        end

        table.insert(bps, bp)
    end

    return bps
end

local function mats_collect(state)
    for i = 1, 4 do
        state.mat[i] = state.mat[i] + state.bots[i]
    end
end

local function get_peak_costs(bp)
    local costs = {0,0,0,0}
    for bot = 1, 4 do
        for mat = 1, 4 do
            costs[mat] = math.max(costs[mat], bp[bot][mat])
        end
    end
    return costs
end

local function is_affordable(state, costs)
    for mat = 1, 4 do
        if state.mat[mat] < costs[mat] then
            return false
        end
    end
    return true
end

local function try_build_geo_bot(state, bp)
    local costs = bp[MAT_GEO]
    if is_affordable(state, costs) then
        for i = 1, 4 do
            state.mat[i] = state.mat[i] - costs[i]
        end
        mats_collect(state)
        state.bots[MAT_GEO] = state.bots[MAT_GEO] + 1
        return true
    end
    return false
end

local function state_branch(state, bp, pc)
    local nstates = {}

    for bot = 1, 3 do
        if state.bots[bot] < pc[bot] and state.viable[bot] == 1 then
            local costs = bp[bot]
            if is_affordable(state, costs) then
                state.viable[bot] = 0
                local nstate = state_clone(state)
                for i = 1, 4 do
                    nstate.viable[i] = 1
                    nstate.mat[i] = nstate.mat[i] - costs[i]
                end
                mats_collect(nstate)
                nstate.bots[bot] = nstate.bots[bot] + 1
                table.insert(nstates, nstate)
            end
        end
    end

    return nstates
end

local function states_prune(states, mr)
    local max_geo = 0
    for _, state in ipairs(states) do
        local this_max_geo = state.mat[MAT_GEO] + state.bots[MAT_GEO] * mr
        max_geo = math.max(max_geo, this_max_geo)
    end

    local i = 1
    while i <= #states do
        local this_max_geo = states[i].mat[MAT_GEO] + states[i].bots[MAT_GEO] * mr
        for m = 1, mr do
            this_max_geo = this_max_geo + m
        end
        if this_max_geo < max_geo then
            table.remove(states, i)
        else
            i = i + 1
        end
    end
end

local function blueprint_run(bp, mins)
    local states = {state_init()}

    local peak_costs = get_peak_costs(bp)

    for m = 1, mins do
        local nstates = {}
        for _, state in ipairs(states) do
            if try_build_geo_bot(state, bp) == false then
                local tmp = state_branch(state, bp, peak_costs)
                for _, nstate in ipairs(tmp) do
                    table.insert(nstates, nstate)
                end
                mats_collect(state)
            end
        end
        for _, nstate in ipairs(nstates) do
            table.insert(states, nstate)
        end
        states_prune(states, mins - m + 1)
    end

    local max_geo = 0
    for _, state in ipairs(states) do
        max_geo = math.max(max_geo, state.mat[MAT_GEO])
    end

    return max_geo
end

local function solve1()
    local bps = blueprints_get()
    -- blueprints_print(bps)
    local sum = 0
    for i, bp in ipairs(bps) do
        sum = sum + i * blueprint_run(bp, 24)
    end
    return sum
end

local function solve2()
    local bps = blueprints_get()
    bps = {bps[1], bps[2], bps[3]}
    local prod = 1
    for _, bp in ipairs(bps) do
        prod = prod * blueprint_run(bp, 32)
    end
    return prod
end

local ans = solve1()
assert(ans == 1349)

ans = solve2()
assert(ans == 21840)
