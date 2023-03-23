#!luajit

local function node_init()
    local node = {
        x = 0,
        prev = nil,
        next = nil,
        mprev = nil,
        mnext = nil,
    }
    return node
end

local function nodelist_init()
    local l = {
        head = nil,
        tail = nil,
        mhead = nil,
        mtail = nil,
    }
    return l
end

local function nodelist_print(l)
    local n = l.head
    local str = ""
    while n ~= l.tail do
        str = str .. " " .. n.x
        n = n.next
    end
    str = str .. " " .. n.x
    print(str)
    n = l.mhead
    str = ""
    while n ~= l.mtail do
        str = str .. " " .. n.x
        n = n.mnext
    end
    str = str .. " " .. n.x
    print(str)
end

local function do_mix(l, n, len)
    local x = n.x
    if x ~= 0 then
        local mprev = n.mprev
        local mnext = n.mnext
        mprev.mnext = mnext
        mnext.mprev = mprev
        if n == l.mhead then
            l.mhead = mnext
        elseif n == l.mtail then
            l.mtail = mprev
        end

        local ins = mprev
        local inc = math.abs(x) % (len - 1)

        for _ = 1, inc do
            if x > 0 then
                ins = ins.mnext
            else
                ins = ins.mprev
            end
        end

        mnext = ins.mnext
        mnext.mprev = n
        n.mnext = mnext
        ins.mnext = n
        n.mprev = ins

        if ins == l.mtail then
            l.mtail = n
        end
    end
end

local function nodelist_mix(l, len)
    local n = l.head
    while n ~= l.tail do
        do_mix(l, n, len)
        n = n.next
    end
    do_mix(l, n, len)
end

local function solve(decrypt_key, nmix)
    local l = nodelist_init()
    local prev = nil
    local first = nil
    local len = 0

    for line in io.lines("problems/problem_20.txt") do
    -- for line in io.lines("/home/danielforde/dev/deforde/advent-of-zig/problems/example_20.txt") do
        local x = tonumber(line) * decrypt_key
        local n = node_init()
        n.x = x
        n.prev = prev
        n.mprev = prev
        if prev ~= nil then
            prev.next = n
            prev.mnext = n
        else
            l.head = n
            l.mhead = n
        end
        l.tail = n
        l.mtail = n
        prev = n
        len = len + 1
        if first == nil then
            first = n
        end
    end

    prev.next = first
    prev.mnext = first
    first.prev = prev
    first.mprev = prev

    for _ = 1, nmix do
        nodelist_mix(l, len)
    end

    local n = l.mhead
    while n.x ~= 0 do
        n = n.mnext
    end
    n = n.mnext

    local sum = 0
    for i = 1, 3000 do
        if i % 1000 == 0 then
            sum = sum + n.x
        end
        n = n.mnext
    end

    return sum
end

local ans = solve(1, 1)
assert(ans == 6712)

ans = solve(811589153, 10)
assert(ans == 1595584274798)
