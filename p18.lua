#!luajit

local function coord_create(x, y, z)
    local c = {
        x = x,
        y = y,
        z = z,
    }
    return c
end

local function grid_init()
    local grid = {}
    for x = 0, 19 do
        grid[x] = {}
        for y = 0, 19 do
            grid[x][y] = {}
            for z = 0, 19 do
                grid[x][y][z] = 0
            end
        end
    end
    return grid
end

local function grid_create()
    local grid = grid_init()
    local dims = coord_create(0, 0, 0)
    for line in io.lines("problems/problem_18.txt") do
        local sx, sy, sz = string.match(line, "(%d+),(%d+),(%d+)")
        local x = tonumber(sx)
        local y = tonumber(sy)
        local z = tonumber(sz)
        grid[x][y][z] = 1
        dims.x = math.max(dims.x, x)
        dims.y = math.max(dims.y, y)
        dims.z = math.max(dims.z, z)
    end
    dims.x = dims.x + 1
    dims.y = dims.y + 1
    dims.z = dims.z + 1
    return grid, dims
end

local function count_exposed_sides1(grid, dims, c)
    local sides = 0

    if c.x == 0 or grid[c.x - 1][c.y][c.z] == 0 then
        sides = sides + 1
    end
    if c.x == dims.x - 1 or grid[c.x + 1][c.y][c.z] == 0 then
        sides = sides + 1
    end

    if c.y == 0 or grid[c.x][c.y - 1][c.z] == 0 then
        sides = sides + 1
    end
    if c.y == dims.y - 1 or grid[c.x][c.y + 1][c.z] == 0 then
        sides = sides + 1
    end

    if c.z == 0 or grid[c.x][c.y][c.z - 1] == 0 then
        sides = sides + 1
    end
    if c.z == dims.z - 1 or grid[c.x][c.y][c.z + 1] == 0 then
        sides = sides + 1
    end

    return sides
end

local function count_exposed_sides2(grid, dims, c)
    local sides = 0

    if c.x == 0 or grid[c.x - 1][c.y][c.z] == 2 then
        sides = sides + 1
    end
    if c.x == dims.x - 1 or grid[c.x + 1][c.y][c.z] == 2 then
        sides = sides + 1
    end

    if c.y == 0 or grid[c.x][c.y - 1][c.z] == 2 then
        sides = sides + 1
    end
    if c.y == dims.y - 1 or grid[c.x][c.y + 1][c.z] == 2 then
        sides = sides + 1
    end

    if c.z == 0 or grid[c.x][c.y][c.z - 1] == 2 then
        sides = sides + 1
    end
    if c.z == dims.z - 1 or grid[c.x][c.y][c.z + 1] == 2 then
        sides = sides + 1
    end

    return sides
end

local function is_exposed(grid, dims, c)
    if c.x == 0 or grid[c.x - 1][c.y][c.z] == 2 then
        return true
    end
    if c.x == dims.x - 1 or grid[c.x + 1][c.y][c.z] == 2 then
        return true
    end

    if c.y == 0 or grid[c.x][c.y - 1][c.z] == 2 then
        return true
    end
    if c.y == dims.y - 1 or grid[c.x][c.y + 1][c.z] == 2 then
        return true
    end

    if c.z == 0 or grid[c.x][c.y][c.z - 1] == 2 then
        return true
    end
    if c.z == dims.z - 1 or grid[c.x][c.y][c.z + 1] == 2 then
        return true
    end

    return false
end

local function flood_fill(grid, dims)
    local change_detected = true
    while change_detected do
        change_detected = false
        for x = 0, dims.x - 1 do
            for y = 0, dims.y - 1 do
                for z = 0, dims.z - 1 do
                    if grid[x][y][z] == 0 then
                        if is_exposed(grid, dims, coord_create(x, y, z)) then
                            grid[x][y][z] = 2
                            change_detected = true
                        end
                    end
                end
            end
        end
    end
end

local function solve1()
    local grid, dims = grid_create()

    local sa = 0

    for x = 0, dims.x - 1 do
        for y = 0, dims.y - 1 do
            for z = 0, dims.z - 1 do
                if grid[x][y][z] == 1 then
                    sa = sa + count_exposed_sides1(grid, dims, coord_create(x, y, z))
                end
            end
        end
    end

    return sa
end

local function solve2()
    local grid, dims = grid_create()
    flood_fill(grid, dims)

    local sa = 0

    for x = 0, dims.x - 1 do
        for y = 0, dims.y - 1 do
            for z = 0, dims.z - 1 do
                if grid[x][y][z] == 1 then
                    sa = sa + count_exposed_sides2(grid, dims, coord_create(x, y, z))
                end
            end
        end
    end

    return sa
end

local ans = solve1()
assert(ans == 3498)

ans = solve2()
assert(ans == 2008)
