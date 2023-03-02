#!luajit

local function create_node(name, parent, size)
    local node = {
        name = name,
        parent = parent,
        children = {},
        size = size,
    }
    return node
end

local function find_child(node, name)
    for _, child in ipairs(node.children) do
        if name == child.name then
            return child
        end
    end
    return nil
end

local function add_child(name, parent, size)
    local sibling = find_child(parent, name)
    if sibling == nil then
        local child = create_node(name, parent, size)
        table.insert(parent.children, child)
        return child
    end
    return sibling
end

local function calc_recursive_size(node)
    if (node.size ~= nil) then
        return node.size
    end
    local size = 0
    for _, child in ipairs(node.children) do
        size = size + calc_recursive_size(child)
    end
    node.size = size
    return size
end

local function accumulate_recursive_sizes(node, max_size)
    local size = 0
    if (node.size <= max_size and #node.children ~= 0) then
        size = node.size
    end
    for _, child in ipairs(node.children) do
        size = size + accumulate_recursive_sizes(child, max_size)
    end
    return size
end

local function find_smallest_dir_in_excess(node, min_size, size)
    assert(size ~= nil)
    if (node.size >= min_size and node.size <= size and #node.children ~= 0) then
        size = node.size
    end
    for _, child in ipairs(node.children) do
        size = find_smallest_dir_in_excess(child, min_size, size)
    end
    return size
end

local function create_tree()
    local root = create_node(nil, nil, nil)
    local cur = root

    for line in io.lines("problems/problem_07.txt") do
        if (string.sub(line, 1, 1) == "$") then
            if (string.sub(line, 3, 3) ~= "l") then
                local dirname = string.sub(line, string.find(line, "[./%a]+$"), string.len(line))
                if (dirname == "..") then
                    cur = cur.parent
                elseif (dirname == "/") then
                    cur = root
                else
                    cur = add_child(dirname, cur, nil)
                end
            end
        else
            local size = nil
            local start_idx, end_idx = string.find(line, "^%d+")
            if (start_idx ~= nil) then
                size = tonumber(string.sub(line, start_idx, end_idx))
            end
            local dirname = string.sub(line, string.find(line, "[./%a]+$"), string.len(line))
            add_child(dirname, cur, size)
        end
    end

    calc_recursive_size(root)
    return root
end

local root = create_tree()

local ans = accumulate_recursive_sizes(root, 100000)
assert(ans == 1232307)

local capacity = 70000000
local required = 30000000
local available = capacity - root.size
local min_to_del = required - available

ans = find_smallest_dir_in_excess(root, min_to_del, 10000000000)
assert(ans == 7268994)
