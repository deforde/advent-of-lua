#!luajit

local function print_stacks(stacks)
    for stack_idx = 1, #stacks do
        print(stack_idx)
        for crate_idx = 1, #stacks[stack_idx] do
            print(stacks[stack_idx][crate_idx])
        end
        print()
    end
end

local function move_crates(src, dst, quant)
    -- for _ = 1, quant do
    --     local crate = table.remove(src)
    --     table.insert(dst, crate)
    -- end

    local temp = {}
    for _ = 1, quant do
        local crate = table.remove(src)
        table.insert(temp, crate)
    end
    for _ = 1, quant do
        local crate = table.remove(temp)
        table.insert(dst, crate)
    end
end

local stacks = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
local building_stacks = true

for line in io.lines("problems/problem_05.txt") do
    if line == "" then
        goto continue
    end
    if building_stacks and string.sub(line, 2, 2) == "1" then
        building_stacks = false
        goto continue
    end
    if building_stacks then
        for crate_idx = 2, 34, 4 do
            local stack_idx = (crate_idx - 2) / 4 + 1
            local crate = string.sub(line, crate_idx, crate_idx)
            if crate ~= " " then
                table.insert(stacks[stack_idx], 1, crate)
            end
        end
    else
        local move = {}
        for n in string.gmatch(line, "%d+") do
            table.insert(move, tonumber(n))
        end
        local quant = move[1]
        local src = move[2]
        local dst = move[3]
        move_crates(stacks[src], stacks[dst], quant)
    end
    ::continue::
end

local ans = ""
for stack_idx = 1, #stacks do
    local height = #stacks[stack_idx]
    if height == 0 then
        break
    end
    ans = ans .. stacks[stack_idx][height]
end

-- assert(ans == "RFFFWBPNS")
assert(ans == "CQQBBJFCS")
