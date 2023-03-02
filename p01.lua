#!luajit

local sum = 0
local arr = {}
local idx = 1

for line in io.lines("problems/problem_01.txt") do
    if line == "" then
        arr[idx] = sum
        idx = idx + 1
        sum = 0
    else
        sum = sum + line
    end
end

table.sort(arr)

assert(arr[#arr] == 67633)
assert(arr[#arr] + arr[#arr - 1] + arr[#arr - 2] == 199628)
