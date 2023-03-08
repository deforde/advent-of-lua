#!luajit

local function create_monkey()
    local monkey = {
        items = {},
        op = "add",
        op_val = nil,
        test_quotient = 1,
        true_target = 0,
        false_target = 0,
        inspect_cnt = 0,
    }
    return monkey
end

local function generate_monkeys()
    local monkeys = {}
    local monkey = nil
    for line in io.lines("problems/problem_11.txt") do
        if string.find(line, "^Monkey ") ~= nil then
            monkey = create_monkey()
        elseif string.find(line, "^  Starting items: ") ~= nil then
            for n in string.gmatch(line, "%d+") do
                monkey.items[#monkey.items + 1] = tonumber(n)
            end
        elseif string.find(line, "^  Operation: new = old ") ~= nil then
            if string.find(line, "old$") ~= nil then
                monkey.op = "sqr"
            else
                if string.find(line, "old %* ") ~= nil then
                    monkey.op = "mul"
                end
                monkey.op_val = tonumber(string.sub(line, string.find(line, "[0-9]+")))
            end
        elseif string.find(line, "^  Test: divisible by ") ~= nil then
            monkey.test_quotient = tonumber(string.sub(line, string.find(line, "[0-9]+")))
        elseif string.find(line, "^    If true: throw to monkey ") ~= nil then
            monkey.true_target = tonumber(string.sub(line, string.find(line, "[0-9]+"))) + 1
        elseif string.find(line, "^    If false: throw to monkey ") ~= nil then
            monkey.false_target = tonumber(string.sub(line, string.find(line, "[0-9]+"))) + 1
            monkeys[#monkeys + 1] = monkey
        end
    end
    return monkeys
end

local function sim_rounds(monkeys, nrounds, do_div)
    local super_mod = 1
    for _, m in ipairs(monkeys) do
        super_mod = super_mod * m.test_quotient
    end
    for _ = 1, nrounds do
        for _, m in ipairs(monkeys) do
            while #m.items > 0 do
                local item = table.remove(m.items)
                m.inspect_cnt = m.inspect_cnt + 1
                if m.op == "add" then
                    item = item + m.op_val
                elseif m.op == "mul" then
                    item = item * m.op_val
                else
                    item = item * item
                end
                if do_div then
                    item = math.floor(item / 3)
                else
                    item = item % super_mod
                end
                if item % m.test_quotient == 0 then
                    table.insert(monkeys[m.true_target].items, item)
                else
                    table.insert(monkeys[m.false_target].items, item)
                end
            end
        end
    end
end

local function print_monkeys(monkeys)
    for i, m in ipairs(monkeys) do
        print("index: " .. i)
        print("  items:")
        for _, item in ipairs(m.items) do
            print("    " .. item)
        end
        print("  op: " .. m.op)
        if m.op_val == nil then
            print("  op_val: none")
        else
            print("  op_val: " .. m.op_val)
        end
        print("  test_quotient: " .. m.test_quotient)
        print("  true_target: " .. m.true_target)
        print("  false_target: " .. m.false_target)
        print("  inspect_cnt: " .. m.inspect_cnt)
        print()
    end
end

local function solve(nrounds, do_div)
    local monkeys = generate_monkeys()
    -- print_monkeys(monkeys)

    sim_rounds(monkeys, nrounds, do_div)

    local inspect_cnts = {}
    for i, m in ipairs(monkeys) do
        inspect_cnts[i] = m.inspect_cnt
    end
    table.sort(inspect_cnts)
    return inspect_cnts[#inspect_cnts] * inspect_cnts[#inspect_cnts - 1]
end

local ans = solve(20, true)
assert(ans == 102399)

ans = solve(10000, false)
assert(ans == 23641658401)
