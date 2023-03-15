#!luajit

local function coord_create(x, y)
    local c = {
        x = x,
        y = y,
    }
    return c
end

local function range_create(strt, stop)
    local r = {
        strt = strt,
        stop = stop,
    }
    return r
end

local function range_merge(a, b)
    local strt_max = math.max(a.strt, b.strt)
    local stop_min = math.min(a.stop, b.stop)
    if strt_max <= stop_min + 1 then
        return range_create(math.min(a.strt, b.strt), math.max(a.stop, b.stop))
    end
    return nil
end

local function sbp_create(s, b, d)
    local sbp = {
        s = s,
        b = b,
        d = d,
    }
    return sbp
end

local function sbp_get_dist(sbp)
    if sbp.d == nil then
        sbp.d = math.abs(sbp.b.x - sbp.s.x) + math.abs(sbp.b.y - sbp.s.y)
    end
    return sbp.d
end

local function get_sbps()
    local sbps = {}

    for line in io.lines("problems/problem_15.txt") do
        local sx, sy, bx, by = string.match(line, "Sensor at x=([0-9-]+), y=([0-9-]+): closest beacon is at x=([0-9-]+), y=([0-9-]+)")
        local sbp = sbp_create(coord_create(sx, sy), coord_create(bx, by), nil)
        sbp_get_dist(sbp)
        table.insert(sbps, sbp)
    end

    return sbps
end

local function add_to_ranges(ranges, range)
    for i, er in ipairs(ranges) do
        local merged = range_merge(range, er)
        if merged ~= nil then
            table.remove(ranges, i)
            add_to_ranges(ranges, merged)
            return
        end
    end
    table.insert(ranges, range)
end

local function sum_ranges(ranges)
    local sum = 0
    for _, r in ipairs(ranges) do
        sum = sum + r.stop - r.strt
    end
    return sum
end

local function get_ranges(sbps, y)
    local ranges = {}
    for _, sbp in ipairs(sbps) do
        local d = sbp.d - math.abs(sbp.s.y - y)
        if d >= 0 then
            local xmin = sbp.s.x - d
            local xmax = sbp.s.x + d
            local r = range_create(xmin, xmax)
            add_to_ranges(ranges, r)
        end
    end
    return ranges
end

local function solve1(y)
    local sbps = get_sbps()
    local ranges = get_ranges(sbps, y)
    return sum_ranges(ranges)
end

local function solve2(xmax, ymax)
    local sbps = get_sbps()
    for y = ymax, 0, -1 do
        local ranges = get_ranges(sbps, y)
        if #ranges > 1 or ranges[1].strt > 0 or ranges[1].stop < xmax then
            for _, r in ipairs(ranges) do
                if r.strt > 0 then
                    return 4000000 * (r.strt - 1) + y
                else
                    return 4000000 * (r.stop + 1) + y
                end
            end
        end
    end
end

local ans = solve1(2000000)
assert(ans == 5335787)

ans = solve2(4000000, 4000000)
assert(ans == 13673971349056)
