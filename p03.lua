#!luajit

local function get_priority(ch)
    if string.byte(ch) > string.byte('Z') then
        return string.byte(ch) - string.byte('a') + 1
    end
    return string.byte(ch) - string.byte('A') + 27
end

local sum = 0
for line in io.lines("problems/problem_03.txt") do
    local slen = string.len(line) / 2
    local c1 = string.sub(line, 1, slen)
    local c2 = string.sub(line, -slen)
    local i = string.find(c1, "[" .. c2 .. "]")
    if i then
        sum = sum + get_priority(string.sub(c1, i, i + 1))
    end
end
assert(sum == 7990)

sum = 0
local idx = 1
local group = {}
for line in io.lines("problems/problem_03.txt") do
    group[idx] = line
    idx = idx + 1
    if idx == 4 then
        local s1 = group[1]
        local s2 = group[2]
        local s3 = group[3]
        for dup in string.gmatch(s1, "[" .. s2 .. "]") do
            if string.find(s3, dup) then
                sum = sum + get_priority(dup)
                break
            end
        end
        idx = 1
    end
end
assert(sum == 2602)
