#!luajit

local function node_create(parent, val)
    local node = {
        parent = parent,
        children = {},
        val = val,
        divider = false,
    }
    return node
end

local function node_descend(node)
    local child = node_create(node, nil)
    table.insert(node.children, child)
    return child
end

local function node_ascend(node)
    return node.parent
end

local function node_print(node, indent)
    local val = node.val
    if val == nil then
        val = -1
    end
    print(indent .. val)
    local nindent = indent .. "  "
    for _, child in pairs(node.children) do
        node_print(child, nindent)
    end
end

local function node_convert_val_to_child(node)
    assert(node.val ~= nil)
    local val = node.val
    node.val = nil
    local child = node_descend(node)
    child.val = val
end

local function gen_node(s)
    local root = node_create(nil, nil)
    local cur = root
    local num_str = ""

    for i = 1, string.len(s) do
        local ch = string.sub(s, i, i)
        if ch == "[" then
            cur = node_descend(cur)
        elseif ch == "]" then
            if num_str ~= "" then
                cur.val = tonumber(num_str)
                num_str = ""
            end
            cur = node_ascend(cur)
        elseif ch == "," then
            if num_str ~= "" then
                cur.val = tonumber(num_str)
                num_str = ""
            end
            cur = node_ascend(cur)
            cur = node_descend(cur)
        else
            num_str = num_str .. ch
        end
    end

    return root
end

local function compare_nodes(l, r)
    if l.val ~= nil and r.val ~= nil then
        if l.val < r.val then
            return 1
        elseif l.val > r.val then
            return -1
        end
    elseif #l.children > 0 and #r.children > 0 then
        local i = 1
        local j = 1
        while i <= #l.children and j <= #r.children do
            local res = compare_nodes(l.children[i], r.children[j])
            if res ~= 0 then
                return res
            end
            i = i + 1
            j = j + 1
        end
        if i > #l.children and j > #r.children then
            return 0
        end
        if i > #l.children and j <= #r.children then
            return 1
        end
        if i <= #l.children and j > #r.children then
            return -1
        end
    elseif l.val ~= nil then
        node_convert_val_to_child(l)
        local res = compare_nodes(l, r)
        if res ~= 0 then
            return res
        end
    elseif r.val ~= nil then
        node_convert_val_to_child(r)
        local res = compare_nodes(l, r)
        if res ~= 0 then
            return res
        end
    elseif #l.children == 0 and #r.children > 0 then
        return 1
    elseif #l.children > 0 and #r.children == 0 then
        return -1
    end
    return 0
end

local function sort_packets(packets)
    local change_made = true
    while change_made do
        change_made = false
        for i = 1, #packets - 1 do
            local sorted = compare_nodes(packets[i], packets[i + 1]) == 1
            if sorted == false then
                local p = table.remove(packets, i + 1)
                table.insert(packets, i, p)
                change_made = true
            end
        end
    end
end

local function solve1()
    local sum = 0
    local cntr = 1
    local idx = 0
    local p = nil
    local q = nil

    for line in io.lines("problems/problem_13.txt") do
        if line ~= "" then
            if idx == 0 then
                p = gen_node(line)
                idx = (idx + 1) % 2
            else
                q = gen_node(line)
                idx = (idx + 1) % 2
                local res = compare_nodes(p, q)
                if res == 1 then
                    sum = sum + cntr
                end
                cntr = cntr + 1
            end
        end
    end

    return sum
end

local function solve2()
    local packets = {
        gen_node("[[2]]"),
        gen_node("[[6]]"),
    }
    packets[1].divider = true
    packets[2].divider = true
    for line in io.lines("problems/problem_13.txt") do
        if line ~= "" then
            table.insert(packets, gen_node(line))
        end
    end
    sort_packets(packets)
    local prod = 1
    for i, p in ipairs(packets) do
        if p.divider then
            prod = prod * i
        end
    end
    return prod
end

local ans = solve1()
assert(ans == 5208)

ans = solve2()
assert(ans == 25792)
