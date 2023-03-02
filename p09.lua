#!luajit

local function create_coord(x, y)
    local coord = {
        x = x,
        y = y,
    }
    return coord
end

local function move_follower(leader, follower)
    local delta_x = leader.x - follower.x
    local delta_y = leader.y - follower.y

    if (math.abs(delta_x) <= 1 and math.abs(delta_y) <= 1) then
        return
    end

    if (delta_x ~= 0) then
        if (delta_x > 0) then
            delta_x = 1
        else
            delta_x = -1
        end
    end
    if (delta_y ~= 0) then
        if (delta_y > 0) then
            delta_y = 1
        else
            delta_y = -1
        end
    end

    follower.x = follower.x + delta_x
    follower.y = follower.y + delta_y
end

local function log_tail_pos(tail, tail_positions)
    for _, pos in ipairs(tail_positions) do
        if (pos.x == tail.x and pos.y == tail.y) then
            return
        end
    end
    table.insert(tail_positions, create_coord(tail.x, tail.y))
end

local function sim_rope(rope, tail_positions)
    for i = 1, #rope - 1 do
        move_follower(rope[i], rope[i + 1])
    end
    log_tail_pos(rope[#rope], tail_positions)
end

local function solve(nknots)
    local rope = {}
    for _ = 1, nknots do
        table.insert(rope, create_coord(0, 0))
    end
    local head = rope[1]
    local tail_positions = { create_coord(0, 0) }

    for line in io.lines("problems/problem_09.txt") do
        local dir = string.sub(line, string.find(line, "^[UDRL]"))
        local cnt = string.sub(line, string.find(line, "%d+$"))
        if (dir == "U") then
            for _ = 1, cnt do
                head.y = head.y + 1
                sim_rope(rope, tail_positions)
            end
        elseif (dir == "D") then
            for _ = 1, cnt do
                head.y = head.y - 1
                sim_rope(rope, tail_positions)
            end
        elseif (dir == "L") then
            for _ = 1, cnt do
                head.x = head.x - 1
                sim_rope(rope, tail_positions)
            end
        else
            for _ = 1, cnt do
                head.x = head.x + 1
                sim_rope(rope, tail_positions)
            end
        end
    end

    return #tail_positions
end

local ans = solve(2)
assert(ans == 6212)

ans = solve(10)
assert(ans == 2522)
