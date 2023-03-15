#!luajit

local function coord_create(x, y)
    local c = {
        x = x,
        y = y,
    }
    return c
end

local function map_insert(map, c)
    if map[c.x] == nil then
        map[c.x] = {}
    end
    map[c.x][c.y] = 1
end

local function map_print(map)
    for x, ys in pairs(map) do
        print(x .. ":")
        for y, _ in pairs(ys) do
            print("  " .. y)
        end
    end
end

local function map_create()
    local map = {}
    local xmin = 1000000000
    local xmax = 0
    local ymax = 0

    for line in io.lines("problems/problem_14.txt") do
        local geo = {}
        for sx, sy in string.gmatch(line, "(%d+),(%d+)") do
            local x = tonumber(sx)
            local y = tonumber(sy)
            xmin = math.min(x, xmin)
            xmax = math.max(x, xmax)
            ymax = math.max(y, ymax)
            table.insert(geo, coord_create(x, y))
        end

        for i = 1, #geo - 1 do
            local strt = geo[i]
            local stop = geo[i + 1]
            local dx = stop.x - strt.x
            dx = math.min(dx, 1)
            dx = math.max(dx, -1)
            local dy = stop.y - strt.y
            dy = math.min(dy, 1)
            dy = math.max(dy, -1)
            local cur = strt
            while cur.x ~= stop.x or cur.y ~= stop.y do
                map_insert(map, cur)
                cur.x = cur.x + dx
                cur.y = cur.y + dy
            end
            map_insert(map, stop)
        end
    end

    -- map_print(map)
    return map, xmin, xmax, ymax
end

local function solve1()
    local map, xmin, xmax, ymax = map_create()

    local orig = coord_create(500, 0)
    local rst_cnt = 0
    local done = false
    while done == false do
        local grain = orig
        while true do
            local nps = {
                coord_create(grain.x, grain.y + 1),
                coord_create(grain.x - 1, grain.y + 1),
                coord_create(grain.x + 1, grain.y + 1),
            }
            local moved = false
            for _, np in ipairs(nps) do
                if map[np.x] == nil or map[np.x][np.y] == nil then
                    moved = true
                    grain = np
                    break
                end
            end
            if moved == false then
                map_insert(map, grain)
                rst_cnt = rst_cnt + 1
                break
            end
            if grain.y > ymax or grain.x < xmin or grain.x > xmax then
                done = true
                break
            end
        end
    end

    return rst_cnt
end

local function solve2()
    local map, xmin, xmax, ymax = map_create()
    local yfloor = ymax + 1

    local orig = coord_create(500, 0)
    local rst_cnt = 0
    local done = false
    while done == false do
        local grain = orig
        while true do
            local nps = {
                coord_create(grain.x, grain.y + 1),
                coord_create(grain.x - 1, grain.y + 1),
                coord_create(grain.x + 1, grain.y + 1),
            }
            local moved = false
            for _, np in ipairs(nps) do
                if map[np.x] == nil or map[np.x][np.y] == nil then
                    moved = true
                    grain = np
                    break
                end
            end
            if moved == false or grain.y == yfloor then
                map_insert(map, grain)
                rst_cnt = rst_cnt + 1
                done = grain.x == orig.x and grain.y == orig.y
                break
            end
        end
    end

    return rst_cnt
end

local ans = solve1()
assert(ans == 1016)

ans = solve2()
assert(ans == 25402)
