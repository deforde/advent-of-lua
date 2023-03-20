#!luajit

local function node_create(fr, conns)
    local n = {
        fr = fr,
        conns = conns,
    }
    return n
end

local function pathtip_create(id, dist)
    local pt = {
        id = id,
        dist = dist,
    }
    return pt
end

local function path_create(node_ids, press)
    local p = {
        node_ids = node_ids,
        press = press,
    }
    return p
end

local function nodemap_gen()
    local nodemap = {}
    for line in io.lines("problems/problem_16.txt") do
        local id, fr, conns_str = string.match(line, "Valve ([A-Z]+) has flow rate=(%d+); %a+ %a+ %a+ %a+ (.*)")
        local conns = {}
        for conn in string.gmatch(conns_str, "[A-Z]+") do
            table.insert(conns, conn)
        end
        nodemap[id] = node_create(tonumber(fr), conns)
    end
    return nodemap
end

local function is_contained(list, id)
    for _, item in ipairs(list) do
        if item == id then
            return true
        end
    end
    return false
end

local function are_paths_unique(p1, p2)
    for i = 2, #p1 do
        for j = 2, #p2 do
            if p1[i] == p2[j] then
                return false
            end
        end
    end
    return true
end

local function list_clone(l)
    local nl = {}
    for _, i in ipairs(l) do
        table.insert(nl, i)
    end
    return nl
end

local function update_path(paths, npath, press)
    for _, path in ipairs(paths) do
        local path_match = true
        if #path.node_ids ~= #npath then
            path_match = false
        else
            for _, node_id in ipairs(npath) do
                if is_contained(path.node_ids, node_id) == false then
                    path_match = false
                    break
                end
            end
        end
        if path_match then
            if press > path.press then
                path.press = press
            end
            return
        end
    end
    table.insert(paths, path_create(list_clone(npath), press))
end

local function distmap_gen(nodemap)
    local distmap = {}
    for src, _ in pairs(nodemap) do
        distmap[src] = {}
        local visited = {
            src = 1,
        }
        local pathtips = {
            pathtip_create(src, 0),
        }
        while #pathtips > 0 do
            local pathtip = table.remove(pathtips)
            local cur = nodemap[pathtip.id]
            for _, conn in ipairs(cur.conns) do
                if visited[conn] == nil then
                    visited[conn] = 1
                    distmap[src][conn] = pathtip.dist + 1
                    table.insert(pathtips, 1, pathtip_create(conn, pathtip.dist + 1))
                end
            end
        end
    end
    return distmap
end

local function get_max_press_path_inner(nodemap, distmap, dst_node_ids, src_id, press, mins_remaining, path, paths)
    local max_press = press
    for i, dst_id in ipairs(dst_node_ids) do
        local dup = list_clone(dst_node_ids)
        table.remove(dup, i)

        local dist = distmap[src_id][dst_id]
        local nmr = mins_remaining - dist - 1
        if nmr >= 1 then
            local new_press = press + nodemap[dst_id].fr * nmr

            local npath = nil
            if paths ~= nil then
                npath = list_clone(path)
                table.insert(npath, dst_id)
                update_path(paths, npath, new_press)
            end

            local nmp = get_max_press_path_inner(nodemap, distmap, dup, dst_id, new_press, nmr, npath, paths)
            max_press = math.max(nmp, max_press)
        end
    end
    return max_press
end

local function get_max_press_path(nodemap, distmap, dst_node_ids, mins_remaining, paths)
    local path = { "AA" }
    return get_max_press_path_inner(nodemap, distmap, dst_node_ids, "AA", 0, mins_remaining, path, paths)
end

local function solve1()
    local nodemap = nodemap_gen()

    local non_zero_fr = {}
    for id, node in pairs(nodemap) do
        if node.fr ~= 0 then
            table.insert(non_zero_fr, id)
        end
    end

    local distmap = distmap_gen(nodemap)

    local p = get_max_press_path(nodemap, distmap, non_zero_fr, 30, nil)

    return p
end

local function solve2()
    local nodemap = nodemap_gen()

    local non_zero_fr = {}
    for id, node in pairs(nodemap) do
        if node.fr ~= 0 then
            table.insert(non_zero_fr, id)
        end
    end

    local distmap = distmap_gen(nodemap)

    local paths = {}
    get_max_press_path(nodemap, distmap, non_zero_fr, 26, paths)

    local max_p = 0
    for i = 1, #paths - 1 do
        for j = 2, #paths do
            local p1 = paths[i]
            local p2 = paths[j]
            if are_paths_unique(p1.node_ids, p2.node_ids) then
                local press = p1.press + p2.press
                max_p = math.max(max_p, press)
            end
        end
    end
    return max_p
end

local ans = solve1()
assert(ans == 1659)

ans = solve2()
assert(ans == 2382)
