#!luajit

local p1lkup = {
    { 4, 8, 3 },
    { 1, 5, 9 },
    { 7, 2, 6 },
}

local p2lkup = {
    { 3, 4, 8 },
    { 1, 5, 9 },
    { 2, 6, 7 },
}

local p1sum = 0
local p2sum = 0

for line in io.lines("problems/problem_02.txt") do
    local p1 = string.byte(line, 1) - string.byte("A") + 1
    local p2 = string.byte(line, 3) - string.byte("X") + 1
    p1sum = p1sum + p1lkup[p1][p2]
    p2sum = p2sum + p2lkup[p1][p2]
end

assert(p1sum == 11475)
assert(p2sum == 16862)
