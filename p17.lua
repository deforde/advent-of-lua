#!luajit

local function coord_create(x, y)
    local c = {
        x = x,
        y = y,
    }
    return c
end

local function recondata_create(min, max, n)
    local d = {
        min = min,
        max = max,
        n = n,
    }
    return d
end

local function cols_shift(cols, dh, min)
    for _, col in ipairs(cols) do
        for i, h in ipairs(col) do
            if h >= min then
                col[i] = h + dh
            end
        end
    end
end

local function state_get(cols, shape_ty_ids, buf_idx)
    local state = {}
    local min = nil
    for _, col in ipairs(cols) do
        table.insert(state, col[#col])
        if min == nil then
            min = state[#state]
        end
        min = math.min(state[#state], min)
    end
    for i = 1, #state do
        state[i] = state[i] - min
    end
    table.insert(state, shape_ty_ids)
    table.insert(state, buf_idx)
    return state
end

local function cols_getmin(cols)
    local min = nil
    for _, col in ipairs(cols) do
        local h = col[#col]
        if min == nil then
            min = h
        end
        min = math.min(min, h)
    end
    return min
end

local function cols_getmax(cols)
    local max = 0
    for _, col in ipairs(cols) do
        local h = col[#col]
        max = math.max(max, h)
    end
    return max
end

local function cols_update(cols, sh)
    for _, c in ipairs(sh) do
        local col = cols[c.x]
        table.insert(col, c.y)
        table.sort(col)
    end
    local min = cols_getmin(cols)
    for _, col in ipairs(cols) do
        local i = #col
        while i > 1 do
            if col[i] == min then
                break
            end
            i = i - 1
        end
        if i ~= 1 then
            for _ = 1, i do
                table.remove(col, 0)
            end
        end
    end
end

local function shape_clone(sh)
    local nsh = {}
    for _, c in ipairs(sh) do
        table.insert(nsh, coord_create(c.x, c.y))
    end
    return nsh
end

local function check_collisions(cols, sh)
    for _, c in ipairs(sh) do
        if c.x < 1 or c.x > 7 then
            return true
        end
        assert(c.x > 0)
        local col = cols[c.x]
        for i = #col, 1, -1 do
            if c.y == col[i] then
                return true
            end
            if c.y > col[i] then
                break
            end
        end
    end
    return false
end

local function descend(cols, sh)
    local nsh = shape_clone(sh)

    for i, c in ipairs(nsh) do
        nsh[i].y = c.y - 1
    end

    if check_collisions(cols, nsh) then
        cols_update(cols, sh)
        return false, sh
    end

    return true, nsh
end

local function proc_move(m, sh, cols)
    local nsh = shape_clone(sh)
    if m == ">" then
        for i, c in ipairs(nsh) do
            nsh[i].x = c.x + 1
        end
    elseif m == "<" then
        for i, c in ipairs(nsh) do
            nsh[i].x = c.x - 1
        end
    end
    if check_collisions(cols, nsh) then
        return sh
    end
    return nsh
end

local function shape_gen(cols, ty)
    local miny = cols_getmax(cols) + 4
    local sh = {}
    if ty == "h" then
        table.insert(sh, coord_create(3, miny))
        table.insert(sh, coord_create(4, miny))
        table.insert(sh, coord_create(5, miny))
        table.insert(sh, coord_create(6, miny))
    elseif ty == "+" then
        table.insert(sh, coord_create(3, miny + 1))
        table.insert(sh, coord_create(4, miny))
        table.insert(sh, coord_create(4, miny + 1))
        table.insert(sh, coord_create(4, miny + 2))
        table.insert(sh, coord_create(5, miny + 1))
    elseif ty == "j" then
        table.insert(sh, coord_create(3, miny))
        table.insert(sh, coord_create(4, miny))
        table.insert(sh, coord_create(5, miny))
        table.insert(sh, coord_create(5, miny + 1))
        table.insert(sh, coord_create(5, miny + 2))
    elseif ty == "v" then
        table.insert(sh, coord_create(3, miny))
        table.insert(sh, coord_create(3, miny + 1))
        table.insert(sh, coord_create(3, miny + 2))
        table.insert(sh, coord_create(3, miny + 3))
    elseif ty == "s" then
        table.insert(sh, coord_create(3, miny))
        table.insert(sh, coord_create(4, miny))
        table.insert(sh, coord_create(3, miny + 1))
        table.insert(sh, coord_create(4, miny + 1))
    end
    return sh
end

local function statemap_find(statemap, state)
    for ext_state, recondata in pairs(statemap) do
        if #ext_state == #state then
            local match = true
            for i, v in ipairs(ext_state) do
                if v ~= state[i] then
                    match = false
                    break
                end
            end
            if match then
                return true, ext_state, recondata
            end
        end
    end
    return false, nil, nil
end

local function cols_print(cols)
    print()
    for _, col in ipairs(cols) do
        print(col[#col])
    end
    print()
end

local function solve(nshapes)
    local buf = io.input("problems/problem_17.txt"):read()
    local buf_idx = 1

    local shape_tys = {
        "h",
        "+",
        "j",
        "v",
        "s",
    }
    local shape_ty_idx = 1

    local cols = { {0}, {0}, {0}, {0}, {0}, {0}, {0} }

    local statemap = {}
    local cycle_found = false

    local n = 1
    while n <= nshapes do
        local sh = shape_gen(cols, shape_tys[shape_ty_idx])

        if cycle_found == false then
            local state = state_get(cols, shape_ty_idx, buf_idx)
            local match, _, recondata = statemap_find(statemap, state)
            if match then
                assert(recondata ~= nil)
                cycle_found = true
                local dn = n - recondata.n
                local ncycles = math.floor((nshapes - n) / dn)
                local dh = (cols_getmax(cols) - recondata.max) * ncycles
                cols_shift(cols, dh, recondata.min)
                n = n + ncycles * dn
                sh = shape_gen(cols, shape_tys[shape_ty_idx])
            else
                statemap[state] = recondata_create(cols_getmin(cols), cols_getmax(cols), n)
            end
        end
        while true do
            local move = string.sub(buf, buf_idx, buf_idx)
            buf_idx = (buf_idx + 1)
            if buf_idx > #buf then
                buf_idx = 1
            end
            sh = proc_move(move, sh, cols)
            local descended = false
            descended, sh = descend(cols, sh)
            if descended == false then
                break
            end
        end

        shape_ty_idx = shape_ty_idx + 1
        if shape_ty_idx > #shape_tys then
            shape_ty_idx = 1
        end

        -- cols_print(cols)
        n = n + 1
    end

    return cols_getmax(cols)
end

local ans = solve(2022)
assert(ans == 3127)

ans = solve(1000000000000)
assert(ans == 1542941176480)
