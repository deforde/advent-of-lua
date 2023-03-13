#!luajit

local function create_coord(x, y)
    local c = {
        x = x,
        y = y,
    }
    return c
end

local function create_path_tip(pos, len)
    local pt = {
        pos = pos,
        len = len,
    }
    return pt
end

local function create_grid()
    local start = create_coord(0, 0)
    local stop = create_coord(0, 0)
    local grid = {}
    local row = 1
    for line in io.lines("problems/problem_12.txt") do
        grid[row] = {}
        for col = 1, string.len(line) do
            local ch = string.sub(line, col, col)
            local height = 0
            if ch == "S" then
                start.x = row
                start.y = col
                height = 0
            elseif ch == "E" then
                stop.x = row
                stop.y = col
                height = 25
            else
                height = string.byte(ch) - string.byte("a")
            end
            grid[row][col] = height
        end
        row = row + 1
    end
    return grid, start, stop
end

local function proc_move(h, op, d, g, v, m)
    local oh = g[op.x][op.y]
    local viable = false
    if d == "f" then
        viable = oh <= h + 1
    else
        viable = h <= oh + 1
    end
    if viable and v[op.x][op.y] ~= 1 then
        table.insert(m, op)
    end
end

local function get_viable_moves(g, v, p, d)
    local h = g[p.x][p.y]
    local m = {}

    local xmin = math.max(1, p.x - 1)
    local xmax = math.min(#g, p.x + 1)
    local ymin = math.max(1, p.y - 1)
    local ymax = math.min(#g[1], p.y + 1)

    for x = xmin, xmax do
        if x ~= p.x then
            proc_move(h, create_coord(x, p.y), d, g, v, m)
        end
    end

    for y = ymin, ymax do
        if y ~= p.y then
            proc_move(h, create_coord(p.x, y), d, g, v, m)
        end
    end

    return m
end

local function get_shortest_path(g, strt, stops, v, d)
    local pts = {
        create_path_tip(strt, 0)
    }

    v[strt.x][strt.y] = 1

    while #pts > 0 do
        local pt = table.remove(pts)
        local ms = get_viable_moves(g, v, pt.pos, d)
        while #ms > 0 do
            local m = table.remove(ms)
            if stops[m.x][m.y] == 1 then
                return pt.len + 1
            end
            v[m.x][m.y] = 1
            table.insert(pts, 1, create_path_tip(m, pt.len + 1))
        end
    end

    return math.maxinteger
end

local function get_all_possible_starts(g)
    local starts = {}
    for r = 1, #g do
        starts[r] = {}
        for c = 1, #g[1] do
            if g[r][c] == 0 then
                starts[r][c] = 1
            else
                starts[r][c] = 0
            end
        end
    end
    return starts
end

local function solve1()
    local g, strt, stop = create_grid()

    local v = {}
    local stops = {}
    for r = 1, #g do
        v[r] = {}
        stops[r] = {}
        for c = 1, #g[1] do
            v[r][c] = 0
            stops[r][c] = 0
        end
    end

    stops[stop.x][stop.y] = 1

    return get_shortest_path(g, strt, stops, v, "f")
end

local function solve2()
    local g, _, stop = create_grid()

    local v = {}
    for r = 1, #g do
        v[r] = {}
        for c = 1, #g[1] do
            v[r][c] = 0
        end
    end

    local strts = get_all_possible_starts(g)

    return get_shortest_path(g, stop, strts, v, "r")
end

local ans = solve1()
assert(ans == 528)

ans = solve2()
assert(ans == 522)
