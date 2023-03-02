#!luajit

local function create_grid()
    local grid = {}
    local row = 1
    for line in io.lines("problems/problem_08.txt") do
        grid[row] = {}
        for col = 1, string.len(line) do
            local height = string.byte(string.sub(line, col, col + 1)) - string.byte("0") + 1
            grid[row][col] = height
        end
        row = row + 1
    end
    return grid
end

local function solve1(grid)
    local nrows = #grid
    local ncols = #grid[1]

    local cnt = 2 * nrows + 2 * (ncols - 2)

    for row = 2, nrows - 1 do
        for col = 2, ncols - 1 do
            local h = grid[row][col]

            local vis = true
            for orow = row - 1, 1, -1 do
                local oh = grid[orow][col]
                if (oh >= h) then
                    vis = false
                    break
                end
            end
            if (vis) then
                cnt = cnt + 1
                goto continue
            end

            vis = true
            for orow = row + 1, nrows do
                local oh = grid[orow][col]
                if (oh >= h) then
                    vis = false
                    break
                end
            end
            if (vis) then
                cnt = cnt + 1
                goto continue
            end

            vis = true
            for ocol = col - 1, 1, -1 do
                local oh = grid[row][ocol]
                if (oh >= h) then
                    vis = false
                    break
                end
            end
            if (vis) then
                cnt = cnt + 1
                goto continue
            end

            vis = true
            for ocol = col + 1, ncols do
                local oh = grid[row][ocol]
                if (oh >= h) then
                    vis = false
                    break
                end
            end
            if (vis) then
                cnt = cnt + 1
                goto continue
            end

            ::continue::
        end
    end

    return cnt
end

local function solve2(grid)
    local nrows = #grid
    local ncols = #grid[1]

    local max_score = 0

    for row = 2, nrows - 1 do
        for col = 2, ncols - 1 do
            local h = grid[row][col]
            local score = 1

            local ntrees = 0
            for orow = row - 1, 1, -1 do
                ntrees = ntrees + 1
                local oh = grid[orow][col]
                if (oh >= h) then
                    break
                end
            end
            score = score * ntrees

            ntrees = 0
            for orow = row + 1, nrows do
                ntrees = ntrees + 1
                local oh = grid[orow][col]
                if (oh >= h) then
                    break
                end
            end
            score = score * ntrees

            ntrees = 0
            for ocol = col - 1, 1, -1 do
                ntrees = ntrees + 1
                local oh = grid[row][ocol]
                if (oh >= h) then
                    break
                end
            end
            score = score * ntrees

            ntrees = 0
            for ocol = col + 1, ncols do
                ntrees = ntrees + 1
                local oh = grid[row][ocol]
                if (oh >= h) then
                    break
                end
            end
            score = score * ntrees

            max_score = math.max(max_score, score)

            ::continue::
        end
    end

    return max_score
end

local grid = create_grid()

local ans = solve1(grid)
assert(ans == 1825)

ans = solve2(grid)
assert(ans == 235200)
